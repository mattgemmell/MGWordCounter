//
//  MGWordCountOperation.h
//
//  Created by Matt Gemmell on 30/01/2013.
//  Copyright (c) 2013 Instinctive Code. License: http://mattgemmell.com/license/
//

#import <Foundation/Foundation.h>

typedef enum _MGWordCountOperationType {
    MGWordCountFull                 = 0, // the entire text of the NSTextStorage object
    MGWordCountReplacementString    = 1, // the replaced and replacement strings during an edit
    MGWordCountSelection            = 2  // the selected text
} MGWordCountOperationType;

@interface MGWordCountOperation : NSOperation

@property (nonatomic, strong) NSString *text;
@property (nonatomic, readonly) NSInteger wordCount;
@property (nonatomic, assign) MGWordCountOperationType countType;

// For use by non-full word counts, during edits.
@property (nonatomic, assign) NSRange affectedRangeForEdit;
@property (nonatomic, assign) NSRange expandedRangeForEdit;
@property (nonatomic, strong) NSString *replacementString; // string replacing text in affectedRangeForEdit.
@property (nonatomic, strong) NSString *affectedStringForEdit; // padded by (at most) MAX_WORD_LEN on either side of affectedRangeForEdit.

@end
