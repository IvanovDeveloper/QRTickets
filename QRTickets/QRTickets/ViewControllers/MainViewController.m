//
//  MainViewController.m
//  QRTickets
//
//  Created by Ivanov Andrey on 7/19/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//

#import "MainViewController.h"

#import "ChooseTicketViewController.h"
#import "TransactionsViewController.h"

#import "QRCodeReaderViewController.h"
#import "QRCodeReaderDelegate.h"
#import "QRCodeReader.h"

#import "TicketCell.h"

#import "Ticket.h"


@interface MainViewController () <QRCodeReaderDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, ChooseTicketViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *internetConnectionStatusLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightButton;

@property (nonatomic, strong) NSFetchedResultsController *ticketsController;

@end

@implementation MainViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Helpers removeBackTitleForBackBarButton:self.navigationItem];
    
    //Configure TableView
    self.tableView.rowHeight = 65.f;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    //Update Tickets
    [self updateTickets];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Configure UI for internet connection
    ReachabilityStatus status = [GLobalRealReachability currentReachabilityStatus];
    [self changeUIForConnecctionStatus:status];
}

#pragma mark - Getters

- (NSFetchedResultsController *)ticketsController
{
    if (_ticketsController == nil) {
        
        NSManagedObjectContext *context = [[DBManager sharedManager] managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ticket" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"objectId"
                                                                       ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
        
        _ticketsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        _ticketsController.delegate = self;
        [_ticketsController performFetch:NULL];
    }
    
    return _ticketsController;
}

#pragma mark - Fetches
         
- (void)updateTickets {
    if ([[Model sharedModel] isConnectedToInternet]) {
     
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.label.text = @"Updating";
        
        __weak __typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            [[Model sharedModel] updateTicketsWithCompletionBlock:^(BOOL success, NSError *error) {
                
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hideAnimated:YES];
                    
                    if (error)
                        [strongSelf handlingError:error];
                    
                    [strongSelf.tableView reloadData];
                });
            }];
        });
    }
    else {
        NSLog(@"Please connect to internet for updating tickets");
        [self.tableView reloadData];
    }
}

#pragma mark - Private

- (void)changeUIForConnecctionStatus:(ReachabilityStatus)status {
    switch (status)
    {
        case RealStatusViaWiFi:
        case RealStatusViaWWAN: {
            UIColor *onlineColor = [UIColor greenColor];
            
            self.internetConnectionStatusLabel.text = @"online";
            
            self.view.backgroundColor = onlineColor;
            
            self.navigationController.navigationBar.barTintColor = onlineColor;
            self.navigationController.navigationBar.translucent = NO;
    
            break;
        }
        case RealStatusNotReachable:
        default: {
            UIColor *offlineColor = [UIColor redColor];
            
            self.internetConnectionStatusLabel.text = @"offline";
            
            self.view.backgroundColor = offlineColor;
            
            self.navigationController.navigationBar.barTintColor = offlineColor;
            self.navigationController.navigationBar.translucent = NO;
            
            break;
        }
    }
}

- (void)checkTicketId:(NSString *)ticketId {
    
    if ([Helpers ticketIdValidation:ticketId] ) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.label.text = @"Updating";
        
        __weak __typeof(self) weakSelf = self;
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *tryAgain = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
            [weakSelf checkTicketId:ticketId];
        }];
        NSMutableArray *actionsArray = [NSMutableArray arrayWithObjects:cancel, tryAgain, nil];
        
        
        //1. Start verifycation. Check exist file
        [[Model sharedModel] ticketExistWithId:ticketId withCompletionBlock:^(BOOL success, NSError *error) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hideAnimated:YES];
                    [strongSelf handlingError:error];
                });
                
                return;
            }
            
            if (!success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hideAnimated:YES];
                    
                    [strongSelf showWarningWithErrorMessage:@"Ticket with such id not exist" withActions:actionsArray];
                });
            }
            else {
                [[Model sharedModel] useCode:ticketId withCompletionBlock:^(BOOL success, NSError *error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [hud hideAnimated:YES];
                        
                        if (error) {
                            [strongSelf handlingError:error];
                            return;
                        }
                        
                        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            [strongSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
                            [strongSelf updateTickets];
                        }];
                        
                        if (success) {
                            [strongSelf showAlertWithTitle:@"Success" withMessage:@"This ticket is allowed" withActions:@[ok]];
                        }
                        else {
                            [strongSelf showAlertWithTitle:@"Failure" withMessage:@"This ticket already used" withActions:@[ok]];
                        }
                        
                        [strongSelf.tableView reloadData];
                    });
                }];
            }
        }];
    }
    else {
        [self showWarningWithErrorMessage:@"Ticket not valid" withActions:nil];
    }
}

