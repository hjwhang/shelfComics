//
//  SaveiCloud.h
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 27/05/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SaveiCloud : UIDocument <UIAlertViewDelegate>

@property (strong) NSData *zipDataContent;

-(void)testiCloudAvailability;

@end
