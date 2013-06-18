//
//  AddViewController.m
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 18/04/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import "AddViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "Comics.h"

@interface AddViewController ()

@property (readwrite) IBOutlet UIBarButtonItem *revealButtonItem;
@property (nonatomic, retain) IBOutlet UIScrollView *mainScrollView;

@end

static int nbFailures = 7;
static bool loadingViewStatus = NO;
static int imageComingFrom = 0; // 0 == scan barcode ; 1 == cover picture

@implementation AddViewController

@synthesize ISBN, comicsTitle, author, volume, publisher, height, width, language, nbPages, price, publicationDate, cover;
@synthesize managedObjectContext;
@synthesize imageToSave, thumbnail;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom implementation
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    [self.revealButtonItem setTarget: self.revealViewController];
    [self.revealButtonItem setAction: @selector(revealToggle:)];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    
    [self performSelector:@selector(adjustScrollViewContentSize) withObject:nil afterDelay:0.05];
    
    int paddingX = 5;
    int paddingY = 20;
    int corner = 5;
    float alpha = 0.5f;
    float border = 2.0f;
    
    self.comicsTitle.layer.cornerRadius = corner;
    [self.comicsTitle.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:alpha] CGColor]];
    [self.comicsTitle.layer setBorderWidth:border];
    self.comicsTitle.clipsToBounds = YES;
    
    self.volume.layer.cornerRadius = corner;
    [self.volume.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:alpha] CGColor]];
    [self.volume.layer setBorderWidth:border];
    self.volume.clipsToBounds = YES;
    self.volume.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingX, paddingY)];;
    self.volume.leftViewMode = UITextFieldViewModeAlways;
    
    self.ISBN.layer.cornerRadius = corner;
    [self.ISBN.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:alpha] CGColor]];
    [self.ISBN.layer setBorderWidth:border];
    self.ISBN.clipsToBounds = YES;
    self.ISBN.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingX, paddingY)];
    self.ISBN.leftViewMode = UITextFieldViewModeAlways;
    
    self.publisher.layer.cornerRadius = corner;
    [self.publisher.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:alpha] CGColor]];
    [self.publisher.layer setBorderWidth:border];
    self.publisher.clipsToBounds = YES;
    self.publisher.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingX, paddingY)];;
    self.publisher.leftViewMode = UITextFieldViewModeAlways;
    
    self.height.layer.cornerRadius = corner;
    [self.height.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:alpha] CGColor]];
    [self.height.layer setBorderWidth:border];
    self.height.clipsToBounds = YES;
    self.height.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingX, paddingY)];;
    self.height.leftViewMode = UITextFieldViewModeAlways;
    
    self.width.layer.cornerRadius = corner;
    [self.width.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:alpha] CGColor]];
    [self.width.layer setBorderWidth:border];
    self.width.clipsToBounds = YES;
    self.width.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingX, paddingY)];;
    self.width.leftViewMode = UITextFieldViewModeAlways;
    
    self.language.layer.cornerRadius = corner;
    [self.language.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:alpha] CGColor]];
    [self.language.layer setBorderWidth:border];
    self.language.clipsToBounds = YES;
    self.language.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingX, paddingY)];;
    self.language.leftViewMode = UITextFieldViewModeAlways;
    
    self.nbPages.layer.cornerRadius = corner;
    [self.nbPages.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:alpha] CGColor]];
    [self.nbPages.layer setBorderWidth:border];
    self.nbPages.clipsToBounds = YES;
    self.nbPages.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingX, paddingY)];;
    self.nbPages.leftViewMode = UITextFieldViewModeAlways;
    
    self.price.layer.cornerRadius = corner;
    [self.price.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:alpha] CGColor]];
    [self.price.layer setBorderWidth:border];
    self.price.clipsToBounds = YES;
    self.price.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingX, paddingY)];;
    self.price.leftViewMode = UITextFieldViewModeAlways;
    
    self.publicationDate.layer.cornerRadius = corner;
    [self.publicationDate.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:alpha] CGColor]];
    [self.publicationDate.layer setBorderWidth:border];
    self.publicationDate.clipsToBounds = YES;
    self.publicationDate.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingX, paddingY)];;
    self.publicationDate.leftViewMode = UITextFieldViewModeAlways;
    
    self.author.layer.cornerRadius = corner;
    [self.author.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:alpha] CGColor]];
    [self.author.layer setBorderWidth:border];
    self.author.clipsToBounds = YES;
    self.author.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingX, paddingY)];;
    self.author.leftViewMode = UITextFieldViewModeAlways;
    
    self.ISBN.delegate = self;
    self.author.delegate = self;
    self.comicsTitle.delegate = self;
    self.volume.delegate = self;
    self.publisher.delegate = self;
    self.height.delegate = self;
    self.width.delegate = self;
    self.language.delegate = self;
    self.nbPages.delegate = self;
    self.price.delegate = self;
    self.publicationDate.delegate = self;
    
    UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTap:)];
    tgr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tgr];
}

