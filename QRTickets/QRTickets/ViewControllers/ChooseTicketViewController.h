//
//  ChooseTicketViewController.h
//  QRTickets
//
//  Created by Ivanov Andrey on 7/25/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ChooseTicketViewControllerDelegate <NSObject>

- (void)selectedTicket:(NSString *)ticketId;

@end

@interface ChooseTicketViewController : UIViewController

@property (nonatomic, weak) id <ChooseTicketViewControllerDelegate> delegate;

@end
