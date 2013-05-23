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

@interface ComicsViewController ()

@property (readwrite) IBOutlet UIBarButtonItem *revealButtonItem;

@end

@implementation ComicsViewController

@synthesize managedObjectContext, comics, letters, sortedKeys, sortedComics;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom
    }
    return self;
}

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 94.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [letters count];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sortedKeys objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[letters objectForKey:[self.sortedKeys objectAtIndex:section]] intValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ComicsCell"];
    Comics *comicsToPrint = [[self.sortedComics objectForKey:[self.sortedKeys objectAtIndex:section]] objectAtIndex:row];//[self.comics objectAtIndex:[indexPath row]];
    
    UIImageView *coverImageView = (UIImageView*)[cell viewWithTag:2099];
    [coverImageView setImage:[UIImage imageWithContentsOfFile:pathInDocumentDirectory([comicsToPrint.isbn stringByAppendingString:@"Thumbnail"])]];
    
    UILabel *title = (UILabel*)[cell viewWithTag:3000];
    title.text = comicsToPrint.title;
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
