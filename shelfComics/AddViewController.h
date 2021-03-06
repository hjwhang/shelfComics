//
//  AddViewController.h
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 18/04/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface AddViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, ZBarReaderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate> {
    NSManagedObjectContext *managedObjectContext;
}

@property (strong, nonatomic) MKNetworkOperation *lookupOperation;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

// File properties
@property (nonatomic, retain) UIImage *imageToSave;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, retain) NSData *thumbnailData;

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
@property (nonatomic, retain) IBOutlet UIButton *cover;

// Tools
-(void)showLoadingView;
-(void)removeLoadingView;
-(NSString*)getCm:(NSString*)value;
-(void)dismissKeyboard;
-(void)lookupWithCode:(NSString*)code;
-(void)parsing:(NSDictionary*)response;
+(CGSize)thumbnailSize;
-(void)setThumbnailDataForImage:(UIImage*)image;
-(void)addPhoto;
-(void)pickPhoto;

// Actions
-(IBAction)lookUp:(id)sender;
-(IBAction)addComics:(id)sender;
-(IBAction)scan:(id)sender;
-(IBAction)takePhoto:(id)sender;

@end
