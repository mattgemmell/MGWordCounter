//
//  MGWordCountOperation.m
//
//  Created by Matt Gemmell on 30/01/2013.
//  Copyright (c) 2013 Instinctive Code. License: http://mattgemmell.com/license/
//

#import "MGWordCountOperation.h"

@implementation MGWordCountOperation


- (void)main
{
    if (![self isCancelled]) {
        if (self.countType == MGWordCountFull || self.countType == MGWordCountSelection) {
            // This is a full word-count.
            __block NSUInteger theWordCount = 0;
            [self.text enumerateSubstringsInRange:NSMakeRange(0, self.text.length)
                                          options:NSStringEnumerationByWords
                                       usingBlock:^(NSString *character, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                           theWordCount++;
                                           if ([self isCancelled]) {
                                               *stop = YES;
                                           }
                                       }];
            _wordCount = theWordCount;
            
        } else if (self.countType == MGWordCountReplacementString) {
            // This is a two-stage partial word count, dealing with a replaced range of text.
            NSInteger deltaWords = 0;
            NSRange adjustedExpandedRange = self.expandedRangeForEdit;
            NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            NSScanner *scanner = [NSScanner localizedScannerWithString:self.affectedStringForEdit];
            BOOL scannedChars;
            
            //NSLog(@"Partial count. Starting conditions: affectedRange: %@, expandedRange: %@, affectedString:\r###\r%@\r###\rreplacement string:\r###\r%@\r###\r", NSStringFromRange(self.affectedRangeForEdit), NSStringFromRange(self.expandedRangeForEdit), self.affectedStringForEdit, self.replacementString);
            
            if (![self isCancelled]) {
                // First, we scan affectedStringForEdit to find the first word-boundary (if any) in the padding before the edit.
                [scanner setCharactersToBeSkipped:[whitespaceSet invertedSet]]; // skip everything except whitespace
                scannedChars = [scanner scanCharactersFromSet:whitespaceSet intoString:NULL];
                //NSLog(@"Expanded string:\r###\r%@\r###\r", self.affectedStringForEdit);
                if (scannedChars) {
                    // We've scanned some whitespace, and scanner's scanLocation is now just past it.
                    // We'll use the scanLocation as the new start of the affected range.
                    //NSLog(@"Scanned past some whitespace; now at %ld", (long)scanner.scanLocation);
                    //NSLog(@"adjustedExpandedRange was: %@", NSStringFromRange(adjustedExpandedRange));
                    if (adjustedExpandedRange.location + scanner.scanLocation <= self.affectedRangeForEdit.location) {
                        adjustedExpandedRange.location += scanner.scanLocation;
                        adjustedExpandedRange.length -= scanner.scanLocation;
                    } else {
                        //NSLog(@"Expanded range seems to be AFTER affected range; moving back. ***");
                    }
                    //NSLog(@"adjustedExpandedRange is now: %@", NSStringFromRange(adjustedExpandedRange));
                }
            }
            
            if (![self isCancelled]) {
                // Second, we scan from start of original affected range to find the first word-boundary after the edit.
                scanner.scanLocation = self.affectedStringForEdit.length - (NSMaxRange(self.expandedRangeForEdit) - NSMaxRange(self.affectedRangeForEdit));
                NSUInteger initialScanLocation = scanner.scanLocation;
                //NSLog(@"Beginning expansion-tail scan at location %ld", scanner.scanLocation);
                scannedChars = [scanner scanUpToCharactersFromSet:whitespaceSet intoString:NULL];
                if (scanner.scanLocation == initialScanLocation) {
                    // Skip initial whitespace.
                    //NSLog(@"Skipping initial found whitespace at %ld", initialScanLocation);
                    [scanner scanCharactersFromSet:whitespaceSet intoString:NULL];
                    scannedChars = [scanner scanUpToCharactersFromSet:whitespaceSet intoString:NULL];
                }
                if (!scannedChars) { // this is correct, despite seeming somewhat illogical.
                    // We've scanned up to some whitespace, and scanner's scanLocation is now just before it.
                    // We'll use the scanLocation as the new END of the affected range.
                    //NSLog(@"Before scan, adjustedExpandedRange is %@", NSStringFromRange(adjustedExpandedRange));
                    //NSLog(@"Scanned up to some whitespace; now at %ld in #%@#", (long)scanner.scanLocation, scanner.string);
                    //NSLog(@"After scan, affected string length: %ld, scanLocation %ld, calc: %ld", self.affectedStringForEdit.length, scanner.scanLocation, (long)MAX(0, (int)(adjustedExpandedRange.length - (self.affectedStringForEdit.length - scanner.scanLocation))));
                    if (scanner.scanLocation > initialScanLocation) {
                        adjustedExpandedRange.length = MAX(0, (int)(adjustedExpandedRange.length - (self.affectedStringForEdit.length - scanner.scanLocation)));
                    }
                    //NSLog(@"Final adjustedExpandedRange is %@", NSStringFromRange(adjustedExpandedRange));
                }
            }
            
            if (![self isCancelled]) {
                // Third, we count the number of words within this adjusted expanded range of the affected string.
                // We must obtain the relevant substring of the affected string first.
                // Note that adjustedExpandedRange is relative to the entire storage, not just the affected string,
                // so we must first convert it to the equivalent range of the affected string.
                NSRange wordBoundaryRange = adjustedExpandedRange;
                wordBoundaryRange.location = (adjustedExpandedRange.location - self.expandedRangeForEdit.location);
                // Proceed with word-count.
                __block NSUInteger theWordCount = 0;
                //NSLog(@"Checking words in range %@ of #%@#", NSStringFromRange(wordBoundaryRange), self.affectedStringForEdit);
                if (wordBoundaryRange.length > 0) {
                    [self.affectedStringForEdit enumerateSubstringsInRange:wordBoundaryRange
                                                                   options:NSStringEnumerationByWords
                                                                usingBlock:^(NSString *character, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                                    theWordCount++;
                                                                    if ([self isCancelled]) {
                                                                        *stop = YES;
                                                                    }
                                                                }];
                }
                // We then subtract this number of words from our running delta.
                //NSLog(@"Counted %ld words (to subtract) in #%@#", (long)theWordCount, [self.affectedStringForEdit substringWithRange:adjustedExpandedRange]);
                deltaWords -= theWordCount;
            }
            
            NSRange replacedAdjustedRange = adjustedExpandedRange;
            if (![self isCancelled]) {
                // Fourth, we calculate what the adjusted expanded range would correspond to in the post-edit storage.
                NSInteger replacementDelta = (self.replacementString.length - self.affectedRangeForEdit.length);
                //NSLog(@"Edit causes a length change of %ld (%ld - %ld; replacement #%@#)", replacementDelta, self.replacementString.length, self.affectedRangeForEdit.length, self.replacementString);
                //NSLog(@"replacedAdjustedRange was: %@", NSStringFromRange(replacedAdjustedRange));
                replacedAdjustedRange.length = MAX(0, (int)replacedAdjustedRange.length + replacementDelta);
                //NSLog(@"replacedAdjustedRange is now: %@", NSStringFromRange(replacedAdjustedRange));
            }
            
            if (![self isCancelled]) {
                // Fifth, we count the number of words in this replaced-expanded range (in the storage, which has been updated).
                __block NSUInteger theWordCount = 0;
                //NSLog(@"Checking words in replacement range %@ of (all text)", NSStringFromRange(replacedAdjustedRange));
                if (replacedAdjustedRange.length > 0) {
                    [self.text enumerateSubstringsInRange:replacedAdjustedRange
                                                  options:NSStringEnumerationByWords
                                               usingBlock:^(NSString *character, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                                   theWordCount++;
                                                   if ([self isCancelled]) {
                                                       *stop = YES;
                                                   }
                                               }];
                }
                // We add this number of words to our running delta.
                //NSLog(@"Counted %ld words (to add) in #%@#", (long)theWordCount, [self.text substringWithRange:replacedAdjustedRange]);
                deltaWords += theWordCount;
            }
            
            // Lastly, we set our running delta as the wordCount of this operation, and allow it to complete.
            //NSLog(@">> Net change in words: %ld <<", deltaWords);
            _wordCount = deltaWords;
        }
    }
    //NSLog(@"Operation finished %@", self);
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@)", [super description], [self descriptionOfCountType]];
}


- (NSString *)descriptionOfCountType
{
    NSString *desc = @"Full word count";
    if (self.countType == MGWordCountReplacementString) {
        desc = @"Partial word count";
    } else if (self.countType == MGWordCountSelection) {
        desc = @"Selection word count";
    }
    
    return desc;
}


@end
