//
//  AddViewController.h
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 18/04/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, ZBarReaderDelegate> {
    NSManagedObjectContext *managedObjectContext;
}

@property (strong, nonatomic) MKNetworkOperation *lookupOperation;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

// Form fields
@property (nonatomic, retain) IBOutlet UITextField *ISBN;
@property (nonatomic, retain) IBOutlet UITextField *author;
@property (nonatomic, retain) IBOutlet UITextView *comicsTitle;
@property (nonatomic, retain) IBOutlet UITextField *volume;
@property (nonatomic, retain) IBOutlet UITextField *publisher;
@property (nonatomic, retain) IBOutlet UITextField *height;
@property (nonatomic, retain) IBOutlet UITextField *width;
@property (nonatomic, retain) IBOutlet UITextField *language;
@property (nonatomic, retain) IBOutlet UITextField *price;
@property (nonatomic, retain) IBOutlet UITextField *nbPages;
@property (nonatomic, retain) IBOutlet UITextField *publicationDate;

-(void)showLoadingView;
-(void)removeLoadingView;
-(NSString*)getCm:(NSString*)value;
-(IBAction)lookUp:(id)sender;
-(IBAction)addComics:(id)sender;
-(void)dismissKeyboard;
-(IBAction)scan:(id)sender;
-(void)lookupWithCode:(NSString*)code;

@end
