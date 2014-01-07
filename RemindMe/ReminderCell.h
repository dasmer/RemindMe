//
//  ReminderCell.h
//  RemindMe
//
//  Created by dasmer on 1/4/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReminderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *recipientLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageLabel;

@property (strong,nonatomic) NSDate *myDate;

- (void) checkIfFireDateIsPassed;

@end
