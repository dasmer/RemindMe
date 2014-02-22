//
//  RemindMeIAPHelper.h
//  RemindMe
//
//  Created by dasmer on 2/21/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "IAPHelper.h"

extern NSString *const IAPEmailAdBlockProductIdentifier;

@interface RemindMeIAPHelper : IAPHelper

+ (RemindMeIAPHelper *)sharedInstance;

- (void) enableEmailsAndDisableAdsForFree;
@end
