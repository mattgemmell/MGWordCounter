//
//  MLGViewController.h
//  MGWordCounterDemoMobile
//
//  Created by Matt Gemmell on 04/02/2013.
//  Copyright (c) 2013 Instinctive Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGWordCounter.h"

@interface MLGViewController : UIViewController <MGWordCounterDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *wordCountLabel;

@end
