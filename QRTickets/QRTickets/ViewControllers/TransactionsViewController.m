//
//  TransactionsViewController.m
//  QRTickets
//
//  Created by Ivanov Andrey on 7/26/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//

#import "TransactionsViewController.h"

#import "TransactionCell.h"

#import "Ticket.h"
#import "Transaction.h"

@interface TransactionsViewController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *transactionsController;

@end

@implementation TransactionsViewController

NSString *TransactionStatusString(TransactionStatus status) {
    switch (status) {
        case TransactionAllowed:
            return @"Allowed";
        case TransactionDuplicated:
            return @"Duplicated";
        default:
            return nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationController.navigationBar.topItem.title = self.ticket.ticketId;
//    self.navigationItem.title = [self.ticket.ticketId stringByAppendingString:];
    
    [Helpers removeSeparatorsForTableView:self.tableView];
    self.tableView.rowHeight = 64.f;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [self.tableView reloadData];
    
    [self updateTransactions];
}

#pragma mark - Private

- (void)updateTransactions {
    if ([[Model sharedModel] isConnectedToInternet]) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeAnnularDeterminate;
        hud.label.text = @"Updating";
        
        __weak __typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            [[Model sharedModel] getTicketWithTickeId:self.ticket.ticketId withCompletionBlock:^(BOOL success, NSError *error) {
                
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

#pragma mark - Getters

- (NSFetchedResultsController *)transactionsController {
    if (_transactionsController == nil) {
        NSManagedObjectContext *context = [[DBManager sharedManager] managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Transaction class]) inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ticketId == %ld", [self.ticket.objectId integerValue]];
        [fetchRequest setPredicate:predicate];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate"
                                                                       ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
        
        _transactionsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        _transactionsController.delegate = self;
        [_transactionsController performFetch:NULL];
    }
    return _transactionsController;
}

#pragma mark - Actions

- (void)refresh:(UIRefreshControl *)refreshControll {
    [refreshControll endRefreshing];
    
    [self updateTransactions];
}

#pragma mark - UITableViewDelegate/DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.transactionsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier =  kTransactionCellReuseIdentifier;
    TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    Transaction *transaction = self.transactionsController.fetchedObjects[indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy  hh:mm.ss"];
    cell.createdAtValueLabel.text = [dateFormatter stringFromDate:transaction.createdDate];
    
    cell.statusValueLabel.text = TransactionStatusString((TransactionStatus)[transaction.transationStatus integerValue]);
    
    return cell;
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

@end
