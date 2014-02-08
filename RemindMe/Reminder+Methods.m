//
//  Reminder+Methods.m
//  RemindMe
//
//  Created by dasmer on 1/4/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "Reminder+Methods.h"

const NSInteger kReminderTypeMessage = 1;
const NSInteger kReminderObjectID = 7;
NSString  *kReminderFireDateCheckNotification = @"FireDateCheck";

@implementation Reminder (Methods)

- (NSInteger)reminderType{
    return [self.type integerValue];
}

- (NSString *)reminderActionType{
    if ([self reminderType] == ReminderTypeMessage){
        return @"Text";
    }
    else if ([self reminderType] == ReminderTypeMail){
        return @"Email";
    }
    else{
        return @"";
    }
}
@end
