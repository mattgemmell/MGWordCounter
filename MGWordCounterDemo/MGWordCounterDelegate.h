//
//  MGWordCounterDelegate.h
//
//  Created by Matt Gemmell on 29/01/2013.
//  Copyright (c) 2013 Instinctive Code. License: http://mattgemmell.com/license/
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

@class MGWordCounter;
@protocol MGWordCounterDelegate <NSObject>

@optional
- (void)wordCounter:(MGWordCounter *)wordCounter updatedCount:(NSInteger)count forSelection:(BOOL)selectionOnly;
// If selectionOnly is YES, the count is for the selection. If NO, the count is for the entire text.

@end
