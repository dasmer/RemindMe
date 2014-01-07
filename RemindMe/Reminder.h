//
//  Reminder.h
//  RemindMe
//
//  Created by dasmer on 1/5/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Reminder : NSManagedObject

@property (nonatomic, retain) NSDate * fireDate;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * recipient;
@property (nonatomic, retain) NSString * recipientName;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * subject;

@end
