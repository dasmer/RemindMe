//
//  ReminderMakerViewController.m
//  RemindMe
//
//  Created by dasmer on 1/3/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "ReminderMakerViewController.h"
#import "UIImage+FontAwesome.h"
#import "UIColor+Custom.h"
#import "TWMessageBarManager.h"
#import "DataStore.h"
#import "NavigationController.h"
#import "ECPhoneNumberFormatter.h"
#import "NSString+Methods.h"
#import "RemindMeIAPHelper.h"
#import "UIAlertView+Blocks.h"
#import "IAPTableViewController.h"

@interface ReminderMakerViewController ()
@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong,nonatomic) UITapGestureRecognizer *tap;
@property (weak, nonatomic) IBOutlet UIButton *addContactButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *subjectCell;
@property (weak, nonatomic) IBOutlet UITextField *subjectField;
@property (weak, nonatomic) IBOutlet UITextView *textArea;
@property (weak, nonatomic) IBOutlet PMEDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *personLabel;
@property (weak, nonatomic) IBOutlet UIButton *rightSideButton;
@property (weak, nonatomic) IBOutlet UIImageView *leftSideImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightSideImageView;
@property (weak, nonatomic) IBOutlet UITextField *customRecipientTextField;
@property (strong,nonatomic) NSDate *selectedDate;
@property (strong,nonatomic) NSString *recipient;
@property (assign,nonatomic) NSInteger currentMessageType;

@end

@implementation ReminderMakerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dropKeyboard)];
    self.title = @"Compose";
    self.datePicker.dateDelegate = self;
    [self.datePicker setMinimumDate:[NSDate date]];
    [self.datePicker setDate:[NSDate date] animated:NO];
    self.textArea.delegate = self;
    self.subjectField.delegate = self;
    [self.personLabel setTextColor:[UIColor twitterColor]];
    self.personLabel.text = @"";
    self.currentMessageType = ReminderTypeUnknown;
    [self constructRecipientCell];
}

- (void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    NavigationController *navController = (NavigationController *) self.navigationController;
    self.tableView.contentSize = CGSizeMake(self.tableView.frame.size.width, self.tableView.frame.size.height + [navController iAdHeight]);
}

- (void)setCurrentMessageType:(NSInteger)currentMessageType{
    _currentMessageType = currentMessageType;
    CGFloat leftSizeImageViewWidth = CGRectGetWidth(self.leftSideImageView.frame);
    CGFloat rightSizeImageViewWidth = CGRectGetWidth(self.rightSideImageView.frame);
    switch (_currentMessageType) {
        case ReminderTypeMessage:{
            [self.leftSideImageView setImage:[UIImage commentIconWithSize:leftSizeImageViewWidth withColor:[UIColor twitterColor]]];
            [self.customRecipientTextField setHidden:YES];
            [self.rightSideImageView setImage:[UIImage minusCircleIconSize:rightSizeImageViewWidth withColor:[UIColor redColor]]];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveReminder)];
            self.subjectField.text = nil;
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            if (!self.selectedDate)
                [self.datePicker setDate:[NSDate date] animated:YES];
            break;
        }
        case ReminderTypeMail:{
            if ([[RemindMeIAPHelper sharedInstance] productPurchased:IAPEmailAdBlockProductIdentifier]){
                [self.leftSideImageView setImage:[UIImage envelopeIconWithSize:leftSizeImageViewWidth withColor:[UIColor twitterColor]]];
                [self.customRecipientTextField setHidden:YES];
                [self.rightSideImageView setImage:[UIImage minusCircleIconSize:rightSizeImageViewWidth withColor:[UIColor redColor]]];
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveReminder)];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                if (!self.selectedDate)
                    [self.datePicker setDate:[NSDate date] animated:YES];
            }
            else{
                self.currentMessageType = ReminderTypeUnknown;
                self.recipient = nil;
                self.personLabel.text = @"";
                IAPTableViewController *iapVC = [[IAPTableViewController alloc] init];
                [self.navigationController pushViewController:iapVC animated:YES];
            }
            break;
        }
        case ReminderTypeUnknown:{
            [self.leftSideImageView setImage:[UIImage userIconWithSize:leftSizeImageViewWidth withColor:[UIColor twitterColor]]];
            [self.customRecipientTextField setHidden:NO];
            self.personLabel.text = @"";
            [self.rightSideImageView setImage:[UIImage plusCircleIconSize:rightSizeImageViewWidth withColor:[UIColor twitterColor]]];
            self.navigationItem.rightBarButtonItem = nil;
            break;
        }
        default:
            break;
    }
}

