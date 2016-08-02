//
//  TransactionCell.h
//  QRTickets
//
//  Created by Ivanov Andrey on 7/26/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTransactionCellReuseIdentifier @"TransactionCellID"

@interface TransactionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *createdAtValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusValueLabel;

@end
