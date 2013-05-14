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
    
    self.ISBN.delegate = self;
    self.author.delegate = self;
    self.comicsTitle.delegate = self;
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
        [[[UIAlertView alloc] initWithTitle:@"PFFFFF"
                                    message:@"Give me an ISBN number dude !!"
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
                                                               [self.author setText:[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"Author"] objectForKey:@"text"]];
                                                               [self.comicsTitle setText:[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"Title"] objectForKey:@"text"]];
                                                               [self.ASIN setText:[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ASIN"] objectForKey:@"text"]];
                                                               [self.publisher setText:[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"Publisher"] objectForKey:@"text"]];
                                                               [self.height setText:[self getCm:[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"ItemDimensions"] objectForKey:@"Height"] objectForKey:@"text"]]];
                                                               [self.width setText:[self getCm:[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"ItemDimensions"] objectForKey:@"Length"] objectForKey:@"text"]]];
                                                               [self.nbPages setText:[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"NumberOfPages"] objectForKey:@"text"]];
                                                               [self.language setText:[[[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"Languages"] objectForKey:@"Language"] objectAtIndex:0] objectForKey:@"Name"] objectForKey:@"text"]];
                                                               [self.price setText:[[[[[[[response objectForKey:@"ItemLookupResponse"] objectForKey:@"Items"] objectForKey:@"Item"] objectForKey:@"ItemAttributes"] objectForKey:@"TradeInValue"] objectForKey:@"FormattedPrice"] objectForKey:@"text"]];
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
            [[[UIAlertView alloc] initWithTitle:@"HOLY SHIT !!"
                                        message:@"Too many requests failed."
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
    
    
#if PREPROD
    NSError *error;
    if (![managedObjectContext save:&error])
        DLog(@"Core Data Error %@", error);
    
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
        NSLog(@"A BIG ERROR OCCURS WHILE GETTING ALL RECORDS: %@", err);
    DLog(@"RESULTS %@", records);
#endif
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ((self.view.center.y - textField.center.y) < 23) {
        if (CGAffineTransformIsIdentity(self.view.transform)) {
            [UIView animateWithDuration:.2 animations:^{
                self.view.transform = CGAffineTransformMakeTranslation(0.f, -216.f);
            }];
        }
    }
}

-(void) _handleTap:(UITapGestureRecognizer*)tgr
{
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
    
    if (!CGAffineTransformIsIdentity(self.view.transform)) {
        [UIView animateWithDuration:.2 animations:^{
            self.view.transform = CGAffineTransformIdentity;
        }];
    }
}

@end