- (void) saveReminder{
    BOOL readyToSave = YES;
    if (!self.selectedDate){
        readyToSave = NO;
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Select a Date" description:nil type:TWMessageBarMessageTypeError];
    }
    
    else if ([self.selectedDate timeIntervalSinceNow] < 0){
        readyToSave = NO;
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Choose A Future Date" description:@"Cannot schedule messages for the past" type:TWMessageBarMessageTypeError];
    }
    
    else if (self.currentMessageType == ReminderTypeUnknown){
        readyToSave = NO;
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Reminder Type Unknown" description:@"Please specify an email address or phone number" type:TWMessageBarMessageTypeError];
    }
    else if (self.currentMessageType == ReminderTypeMail && ![MFMailComposeViewController canSendMail]){
        readyToSave = NO;
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Setup Device For Emails" description:@"This device is not currently set up to send emails. Please configure it to send emails before scheduling email reminders." type:TWMessageBarMessageTypeError];
    }
    else if (self.currentMessageType == ReminderTypeMessage && ![MFMessageComposeViewController canSendText]){
        readyToSave = NO;
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Setup Device For Texts" description:@"This device is not currently set up to send texts. Please configure it to send texts before scheduling text reminders." type:TWMessageBarMessageTypeError];
    }

    
    if (readyToSave){
        if ([[DataStore instance] createNewReminderWithType:self.currentMessageType recipientName:self.personLabel.text recipient:self.recipient subject:self.subjectField.text message:self.textArea.text andFireDate:self.selectedDate]){
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void) showContactList: (id) sender{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    [self presentViewController:peoplePicker animated:YES completion:^{
    }];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - People Picker Delegate Methods
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    if (property == kABPersonPhoneProperty || property == kABPersonEmailProperty){
        self.personLabel.text = [self getName:person];
        ABMultiValueRef multiAddressBookEntries = ABRecordCopyValue(person, property);
        for(CFIndex i = 0; i < ABMultiValueGetCount(multiAddressBookEntries); i++) {
    		if(identifier == ABMultiValueGetIdentifierAtIndex (multiAddressBookEntries, i)) {
    			CFStringRef addressBookRef = ABMultiValueCopyValueAtIndex(multiAddressBookEntries, i);
    			CFRelease(multiAddressBookEntries);
    			NSString *recipient = (__bridge NSString *) addressBookRef;
    			CFRelease(addressBookRef);
    			self.recipient = [NSString stringWithFormat:@"%@", recipient];
            }
    	}
        [peoplePicker dismissViewControllerAnimated:YES completion:^{
            if (property == kABPersonPhoneProperty){
                self.currentMessageType = ReminderTypeMessage;
            }
            else if (property == kABPersonEmailProperty){
                self.currentMessageType = ReminderTypeMail;
            }
            else{
                self.currentMessageType = ReminderTypeUnknown;
            }
        }];
    }
    else{
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Not a Supported Format" description:@"Please choose a Phone Number or Email Address" type:TWMessageBarMessageTypeError];
    }
    return NO;
    
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *) getName: (ABRecordRef) person
{
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString *biz = (__bridge NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
    if ((!firstName) && !(lastName))
    {
        if (biz) return biz;
        return @"[No name supplied]";
    }
    if (!lastName) lastName = @"";
    if (!firstName) firstName = @"";
    return [NSString stringWithFormat:@"%@ %@", firstName, lastName];
}

#pragma mark - PMEDatePicker Delegate Methods
- (void)datePicker:(PMEDatePicker *)datePicker didSelectDate:(NSDate *)date{
    self.selectedDate = date;
}

#pragma mark - UITextViewDelegate Methods


- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"did begin ediing");
    [self.view addGestureRecognizer:self.tap];
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}

- (void) dropKeyboard{
    NSLog(@"drop keyboard called");
    [self.textArea resignFirstResponder];
    [self.view removeGestureRecognizer:self.tap];
}

#pragma mark - Choose Recipient Methods

- (void) constructRecipientCell{
    self.rightSideButton.layer.cornerRadius = CGRectGetWidth(self.rightSideButton.frame)/2;
    self.rightSideButton.clipsToBounds = YES;
    [self.rightSideImageView setImage:[UIImage  plusCircleIconSize:CGRectGetWidth(self.rightSideButton.frame) withColor:[UIColor twitterColor]]];
    self.customRecipientTextField.delegate = self;
    [self.rightSideButton addTarget:self action:@selector(rightSideButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}


- (void) rightSideButtonClicked{
    
    if (self.currentMessageType == ReminderTypeUnknown){
        if ([self.customRecipientTextField isFirstResponder]){
            [self.customRecipientTextField resignFirstResponder];
        }
        else{
            [self showContactList:self.rightSideButton];
        }
    }
    else{
        self.currentMessageType = ReminderTypeUnknown;
    }
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (textField == self.customRecipientTextField){
    [self.rightSideImageView setImage:[UIImage checkOSquareIconWithSize:CGRectGetWidth(self.rightSideImageView.frame) withColor:[UIColor twitterColor]]];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField{
    
    if (textField == self.customRecipientTextField){
        NSLog(@"textFieldShouldEndEditing called");
        if ([textField.text isValidEmail]){
                self.personLabel.text = textField.text;
                self.recipient = textField.text;
                self.currentMessageType = ReminderTypeMail;
        }
        else if ([textField.text isPhoneNumber]){
            ECPhoneNumberFormatter *formatter = [[ECPhoneNumberFormatter alloc] init];
            NSString *formattedNumber = [formatter stringForObjectValue:textField.text];
            self.personLabel.text = formattedNumber;
            self.currentMessageType = ReminderTypeMessage;
            self.recipient = [textField.text stringByExtractingPhoneNumberComponents];
        }
        else{
            self.currentMessageType = ReminderTypeUnknown;
            if (self.navigationController.topViewController == self){
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Not a Valid Entry" description:@"Retry or tap + to use address book." type:TWMessageBarMessageTypeInfo];
            }
        }
        textField.text = @"";

    }
    return YES;
}

@end
