//
//  AddViewController.h
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 18/04/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) MKNetworkOperation *lookupOperation;

// Form fields
@property (nonatomic, retain) IBOutlet UITextField *ISBN;
@property (nonatomic, retain) IBOutlet UITextField *author;
@property (nonatomic, retain) IBOutlet UITextField *comicsTitle;

-(void)showLoadingView;
-(void)removeLoadingView;

@end
