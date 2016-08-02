//
//  Ticket+CoreDataProperties.h
//  QRTickets
//
//  Created by Ivanov Andrey on 7/22/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Ticket.h"

NS_ASSUME_NONNULL_BEGIN

@interface Ticket (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdDate;
@property (nullable, nonatomic, retain) NSString *ticketId;
@property (nullable, nonatomic, retain) NSNumber *objectId;
@property (nullable, nonatomic, retain) NSDate *updatedDate;
@property (nullable, nonatomic, retain) NSDate *usedDate;
@property (nullable, nonatomic, retain) NSNumber *usedStatus;
@property (nullable, nonatomic, retain) NSSet<Transaction *> *transactions;

@end

@interface Ticket (CoreDataGeneratedAccessors)

- (void)addTransactionsObject:(Transaction *)value;
- (void)removeTransactionsObject:(Transaction *)value;
- (void)addTransactions:(NSSet<Transaction *> *)values;
- (void)removeTransactions:(NSSet<Transaction *> *)values;

@end

NS_ASSUME_NONNULL_END
