//
//  DataStore.m
//  RemindMe
//
//  Created by dasmer on 1/3/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "DataStore.h"

@implementation DataStore

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (DataStore *) instance {
    static DataStore *sharedDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataStore = [[self alloc] init];
    });
    return sharedDataStore;
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Custom Functions

- (BOOL) deleteReminder:(Reminder *)reminderToDelete{
    NSString *objectID = [[[reminderToDelete objectID] URIRepresentation] absoluteString];
    
    UILocalNotification *notificationToStop;
    for (UILocalNotification *notif in [[UIApplication sharedApplication] scheduledLocalNotifications]){
        if ([[notif.userInfo objectForKey:[[NSNumber numberWithInteger:kReminderObjectID] stringValue]] isEqual:objectID]){
            notificationToStop = notif;
            NSLog(@"deleting notification");
            break;
        }
    }
    if (notificationToStop)
        [[UIApplication sharedApplication] cancelLocalNotification:notificationToStop];
    
    
    if (reminderToDelete){
    [self.managedObjectContext deleteObject:reminderToDelete];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
        abort();
    }
    else{
        return YES;
    }
    }
    else{
        return YES;
    }
}

#pragma mark - creating reminders

- (BOOL) createNewReminderWithType: (NSInteger)type recipientName: (NSString *)recipientName recipient: (NSString *)recipient subject: (NSString *)subject message: (NSString *) message andFireDate: (NSDate *)fireDate{
    
    Reminder *newReminder = [NSEntityDescription insertNewObjectForEntityForName:@"Reminder" inManagedObjectContext:self.managedObjectContext];
    if (!newReminder){
        NSLog(@"failed to create new person");
        return NO;
    }
    newReminder.type = [NSNumber numberWithInteger:type];
    newReminder.recipientName = recipientName;
    newReminder.recipient = recipient;
    newReminder.subject = subject;
    newReminder.message = message;
    newReminder.fireDate = fireDate;
    NSString *notificationAction = [newReminder reminderActionType];
    
    NSError *savingError = nil;
    
    if([self.managedObjectContext save:&savingError]){
        if (![[newReminder objectID] isTemporaryID]){
            NSLog(@"objectID is %@",[newReminder objectID]);
            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = fireDate;
            localNotification.alertAction = @"Show me the item";
            localNotification.alertBody =   [NSString stringWithFormat:@"%@ %@", notificationAction, recipientName];
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
            NSDictionary *infoDictionary = [NSDictionary dictionaryWithObject:[[[newReminder objectID] URIRepresentation] absoluteString]  forKey:[[NSNumber numberWithInteger:kReminderObjectID] stringValue]];
            localNotification.userInfo = infoDictionary;
            localNotification.soundName = @"text_notification.mp3";
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
        NSLog(@"Saved reminder for type %ld recipientName %@ recipient %@ message %@ and fireDate %@", (long)type, recipientName,recipient,message,fireDate);
        
        return YES;
    }
    else{
        NSLog(@"failed to save person with error: %@", savingError);
        return NO;
    }
}

@end
