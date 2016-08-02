//
//  Transaction+CoreDataProperties.h
//  QRTickets
//
//  Created by Ivanov Andrey on 7/22/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Transaction.h"

NS_ASSUME_NONNULL_BEGIN

@interface Transaction (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *objectId;
@property (nullable, nonatomic, retain) NSNumber *ticketId;
@property (nullable, nonatomic, retain) NSString *appId;
@property (nullable, nonatomic, retain) NSNumber *deviceType;
@property (nullable, nonatomic, retain) NSDate *createdDate;
@property (nullable, nonatomic, retain) NSDate *updatedDate;
@property (nullable, nonatomic, retain) NSNumber *transationStatus;
@property (nullable, nonatomic, retain) Ticket *ticket;

@end

NS_ASSUME_NONNULL_END
