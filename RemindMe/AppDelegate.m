//
//  AppDelegate.m
//  RemindMe
//
//  Created by dasmer on 1/3/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "AppDelegate.h"
#import "UIColor+Custom.h"
#import "NavigationController.h"
#import "Reminder+Methods.h"

@implementation AppDelegate




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];
    [[UINavigationBar appearance] setBarTintColor:[UIColor twitterColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Set icon badge number to zero
        if([self.window.rootViewController isKindOfClass:[NavigationController class]]){
            NavigationController *nc = (NavigationController *) self.window.rootViewController;
            [nc showReminderForReminderObjectIDURIString:[locationNotification.userInfo objectForKey:[[NSNumber numberWithInteger:kReminderObjectID] stringValue]]];
            //        }
        }
        
    }
    
    application.applicationIconBadgeNumber = 0;

    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kReminderFireDateCheckNotification
     object:self];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
//    if (state == UIApplicationStateActive)
//    {
        if([self.window.rootViewController isKindOfClass:[NavigationController class]]){
            NavigationController *nc = (NavigationController *) self.window.rootViewController;
            [nc showReminderForReminderObjectIDURIString:[notification.userInfo objectForKey:[[NSNumber numberWithInteger:kReminderObjectID] stringValue]]];
//        }
    }
//    else {
//        NSLog(@"recieved notification");
//        
//    }
    
    // Set icon badge number to zero
    
    
    
    if (state == UIApplicationStateActive){
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kReminderFireDateCheckNotification
     object:self];
    application.applicationIconBadgeNumber = 0;
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kReminderFireDateCheckNotification
     object:self];
    application.applicationIconBadgeNumber = 0;

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}




@end
