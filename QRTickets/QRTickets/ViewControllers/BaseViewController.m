//
//  BaseViewController.m
//  QRTickets
//
//  Created by Ivanov Andrey on 7/19/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController () 

@end

@implementation BaseViewController

#pragma mark - Life Cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkChanged:)
                                                 name:kRealReachabilityChangedNotification
                                               object:nil];
}

#pragma mark - Notifications

- (void)networkChanged:(NSNotification *)notification {
    RealReachability *reachability = (RealReachability *)notification.object;
    ReachabilityStatus status = [reachability currentReachabilityStatus];
    NSLog(@"currentStatus:%@",@(status));
    
    [self changeUIForConnecctionStatus:status];
}

#pragma mark - UI

- (void)changeUIForConnecctionStatus:(ReachabilityStatus)status {
    switch (status)
    {
        case RealStatusViaWiFi:
        case RealStatusViaWWAN: {
            UIColor *onlineColor = [UIColor greenColor];
            
            self.view.backgroundColor = onlineColor;
            
            self.navigationController.navigationBar.barTintColor = onlineColor;
            self.navigationController.navigationBar.translucent = NO;
            
            break;
        }
        case RealStatusNotReachable:
        default: {
            UIColor *offlineColor = [UIColor redColor];
            
            self.view.backgroundColor = offlineColor;
            
            self.navigationController.navigationBar.barTintColor = offlineColor;
            self.navigationController.navigationBar.translucent = NO;
            
            break;
        }
    }
}

#pragma mark - Error

- (void)handlingError:(NSError *)error {
    NSLog(@"Start handle error: %@", error.description);
    
    if ([error.domain isEqualToString:kQRTicketsErrorDomain]) {
        switch((QRErrorCode)error.code) {
            case kErrorFailedRetrieveDataFromServer:
            case kErrorTicketNotExist: {
                [self showWarningWithErrorMessage:error.localizedDescription withActions:nil];
                break;
            }
            default: {
                [self showWarningWithErrorMessage:@"Something went wrong" withActions:nil];
                break;
            }
        }
    }
    else {
        [self showWarningWithErrorMessage:error.localizedDescription withActions:nil];
    }
}

#pragma mark - AlertController

- (void)showAlertWithTitle:(NSString *)title withMessage:(NSString *)message withActions:(NSArray *)actions {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (actions == nil) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            
        }];
        [alertController addAction:cancel];
    }
    else {
        for (UIAlertAction *action in actions)
            [alertController addAction:action];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        // code here
    
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
        });
}

- (void)showWarningWithErrorMessage:(NSString *)errorMessage withActions:(NSArray *)actions {
    [self showAlertWithTitle:@"Warning" withMessage:errorMessage withActions:actions];
}

@end
