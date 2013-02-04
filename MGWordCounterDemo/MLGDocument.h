//
//  MLGDocument.h
//  MGWordCounterDemo
//
//  Created by Matt Gemmell on 04/02/2013.
//  Copyright (c) 2013 Instinctive Code. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MGWordCounter.h"

@interface MLGDocument : NSDocument <MGWordCounterDelegate>

@property (unsafe_unretained) IBOutlet NSTextView *textview;
@property (unsafe_unretained) IBOutlet NSTextField *wordCountLabel;

@end
