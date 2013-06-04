//
//  SaveiCloud.h
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 27/05/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SaveiCloud : NSObject {
    NSManagedObjectContext *managedObjectContext;
    NSMutableArray *comics;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *comics;

@end
