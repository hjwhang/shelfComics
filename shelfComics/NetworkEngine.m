//
//  NetworkEngine.m
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 22/04/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import "NetworkEngine.h"

@implementation NetworkEngine

-(MKNetworkOperation*) itemForUPC:(NSString *)UPC completionHandler:(ItemResponseBlock)completionBlock errorHandler:(MKNKErrorBlock)errorBlock {
    
    MKNetworkOperation *op = [self operationWithPath:@"yopyop"
                                              params:nil
                                          httpMethod:@"GET"];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation)
     {
         // the completionBlock will be called twice.
         // if you are interested only in new values, move that code within the else block
         
         NSString *valueString = [[completedOperation responseString] componentsSeparatedByString:@","][1];
         DLog(@"%@", valueString);
         
         if([completedOperation isCachedResponse]) {
             DLog(@"Data from cache %@", [completedOperation responseString]);
         }
         else {
             DLog(@"Data from server %@", [completedOperation responseString]);
         }
         
         completionBlock(valueString);
         
     }errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
         
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;
    
}

@end
