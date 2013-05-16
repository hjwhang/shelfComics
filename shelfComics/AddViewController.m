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
#import <QuartzCore/QuartzCore.h>

@interface AddViewController ()

@property (readwrite) IBOutlet UIBarButtonItem *revealButtonItem;
@property (nonatomic, retain) IBOutlet UIScrollView *mainScrollView;

@end

static int nbFailures = 7;

@implementation AddViewController

@synthesize ISBN, comicsTitle, author, ASIN, publisher, height, width, language, nbPages, price, publicationDate;
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    self.comicsTitle.layer.cornerRadius = 5;
    [self.comicsTitle.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.comicsTitle.layer setBorderWidth:2.0];
    self.comicsTitle.clipsToBounds = YES;
    
    self.ASIN.layer.cornerRadius = 5;
    [self.ASIN.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.ASIN.layer setBorderWidth:2.0];
    self.ASIN.clipsToBounds = YES;
    
    self.ISBN.layer.cornerRadius = 5;
    [self.ISBN.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.ISBN.layer setBorderWidth:2.0];
    self.ISBN.clipsToBounds = YES;
    
    self.publisher.layer.cornerRadius = 5;
    [self.publisher.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.publisher.layer setBorderWidth:2.0];
    self.publisher.clipsToBounds = YES;
    
    self.height.layer.cornerRadius = 5;
    [self.height.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.height.layer setBorderWidth:2.0];
    self.height.clipsToBounds = YES;
    
    self.width.layer.cornerRadius = 5;
    [self.width.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.width.layer setBorderWidth:2.0];
    self.width.clipsToBounds = YES;
    
    self.language.layer.cornerRadius = 5;
    [self.language.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.language.layer setBorderWidth:2.0];
    self.language.clipsToBounds = YES;
    
    self.nbPages.layer.cornerRadius = 5;
    [self.nbPages.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.nbPages.layer setBorderWidth:2.0];
    self.nbPages.clipsToBounds = YES;
    
    self.price.layer.cornerRadius = 5;
    [self.price.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.price.layer setBorderWidth:2.0];
    self.price.clipsToBounds = YES;
    
    self.publicationDate.layer.cornerRadius = 5;
    [self.publicationDate.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.publicationDate.layer setBorderWidth:2.0];
    self.publicationDate.clipsToBounds = YES;
    
    self.author.layer.cornerRadius = 5;
    [self.author.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.author.layer setBorderWidth:2.0];
    self.author.clipsToBounds = YES;
    
    self.ISBN.delegate = self;
    self.author.delegate = self;
    //self.comicsTitle.delegate = self;
    self.ASIN.delegate = self;
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

-(IBAction)lookUp:(id)sender {
    
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
                                                               
                                                               [self.ISBN setText:[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"ISBN"] objectForKey:@"text"]];
                                                               
                                                               if ([[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"Author"] isKindOfClass:[NSArray class]]) {
                                                                   [self.author setText:[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"Author"] objectAtIndex:0] objectForKey:@"text"]];
                                                               } else {
                                                                   [self.author setText:[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"Author"] objectForKey:@"text"]];
                                                               }
                                                               
                                                               [self.comicsTitle setText:[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"Title"] objectForKey:@"text"]];
                                                               [self.ASIN setText:[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ASIN"] objectForKey:@"text"]];
                                                               [self.publisher setText:[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"Publisher"] objectForKey:@"text"]];
                                                               [self.height setText:[self getCm:[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"ItemDimensions"] objectForKey:@"Height"] objectForKey:@"text"]]];
                                                               [self.width setText:[self getCm:[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"ItemDimensions"] objectForKey:@"Length"] objectForKey:@"text"]]];
                                                               [self.nbPages setText:[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"NumberOfPages"] objectForKey:@"text"]];
                                                               [self.language setText:[[[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"Languages"] objectForKey:@"Language"] objectAtIndex:0] objectForKey:@"Name"] objectForKey:@"text"]];
                                                               [self.price setText:[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"ListPrice"] objectForKey:@"FormattedPrice"] objectForKey:@"text"]];
                                                               [self.publicationDate setText:[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"PublicationDate"] objectForKey:@"text"]];
                                                               
                                                               nbFailures = 7;
                                                           }
                                                                errorHandler:^(NSError* error) {
                                                                    [self removeLoadingView];
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

-(NSString*)getCm:(NSString*)value {
    float initialValue = [value floatValue];
    initialValue *= 2.54f;
    initialValue /= 100.0f;
    return [NSString stringWithFormat:@"%.02f", initialValue];
}

-(IBAction)addComics:(id)sender {
    
    [self dismissKeyboard];
    
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
            [comics setValue:self.ASIN.text forKey:@"asin"];
            [comics setValue:self.ISBN.text forKey:@"isbn"];
            [comics setValue:self.author.text forKey:@"author"];
            [comics setValue:self.publisher.text forKey:@"publisher"];
            [comics setValue:self.publicationDate.text forKey:@"publicationDate"];
            [comics setValue:self.height.text forKey:@"height"];
            [comics setValue:self.width.text forKey:@"width"];
            [comics setValue:self.price.text forKey:@"price"];
            [comics setValue:self.language.text forKey:@"language"];
            [comics setValue:self.nbPages.text forKey:@"nbPages"];
                
            NSError *error;
            if (![managedObjectContext save:&error])
                DLog(@"Core Data Error %@", error);
            
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

-(void)dismissKeyboard {
    [self.ISBN resignFirstResponder];
    [self.author resignFirstResponder];
    [self.comicsTitle resignFirstResponder];
    [self.ASIN resignFirstResponder];
    [self.publisher resignFirstResponder];
    [self.height resignFirstResponder];
    [self.width resignFirstResponder];
    [self.language resignFirstResponder];
    [self.nbPages resignFirstResponder];
    [self.price resignFirstResponder];
    [self.publicationDate resignFirstResponder];
}

#pragma mark -
#pragma mark Loading View

-(void)showLoadingView {
    
    UIView *loadingView = [[UIView alloc] initWithFrame:self.view.bounds];
    [loadingView setBackgroundColor:[UIColor lightGrayColor]];
    [loadingView setAlpha:0.8];
    
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 220, 100, 100)];
    [loadingLabel setText:@"Loading"];
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
}

-(void)removeLoadingView {
    for (UIView *subview in [self.view subviews]) {
        if (subview.tag == [kLoadingViewTag intValue]) {
            [subview removeFromSuperview];
        }
    }
    
    [self performSelector:@selector(adjustScrollViewContentSize) withObject:nil afterDelay:0.05];
}

#pragma mark - 
#pragma mark TextField methods

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (!CGAffineTransformIsIdentity(self.view.transform)) {
        [UIView animateWithDuration:.2 animations:^{
            self.view.transform = CGAffineTransformIdentity;
        }];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.ASIN)
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

-(void) _handleTap:(UITapGestureRecognizer*)tgr
{
    [self dismissKeyboard];
    
    [UIView animateWithDuration:.2 animations:^{
        [self.mainScrollView setFrame:CGRectMake(0, 0, 320, 500)];
    }];
}

@end
