//
//  ComicsViewController.h
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 20/05/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComicsViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate> {
    NSManagedObjectContext *managedObjectContext;
    NSMutableArray *comics;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *comics;
@property (nonatomic, retain) NSMutableDictionary *sortedComics;
@property (nonatomic, retain) NSMutableDictionary *letters;
@property (nonatomic, retain) NSArray *sortedKeys;

@property (nonatomic, strong) NSMutableArray *searchResults;
@property IBOutlet UISearchBar *comicsSearchBar;

@end
