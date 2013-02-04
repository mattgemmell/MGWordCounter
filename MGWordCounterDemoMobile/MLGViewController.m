//
//  MLGViewController.m
//  MGWordCounterDemoMobile
//
//  Created by Matt Gemmell on 04/02/2013.
//  Copyright (c) 2013 Instinctive Code. All rights reserved.
//

#import "MLGViewController.h"

@interface MLGViewController ()

{
    MGWordCounter *wordCounter;
}

@end

@implementation MLGViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Configure word-counter.
    wordCounter = [MGWordCounter wordCounterForTextView:self.textView];
    wordCounter.counterUpdateBlock = ^(NSInteger count, BOOL selectionOnly){
        //NSLog(@"Word count updated: %ld words (for %@)", (long)count, ((selectionOnly) ? @"selection" : @"full text"));
    };
    wordCounter.delegate = self;
    self.textView.delegate = wordCounter;
    [wordCounter startCounting]; // Asynchronous; will return immediately and notify later.
}


- (void)viewDidAppear:(BOOL)animated
{
    [self.textView becomeFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)wordCounter:(MGWordCounter *)theWordCounter updatedCount:(NSInteger)count forSelection:(BOOL)selectionOnly;
{
    //NSLog(@"Word count updated: %ld words (for %@)", (long)count, ((selectionOnly) ? @"selection" : @"full text"));
    BOOL hasSelection = (self.textView.selectedRange.length > 0);
    NSInteger charCount = (hasSelection) ? self.textView.selectedRange.length : self.textView.text.length;
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
    self.wordCountLabel.text = [NSString stringWithFormat:@"%@%@ word%@ - %@ char%@%@",
                                ((hasSelection) ? @"(" : @""),
                                [formatter stringFromNumber:[NSNumber numberWithInteger:wordCount]],
                                ((wordCount != 1) ? @"s" : @""),
                                [formatter stringFromNumber:[NSNumber numberWithInteger:charCount]],
                                ((charCount != 1) ? @"s" : @""),
                                ((hasSelection) ? @")" : @"")];
}


@end
