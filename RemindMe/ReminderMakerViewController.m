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


@interface ReminderMakerViewController ()

@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong,nonatomic) UITapGestureRecognizer *tap;


@property (weak, nonatomic) IBOutlet UIButton *addContactButton;
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
    self.managedObjectContext = [DataStore instance].managedObjectContext;
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dropKeyboard)];
    self.title = @"Compose";
//    [self.addContactButton setImage:[UIImage plusCircleIconSize:self.addContactButton.frame.size.width withColor:[UIColor twitterColor]] forState:UIControlStateNormal];
    self.datePicker.dateDelegate = self;
    [self.datePicker setMinimumDate:[NSDate date]];
    [self.datePicker setDate:[NSDate date] animated:NO];
    self.textArea.delegate = self;
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

            break;
        }
        case ReminderTypeMail:{
            [self.leftSideImageView setImage:[UIImage envelopeIconWithSize:leftSizeImageViewWidth withColor:[UIColor twitterColor]]];
            [self.customRecipientTextField setHidden:YES];
            [self.rightSideImageView setImage:[UIImage minusCircleIconSize:rightSizeImageViewWidth withColor:[UIColor redColor]]];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveReminder)];

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
        if([self createNewReminderWithType:self.currentMessageType recipientName:self.personLabel.text recipient:self.recipient message:self.textArea.text andFireDate:self.selectedDate]){
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
                if (property == kABPersonPhoneProperty){
                    self.currentMessageType = ReminderTypeMessage;
                }
                else if (property == kABPersonEmailProperty){
                    self.currentMessageType = ReminderTypeMail;
                }
                else{
                    self.currentMessageType = ReminderTypeUnknown;
                }
            }
    	}
        [peoplePicker dismissViewControllerAnimated:YES completion:^{
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            if (!self.selectedDate)
                [self.datePicker setDate:[NSDate date] animated:YES];
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


#pragma mark - Core Data
- (BOOL) createNewReminderWithType: (NSInteger) type recipientName: (NSString *) recipientName recipient: (NSString *) recipient message: (NSString *) message andFireDate: (NSDate *) fireDate{
    
    Reminder *newReminder = [NSEntityDescription insertNewObjectForEntityForName:@"Reminder" inManagedObjectContext:self.managedObjectContext];
    if (!newReminder){
        NSLog(@"failed to create new person");
        return NO;
    }
    newReminder.type = [NSNumber numberWithInteger:type];
    newReminder.recipientName = recipientName;
    newReminder.recipient = recipient;
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

#pragma mark - CommonClassFunctions
+  (BOOL) isContentInString: (NSString *) string{
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if ([[string stringByTrimmingCharactersInSet: set] length] == 0)
    {
        return NO;
    }
    else{
        return YES;
    }
}


+ (BOOL) isValidEmailFromString:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (NSString *) stringByExtractingPhoneNumberComponentsInString: (NSString *) string{
    NSArray *charactersToRemove = @[@" ",@"(",@")",@"-"];
    for (NSString *characterToRemove in charactersToRemove){
        string = [string stringByReplacingOccurrencesOfString:characterToRemove withString:@""];
    }
    return string;
}

+ (BOOL) isPhoneNumberInString:(NSString *) string{
    string = [[self class] stringByExtractingPhoneNumberComponentsInString:string];
    if ([string length] >= 7 && [string length] <= 15 && [[self class] isAllDigitsInString:string]){
        return YES;
    }
    else{
        return NO;
    }
}

+ (BOOL) isAllDigitsInString: (NSString *) string
{
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [string rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound;
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
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField{
    
    if (textField == self.customRecipientTextField){
        if ([[self class] isValidEmailFromString:textField.text]){
            self.personLabel.text = textField.text;
            self.currentMessageType = ReminderTypeMail;
            self.recipient = textField.text;
        }
        else if ([[self class] isPhoneNumberInString:textField.text]){
            ECPhoneNumberFormatter *formatter = [[ECPhoneNumberFormatter alloc] init];
            NSString *formattedNumber = [formatter stringForObjectValue:textField.text];
            self.personLabel.text = formattedNumber;
            self.currentMessageType = ReminderTypeMessage;
            self.recipient = textField.text;
        }
        else{
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Not a Valid Entry" description:@"Please type in a valid Phone Number or Date" type:TWMessageBarMessageTypeError];
            
        }
    }
    textField.text = @"";
    return YES;
}



@end
