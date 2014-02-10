//
//  NSString+Methods.m
//  DSSPaymentForm
//
//  Created by dasmer on 1/23/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "NSString+Methods.h"

@implementation NSString (Methods)


- (BOOL) hasContent{
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if ([[self stringByTrimmingCharactersInSet: set] length] == 0)
    {
        return NO;
    }
    else{
        return YES;
    }
}

- (BOOL) isValidEmail{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (NSString *) stringByExtractingPhoneNumberComponents{
    NSString *tempString = [self copy];
    NSArray *charactersToRemove = @[@" ",@"(",@")",@"-"];
    for (NSString *characterToRemove in charactersToRemove){
        tempString = [tempString stringByReplacingOccurrencesOfString:characterToRemove withString:@""];
    }
    return tempString;
}

- (BOOL) isAllDigits{
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [self rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound;
}

- (BOOL) isPhoneNumber{
    NSString *tempString = [self copy];
    tempString = [tempString stringByExtractingPhoneNumberComponents];
    if ([tempString length] >= 7 && [tempString length] <= 15 && [tempString isAllDigits]){
        return YES;
    }
    else{
        return NO;
    }
}



@end