#pragma mark - Notifications

- (void)networkChanged:(NSNotification *)notification {
    RealReachability *reachability = (RealReachability *)notification.object;
    ReachabilityStatus status = [reachability currentReachabilityStatus];
    
    [self changeUIForConnecctionStatus:status];
}

#pragma mark - Actions

- (void)refresh:(UIRefreshControl *)refreshControl {
    [refreshControl endRefreshing];
    
    [self updateTickets];
}

- (IBAction)onRefresh:(id)sender {
    for (Ticket *ticket in self.ticketsController.fetchedObjects) {
        NSManagedObjectContext *context = [[DBManager sharedManager] managedObjectContext];
        [context deleteObject:ticket];
    }
    
    [[DBManager sharedManager] saveContext];
}

- (IBAction)onScan:(id)sender {
  
    /*
    ChooseTicketViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ChooseTicketViewController class])];
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
     */
    
    //*
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [Helpers hasCameraAccess:^(BOOL granted) {
            
            if (granted) {
                
                if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
                    static QRCodeReaderViewController *vc = nil;
                    static dispatch_once_t onceToken;
                    
                    dispatch_once(&onceToken, ^{
                        QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
                        vc = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel"
                                                                          codeReader:reader
                                                                 startScanningAtLoad:YES
                                                              showSwitchCameraButton:YES
                                                                     showTorchButton:YES];
                    });
                    
                    vc.delegate = self;
                    
                    [vc setCompletionWithBlock:^(NSString *resultAsString) {
                        NSLog(@"QRCode Completion with result: %@", resultAsString);
                    }];
                    
                    [self presentViewController:vc animated:YES completion:NULL];
                }
                else {
                    [self showWarningWithErrorMessage:@"Reader not supported by the current device" withActions:nil];
                }
            }
            else {
                
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
                
                UIAlertAction *openSettings = [UIAlertAction actionWithTitle:@"Open settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:url];
                }];
                
                [self showWarningWithErrorMessage:@"Give camera permission" withActions:@[cancel, openSettings]];
            }
        }];
    });
    //     */
}

#pragma mark - QRCodeReader Delegate Methods

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSString *ticketId = [Helpers getTicketIdFromQRString:result];
        [self checkTicketId:ticketId];
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITableViewDataDelegate/Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ticketsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = kTicketCellReuseID;
    TicketCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([TicketCell class]) bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }

    Ticket *ticket = self.ticketsController.fetchedObjects[indexPath.row];
    
    cell.titleLabel.text = @"Посадочный документ:";
    cell.desciptionLabel.text = ticket.ticketId;
    
    [cell configureStatus:(TicketStatus)[ticket.usedStatus boolValue]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TransactionsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([TransactionsViewController class])];
    viewController.ticket = self.ticketsController.fetchedObjects[indexPath.row];
    [self.navigationController showViewController:viewController sender:self];
}

#pragma mark - NSFetchResultControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            break;
        case NSFetchedResultsChangeDelete:
            
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            break;
        case NSFetchedResultsChangeMove:
            
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
        case NSFetchedResultsChangeUpdate:
            
            break;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - ChooseTicketViewControllerDelegate

- (void)selectedTicket:(NSString *)ticketId {
    [self.navigationController popViewControllerAnimated:YES];
    [self checkTicketId:ticketId];
}

@end
