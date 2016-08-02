//
//  TransactionCell.m
//  QRTickets
//
//  Created by Ivanov Andrey on 7/26/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//

#import "TransactionCell.h"

@implementation TransactionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self prepareForReuse];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.createdAtValueLabel.text = @"";
    self.statusValueLabel.text = @"";
}

@end
