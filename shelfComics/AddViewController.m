//
//  AddViewController.m
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 18/04/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import "AddViewController.h"
#import "AppDelegate.h"

@interface AddViewController ()

@property (readwrite) IBOutlet UIBarButtonItem *revealButtonItem;

@end

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)lookUp:(id)sender {
    self.lookupOperation = [ApplicationDelegate.networkEngine itemForUPC:@"qsdfqsdf"
                                                       completionHandler:^(NSString *response) {
                                                           
                                                           [[[UIAlertView alloc] initWithTitle:@"YOOOOOO"
                                                                                       message:[NSString stringWithFormat:@"%@", response]
                                                                                      delegate:nil
                                                                             cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                                                                             otherButtonTitles:nil] show];
                                                       }
                                                            errorHandler:^(NSError* error) {
                                                                
                                                                
                                                                DLog(@"%@\t%@\t%@\t%@", [error localizedDescription], [error localizedFailureReason],
                                                                     [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
                                                            }
                            ];
}

@end
