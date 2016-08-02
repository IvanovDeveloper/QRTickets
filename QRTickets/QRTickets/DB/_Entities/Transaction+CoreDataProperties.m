//
//  Transaction+CoreDataProperties.m
//  QRTickets
//
//  Created by Ivanov Andrey on 7/22/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Transaction+CoreDataProperties.h"

@implementation Transaction (CoreDataProperties)

@dynamic objectId;
@dynamic ticketId;
@dynamic appId;
@dynamic deviceType;
@dynamic createdDate;
@dynamic updatedDate;
@dynamic transationStatus;
@dynamic ticket;

@end