// Tweak de merde à cause du resizeWithOldSuperviewSize qui m'empèche de resizer dans le viewDidLoad. Sais pas pourquoi ;(
-(void)adjustScrollViewContentSize {
    self.mainScrollView.contentSize = CGSizeMake(320, 550);
}

-(void)viewDidDisappear:(BOOL)animated {
        [self.lookupOperation cancel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

-(IBAction)lookUp:(id)sender {
    
    [self dismissKeyboard];
    
    
    if ([self.ISBN.text isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ISBN missing Title", nil)
                                    message:NSLocalizedString(@"ISBN missing Msg", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Close", @"")
                          otherButtonTitles:nil] show];
    } else {
    
        [self showLoadingView];
    
        if (nbFailures != 0) {
            self.lookupOperation = [ApplicationDelegate.networkEngine itemForUPC:self.ISBN.text
                                                           completionHandler:^(NSDictionary *response) {
                                                               
                                                               [self removeLoadingView];
                                                               [self parsing:response];
                                                               
                                                           }
                                                                errorHandler:^(NSError* error) {
                                                                    nbFailures--;
                                                                    
                                                                    DLog(@"%@\t%@\t%@\t%@", [error localizedDescription], [error localizedFailureReason],
                                                                         [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
                                                                    
                                                                    [self lookUp:nil];
                                                                }
                                ];
        } else {
            [self removeLoadingView];
            nbFailures = 7;
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed Title", nil)
                                        message:NSLocalizedString(@"Failed Msg", nil)
                                       delegate:nil
                              cancelButtonTitle:@"Close"
                              otherButtonTitles:nil] show];
        }
    }
}

-(void)lookupWithCode:(NSString *)code {
    
    [self showLoadingView];
    
    if (nbFailures != 0) {
        self.lookupOperation = [ApplicationDelegate.networkEngine itemForUPC:code
                                                           completionHandler:^(NSDictionary *response) {
                                                               
                                                               [self removeLoadingView];
                                                               [self parsing:response];
                                                               
                                                           }
                                                                errorHandler:^(NSError* error) {
                                                                    [self removeLoadingView];
                                                                    nbFailures--;
                                                                    
                                                                    DLog(@"%@\t%@\t%@\t%@", [error localizedDescription], [error localizedFailureReason],
                                                                         [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
                                                                    [self lookupWithCode:code];
                                                                }
                                ];
    } else {
        [self removeLoadingView];
        nbFailures = 7;
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed Title", nil)
                                    message:NSLocalizedString(@"Failed Msg", nil)
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles:nil] show];
    }
}

-(NSString*)getCm:(NSString*)value {
    float initialValue = [value floatValue];
    initialValue *= 2.54f;
    initialValue /= 100.0f;
    return [NSString stringWithFormat:@"%.02f", initialValue];
}

-(IBAction)scan:(id)sender {
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentViewController:reader animated:YES completion:nil];
}

-(void)parsing:(NSDictionary *)response {

    if (![[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Request"] objectForKey:@"Errors"] isKindOfClass:[NSDictionary class]]) {
    
        if ([[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] isKindOfClass:[NSArray class]]) {
            int goodIndex=0;
            
            for (int i=0; i<[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] count]; i++) {
                if ([[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:i] objectForKey:@"Binding"] objectForKey:@"text"] isEqualToString:@"Paperback"]) {
                    goodIndex = i;
                    break;
                }
            }
            
            [self.ISBN setText:[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:goodIndex] objectForKey:@"ItemAttributes"] objectForKey:@"ISBN"] objectForKey:@"text"]];
            
            if ([[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:goodIndex] objectForKey:@"ItemAttributes"] objectForKey:@"Author"] isKindOfClass:[NSArray class]]) {
                [self.author setText:[[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:goodIndex] objectForKey:@"ItemAttributes"] objectForKey:@"Author"] objectAtIndex:0] objectForKey:@"text"]];
            } else {
                [self.author setText:[[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:goodIndex] objectAtIndex:goodIndex] objectForKey:@"ItemAttributes"] objectForKey:@"Author"] objectForKey:@"text"]];
            }
            
            [self.comicsTitle setText:[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:goodIndex] objectForKey:@"ItemAttributes"] objectForKey:@"Title"] objectForKey:@"text"]];
            
            [self.publisher setText:[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:goodIndex] objectForKey:@"ItemAttributes"] objectForKey:@"Publisher"] objectForKey:@"text"]];
            
            [self.height setText:[self getCm:[[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:goodIndex] objectForKey:@"ItemAttributes"] objectForKey:@"ItemDimensions"] objectForKey:@"Height"] objectForKey:@"text"]]];
            
            [self.width setText:[self getCm:[[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:goodIndex] objectForKey:@"ItemAttributes"] objectForKey:@"ItemDimensions"] objectForKey:@"Length"] objectForKey:@"text"]]];
            
            [self.nbPages setText:[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:goodIndex] objectForKey:@"ItemAttributes"] objectForKey:@"NumberOfPages"] objectForKey:@"text"]];
            
            [self.language setText:[[[[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:goodIndex] objectForKey:@"ItemAttributes"] objectForKey:@"Languages"] objectForKey:@"Language"] objectAtIndex:0] objectForKey:@"Name"] objectForKey:@"text"]];
            
            [self.price setText:[[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:goodIndex] objectForKey:@"ItemAttributes"] objectForKey:@"ListPrice"] objectForKey:@"FormattedPrice"] objectForKey:@"text"]];
            
            [self.publicationDate setText:[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectAtIndex:goodIndex] objectForKey:@"ItemAttributes"] objectForKey:@"PublicationDate"] objectForKey:@"text"]];
            
            nbFailures = 7;
            
        } else {
            
            [self.ISBN setText:[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"ISBN"] objectForKey:@"text"]];
            
            if ([[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"Author"] isKindOfClass:[NSArray class]]) {
                [self.author setText:[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"Author"] objectAtIndex:0] objectForKey:@"text"]];
            } else {
                [self.author setText:[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"Author"] objectForKey:@"text"]];
            }
            
            [self.comicsTitle setText:[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"Title"] objectForKey:@"text"]];
            [self.publisher setText:[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"Publisher"] objectForKey:@"text"]];
            [self.height setText:[self getCm:[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"ItemDimensions"] objectForKey:@"Height"] objectForKey:@"text"]]];
            [self.width setText:[self getCm:[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"ItemDimensions"] objectForKey:@"Length"] objectForKey:@"text"]]];
            [self.nbPages setText:[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"NumberOfPages"] objectForKey:@"text"]];
            [self.language setText:[[[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"Languages"] objectForKey:@"Language"] objectAtIndex:0] objectForKey:@"Name"] objectForKey:@"text"]];
            [self.price setText:[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"ListPrice"] objectForKey:@"FormattedPrice"] objectForKey:@"text"]];
            [self.publicationDate setText:[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"PublicationDate"] objectForKey:@"text"]];
            
            nbFailures = 7;
        }
    } else {
        UIAlertView *noResult = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noResult Title", nil)
                                                           message:NSLocalizedString(@"noResult Msg", nil)
                                                          delegate:nil
                                                 cancelButtonTitle:@"Close"
                                                 otherButtonTitles:nil];
        [noResult show];
    }
}

