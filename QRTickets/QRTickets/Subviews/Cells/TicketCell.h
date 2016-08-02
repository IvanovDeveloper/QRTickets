//
//  TicketCell.h
//  QRTickets
//
//  Created by Ivanov Andrey on 7/19/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTicketCellReuseID @"TicketCellID"

@interface TicketCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *desciptionLabel;

- (void)configureStatus:(TicketStatus)status;

@end
