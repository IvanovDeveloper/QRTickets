//
//  Helpers.m
//  QRTickets
//
//  Created by Ivanov Andrey on 7/18/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//

#import "Helpers.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface Helpers () <UIAlertViewDelegate>

@end

@implementation Helpers

#pragma mark - QRCode

+ (NSString *)getTicketIdFromQRString:(NSString *)qrString {
    NSString *ticketId = nil;
    
#warning 100 implemet get ticket id from qr string
    ticketId = qrString;
    
    return ticketId;
}

+ (BOOL)ticketIdValidation:(NSString *)ticketId {
    BOOL isValid = YES;
    
#warning 101 implemnt validation ticket id
    if (ticketId == nil)
        return NO;
    
    return isValid;
}

#pragma mark - TableView

+ (void)removeSeparatorsForTableView:(UITableView *)tableView {
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Navigation

+ (void)removeBackTitleForBackBarButton:(UINavigationItem *)navigationItem {
    navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - Access

+ (void)hasCameraAccess:(AccessBlock)accessBlock {
    
    AccessBlock localBlock = ^(BOOL granted) {
        accessBlock(granted);
    };
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusAuthorized) {
        localBlock(YES);
    } else if(status == AVAuthorizationStatusDenied){
        localBlock(NO);
    } else if(status == AVAuthorizationStatusRestricted){
        localBlock(NO);
    } else if(status == AVAuthorizationStatusNotDetermined){
        // not determined
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            localBlock(granted);
        }];
    }
}

#pragma mark - UIalertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.cancelButtonIndex != buttonIndex) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    
}


@end
