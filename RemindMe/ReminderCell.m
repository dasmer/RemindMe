//
//  ReminderCell.m
//  RemindMe
//
//  Created by dasmer on 1/4/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "ReminderCell.h"
#import "UIImage+FontAwesome.h"

@interface ReminderCell ()
@property (weak, nonatomic) IBOutlet UIImageView *warningImageView;
@property (weak, nonatomic) IBOutlet UILabel *passedDueLabel;



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
    self.messageLabel.userInteractionEnabled = NO;
    if (!self.warningImageView.image){
        self.warningImageView.image = [UIImage warningIconSize:30 withColor:[UIColor redColor]];
    }
    
    [self checkIfFireDateIsPassed];
}

- (void) checkIfFireDateIsPassed{
    NSLog(@"chekcing if fire date passed");
    
    if ([self.myDate timeIntervalSinceNow] < 0){
//        self.backgroundColor = [UIColor redColor];
        [self.warningImageView setHidden:NO];
        [self.passedDueLabel setHidden:NO];
    }
    else{
//        self.backgroundColor = [UIColor whiteColor];
        [self.warningImageView setHidden:YES];
        [self.passedDueLabel setHidden:YES];
    }
}

- (void) dealloc
{
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
