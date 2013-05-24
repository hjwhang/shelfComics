//
//  ContentViewController.h
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 23/05/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comics.h"

@interface ContentViewController : UIViewController {
    NSManagedObjectContext *managedObjectContext;
    Comics *comicsToPrint;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) Comics *comicsToPrint;

// Details properties
@property (nonatomic, retain) IBOutlet UILabel *comicsTitle;
@property (nonatomic, retain) IBOutlet UILabel *publicationDate;
@property (nonatomic, retain) IBOutlet UILabel *publisher;
@property (nonatomic, retain) IBOutlet UILabel *dimensions;
@property (nonatomic, retain) IBOutlet UILabel *nbPages;
@property (nonatomic, retain) IBOutlet UILabel *volume;
@property (nonatomic, retain) IBOutlet UILabel *language;
@property (nonatomic, retain) IBOutlet UILabel *price;
@property (nonatomic, retain) IBOutlet UILabel *isbn;
@property (nonatomic, retain) IBOutlet UILabel *author;
@property (nonatomic, retain) IBOutlet UIImageView *thumbnail;
@property (nonatomic, retain) UIImage *cover;

-(void)zoom:(UITapGestureRecognizer*)tgr;

@end
