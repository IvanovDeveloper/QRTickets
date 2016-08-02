//
//  Model.h
//  QRTickets
//
//  Created by Ivanov Andrey on 7/19/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TicketStatus) {
    StatusNotUsed,
    StatusUsed
};

typedef NS_ENUM(NSInteger, TransactionStatus) {
    TransactionAllowed = 1
    , TransactionDuplicated = 2
};

#define kQRTicketsErrorDomain [NSString stringWithFormat:@"%@.ErrorDomain", KAppIdentifier]

#define kParseResponseError [NSError errorWithDomain:kQRTicketsErrorDomain code:kParseResponseErrorCode userInfo:nil]

typedef NS_ENUM(NSInteger, QRErrorCode) {
    kInvalidErrorCode = 0
    , kConnectionErrorCode = 300
    , kParseResponseErrorCode = 300

    , kErrorTicketNotExist = 100
    , kErrorFailedRetrieveDataFromServer = 101
};


typedef void (^SuccessCompletionBlock)(BOOL success, NSError *error);

@interface Model : NSObject

@property (nonatomic, readonly, assign) BOOL isConnectedToInternet;

+ (id)sharedModel;

#pragma mark -

- (void)ticketExistWithId:(NSString *)ticketId withCompletionBlock:(SuccessCompletionBlock)block;

#pragma mark - Fetches

- (void)updateTicketsWithCompletionBlock:(SuccessCompletionBlock)block;

- (void)getTicketWithTickeId:(NSString *)ticketId withCompletionBlock:(SuccessCompletionBlock)block;

- (void)useCode:(NSString *)aCode withCompletionBlock:(SuccessCompletionBlock)block;

@end


