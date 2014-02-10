//
//  DataStore.h
//  RemindMe
//
//  Created by dasmer on 1/3/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reminder+Methods.h"
@import CoreData;

@interface DataStore : NSObject
+ (DataStore *) instance;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (BOOL) deleteReminder: (Reminder *) reminderToDelete;
- (BOOL) createNewReminderWithType: (NSInteger)type recipientName: (NSString *)recipientName recipient: (NSString *)recipient subject: (NSString *)subject message: (NSString *) message andFireDate: (NSDate *)fireDate;


@end
