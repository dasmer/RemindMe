//
//  NavigationController.h
//  RemindMe
//
//  Created by dasmer on 1/4/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MessageUI;
#import "DataStore.h"

@interface NavigationController : UINavigationController <MFMessageComposeViewControllerDelegate,UIAlertViewDelegate>


- (void)showReminderForMyReminder: (Reminder *) myReminder;
- (void) showReminderForReminderObjectIDURIString: (NSString *) uriString;

@end
