//
//  Reminder+Methods.h
//  RemindMe
//
//  Created by dasmer on 1/4/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "Reminder.h"

@interface Reminder (Methods)
typedef enum {
    ReminderTypeUnknown,
    ReminderTypeMessage,
    ReminderTypeMail
} ReminderType;

extern const NSInteger kReminderTypeMessage;
extern const NSInteger kReminderObjectID;
extern NSString  *kReminderFireDateCheckNotification;

- (NSInteger) reminderType;
- (NSString *) reminderActionType;

@end
