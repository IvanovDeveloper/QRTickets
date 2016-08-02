//
//  AppDelegate.m
//  QRTickets
//
//  Created by Ivanov Andrey on 7/18/16.
//  Copyright © 2016 Ivanov Andrey. All rights reserved.
//

#import "AppDelegate.h"

#import "RealReachability.h"

#import <AFNetworking.h>

@interface AppDelegate ()



@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [GLobalRealReachability startNotifier];
    
    [self configureApperance];
    
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    
    NSDictionary *parametersDictionary = @  {
        @"code_id": @2,
        @"app_id": @"some_app_id",
        @"device": @1,
        @"status": @1
    };
    
    NSString *address =
//        @"http://api.dev"
//        "/v1/codes/all";
    //    "/v1/codes/findByCode/5555";
//        @"http://api.dev/v1/codes/1";
        @"http://api.dev/v1/codes/synchronization";
//        @"/v1/codes/use/Ticket1/1/qrcode";
    
//    [manager GET:address parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"success!");
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"error: %@", error);
//    }];
//
    
//    NSArray *arrayParametrs = [NSArray arrayWithObject:parametersDictionary];
//    
//    [manager POST:address parameters:arrayParametrs progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"success!");
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"error: %@", error);
//    }];
    
    
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    
//    NSString *address =
//    @"http://api.dev"
//    "/v1/codes/all";
////    "/v1/codes/all";
////    "/v1/codes/findByCode/5555";
////    @"http://api.dev/v1/codes/1";
////    @"http://api.dev/v1/codes/synchronization";
////    @"http://api.dev/v1/codes/use/555/1/qr";
//    
//    NSURL *URL = [NSURL URLWithString:address];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    
//    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//        } else {
//            NSLog(@"%@ %@", response, responseObject);
//        }
//    }];
//    [dataTask resume];
    
    //*
//    NSURL *URL = [NSURL URLWithString:@"http://api.dev"];
//    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:URL];
//    [manager POST:@"/v1/codes/use/5556/1/qr" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"");
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"");
//    }];
//              GET:@"/v1/codes/1" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
     
//        NSLog(@"");
     
//        [resources addObjectsFromArray:responseObject[@"resources"]];
//        
//        [manager SUBSCRIBE:@"/resources" usingBlock:^(NSArray *operations, NSError *error) {
//            for (AFJSONPatchOperation *operation in operations) {
//                switch (operation.type) {
//                    case AFJSONAddOperationType:
//                        [resources addObject:operation.value];
//                        break;
//                    default:
//                        break;
//                }
//            }
//        } error:nil];
//    } failure:nil];
 //    */
     
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[DBManager sharedManager] saveContext];
}

#pragma mark - Private

- (void)configureApperance {
    {
        NSDictionary *appearanseAttribtutes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
        [[UINavigationBar appearance] setTitleTextAttributes:appearanseAttribtutes];
        [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
        [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
        [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    }
    {
        NSDictionary *appearanseAttribtutes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
        [[UIBarButtonItem appearance] setTitleTextAttributes:appearanseAttribtutes forState:UIControlStateNormal];
        [[UIBarButtonItem appearance] setTintColor:[UIColor blackColor]];
    }
    {
        [[UITableViewCell appearance] setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
}


@end