-(IBAction)addComics:(id)sender {
    
    [self dismissKeyboard];
    [UIView animateWithDuration:.2 animations:^{
        [self.mainScrollView setFrame:CGRectMake(0, 0, 320, 500)];
    }];
    
    int roror = 0;
    
    if ([self.comicsTitle.text isEqualToString:@""] || (self.comicsTitle.text == nil)) {
        roror = 1;
    } else if ([self.ISBN.text isEqualToString:@""] || (self.ISBN.text == nil)) {
        roror = 2;
    }
    
    if (roror != 0) {
        switch (roror) {
            case 1:
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Title Missing Tile", nil)
                                            message:NSLocalizedString(@"Title Missing Msg", nil)
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                  otherButtonTitles:nil] show];
                break;
            case 2:
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ISBN Missing Title", nil)
                                            message:NSLocalizedString(@"ISBN Missing Msg", nil)
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                  otherButtonTitles:nil] show];
                break;
            default:
                break;
        }
    } else {
        // Test if already exist
        NSError *fetchError;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comics" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchLimit:1];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"isbn == %@", self.ISBN.text]];
        if ([managedObjectContext countForFetchRequest:fetchRequest error:&fetchError]) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Comics exists Title", nil)
                                        message:NSLocalizedString(@"Comics exists Msg", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Close", @"")
                              otherButtonTitles:nil] show];
        } else {
            
            Comics *comics = [NSEntityDescription insertNewObjectForEntityForName:@"Comics" inManagedObjectContext:managedObjectContext];
            
            [comics setValue:self.comicsTitle.text forKey:@"title"];
            [comics setValue:self.volume.text forKey:@"volume"];
            [comics setValue:self.ISBN.text forKey:@"isbn"];
            [comics setValue:self.author.text forKey:@"author"];
            [comics setValue:self.publisher.text forKey:@"publisher"];
            [comics setValue:self.publicationDate.text forKey:@"publicationDate"];
            [comics setValue:self.height.text forKey:@"height"];
            [comics setValue:self.width.text forKey:@"width"];
            [comics setValue:self.price.text forKey:@"price"];
            [comics setValue:self.language.text forKey:@"language"];
            [comics setValue:self.nbPages.text forKey:@"nbPages"];
            
            NSString *imagePath = pathInDocumentDirectory(self.ISBN.text);
            NSData *imageData = UIImageJPEGRepresentation(imageToSave, 0.5);
            [imageData writeToFile:imagePath atomically:YES];
            
            NSString *thumbnailName = [self.ISBN.text stringByAppendingString:@"Thumbnail"];
            
            NSString *thumbnailPath = pathInDocumentDirectory(thumbnailName);
            NSData *thumbnailData = UIImagePNGRepresentation(thumbnail);
            [thumbnailData writeToFile:thumbnailPath atomically:YES];
            
            NSError *error;
            if (![managedObjectContext save:&error]) {
                DLog(@"Core Data Error %@", error);
            } else {
                UIImageView *check = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button-round-tick-ok-icon.png"]];
                [check setFrame:CGRectMake(20, 20, 50, 50)];
                [self.view addSubview:check];
                
                [UIView animateWithDuration:1.0f
                                      delay:0.5f
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     [check setAlpha:0.0f];}
                                 completion:nil];
                
                self.comicsTitle.text = @"";
                self.volume.text = @"";
                self.ISBN.text = @"";
                self.author.text = @"";
                self.publicationDate.text = @"";
                self.publisher.text = @"";
                self.height.text = @"";
                self.width.text = @"";
                self.price.text = @"";
                self.language.text = @"";
                self.nbPages.text = @"";
                [self.cover setBackgroundImage:[UIImage imageNamed:@"no_file.jpg"] forState:UIControlStateNormal];
            }
            
