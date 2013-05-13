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
@property (nonatomic, retain) IBOutlet UITextField *ASIN;
@property (nonatomic, retain) IBOutlet UITextField *publisher;
@property (nonatomic, retain) IBOutlet UITextField *height;
@property (nonatomic, retain) IBOutlet UITextField *width;
@property (nonatomic, retain) IBOutlet UITextField *language;
@property (nonatomic, retain) IBOutlet UITextField *price;
@property (nonatomic, retain) IBOutlet UITextField *nbPages;
@property (nonatomic, retain) IBOutlet UITextField *publicationDate;

-(void)showLoadingView;
-(void)removeLoadingView;

@end
