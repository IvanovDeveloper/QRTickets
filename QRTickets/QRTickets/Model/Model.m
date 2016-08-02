//
//  Model.m
//  QRTickets
//
//  Created by Ivanov Andrey on 7/19/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//

#import "Model.h"

#import <AFNetworking/AFNetworking.h>
#import "RealReachability.h"

#import "Ticket.h"
#import "Transaction.h"

#define kBaseURL @"http://api.dev"
#define kGetAllTickets                      [kBaseURL stringByAppendingString:@"/v1/codes/all"]
#define kGetTicketById(id)                  [kBaseURL stringByAppendingString:[NSString stringWithFormat:@"/v1/codes/%@", id]]
#define kGetTicketByCode(code)              [kBaseURL stringByAppendingString:[NSString stringWithFormat:@"/v1/codes/findByCode/%@", code]]
#define kUseTicket(code, deviceId, appId)   [kBaseURL stringByAppendingString:[NSString stringWithFormat:@"/v1/codes/use/%@/%@/%@", code, deviceId, appId]]
#define kSynchronisation                    [kBaseURL stringByAppendingString:@"/v1/codes/synchronization"] 

#define kiOSDeviceId @"2"

#define kTimeoutInterval 10

#define kErrorWithCode(codeNumber) [NSError errorWithDomain:kQRTicketsErrorDomain code:codeNumber userInfo:userInfoMyError(codeNumber)]

@interface Model ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation Model

NSDictionary *userInfoMyError(QRErrorCode errorCode) {
    NSMutableDictionary *userInfo = @{}.mutableCopy;
    
    switch (errorCode) {
        case kErrorTicketNotExist:
            userInfo[NSLocalizedDescriptionKey] = @"Ticket with such id not exist";
            return userInfo;
        case kErrorFailedRetrieveDataFromServer:
            userInfo[NSLocalizedDescriptionKey] = @"Failed to retrieve data from the server";
            return userInfo;
        default:
            return nil;
    }
}

#pragma mark - Lifecycle

+ (id)sharedModel {
    static Model *singletonObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
    });
    return singletonObject;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        self.sessionManager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self.sessionManager.requestSerializer setTimeoutInterval:kTimeoutInterval];
        
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

#pragma mark - Public

- (void)ticketExistWithId:(NSString *)ticketId withCompletionBlock:(SuccessCompletionBlock)block {
    NSManagedObjectContext *context = [[DBManager sharedManager] managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Ticket class])];
    [request setFetchLimit:1];
    [request setPredicate:[ NSPredicate predicateWithFormat:@"ticketId == %@", ticketId]];
    
    NSError *error = nil;
    Ticket *ticket = [context executeFetchRequest:request error:&error].lastObject;
    
    if (error)
        block(NO, error);
    
    if (ticket) {
        block(YES, nil);
    }
    else {
        [self getTicketWithTickeId:ticketId withCompletionBlock:block];
    }
}

#pragma mark - Api

- (void)getTicketWithTickeId:(NSString *)ticketId withCompletionBlock:(SuccessCompletionBlock)block {
    
    NSString *link = [kGetTicketByCode(ticketId) stringByRemovingPercentEncoding];
    
    NSURL *URL = [NSURL URLWithString:link];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTimeoutInterval];

    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        if (error) {
            if ([responseObject[@"name"] isEqualToString:@"Not Found"]) {
                NSError *localError = kErrorWithCode(kErrorTicketNotExist);
                block(NO, localError);
            }
            else
                block(NO, error);
        } else {
            
            NSManagedObjectContext *context = [[DBManager sharedManager] managedObjectContext];
            
            [context performBlockAndWait:^{
                
                Ticket *ticket = [self deserializeTicket:responseObject saveInContext:context];
                if (ticket)
                    block(YES, nil);
                else
                    block(NO, nil);
            }];
        }
    }];
    [dataTask resume];
    
    /*
    [self.sessionManager GET:link parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSManagedObjectContext *context = [[DBManager sharedManager] managedObjectContext];
        
        [context performBlockAndWait:^{
            
            Ticket *ticket = [self deserializeTicket:responseObject saveInContext:context];
            if (ticket)
                block(YES, nil);
            else
                block(NO, nil);
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        if (error.code == 404)
            block(NO, nil);
        else {
            NSError *localError = kErrorWithCode(kErrorFailedRetrieveDataFromServer);
            block(NO, localError);
        }
    }];
     */
}

