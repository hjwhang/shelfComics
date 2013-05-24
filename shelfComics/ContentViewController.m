//
//  ContentViewController.m
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 23/05/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import "ContentViewController.h"
#import "AppDelegate.h"
#import "Comics.h"

@interface ContentViewController ()

@property (readwrite) IBOutlet UIBarButtonItem *revealButtonItem;

@end

@implementation ContentViewController

@synthesize managedObjectContext, comicsToPrint;
@synthesize comicsTitle, cover, thumbnail, author, publicationDate, publisher, price, nbPages, isbn, dimensions, language, volume;

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
    
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    [self.comicsTitle setText:comicsToPrint.title];
    [self.comicsTitle setNumberOfLines:2];
    [self.author setText:comicsToPrint.author];
    [self.publicationDate setText:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"publicationDate", nil), comicsToPrint.publicationDate]];
    [self.publisher setText:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"publisher", nil), comicsToPrint.publisher]];
    [self.price setText:comicsToPrint.price];
    [self.nbPages setText:[NSString stringWithFormat:@"%@%@", comicsToPrint.nbPages, NSLocalizedString(@"pages", nil)]];
    [self.isbn setText:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"isbn", nil), comicsToPrint.isbn]];
    [self.volume setText:[NSString stringWithFormat:@"%@%@", NSLocalizedString(@"volume", nil), comicsToPrint.volume]];
    [self.dimensions setText:[NSString stringWithFormat:@"%@cm x %@cm", comicsToPrint.width, comicsToPrint.height]];
    [self.thumbnail setImage:[UIImage imageWithContentsOfFile:pathInDocumentDirectory(comicsToPrint.isbn)]];
    self.cover = [UIImage imageWithContentsOfFile:pathInDocumentDirectory(comicsToPrint.isbn)];
    
    UITapGestureRecognizer *tgrSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)];
    tgrSingleTap.numberOfTapsRequired = 1;
    tgrSingleTap.numberOfTouchesRequired = 1;
    [thumbnail addGestureRecognizer:tgrSingleTap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)zoom:(UITapGestureRecognizer *)tgr {
    if (tgr.enabled==NO || tgr.state!=UIGestureRecognizerStateEnded)
        return;
    
    CGPoint pos = [tgr locationInView:tgr.view];
    UIView* v = [tgr.view hitTest:pos withEvent:nil];
    
    if ([v isKindOfClass:[UIImageView class]]) {
        if (self.thumbnail.bounds.size.width == 320.0f) {
            [UIView animateWithDuration:0.5f
                             animations:^{
                                 [self.thumbnail setFrame:CGRectMake(self.view.bounds.origin.x + 20.0f, self.view.bounds.origin.y + 58.0f, 110.0f, 140.0f)];
                                 ;}
                             completion:nil];
        } else {
            [UIView animateWithDuration:0.5f
                             animations:^{
                                 [self.thumbnail setFrame:CGRectMake(0, 0, 320.0f, self.view.bounds.size.height)];
                                 ;}
                             completion:nil];
        }
    }
}

@end
