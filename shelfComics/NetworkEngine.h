//
//  NetworkEngine.h
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 22/04/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

@interface NetworkEngine : MKNetworkEngine

typedef void (^ItemResponseBlock)(NSString *response);

-(MKNetworkOperation*) itemForUPC:(NSString*)UPC completionHandler:(ItemResponseBlock) completionBlock errorHandler:(MKNKErrorBlock) errorBlock;

@end
