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

@synthesize managedObjectContext, comics;

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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.comics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ComicsCell"];
    Comics *comicsToPrint = [self.comics objectAtIndex:[indexPath row]];
    
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
