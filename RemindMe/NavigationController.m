//
//  NavigationController.m
//  RemindMe
//
//  Created by   on 1/4/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "NavigationController.h"
#import "TWMessageBarManager.h"
#import "UIColor+Custom.h"
#import "RemindMeIAPHelper.h"

const NSInteger NumberOfAppOpensBeforeAds = 2;
const NSString *kNumberOfAppOpens = @"NumberOfAppOpens";

@interface NavigationController ()
@property (strong,nonatomic) ADBannerView *iAd;
@property (strong,nonatomic) Reminder *currentReminder;
@end

@implementation NavigationController


- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iapHelperProductWasPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)showReminderForReminderObjectIDURIString:(NSString *)uriString{
    NSURL *uri = [NSURL URLWithString:uriString];
    NSManagedObjectID *moID = [[DataStore instance].persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
    NSManagedObject *myMO = [[DataStore instance].managedObjectContext objectWithID:moID];
    
    if ([myMO isKindOfClass:[Reminder class]]){
        NSLog(@"found reminder");
        Reminder *myReminder = (Reminder *) myMO;
        [self showReminderForMyReminder:myReminder];
    }
    
}

- (void)showReminderForMyReminder: (Reminder *) myReminder{
    self.currentReminder = myReminder;
    NSInteger reminderType = [myReminder.type integerValue];
    if (reminderType == ReminderTypeMessage){
        if ([MFMessageComposeViewController canSendText])
        {
            MFMessageComposeViewController *mvc = [[MFMessageComposeViewController alloc] init];
            [mvc.navigationBar setTintColor:[UIColor whiteColor]];
            mvc.messageComposeDelegate = self;
            [mvc setBody:myReminder.message];
            [mvc setRecipients:@[myReminder.recipient]];
            [self presentViewController:mvc animated:YES completion:nil];
            
            
        }
        else{
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Cannot Sent Texts" description:@"Your device is not setup to send texts" type:TWMessageBarMessageTypeError];
        }

    }
    else if (reminderType == ReminderTypeMail){
        if ([MFMailComposeViewController canSendMail]){
            MFMailComposeViewController *mvc = [[MFMailComposeViewController alloc] init];
            [mvc.navigationBar setTintColor:[UIColor whiteColor]];
            [mvc setMessageBody:myReminder.message isHTML:NO];
            [mvc setSubject:myReminder.subject];
            [mvc setToRecipients:@[myReminder.recipient]];
            mvc.mailComposeDelegate = self;
            [self presentViewController:mvc animated:YES completion:nil];
        }
        else{
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Cannot Sent Emails" description:@"Your device is not setup to send emails" type:TWMessageBarMessageTypeError];
        }
    }
}

#pragma mark - MFMessageCompose Delegate Methods

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    NSString *eventLabel;
    NSTimeInterval secondsSince = [[NSDate date] timeIntervalSinceDate:self.currentReminder.fireDate];
    if (result == MessageComposeResultSent){
        [controller dismissViewControllerAnimated:YES completion:^{
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Message Sent" description:[NSString stringWithFormat:@"to %@", self.currentReminder.recipientName] type:TWMessageBarMessageTypeSuccess];
            [[DataStore instance] deleteReminder:self.currentReminder];
            self.currentReminder = nil;
        }];
        eventLabel = @"MessageComposeResultSent";
    }
    else if (result == MessageComposeResultCancelled){
        [[[UIAlertView alloc] initWithTitle:@"Delete Message?" message:@"This cannot be undone." delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil] show];
        [controller dismissViewControllerAnimated:YES completion:nil];
        eventLabel = @"MessageComposeResultCancelled";
    }
    else{
        [controller dismissViewControllerAnimated:YES completion:nil];
        eventLabel = @"MessageComposeResultUnknown";

    }
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"messsagevc_finished" label:eventLabel value:@(secondsSince)] build]];
}

#pragma mark - MFMailCompose Delegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    NSString *eventLabel;
    NSTimeInterval secondsSince = [[NSDate date] timeIntervalSinceDate:self.currentReminder.fireDate];
    if (result == MFMailComposeResultSent){
        [controller dismissViewControllerAnimated:YES completion:^{
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Email Sent" description:[NSString stringWithFormat:@"to %@", self.currentReminder.recipientName] type:TWMessageBarMessageTypeSuccess];
            [[DataStore instance] deleteReminder:self.currentReminder];
            self.currentReminder = nil;
        }];
        eventLabel = @"MailComposeResultSent";
    }
    else if (result == MFMailComposeResultCancelled){
        [[[UIAlertView alloc] initWithTitle:@"Delete Email?" message:@"This cannot be undone." delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil] show];
        [controller dismissViewControllerAnimated:YES completion:nil];
        eventLabel = @"MailComposeResultCanceled";
        
    }
    else{
        [controller dismissViewControllerAnimated:YES completion:nil];
        eventLabel = @"MailComposeResultUnknown";

    }
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"mailvc_finished" label:eventLabel value:@(secondsSince)] build]];
}


#pragma mark - UIAlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        [[DataStore instance] deleteReminder:self.currentReminder];
    }
    self.currentReminder = nil;
}

#pragma mark - iAd Methods

- (void) constructAd{
    NSLog(@"construct iAd called");
    self.iAd = [[ADBannerView alloc] init];
    self.iAd.hidden = YES;
    self.iAd.delegate = self;
    [self.iAd setBackgroundColor:[UIColor whiteColor]];
    CGRect iAdFrame = self.iAd.frame;
    CGFloat newOriginY = self.view.frame.size.height - iAdFrame.size.height;
    self.iAd.frame = CGRectMake(iAdFrame.origin.x, newOriginY, iAdFrame.size.width, iAdFrame.size.height);
    [self.view addSubview:self.iAd];
}

- (CGFloat) iAdHeight{
    return CGRectGetHeight(self.iAd.frame);
}

#pragma mark - AdBannerView Delegate Methods

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    banner.hidden = YES;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner{
    banner.hidden = NO;
}

#pragma mark - App Notification Methods

- (void)applicationDidBecomeActive:(NSNotification*)note {
    NSInteger numberOfAppOpens = [[NSUserDefaults standardUserDefaults] integerForKey:[kNumberOfAppOpens copy]];
    numberOfAppOpens ++;
    [[NSUserDefaults standardUserDefaults] setObject:@(numberOfAppOpens) forKey:[kNumberOfAppOpens copy]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"applicationDidBecomeActive and app has been opened %ld times",(long)numberOfAppOpens);
    BOOL userBoughtIAPAdBlock = [[RemindMeIAPHelper sharedInstance] productPurchased:IAPEmailAdBlockProductIdentifier];
    if (numberOfAppOpens > NumberOfAppOpensBeforeAds && !self.iAd && !userBoughtIAPAdBlock){
    [self constructAd];
    }
}

- (void) iapHelperProductWasPurchased:(NSNotification*)note {
    NSLog(@"iapHelperProductWasPurchased called");
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"ns_notification" action:@"product_purchased" label:note.object value:nil] build]];
    if ([((NSString *) note.object) isEqualToString:IAPEmailAdBlockProductIdentifier]){
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Thanks for your support" description:@"Enabled Emails and Disabled iAds" type:TWMessageBarMessageTypeSuccess];
        NSLog(@"iapHelperProductWasPurchased called and ads were told to be hidden");
        if (self.iAd){
            self.iAd.hidden = YES;
            [self.iAd removeFromSuperview];
            self.iAd = nil;
        }
    }
}

@end