#if PREPROD
            NSEntityDescription *comicsEntity = [NSEntityDescription entityForName:@"Comics" inManagedObjectContext:managedObjectContext];
            
            NSFetchRequest *fetchAllrecords = [[NSFetchRequest alloc] init];
            [fetchAllrecords setEntity:comicsEntity];
            NSSortDescriptor *keyDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
            NSArray *sortDescriptors = [NSArray arrayWithObject:keyDescriptor];
            [fetchAllrecords setSortDescriptors:sortDescriptors];
            [fetchAllrecords setReturnsObjectsAsFaults:NO];
            
            NSError *err;
            NSMutableArray *records = [[managedObjectContext executeFetchRequest:fetchAllrecords error:&err] mutableCopy];
            if (!records)
                DLog(@"A BIG ERROR OCCURS WHILE GETTING ALL RECORDS: %@", err);
            DLog(@"RESULTS %@", records);
#endif
        }
    }
}


#pragma mark - Photo methods

-(IBAction)takePhoto:(id)sender {
    
    UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:NSLocalizedString(@"Camera", nil), NSLocalizedString(@"Gallery", nil), nil];
    [as showInView:self.view.superview];
}

-(void)addPhoto {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *pick = [[UIImagePickerController alloc] init];
        pick.sourceType = UIImagePickerControllerSourceTypeCamera;
        pick.allowsEditing = NO;
        pick.mediaTypes = [NSArray arrayWithObject:(NSString*) kUTTypeImage];
        pick.delegate = self;
        [self presentModalViewController:pick animated:YES];
    } else {
        UIAlertView *noPhoto = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noPhoto Title", nil)
                                                          message:NSLocalizedString(@"noPhoto Msg", nil)
                                                         delegate:nil
                                                cancelButtonTitle:@"Close"
                                                otherButtonTitles:nil];
        [noPhoto show];
    }
    imageComingFrom = 1;
}

