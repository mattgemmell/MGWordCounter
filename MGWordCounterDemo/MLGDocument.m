//
//  MLGDocument.m
//  MGWordCounterDemo
//
//  Created by Matt Gemmell on 04/02/2013.
//  Copyright (c) 2013 Instinctive Code. All rights reserved.
//

#import "MLGDocument.h"

@implementation MLGDocument

{
    MGWordCounter *wordCounter;
}


#pragma mark - Setup


- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}


- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MLGDocument";
}


- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    // Configure word-counter.
    wordCounter = [MGWordCounter wordCounterForTextView:self.textview];
    wordCounter.delegate = self;
    wordCounter.counterUpdateBlock = ^(NSInteger count, BOOL selectionOnly){
        //NSLog(@"Word count updated: %ld words (for %@)", (long)count, ((selectionOnly) ? @"selection" : @"full text"));
    };
    self.textview.delegate = wordCounter;
    [wordCounter startCounting]; // Asynchronous; will return immediately and notify later.
}


#pragma mark - MGWordCounterDelegate


- (void)wordCounter:(MGWordCounter *)theWordCounter updatedCount:(NSInteger)count forSelection:(BOOL)selectionOnly;
{
    //NSLog(@"Word count updated: %ld words (for %@)", (long)count, ((selectionOnly) ? @"selection" : @"full text"));
    BOOL hasSelection = (self.textview.selectedRange.length > 0);
    NSInteger charCount = (hasSelection) ? self.textview.selectedRange.length : self.textview.string.length;
    NSInteger wordCount = (hasSelection) ? theWordCounter.selectionWordCount : theWordCounter.wordCount;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    /*
     This bit _looks_ nasty, but basically it just:
        1. Shows a word and character count like "2 words - 13 chars".
        2. Uses the singular or plural form of "word" or "char" where appropriate.
        3. When there's a selection, shows counts only for that selection, surrounded by parentheses.
     (In a real app, you should localise "words" and "chars", of course.)
     */
    self.wordCountLabel.stringValue = [NSString stringWithFormat:@"%@%@ word%@ - %@ char%@%@",
                                       ((hasSelection) ? @"(" : @""),
                                       [formatter stringFromNumber:[NSNumber numberWithInteger:wordCount]],
                                       ((wordCount != 1) ? @"s" : @""),
                                       [formatter stringFromNumber:[NSNumber numberWithInteger:charCount]],
                                       ((charCount != 1) ? @"s" : @""),
                                       ((hasSelection) ? @")" : @"")];
}


#pragma mark - File-handling (left as an exercise for the reader)


+ (BOOL)autosavesInPlace
{
    return NO;
}


- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    //NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    //@throw exception;
    return nil;
}


- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    //NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    //@throw exception;
    return YES;
}


@end
