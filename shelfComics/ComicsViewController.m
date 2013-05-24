//
//  ComicsViewController.m
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 20/05/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import "ComicsViewController.h"
#import "AppDelegate.h"
#import "Comics.h"
#import "ContentViewController.h"

@interface ComicsViewController ()

@property (readwrite) IBOutlet UIBarButtonItem *revealButtonItem;

@end

@implementation ComicsViewController

@synthesize managedObjectContext, comics, letters, sortedKeys, sortedComics;
@synthesize comicsSearchBar, searchResults;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom
    }
    return self;
}

#warning To clean and comment
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.revealButtonItem setTarget: self.revealViewController];
    [self.revealButtonItem setAction: @selector(revealToggle:)];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *toStore = [NSEntityDescription entityForName:@"Comics" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:toStore];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSError *err = nil;
    
    self.comics = [[self.managedObjectContext executeFetchRequest:request error:&err] mutableCopy];
    if (!self.comics)
        DLog(@"Error while requesting Core Data.");
    
    int numberOfLetters = 1;
    NSString *currentLetter;
    self.letters = [[NSMutableDictionary alloc] init];
    
    for (int i=0; i<[self.comics count]-1; i++) {
        currentLetter = [[[self.comics objectAtIndex:i] title] substringToIndex:1];
        if ([self.comics count] == 1) {
            [letters setObject:[NSNumber numberWithInt:1] forKey:currentLetter];
        } else {
            if ([currentLetter isEqualToString:[[[self.comics objectAtIndex:i+1] title] substringToIndex:1]]) {
                numberOfLetters++;
            } else {
                [letters setObject:[NSNumber numberWithInt:numberOfLetters] forKey:currentLetter];
                numberOfLetters = 1;
            }
        }
        if (i == [self.comics count]-2) {
            [letters setObject:[NSNumber numberWithInt:numberOfLetters] forKey:currentLetter];
        }
    }
    
    NSArray *keys = [letters allKeys];
    self.sortedKeys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.sortedComics = [[NSMutableDictionary alloc] init];
    NSMutableArray *arrayTmp = [[NSMutableArray alloc] init];
    
    for (NSString *key in self.sortedKeys) {
        for (Comics *toSort in self.comics) {
            if ([[letters objectForKey:key] intValue] == [arrayTmp count])
                break;
            if ([key isEqualToString:[toSort.title substringToIndex:1]])
                [arrayTmp addObject:toSort];
        }
        [self.sortedComics setObject:[arrayTmp mutableCopy] forKey:key];
        [arrayTmp removeAllObjects];
    }
    
    self.searchResults = [NSMutableArray arrayWithCapacity:[self.comics count]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ( [segue.destinationViewController isKindOfClass: [ContentViewController class]] &&
        [sender isKindOfClass:[UITableViewCell class]] )
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Comics *comicsToPass = [[self.sortedComics objectForKey:[self.sortedKeys objectAtIndex:[indexPath section]]] objectAtIndex:[indexPath row]];

        ContentViewController* cvc = segue.destinationViewController;
        cvc.comicsToPrint = comicsToPass;
        [cvc view];
    }
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return 44.f;
    else
        return 94.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView != self.searchDisplayController.searchResultsTableView)
        return [letters count];
    else
        return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView != self.searchDisplayController.searchResultsTableView)
        return [sortedKeys objectAtIndex:section];
    else
        return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{   
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    } else {
        return [[letters objectForKey:[self.sortedKeys objectAtIndex:section]] intValue];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    static NSString *comicsCell = @"ComicsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:comicsCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:comicsCell];
    }
    
    Comics *comicsToPrint;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        comicsToPrint = [searchResults objectAtIndex:row];
        cell.textLabel.text = comicsToPrint.title;
    }
    else {
        comicsToPrint = [[self.sortedComics objectForKey:[self.sortedKeys objectAtIndex:section]] objectAtIndex:row];
        UIImageView *coverImageView = (UIImageView*)[cell viewWithTag:2099];
        [coverImageView setImage:[UIImage imageWithContentsOfFile:pathInDocumentDirectory([comicsToPrint.isbn stringByAppendingString:@"Thumbnail"])]];
        
        UILabel *title = (UILabel*)[cell viewWithTag:3000];
        title.text = comicsToPrint.title;
    }
    
    return cell;
}


#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *toDelete = [NSEntityDescription entityForName:@"Comics" inManagedObjectContext:self.managedObjectContext];
        [request setEntity:toDelete];
        

        Comics *comicsToDelete = [self.comics objectAtIndex:[indexPath row]];
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"isbn == %@", comicsToDelete.isbn]];
        NSError *err = nil;
        
        NSArray *comicsArray = [self.managedObjectContext executeFetchRequest:request error:&err];

        for (NSManagedObject *comicsObject in comicsArray)
            [self.managedObjectContext deleteObject:comicsObject];

        [self.comics removeObjectAtIndex:[indexPath row]];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        if (![self.managedObjectContext save:&err]) {
            DLog(@"Delete fail");
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Content Filtering

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [self.searchResults removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[c] %@",searchText];
    self.searchResults = [NSMutableArray arrayWithArray:[self.comics filteredArrayUsingPredicate:predicate]];
}


#pragma mark - UISearchDisplayController Delegate Methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

@end
