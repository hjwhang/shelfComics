//
//  MenuViewController.m
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 18/04/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import "MenuViewController.h"
#import "HomeViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

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
    
    UIButton *transparentBackHome = [[UIButton alloc] init];
    [transparentBackHome setBounds:CGRectMake(0, 0, 320, 44)];
    [transparentBackHome setFrame:CGRectMake(0, 0, 320, 44)];
    [transparentBackHome addTarget:self action:@selector(backHome:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:transparentBackHome];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Configure the segue
    if ([segue isKindOfClass:[SWRevealViewControllerSegue class]]) {
        SWRevealViewControllerSegue *rvcs = (SWRevealViewControllerSegue *) segue;
        SWRevealViewController *rvc = self.revealViewController;
        NSAssert(rvc != nil, @"oops, must have a revealViewController");
        
        NSAssert([rvc.frontViewController isKindOfClass:[UINavigationController class]], @"oops, for this segue we want a permanent navigation controller in the front.");
        
        rvcs.performBlock = ^(SWRevealViewControllerSegue *rvc_segue, UIViewController *scv, UIViewController *dvc) {
            UINavigationController *nc = (UINavigationController *)rvc.frontViewController;
            [nc setViewControllers:@[dvc] animated:YES];
            [rvc setFrontViewPosition:FrontViewPositionLeft animated:YES];
        };
    }
}

#pragma mark - Back methods

- (void)backHome:(UIButton *)sender {
    if ([[[self.revealViewController.frontViewController.childViewControllers lastObject] class] isSubclassOfClass:[HomeViewController class]]) {
        [self.revealViewController revealToggleAnimated:YES];
    }
    
    if (![[[self.revealViewController.frontViewController.childViewControllers lastObject] class] isSubclassOfClass:[HomeViewController class]]) {
        [self performSegueWithIdentifier:@"homeSegue" sender:nil];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    switch (indexPath.row) {
        case 0:
            CellIdentifier = @"titleShelf";
            break;
        case 1:
            CellIdentifier = @"shelfAdd";
            break;
        case 2:
            CellIdentifier = @"shelfCheck";
            break;
        case 3:
            CellIdentifier = @"titleSync";
            break;
        case 4:
            CellIdentifier = @"syncSave";
            break;
        case 5:
            CellIdentifier = @"syncImport";
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];
    
    return cell;
}

#pragma mark - Table view delegate
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cellTaped = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ((cellTaped.tag == 0) && [[[self.revealViewController.frontViewController.childViewControllers lastObject] class] isSubclassOfClass:[HomeViewController class]]) {
        [self.revealViewController revealToggleAnimated:YES];
    }
    
    if ((cellTaped.tag == 0) && ![[[self.revealViewController.frontViewController.childViewControllers lastObject] class] isSubclassOfClass:[HomeViewController class]]) {
        [self performSegueWithIdentifier:@"homeSegue" sender:nil];
    }
}
*/
@end
