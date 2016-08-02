//
//  TransactionsViewController.h
//  QRTickets
//
//  Created by Ivanov Andrey on 7/26/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class Ticket;

@interface TransactionsViewController : BaseViewController

@property (nonatomic, strong) Ticket *ticket;

@end