- (void)updateTicketsWithCompletionBlock:(SuccessCompletionBlock)block {
 
    NSString *link = kGetAllTickets;
    
    [self.sessionManager GET:link parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSManagedObjectContext *context = [[DBManager sharedManager] managedObjectContext];
        
        [context performBlockAndWait:^{
            
            NSArray *tickets = responseObject;
            NSError *error = [self deserializeTickets:&tickets saveInContext:context];
            if( error ) {
                block(NO, error);
                return;
            }
            
            block(YES, nil);
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        NSError *localError = kErrorWithCode(kErrorFailedRetrieveDataFromServer);
        block(NO, localError);
    }];
}

- (void)useCode:(NSString *)ticketId withCompletionBlock:(SuccessCompletionBlock)block {
    
    NSString *link = kUseTicket(ticketId, kiOSDeviceId, KAppIdentifier);
    
    [self.sessionManager POST:link parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSManagedObjectContext *context = [[DBManager sharedManager] managedObjectContext];
        
        [context performBlockAndWait:^{
            
            NSError *error = [self deserializeUseTicketAnswer:responseObject forTickit:ticketId saveInContext:context];
            if (error) {
                block(NO, error);
                return;
            }
            
            BOOL isTicketAllowed = (BOOL)[responseObject[@"result"] integerValue];
            
            if (isTicketAllowed) {
                block(YES, nil);
            }
            else {
                block(NO, nil);
            }
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
        NSError *localError = kErrorWithCode(kErrorFailedRetrieveDataFromServer);
        block(NO, localError);
    }];
}

#pragma mark - Desereliazation

- (NSError *)deserializeUseTicketAnswer:(id)responseObject forTickit:(NSString *)ticketId saveInContext:(NSManagedObjectContext *)aContext {
    NSError *error = nil;
    
    if (!responseObject[@"result"]) {
        error = kErrorWithCode(kErrorFailedRetrieveDataFromServer);
        return error;
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Ticket class])];
    [request setFetchLimit:1];
    [request setPredicate:[NSPredicate predicateWithFormat:@"ticketId == %@", ticketId]];
    
    Ticket *ticket = [aContext executeFetchRequest:request error:&error].lastObject;
    if (error)
        return error;
    
    if (ticket.usedStatus.boolValue)
        return error;
    
    ticket.usedStatus = [NSNumber numberWithBool:YES];
    
    if( ![aContext save:&error])
        NSLog(@"Unable to save, error:%@", error.description);
    
    return error;
}

- (NSError *)deserializeTickets:(NSArray **)tickets saveInContext:(NSManagedObjectContext *)context {
    
    __block NSError *deserializationError = nil;
    __block NSMutableArray *mo = [ @[] mutableCopy ];
    
    @try {
        
#warning 103 should remove space from string and use Encoding
        
        for (NSDictionary *object in *tickets )
        {
            @autoreleasepool {
                Ticket *ticket = [self deserializeTicket:object saveInContext:context];
                if (ticket)
                    [mo addObject:ticket];
            }
        }
    }
    @catch (NSException *exception) {
        
        deserializationError = kParseResponseError;
        NSLog(@"%s caught exception %@", __PRETTY_FUNCTION__, exception.description);
        
        [mo removeAllObjects];
    }
    @finally {
    }
    
    *tickets = mo;
    
    return deserializationError;
}

- (Ticket *)deserializeTicket:(NSDictionary *)aTicket saveInContext:(NSManagedObjectContext *)context {
    
#warning 104 Add removing data from local DB, whose not exist at server
    
    NSDictionary *object = aTicket;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Ticket class])];
    [request setFetchLimit:1];
    [request setPredicate:[ NSPredicate predicateWithFormat:@"ticketId == %@", object[@"code"]]];
    
    __block NSError *error = nil;
    Ticket *ticket = [context executeFetchRequest:request error:&error].lastObject;
    if(!ticket) {
        ticket = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Ticket class]) inManagedObjectContext:context];
        
        NSTimeInterval createdDateTimeInterval = [object[@"created_at"] integerValue];
        ticket.createdDate = [NSDate dateWithTimeIntervalSince1970:createdDateTimeInterval];
    }
    
    NSTimeInterval updatedTimeInterval = [object[@"updated_at"] integerValue];
