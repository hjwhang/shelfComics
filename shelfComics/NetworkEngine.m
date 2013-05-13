//
//  NetworkEngine.m
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 22/04/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import "NetworkEngine.h"
#import "Constants.h"
#import <AWSRuntime/AWSRuntime.h>
#import "XMLReader.h"


@implementation NetworkEngine

#pragma mark - Network methods

-(MKNetworkOperation*) itemForUPC:(NSString *)UPC completionHandler:(ItemResponseBlock)completionBlock errorHandler:(MKNKErrorBlock)errorBlock {
    
    NSString *path = [self getURLFormated:UPC];
    
    // Test sur twitter API
    //path = @"1/statuses/user_timeline.json?include_entities=true&include_rts=true&screen_name=alienfamily&count=1";
    
    MKNetworkOperation *op = [self operationWithPath:path
                                              params:nil
                                          httpMethod:@"GET"];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation)
     {
         NSString *value = [completedOperation responseString];
         DLog(@"Response in NSString --> %@", value);
         
         NSError *error = nil;
         
         NSDictionary *responseDico = [XMLReader dictionaryForXMLString:value error:&error];
         DLog(@"REMY %@", responseDico);
         
         if([completedOperation isCachedResponse]) {
             DLog(@"Data from cache %@", [completedOperation responseString]);
         }
         else {
             DLog(@"Data from server %@", [completedOperation responseString]);
         }
         
         completionBlock(value);
         
     } errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation:op];
    
    return op;    
}


#pragma mark - URLs methods

-(NSString*) getURLFormated:(NSString*)UPC {

    // Appending parametters and setting timestamp
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            kService, @"Service",
                            kResponseGroup, @"ResponseGroup",
                            kAccessKey, @"AWSAccessKeyId",
                            kOperation, @"Operation",
                            UPC, @"ItemId",
                            kAssociateTag, @"AssociateTag",
                            kVersion, @"Version", nil];

    NSMutableString *brutURL = [[NSMutableString alloc] initWithString:@""];

    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         [brutURL appendFormat:@"%@=%@&", key, obj];
     }];

    [brutURL appendString:@"Timestamp="];
    
    NSDate *timestamp= [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    
    [brutURL appendString:[formatter stringFromDate:timestamp]];
    
    DLog(@"\n\n\nURL BRUTE %@\n\n\n", brutURL);
    
    // Encoding and sorting parameters
    
    NSString *encodeURL = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                (CFStringRef)(brutURL),
                                                                                                NULL,
                                                                                                (CFStringRef)@",: ",
                                                                                                CFStringConvertNSStringEncodingToEncoding(NSASCIIStringEncoding)));
    
    
    DLog(@"\n\n\nURL ENCODEE %@\n\n\n", encodeURL);
    
    NSMutableArray *array = [[encodeURL componentsSeparatedByString:@"&"] mutableCopy];
    
    NSArray *sortedArray;
    
    sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = a;
        NSString *second = b;
        return [first compare:second];
    }];
    
    DLog(@"\n\n\nURL CLASSEE %@\n\n\n", sortedArray);
    
    NSString *rejoinParameters = @"";
    
    for (int i=0; i<[sortedArray count]; i++) {
        rejoinParameters = [rejoinParameters stringByAppendingString:[sortedArray objectAtIndex:i]];
        if (i != ([sortedArray count]-1))
            rejoinParameters = [rejoinParameters stringByAppendingString:@"&"];
    }

    // Signing request
    
    NSString *toSign = @"GET\nwebservices.amazon.com\n/onca/xml\n";
    
    toSign = [toSign stringByAppendingString:rejoinParameters];
    
    NSData *dataToSign = [toSign dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *signature = [AmazonAuthUtils HMACSign:dataToSign withKey:kPrivateKey usingAlgorithm:kCCHmacAlgSHA256];
    
    NSString *lastURL = [rejoinParameters stringByAppendingString:@"&Signature="];
    lastURL = [lastURL stringByAppendingString:signature];
    lastURL = [@"/onca/xml?" stringByAppendingString:lastURL];
    
    DLog(@"URL generated %@", lastURL);
    
    return lastURL;
}

@end
