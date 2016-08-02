//
//  DBManager.h
//  QRTickets
//
//  Created by Ivanov Andrey on 7/18/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Ticket;

@interface DBManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (id)sharedManager;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (Ticket *)createNewTicket;

@end
