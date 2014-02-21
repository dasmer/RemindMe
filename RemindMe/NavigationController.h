//
//  NavigationController.h
//  RemindMe
//
//  Created by dasmer on 1/4/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataStore.h"
@import MessageUI;
@import iAd;

@interface NavigationController : UINavigationController <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate,ADBannerViewDelegate>

- (void)showReminderForMyReminder: (Reminder *) myReminder;
- (void) showReminderForReminderObjectIDURIString: (NSString *) uriString;
- (CGFloat) iAdHeight;
@end
