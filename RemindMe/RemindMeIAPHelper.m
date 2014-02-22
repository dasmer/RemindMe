//
//  RemindMeIAPHelper.m
//  RemindMe
//
//  Created by dasmer on 2/21/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "RemindMeIAPHelper.h"

NSString *const IAPEmailAdBlockProductIdentifier = @"edu.columbia.ds2644.emailadblock";

@implementation RemindMeIAPHelper

+ (RemindMeIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static RemindMeIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      IAPEmailAdBlockProductIdentifier,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}


- (void)enableEmailsAndDisableAdsForFree{
    [self provideContentForProductIdentifier:IAPEmailAdBlockProductIdentifier];
}

@end
