![alt text](https://raw.github.com/duliodenis/RemindMe/master/images/appIcon120.png "RemindMe Logo")
## RemindMe

#### Functionality

RemindMe is a useful **iOS 7** reminder app that allows the user to set-up a reminder to text a contact.

The App uses the user's **AddressBook** in order for the user to select a contact and get the phone number to text to.  The user sets-up the time and day to be reminded as well as type the message that is to be sent in the future.  

At any time the user can see a listing of all their reminders providing a single quick view of the recipient, the phone number, the date and time of the reminder and the message to be texted.

Perhaps the best feature of the app is on the time and date of the reminder the app provides the user with a **local notification** thereby reminding the user to send the text message with a click of a button.

#### Installation with CocoaPods

[CocoaPods](http://cocoapods.org/ "CocoPods Home Page") is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. RemindMe takes advantage of CocoaPods.  The following Pods are used:

##### Podfile
```
platform :ios, '7.0'
pod 'FontAwesomeKit'<br>
pod 'TWMessageBarManager'<br>
pod 'ECPhoneNumberFormatter'<br>
pod 'UIAlertView+Blocks'<br>
```

#### Contributing

Please fork this repo and submit a pull request with any update you make.