-(void)pickPhoto {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *pick = [[UIImagePickerController alloc] init];
        pick.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pick.allowsEditing = NO;
        pick.mediaTypes = [NSArray arrayWithObject:(NSString*) kUTTypeImage];
        pick.delegate = self;
        [self presentModalViewController:pick animated:YES];
    }
    imageComingFrom = 1;
}

- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info {
    if (imageComingFrom == 0) {
        // ADD: get the decode results
        id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
        ZBarSymbol *symbol = nil;
        
        for(symbol in results)
            // EXAMPLE: just grab the first barcode
            break;
        
        // EXAMPLE: do something useful with the barcode data
        
        [self lookupWithCode:symbol.data];
        
        // EXAMPLE: do something useful with the barcode image
        // resultImage.image = [info objectForKey: UIImagePickerControllerOriginalImage];
        
        // ADD: dismiss the controller (NB dismiss from the *reader*!)
        [reader dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.imageToSave = [image copy];
        [reader dismissModalViewControllerAnimated:NO];
        if (image) {
            [self.cover setBackgroundImage:image forState:UIControlStateNormal];
        }
        
        [self setThumbnailDataForImage:image];
        
        imageComingFrom = 0;
    }
    [self performSelector:@selector(adjustScrollViewContentSize) withObject:nil afterDelay:0.05];
}

-(void)setThumbnailDataForImage:(UIImage *)image {
    CGSize originalImageSize = [image size];
    CGRect newRect;
    
    newRect.origin = CGPointZero;
    newRect.size = [[self class] thumbnailSize];
    
    float ratio = MAX(newRect.size.width/originalImageSize.width,
                      newRect.size.height/originalImageSize.height);
    UIGraphicsBeginImageContext(newRect.size);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0f];
    [path addClip];
    
    CGRect projectRect;
    projectRect.size.width = ratio * originalImageSize.width;
    projectRect.size.height = ratio * originalImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0f;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0f;
    
    [image drawInRect:projectRect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    self.thumbnail = [smallImage copy];
    
    UIGraphicsEndImageContext();
}

+(CGSize)thumbnailSize {
    return CGSizeMake(63, 85);
}

#pragma mark - Loading View

-(void)showLoadingView {
    
    if (!loadingViewStatus) {
        UIView *loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
        [loadingView setBackgroundColor:[UIColor lightGrayColor]];
        [loadingView setAlpha:0.8];
        
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 220, 100, 100)];
        [loadingLabel setText:NSLocalizedString(@"Loading", nil)];
        [loadingLabel setTextAlignment:NSTextAlignmentCenter];
        [loadingLabel setTextColor:[UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:1.0f]];
        [loadingLabel setBackgroundColor:[UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.0]];
        [loadingView addSubview:loadingLabel];
        
        UIActivityIndicatorView *loadingActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [loadingActivity startAnimating];
        [loadingActivity setCenter:CGPointMake(160, 225)];
        [loadingView addSubview:loadingActivity];
        
        [loadingView setTag:[kLoadingViewTag intValue]];
        
        [self.view addSubview:loadingView];
        loadingViewStatus = YES;
    }
}

