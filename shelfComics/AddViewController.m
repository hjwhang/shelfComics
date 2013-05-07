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

@interface AddViewController ()

@property (readwrite) IBOutlet UIBarButtonItem *revealButtonItem;
@property (nonatomic, retain) IBOutlet UIScrollView *mainScrollView;

@end

static int nbFailures = 5;

@implementation AddViewController

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
	
    [self.revealButtonItem setTarget: self.revealViewController];
    [self.revealButtonItem setAction: @selector(revealToggle:)];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    
    [self performSelector:@selector(adjustScrollViewContentSize) withObject:nil afterDelay:0.05];
}

// Tweak de merde à cause du resizeWithOldSuperviewSize qui m'empèche de resizer dans le viewDidLoad. Sais pas pourquoi ;(
-(void)adjustScrollViewContentSize {
    self.mainScrollView.contentSize = CGSizeMake(320, 625);
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
    
    [self showLoadingView];
    
    if (nbFailures != 0) {
        self.lookupOperation = [ApplicationDelegate.networkEngine itemForUPC:@"0785156658"
                                                           completionHandler:^(NSString *response) {
                                                               
                                                               [self removeLoadingView];
                                                               
                                                               [[[UIAlertView alloc] initWithTitle:@"It Works!"
                                                                                           message:[NSString stringWithFormat:@"%@", response]
                                                                                          delegate:nil
                                                                                 cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                                                                 otherButtonTitles:nil] show];
                                                               nbFailures = 5;
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
        nbFailures = 5;
        [[[UIAlertView alloc] initWithTitle:@"ERROR!!"
                                    message:@"Too many requests failed."
                                   delegate:nil
                          cancelButtonTitle:@"Close"
                          otherButtonTitles:nil] show];
    }
    
}

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
}

@end
