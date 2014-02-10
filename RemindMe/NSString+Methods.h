//
//  NSString+Methods.h
//  DSSPaymentForm
//
//  Created by dasmer on 1/23/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Methods)

- (BOOL) hasContent;
- (BOOL) isValidEmail;
- (NSString *) stringByExtractingPhoneNumberComponents;
- (BOOL) isAllDigits;
- (BOOL) isPhoneNumber;
@end
