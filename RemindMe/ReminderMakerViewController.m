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

@interface ReminderMakerViewController ()
@property (weak, nonatomic) IBOutlet UIView *recipientView;

@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong,nonatomic) UITapGestureRecognizer *tap;

@property (weak, nonatomic) IBOutlet UIButton *addContactButton;
@property (weak, nonatomic) IBOutlet UITextView *textArea;
@property (weak, nonatomic) IBOutlet PMEDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *personLabel;
@property (strong,nonatomic) NSDate *selectedDate;
@property (strong,nonatomic) NSString *recipient;

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

    
    [self.addContactButton setImage:[UIImage plusCircleIconSize:self.addContactButton.frame.size.width withColor:[UIColor twitterColor]] forState:UIControlStateNormal];
    [self.addContactButton addTarget:self action:@selector(showContactList:) forControlEvents:UIControlEventTouchUpInside];
    
    self.datePicker.dateDelegate = self;
    [self.datePicker setMinimumDate:[NSDate date]];
    [self.datePicker setDate:[NSDate date] animated:NO];
    self.textArea.delegate = self;
    [self.personLabel setTextColor:[UIColor twitterColor]];
    self.personLabel.text = @"";
    
//    self.datePicker.userInteractionEnabled = NO;
//    self.datePicker.alpha = .6;
//    self.datePicker.tintColor = [UIColor twitterColor];
    
//    self.textArea.layer.borderColor = [[UIColor twitterColor] CGColor];
//    self.textArea.layer.borderWidth = 3;
//    self.textArea.clipsToBounds = YES;
    UITapGestureRecognizer *tapRecipient = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showContactList:)];
    [self.recipientView addGestureRecognizer:tapRecipient];
    
}

- (void) saveReminder{
    BOOL readyToSave = YES;
    if (!self.selectedDate){
        readyToSave = NO;
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Select a Date" description:nil type:TWMessageBarMessageTypeError];
    }
    
    if ([self.selectedDate timeIntervalSinceNow] < 0){
        readyToSave = NO;
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Choose A Future Date" description:@"Cannot schedule messages for the past" type:TWMessageBarMessageTypeError];
    }
    
    if (readyToSave){
        if([self createNewReminderWithType:kReminderTypeMessage recipientName:self.personLabel.text recipient:self.recipient message:self.textArea.text andFireDate:self.selectedDate]){
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
    NSLog(@"%@",[self getName:person]);
    NSLog(@"propertyID %d", property);
    NSLog(@"identifier %d", identifier);
    
    NSLog(@"kABPersonEmailProperty = %d",kABPersonPhoneProperty  );

    if (property == kABPersonPhoneProperty){
        self.personLabel.text = [self getName:person];
        ABMultiValueRef multiPhones = ABRecordCopyValue(person, property);
        for(CFIndex i = 0; i < ABMultiValueGetCount(multiPhones); i++) {
    		if(identifier == ABMultiValueGetIdentifierAtIndex (multiPhones, i)) {
    			CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
    			CFRelease(multiPhones);
    			NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
    			CFRelease(phoneNumberRef);
    			self.recipient = [NSString stringWithFormat:@"%@", phoneNumber];
                
                

//                self.datePicker.userInteractionEnabled = YES;
//                self.datePicker.alpha = 1.0;
                
    		}
    	}
        

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveReminder)];
        [peoplePicker dismissViewControllerAnimated:YES completion:^{
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        if (!self.selectedDate)
        [self.datePicker setDate:[NSDate date] animated:YES];

            
        }];
    }
    else{
        //            [[[UIAlertView alloc] initWithTitle:@"Not an Accepted Method" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Phone Numbers Supported Only" description:@"Choose a Phone Number" type:TWMessageBarMessageTypeError];
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
    
    NSError *savingError = nil;
    
    if([self.managedObjectContext save:&savingError]){
        if (![[newReminder objectID] isTemporaryID]){
            NSLog(@"objectID is %@",[newReminder objectID]);
            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = fireDate;
            localNotification.alertAction = @"Show me the item";
            localNotification.alertBody = [NSString stringWithFormat:@"Text %@", recipientName];
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
            NSDictionary *infoDictionary = [NSDictionary dictionaryWithObject:[[[newReminder objectID] URIRepresentation] absoluteString]  forKey:[[NSNumber numberWithInteger:kReminderObjectID] stringValue]];
            localNotification.userInfo = infoDictionary;
            localNotification.soundName = @"text_notification.mp3";
            
            //localNotification.soundName = UILocalNotificationDefaultSoundName;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
        NSLog(@"Saved reminder for type %d recipientName %@ recipient %@ message %@ and fireDate %@", type, recipientName,recipient,message,fireDate);
        
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






@end
