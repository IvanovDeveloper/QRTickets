//
//  ChooseTicketViewController.m
//  QRTickets
//
//  Created by Ivanov Andrey on 7/25/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//

#import "ChooseTicketViewController.h"

#import "Ticket.h"

@interface ChooseTicketViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *tickets;

@end

@implementation ChooseTicketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tickets = @[].mutableCopy;
    
    [self updateData];
}

#pragma mark - Private

- (void)updateData {
    [self.tickets removeAllObjects];
    
    //Get all ticket ids
    NSManagedObjectContext *context = [[DBManager sharedManager] managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription  entityForName:@"Ticket" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:@[@"ticketId"]];
    
    NSError *error = nil;;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    for (NSDictionary *dict in objects) {
        [self.tickets addObject:dict[@"ticketId"]];
    }
    
    [self.tickets addObject:@"Ticket-Ivanov"];
    [self.tickets addObject:@"Ticket-Petrov"];
    [self.tickets addObject:@"Ticket-Sidorov"];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate/DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tickets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.textLabel.text = self.tickets[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *ticketId = self.tickets[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(selectedTicket:)]) {
        [self.delegate selectedTicket:ticketId];
    }
}

@end
