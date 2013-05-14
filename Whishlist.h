//
//  Whishlist.h
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 14/05/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Whishlist : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSManagedObject *relationship;

@end
