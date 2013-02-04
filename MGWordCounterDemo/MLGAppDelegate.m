//
//  MLGAppDelegate.m
//  MGWordCounterDemo
//
//  Created by Matt Gemmell on 04/02/2013.
//  Copyright (c) 2013 Instinctive Code. All rights reserved.
//

#import "MLGAppDelegate.h"

@implementation MLGAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSDocumentController *sharedDocController = [NSDocumentController sharedDocumentController];
    NSUInteger documentCount = [sharedDocController documents].count;
    
    // Open an untitled document what if there is no document. (restored, opened).
    if (documentCount == 0) {
        [sharedDocController openUntitledDocumentAndDisplay:YES error:nil];
    }
}


@end
