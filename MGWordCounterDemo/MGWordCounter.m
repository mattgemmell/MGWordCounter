//
//  MGWordCounter.m
//
//  Created by Matt Gemmell on 29/01/2013.
//  Copyright (c) 2013 Instinctive Code. License: http://mattgemmell.com/license/
//

#import "MGWordCounter.h"
#import "MGWordCountOperation.h"

#define OPERATION_FINISHED_KEY @"isFinished" // For KVO.
#define MAX_WORD_LENGTH 100 // To hint the scanner during live counting. Bigger = more accurate, but slower. 100 is fine for English.

// Notifications.
NSString *MGWordCounterDidUpdateWordCountNotification = @"MGWordCounterDidUpdateWordCountNotification";


@implementation MGWordCounter

{
    NSOperationQueue *_operationQueue;
    NSRange _affectedRangeForEdit;
    NSRange _expandedRangeForEdit;
    NSString *_replacementStringForEdit;
    NSString *_affectedStringForEdit;
    NSInteger _deltaWordCount;
    BOOL _fullCountPending;
    NSRange _lastSelectedRange;
}

@synthesize delegate = _delegate;
@synthesize textView = _textView;
@synthesize wordCount = _wordCount;
@synthesize updating = _updating;

#if TARGET_OS_IPHONE
+ (id)wordCounterForTextView:(UITextView *)theTextView;
#else
+ (id)wordCounterForTextView:(NSTextView *)theTextView;
#endif
{
    return [[self alloc] initWithTextView:theTextView];
}

#if TARGET_OS_IPHONE
- (id)initWithTextView:(UITextView *)theTextView;
#else
- (id)initWithTextView:(NSTextView *)theTextView;
#endif
{
    if (!theTextView) {
        return nil;
    }
    
    if (self = [super init]) {
        _textView = theTextView;
        _fullCountPending = NO;
        _updating = NO;
        _wordCount = 0;
        _delegate = nil;
        _fullCountPending = NO;
        _enabled = YES;
        _lastSelectedRange = NSMakeRange(0, 0);
    }
    
    return self;
}


- (void)startCounting
{
    _enabled = YES;
    
    // Do an initial full count.
    [self updateCount];
}


- (void)stopCounting
{
    _enabled = NO;
    
    _deltaWordCount = 0;
    _operationQueue = nil;
}


- (void)updateCount
{
    if (_enabled) {
        MGWordCountOperation *countOperation = [[MGWordCountOperation alloc] init];
        countOperation.text = [self textViewString];
        countOperation.countType = MGWordCountFull;
        _operationQueue = [[NSOperationQueue alloc] init];
        [countOperation addObserver:self forKeyPath:OPERATION_FINISHED_KEY options:0 context:NULL];
        _fullCountPending = YES;
        _updating = YES;
        [_operationQueue addOperation:countOperation];
    }
}


- (NSString *)textViewString
{
    // Thanks, Apple, for making crap like this necessary. Thanks A LOT.
#if TARGET_OS_IPHONE
    return _textView.text;
#else
    return _textView.string;
#endif
}


#if TARGET_OS_IPHONE
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementText:(NSString *)replacementString
#else
- (BOOL)textView:(NSTextView *)aTextView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
#endif
{
    // This is called when the user has performed an edit, but before the edit is committed to the storage.
    if (!_enabled) {
        return YES;
    }
    
    //NSLog(@"Text changing in range: %@; replacement string: \"%@\"", NSStringFromRange(affectedCharRange), replacementString);
    
    // Note parameters for later use.
    _affectedRangeForEdit = affectedCharRange;
    _replacementStringForEdit = replacementString;
    
    // Note an expanded string around the affected range, in which we'll count words later.
    NSRange expandedRange = affectedCharRange;
    NSUInteger delta = 0;
    // Expand range's location backwards.
    expandedRange.location = MAX(0, (int)affectedCharRange.location - MAX_WORD_LENGTH);
    delta = affectedCharRange.location - expandedRange.location;
    expandedRange.length += delta; // adjust for the changed starting point.
    // Expand range's length forwards.
    delta = MIN([self textViewString].length - NSMaxRange(affectedCharRange), MAX_WORD_LENGTH);
    expandedRange.length += delta;
    _expandedRangeForEdit = expandedRange;
    _affectedStringForEdit = [[self textViewString] substringWithRange:_expandedRangeForEdit];
    //NSLog(@"affectedRange: %@, expandedRange: %@", NSStringFromRange(_affectedRangeForEdit), NSStringFromRange(_expandedRangeForEdit));
    
    return YES;
}


