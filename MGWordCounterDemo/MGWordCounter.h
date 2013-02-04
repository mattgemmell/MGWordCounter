//
//  MGWordCounter.h
//
//  Created by Matt Gemmell on 29/01/2013.
//  Copyright (c) 2013 Instinctive Code. License: http://mattgemmell.com/license/
//

#import <Foundation/Foundation.h>
#import "MGWordCounterDelegate.h"

#if TARGET_OS_IPHONE
@interface MGWordCounter : NSObject <UITextViewDelegate>
#else
@interface MGWordCounter : NSObject <NSTextViewDelegate>
#endif

/*
 NOTE: Instances of this class expect to be the delegate of a Text View
        (i.e. NSTextViewDelegate on OS X, or UITextViewDelegate on iOS),
        but MGWordCounter does NOT attempt to create this relationship itself.
 
        You should either set your MGWordCounter to be the delegate of the 
        relevant TextView, or alternatively you should forward the following
        (NS/UI)TextViewDelegate method calls from your actual TextView delegate:
        
        On Mac:
            - textView:shouldChangeTextInRange:replacementString:
            - textDidChange:
        
        On iOS:
            - textView:shouldChangeTextInRange:replacementText:
            - textViewDidChange:
 
        (As long as the expected information is provided to the above delegate 
        method, the only other method called on the TextView instance will be
        the -string method on OS X, or the -text method on iOS.)
 
        To support counting of the _selected_ text, you should also ensure that the
        MGWordCounter instance receives this (NS/UI)TextViewDelegate method:
        
        On Mac:
            - textView:willChangeSelectionFromCharacterRange:toCharacterRange:
                (The last parameter, unchanged, will be the return value.)
        
        On iOS:
            - textViewDidChangeSelection:
 */

#if TARGET_OS_IPHONE
+ (id)wordCounterForTextView:(UITextView *)theTextView;
- (id)initWithTextView:(UITextView *)theTextView; // Takes a text-view whose contents will be monitored.
#else
+ (id)wordCounterForTextView:(NSTextView *)theTextView;
- (id)initWithTextView:(NSTextView *)theTextView; // Takes a text-view whose contents will be monitored.
#endif

- (void)startCounting; // Enables word counting. Will immediately do a full recount.
- (void)stopCounting; // Disables word counting. Pending recounts (and notifications thereof) will be allowed to finish.
// Note: You must explicitly call -startCounting to begin counting.

- (void)updateCount; // Updates count immediately, via full recount. You shouldn't need to call this; updates happen automatically.

@property (nonatomic, weak) id <MGWordCounterDelegate> delegate; // Delegate for this object.
#if TARGET_OS_IPHONE
@property (nonatomic, strong) UITextView *textView; // This counter's associated text-view.
#else
@property (nonatomic, strong) NSTextView *textView; // This counter's associated text-view.
#endif

@property (nonatomic, readonly) NSInteger wordCount; // Current word count of full text.
@property (nonatomic, readonly) NSInteger selectionWordCount; // Current word count of selection.
@property (nonatomic, readonly, getter = isUpdating) BOOL updating; // Whether we're in the middle of a recount.
@property (nonatomic, readonly, getter = isEnabled) BOOL enabled; // Whether counting is enabled.

@end

// Notifications
// The notification `object' is the sending MGWordCounter.
// Notifications also have a userInfo dictionary with the following keys and values:
#define MGWordCountKey @"MGWordCount" //"MGWordCount" with an NSNumber (integer, zero-based) value.
#define MGCountIsForSelection @"MGCountIsForSelection" // "MGCountIsForSelection" with an NSNumber (BOOL) value.
// Note: if MGCountIsForSelection is YES, then MGWordCount is the selection's word-count. If NO, MGWordCount is for the full text.
extern NSString *MGWordCounterDidUpdateWordCountNotification; // word count was updated
