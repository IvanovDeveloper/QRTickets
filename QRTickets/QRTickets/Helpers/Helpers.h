//
//  Helpers.h
//  QRTickets
//
//  Created by Ivanov Andrey on 7/18/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^AccessBlock)(BOOL granted);

@interface Helpers : NSObject

#pragma mark - QRCode

+ (NSString *)getTicketIdFromQRString:(NSString *)qrString;

+ (BOOL)ticketIdValidation:(NSString *)idCode;

#pragma mark - TableView

+ (void)removeSeparatorsForTableView:(UITableView *)tableView;

#pragma mark - Navigation

+ (void)removeBackTitleForBackBarButton:(UINavigationItem *)navigationItem;

+ (void)hasCameraAccess:(AccessBlock)accessBlock;

@end
