//
//  NetworkEngine.h
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 22/04/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

@interface NetworkEngine : MKNetworkEngine

typedef void (^ItemResponseBlock)(NSString *response);

/*
 * Launch the http request to Amazon Product API
 */
-(MKNetworkOperation*) itemForUPC:(NSString*)UPC completionHandler:(ItemResponseBlock) completionBlock errorHandler:(MKNKErrorBlock) errorBlock;

/*
 * Generate the URL at the right format for Amazon (with signature and everything)
 */
-(NSString*) getURLFormated:(NSString*)UPC;

@end
