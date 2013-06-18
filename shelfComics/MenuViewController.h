//
//  MenuViewController.h
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 18/04/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UITableViewController <UIAlertViewDelegate>

@property (strong) NSMetadataQuery *query;

/*
 * Is used to go back home without instantiating a new instance of HomeViewController
 */
- (void)backHome:(UIButton *)sender;

-(void)backupDatas;
-(void)uploadDatas;
-(void)loadDocument;
-(void)loadData:(NSMetadataQuery*)query;
-(void)printLoadingView;
-(void)hideLoadingView;

@end