#warning should be >=
    if ([ticket.updatedDate timeIntervalSince1970] > updatedTimeInterval)
        return ticket;
    
    if (object[@"updated_at"]) {
        NSTimeInterval timeInterval = [object[@"updated_at"] integerValue];
        ticket.updatedDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    }
    
    if (object[@"used_at"] && ![object[@"used_at"] isKindOfClass:[NSNull class]]) {
        NSTimeInterval timeInterval = [object[@"used_at"] integerValue];
        ticket.usedDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    }
    
    if (object[@"code"]) {
        ticket.ticketId = object[@"code"];
    }
    
    if (object[@"id"]) {
        ticket.objectId = [NSNumber numberWithInteger:[object[@"id"] integerValue]];
    }
    
    if (object[@"status"]) {
        NSInteger statusCode = [object[@"status"] integerValue];
        BOOL status = (BOOL)statusCode;
        ticket.usedStatus = [NSNumber numberWithBool:status];
    }
    
    if (object[@"transactions"]) {
        NSArray *transatcions = object[@"transactions"];
        for (NSDictionary *transactionObject in transatcions) {
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Transaction class])];
            [request setFetchLimit:1];
            [request setPredicate:[NSPredicate predicateWithFormat:@"objectId == %ld", [transactionObject[@"id"] integerValue] ]];
            
            BOOL newTransaction = NO;
            
            __block NSError *error = nil;
            
            Transaction *transaction = [context executeFetchRequest:request error:&error].lastObject;
            if(!transaction) {
                
                newTransaction = YES;
                transaction = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Transaction class]) inManagedObjectContext:context];
                
                NSTimeInterval createdDateTimeInterval = [transactionObject[@"created_at"] integerValue];
                transaction.createdDate = [NSDate dateWithTimeIntervalSince1970:createdDateTimeInterval];
            }
            
            NSTimeInterval updatedTimeInterval = [transactionObject[@"updated_at"] integerValue];
#warning should be >=
            if ([transaction.updatedDate timeIntervalSince1970] > updatedTimeInterval)
                continue;
            
            if (transactionObject[@"updated_at"]) {
                NSTimeInterval timeInterval = [transactionObject[@"updated_at"] integerValue];
                transaction.updatedDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            }
            
            if (transactionObject[@"app_id"]) {
                transaction.appId = transactionObject[@"app_id"];
            }
            
            if (transactionObject[@"id"]) {
                transaction.objectId = [NSNumber numberWithInteger:[transactionObject[@"id"] integerValue]];
            }
            
            if (transactionObject[@"device"]) {
                transaction.deviceType = [NSNumber numberWithInteger:[transactionObject[@"device"] integerValue]];
            }
            
            if (transactionObject[@"status"]) {
                transaction.transationStatus = [NSNumber numberWithInteger:[transactionObject[@"status"] integerValue]];
            }
            
            if (transactionObject[@"code_id"]) {
                transaction.ticketId = [NSNumber numberWithInteger:[transactionObject[@"code_id"] integerValue]];
            }
            
            if (newTransaction)
                [ticket addTransactionsObject:transaction];
        }
    }
    
    [context performBlock:^{
        if( ![ context save:&error ] )
            NSLog(@"Unable to save Photo, error:%@", error.description);
    }];
    
    return ticket;
}


#pragma mark - Getters

- (BOOL)isConnectedToInternet {
    BOOL isConnected = NO;
    
    ReachabilityStatus status = [GLobalRealReachability currentReachabilityStatus];
    switch (status)
    {
        case RealStatusViaWiFi:
        case RealStatusViaWWAN: {
            isConnected = YES;
            break;
        }
        case RealStatusNotReachable:
        default: {
            isConnected = NO;
            break;
        }
    }
    return isConnected;
}

@end