#if TARGET_OS_IPHONE
- (void)textViewDidChange:(UITextView *)aTextView
#else
- (void)textDidChange:(NSNotification *)aNotification
#endif
{
    // This is called after an edit has been committed to the storage.
    if (!_enabled) {
        return;
    }

#if TARGET_OS_IPHONE
    if (aTextView == _textView) {
#else
    if (aNotification.object == _textView) {
#endif
        //NSLog(@"Text changed.");
        
        // Initiate a partial word-count operation using the information we've gathered about the edit.
        MGWordCountOperation *countOperation = [[MGWordCountOperation alloc] init];
        countOperation.text = [self textViewString];
        countOperation.countType = MGWordCountReplacementString;
        countOperation.affectedStringForEdit = _affectedStringForEdit;
        countOperation.replacementString = [_replacementStringForEdit copy];
        countOperation.affectedRangeForEdit = _affectedRangeForEdit;
        countOperation.expandedRangeForEdit = _expandedRangeForEdit;
        [countOperation addObserver:self forKeyPath:OPERATION_FINISHED_KEY options:0 context:NULL];
        _updating = YES;
        [_operationQueue addOperation:countOperation];
    }
}


#if TARGET_OS_IPHONE
- (void)textViewDidChangeSelection:(UITextView *)aTextView
#else
- (NSRange)textView:(NSTextView *)aTextView willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange toCharacterRange:(NSRange)newSelectedCharRange
#endif
{
#if TARGET_OS_IPHONE
    NSRange newSelectedCharRange = _textView.selectedRange;
    if (_lastSelectedRange.length == 0 && newSelectedCharRange.length == 0) {
        // No need to recount.
        return;
    }
#else
    if (oldSelectedCharRange.length == 0 && newSelectedCharRange.length == 0) {
        // No need to recount.
        return newSelectedCharRange;
    }
#endif
    _lastSelectedRange = newSelectedCharRange;
    
    MGWordCountOperation *countOperation = [[MGWordCountOperation alloc] init];
    countOperation.text = [[self textViewString] substringWithRange:newSelectedCharRange];
    countOperation.countType = MGWordCountSelection;
    _operationQueue = [[NSOperationQueue alloc] init];
    [countOperation addObserver:self forKeyPath:OPERATION_FINISHED_KEY options:0 context:NULL];
    _updating = YES;
    [_operationQueue addOperation:countOperation];

#if TARGET_OS_IPHONE
#else
    return newSelectedCharRange;
#endif
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    // We're Key-Value Observing changes to the QUEUE_COUNT_KEY key-path of our operationQueue.
    // When the number of operations in the queue changes, this method is called.
    // Operation Queues remove completed operations, hence this means the operation finished.
    
    MGWordCountOperation *countOperation = (MGWordCountOperation *)object;
    if (object && [keyPath isEqualToString:OPERATION_FINISHED_KEY]) {
        if (countOperation.isFinished) {
            @synchronized(self) {
                //NSLog(@"Operation %@ has finished.", countOperation);
                if (!(countOperation.isCancelled)) {
                    if (countOperation.countType == MGWordCountFull || countOperation.countType == MGWordCountSelection) {
                        // Update our word count, noting any delta which should be applied.
                        BOOL selectionCount = (countOperation.countType == MGWordCountSelection);
                        if (!selectionCount) {
                            _wordCount = countOperation.wordCount;
                        } else  {
                            _selectionWordCount = countOperation.wordCount;
                        }
                        if (_deltaWordCount != 0 && !selectionCount) {
                            _wordCount += _deltaWordCount;
                            _deltaWordCount = 0;
                        }
                        
                        // Inform delegate that the full word-count is complete.
                        NSInteger relevantCount = (selectionCount) ? _selectionWordCount : _wordCount;
                        if (self.delegate && [self.delegate respondsToSelector:@selector(wordCounter:updatedCount:forSelection:)]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.delegate wordCounter:self
                                              updatedCount:relevantCount
                                              forSelection:selectionCount];
                            });
                        }
                        
                        // Send notification.
                        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithInteger:relevantCount], MGWordCountKey,
                                              [NSNumber numberWithBool:selectionCount], MGCountIsForSelection,
                                              nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:MGWordCounterDidUpdateWordCountNotification
                                                                            object:self 
                                                                          userInfo:info];
                        
                        if (!selectionCount) {
                            _fullCountPending = NO;
                        }
                        
                    } else if (countOperation.countType == MGWordCountReplacementString) {
                        if (_fullCountPending) {
                            // A full count is still ongoing; we'll just log our count-delta without informing the delegate.
                            _deltaWordCount = countOperation.wordCount;
                            
                        } else {
                            // Update our word count using operation's count as a delta, and inform delegate of the change.
                            _wordCount += countOperation.wordCount;
                            _deltaWordCount = 0;
                            
                            // Inform delegate.
                            if (self.delegate && [self.delegate respondsToSelector:@selector(wordCounter:updatedCount:forSelection:)]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.delegate wordCounter:self updatedCount:_wordCount forSelection:NO];
                                });
                            }
                            
                            // Send notification.
                            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInteger:_wordCount], MGWordCountKey,
                                                  [NSNumber numberWithBool:NO], MGCountIsForSelection,
                                                  nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:MGWordCounterDidUpdateWordCountNotification
                                                                                object:self
                                                                              userInfo:info];
                        }
                    }
                    
                } else {
                    // Cancelled.
                }
                
                _replacementStringForEdit = nil;
                _affectedStringForEdit = nil;
                _updating = NO;
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    }
}


@end
