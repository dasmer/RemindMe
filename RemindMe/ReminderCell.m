//
//  ReminderCell.m
//  RemindMe
//
//  Created by dasmer on 1/4/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "ReminderCell.h"
#import "UIImage+FontAwesome.h"
#import "ECPhoneNumberFormatter.h"
#import "UIColor+Custom.h"
#import "NSDate-Utilities.h"



@interface ReminderCell ()
@property (weak, nonatomic) IBOutlet UIImageView *warningImageView;
@property (weak, nonatomic) IBOutlet UILabel *passedDueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *reminderTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *recipientLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (strong,nonatomic) NSDate *myDate;
- (void) checkIfFireDateIsPassed;


@end



@implementation ReminderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self fillInLabelsAndImages];
    self.messageLabel.userInteractionEnabled = NO;
    if (!self.warningImageView.image){
        self.warningImageView.image = [UIImage warningIconSize:30 withColor:[UIColor redColor]];
    }
    
    [self checkIfFireDateIsPassed];
}

- (void) checkIfFireDateIsPassed{
    if ([self.myDate timeIntervalSinceNow] < 0){
        [self.warningImageView setHidden:NO];
        [self.passedDueLabel setHidden:NO];
    }
    else{
        [self.warningImageView setHidden:YES];
        [self.passedDueLabel setHidden:YES];
    }
}
- (void) fillInLabelsAndImages{
    self.messageLabel.text = self.reminder.message;
    
    UIColor *reminderTypeImageViewColor = [UIColor twitterColor];
    CGFloat reminderTypeImageViewWidth = CGRectGetWidth(self.reminderTypeImageView.frame);
    NSString *recipient;
    if ([self.reminder reminderType] == ReminderTypeMessage){
        ECPhoneNumberFormatter *formatter = [[ECPhoneNumberFormatter alloc] init];
        NSString *formattedNumber = [formatter stringForObjectValue:self.reminder.recipient];
        recipient = formattedNumber;
        self.reminderTypeImageView.image = [UIImage commentIconWithSize:reminderTypeImageViewWidth withColor:reminderTypeImageViewColor];
    }
    else if ([self.reminder reminderType] == ReminderTypeMail){
        recipient = self.reminder.recipient;
        self.reminderTypeImageView.image = [UIImage envelopeIconWithSize:reminderTypeImageViewWidth withColor:reminderTypeImageViewColor];
    }
    
    if (![self.reminder.recipient isEqualToString:self.reminder.recipientName]){
        self.recipientLabel.text = recipient;
        self.nameLabel.text = self.reminder.recipientName;
    }
    else{
        self.nameLabel.text = recipient;
    }
    
    NSDate *fireDate = self.reminder.fireDate;
    self.myDate = fireDate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd yyyy"];
    self.dateLabel.text = [dateFormatter stringFromDate:fireDate];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hh:mma"];
    self.timeLabel.text = [timeFormatter stringFromDate:fireDate];
    
    if ([fireDate isTomorrow]){
        self.dayLabel.text = @"Tomorrow";
    }
    else if ([fireDate isToday]){
        self.dayLabel.text = @"Today";
        
    }
    else if ([fireDate isYesterday]){
        self.dayLabel.text = @"Yesterday";
    }
    else{
        NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
        [dayFormatter setDateFormat:@"EEEE"];
        self.dayLabel.text = [dayFormatter stringFromDate:fireDate];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkIfFireDateIsPassed) name:kReminderFireDateCheckNotification object:nil];
}



- (void) dealloc
{
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
