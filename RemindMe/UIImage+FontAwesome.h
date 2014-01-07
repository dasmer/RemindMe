//
//  UIImage+FontAwesome.h
//  RemindMe
//
//  Created by dasmer on 1/3/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FontAwesome)
+ (UIImage *) warningIconSize:(float)size withColor:(UIColor *)color;
+ (UIImage *) composeIconSize:(float)size withColor:(UIColor *)color;
+ (UIImage *) eraseIconSize:(float)size withColor:(UIColor *)color;
+ (UIImage *) checkIconSize:(float)size withColor:(UIColor *)color;
+ (UIImage *) plusCircleIconSize:(float)size withColor:(UIColor *)color;
@end