-(void)removeLoadingView {
    for (UIView *subview in [self.view subviews]) {
        if (subview.tag == [kLoadingViewTag intValue]) {
            [subview removeFromSuperview];
        }
    }
    loadingViewStatus = NO;
    [self performSelector:@selector(adjustScrollViewContentSize) withObject:nil afterDelay:0.05];
}


#pragma mark - TextField methods

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (!CGAffineTransformIsIdentity(self.view.transform)) {
        [UIView animateWithDuration:.2 animations:^{
            self.view.transform = CGAffineTransformIdentity;
        }];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.volume)
        [self.ISBN becomeFirstResponder];
    else if (textField == self.ISBN)
        [self.author becomeFirstResponder];
    else if (textField == self.author)
        [self.publisher becomeFirstResponder];
    else if (textField == publisher)
        [self.height becomeFirstResponder];
    else if (textField == self.height)
        [self.width becomeFirstResponder];
    else if (textField == self.width)
        [self.language becomeFirstResponder];
    else if (textField == self.language)
        [self.price becomeFirstResponder];
    else if (textField == self.price)
        [self.nbPages becomeFirstResponder];
    else if (textField == self.nbPages)
        [self.publicationDate becomeFirstResponder];
    else {
        [textField resignFirstResponder];
        [UIView animateWithDuration:.2 animations:^{
            [self.mainScrollView setFrame:CGRectMake(0, 0, 320, 500)];
        }];
    }
    
    return YES;
}   

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ((self.view.center.y - textField.center.y) < 0) {
        
        [self.mainScrollView setFrame:CGRectMake(0, 0, 320, 300)];
        
        [self.mainScrollView scrollRectToVisible:CGRectMake(0, textField.center.y, self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height)
                                        animated:YES];
        
        /*
        if (CGAffineTransformIsIdentity(self.view.transform)) {
            [UIView animateWithDuration:.2 animations:^{
                //self.view.transform = CGAffineTransformMakeTranslation(0.f, -216.f);
                self.mainScrollView.transform = CGAffineTransformMakeTranslation(0.f, -216.f);
            }];
        }*/
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL shouldChangeText = YES;
    
    if ([text isEqualToString:@"\n"]) {
        [self.volume becomeFirstResponder];
        shouldChangeText = NO;  
    }
    
    return shouldChangeText;  
}

-(void) _handleTap:(UITapGestureRecognizer*)tgr
{
    [self dismissKeyboard];
    
    [UIView animateWithDuration:.2 animations:^{
        [self.mainScrollView setFrame:CGRectMake(0, 0, 320, 500)];
    }];
}

-(void)dismissKeyboard {
    [self.ISBN resignFirstResponder];
    [self.author resignFirstResponder];
    [self.comicsTitle resignFirstResponder];
    [self.volume resignFirstResponder];
    [self.publisher resignFirstResponder];
    [self.height resignFirstResponder];
    [self.width resignFirstResponder];
    [self.language resignFirstResponder];
    [self.nbPages resignFirstResponder];
    [self.price resignFirstResponder];
    [self.publicationDate resignFirstResponder];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    } else {
        switch (buttonIndex-actionSheet.firstOtherButtonIndex) {
            case 0:
                [self addPhoto];
                break;
            case 1:
                [self pickPhoto];
                break;
            default:
                break;
        }
    }
}

@end
