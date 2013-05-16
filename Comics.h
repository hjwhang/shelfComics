//
//  Comics.h
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 14/05/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Comics : NSManagedObject

@property (nonatomic, retain) NSString * volume;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * isbn;
@property (nonatomic, retain) NSString * publisher;
@property (nonatomic, retain) NSString * publicationDate;
@property (nonatomic, retain) NSString * width;
@property (nonatomic, retain) NSString * height;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * nbPages;

@end
