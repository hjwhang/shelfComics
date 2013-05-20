//
//  ComicsViewController.h
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 20/05/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComicsViewController : UITableViewController {
    NSManagedObjectContext *managedObjectContext;
    NSMutableArray *comics;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *comics;

@end
