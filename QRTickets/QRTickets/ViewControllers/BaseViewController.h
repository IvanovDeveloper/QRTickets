//
//  BaseViewController.h
//  QRTickets
//
//  Created by Ivanov Andrey on 7/19/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RealReachability.h"
#import "MBProgressHUD.h"

@interface BaseViewController : UIViewController

- (void)handlingError:(NSError *)error;

- (void)showAlertWithTitle:(NSString *)title withMessage:(NSString *)message withActions:(NSArray *)actions;
- (void)showWarningWithErrorMessage:(NSString *)errorMessage withActions:(NSArray *)actions;

@end
