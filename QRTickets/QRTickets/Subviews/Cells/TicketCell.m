//
//  TicketCell.m
//  QRTickets
//
//  Created by Ivanov Andrey on 7/19/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//

#import "TicketCell.h"

@interface TicketCell ()

@property (weak, nonatomic) IBOutlet UIButton *statusButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthStatusButtonConstraint;

@end

@implementation TicketCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.statusButton.layer.masksToBounds = YES;
    self.statusButton.layer.cornerRadius = self.widthStatusButtonConstraint.constant/2;
    
    [self prepareForReuse];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.titleLabel.text = @"";
}

#pragma mark - Public

- (void)configureStatus:(TicketStatus)status {
    switch (status) {
        case StatusUsed: {
            self.statusButton.backgroundColor = [UIColor greenColor];
            break;
        }
        case StatusNotUsed:
        default: {
            self.statusButton.backgroundColor = [UIColor redColor];
            
            break;
        }
    }
}

@end
