//
//  ViewController.m
//  RemindMe
//
//  Created by dasmer on 1/3/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+FontAwesome.h"
#import "ReminderCell.h"
#import "ECPhoneNumberFormatter.h"
#import "UIAlertView+Blocks.h"
#import "NavigationController.h"

@interface ViewController ()
@property  (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (strong,nonatomic) UIButton *eraseButton;
@property (strong,nonatomic) UIButton *doneButton;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.managedObjectContext = [DataStore instance].managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Reminder"];
    NSSortDescriptor *ageSort = [[NSSortDescriptor alloc] initWithKey:@"fireDate" ascending:YES];
    fetchRequest.sortDescriptors = @[ageSort];
    self.frc =
    [[NSFetchedResultsController alloc]
     initWithFetchRequest:fetchRequest
     managedObjectContext:[self managedObjectContext]
     sectionNameKeyPath:nil
     cacheName:nil];
    [self.frc performFetch:nil];
    self.frc.delegate = self;
    self.title = @"Reminders";
    CGFloat buttonSize = 22;
    UIButton *composeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonSize, buttonSize)];
    [composeButton setContentMode:UIViewContentModeCenter];
    [composeButton addTarget:self action:@selector(showNewReminderViewController:) forControlEvents:UIControlEventTouchUpInside];
    [composeButton setBackgroundImage:[UIImage composeIconSize:buttonSize withColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithCustomView:composeButton];
    self.eraseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonSize, buttonSize)];
    [self.eraseButton setContentMode:UIViewContentModeCenter];
    [self.eraseButton addTarget:self action:@selector(editButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.eraseButton setBackgroundImage:[UIImage eraseIconSize:buttonSize withColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    
    self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 0, buttonSize, buttonSize)];
    [self.doneButton setContentMode:UIViewContentModeCenter];
    [self.doneButton addTarget:self action:@selector(doneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton setBackgroundImage:[UIImage checkIconSize:buttonSize withColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithCustomView:self.eraseButton];
    
    self.navigationItem.leftBarButtonItem = editButton;
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    NavigationController *navController = (NavigationController *) self.navigationController;
    self.tableView.contentSize = CGSizeMake(self.tableView.frame.size.width, self.tableView.frame.size.height + [navController iAdHeight]);
}

- (void) editButtonClicked: (id) sender{
    [self setEditing:YES animated:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.doneButton];
}

- (void) doneButtonClicked: (id) sender{
    [self setEditing:NO animated:YES];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.eraseButton];
}
- (void) showNewReminderViewController: (id) sender{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Cancel"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    UIViewController *rmvc = [self.storyboard instantiateViewControllerWithIdentifier:@"reminderMaker"];
    [self.navigationController pushViewController:rmvc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.

    id <NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
    NSInteger numObjects = sectionInfo.numberOfObjects;
    if (numObjects <= 0){
        [self.eraseButton setEnabled:NO];
    }
    else{
        [self.eraseButton setEnabled:YES];
    }

    return numObjects;
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ReminderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Reminder *reminder = [self.frc objectAtIndexPath:indexPath];
    
    cell.nameLabel.text = reminder.recipientName;
    cell.messageLabel.text = reminder.message;
    
    if ([reminder reminderType] == ReminderTypeMessage){
    ECPhoneNumberFormatter *formatter = [[ECPhoneNumberFormatter alloc] init];
    NSString *formattedNumber = [formatter stringForObjectValue:reminder.recipient];
    cell.recipientLabel.text = formattedNumber;
    }
    else{
        cell.recipientLabel.text = reminder.recipient;
    }
    
    cell.myDate = reminder.fireDate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE MMM dd yyyy"];
    NSLog(@"desc %@",[reminder.fireDate description]);
    cell.dateLabel.text = [dateFormatter stringFromDate:reminder.fireDate];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hh:mma"];
    cell.timeLabel.text = [timeFormatter stringFromDate:reminder.fireDate];

    [[NSNotificationCenter defaultCenter] removeObserver:cell];
    [[NSNotificationCenter defaultCenter] addObserver:cell selector:@selector(checkIfFireDateIsPassed) name:kReminderFireDateCheckNotification object:nil];
    
    return cell;
}
- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Reminder *reminderToDelete = [self.frc objectAtIndexPath:indexPath];
        if(![[DataStore instance] deleteReminder:reminderToDelete]){
            NSLog(@"Did Not Deleted Reminder");
        }
        else{
            if ([self.tableView numberOfRowsInSection:0] <= 0){
                [self doneButtonClicked:nil];
                [self.eraseButton setEnabled:NO];
            }
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    Reminder *reminder = [self.frc objectAtIndexPath:indexPath];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Send %@ Now?", [reminder reminderActionType]] message:Nil delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
   av.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
       if (buttonIndex == 1){
           NavigationController *nc = (NavigationController *) self.navigationController;
           [nc showReminderForMyReminder:reminder];
       }
   };
    [av show];
}


#pragma mark - NSFetchedResultsController Delegate Methods

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath{
    
    if (type == NSFetchedResultsChangeDelete){
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else if (type == NSFetchedResultsChangeInsert){
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
