//
//  MenuViewController.m
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 18/04/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import "MenuViewController.h"
#import "HomeViewController.h"
#import "Constants.h"
#import "SaveiCloud.h"

// TEST iCLOUD
#import "ZipArchive.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

@synthesize query = _query;


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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cellTaped = [self.tableView cellForRowAtIndexPath:indexPath];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([cellTaped.reuseIdentifier isEqualToString:@"syncSave"]) {
        UIAlertView *toSync = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"save Title", nil)
                                                         message:NSLocalizedString(@"save Msg", nil)
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"Save", nil];
        [toSync setTag:kSaveTag];
        [toSync show];
    }
    
    if ([cellTaped.reuseIdentifier isEqualToString:@"syncImport"]) {
        UIAlertView *toImport = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"import Title", nil)
                                                           message:NSLocalizedString(@"import Msg", nil)
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"Import", nil];
        [toImport setTag:kImportTag];
        [toImport show];
    }
}

#pragma mark - Alert View delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case kSaveTag:
            if (buttonIndex == 1) {
                DLog(@"Save");
                [self backupDatas];
            }
            break;
            
        case kImportTag:
            if (buttonIndex == 1) {
                [self loadDocument];
            }
            break;
            
        default:
            break;
    }
}

-(void)backupDatas {
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSURL *ubiquitousPackage = [[ubiq URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:kBackup];
    SaveiCloud *toSave = [[SaveiCloud alloc] initWithFileURL:ubiquitousPackage];
    [toSave testiCloudAvailability];
    
    [[NSFileManager defaultManager] copyItemAtPath:[pathInDocumentDirectory(@"") stringByAppendingPathComponent:kDBName]
                                            toPath:pathInDocumentDirectory(kDBName)
                                             error:nil];
    
    /********************************************************************/
    /*                      Zipping "Documents"                         */
    /********************************************************************/
    
    NSString *documentsDirectory = pathInDocumentDirectory(@"");
    NSArray *subPaths;
    NSString *toCompress = @"Images";
    NSString *pathToCompress = [documentsDirectory stringByAppendingPathComponent:toCompress];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //if ([fileManager fileExistsAtPath:pathToCompress isDirectory:YES])
    subPaths = [fileManager subpathsAtPath:pathToCompress];
    NSString *zipFilePath = [documentsDirectory stringByAppendingPathComponent:kBackup];
    ZipArchive *za = [[ZipArchive alloc] init];
    [za CreateZipFile2:zipFilePath];
    
    for (NSString *path in subPaths) {
        NSString *fullPath = [pathToCompress stringByAppendingPathComponent:path];
        [za addFileToZip:fullPath newname:path];
    }
    
    BOOL successCompressing = [za CloseZipFile2];
    
    if (successCompressing) {
        DLog(@"Compressing directory succeded");
    } else {
        DLog(@"Compressing directory failed.");
    }
    
    /********************************************************************/
    /*                      Sync backup.zip                             */
    /********************************************************************/
    
    NSURL *url = [[NSURL alloc] initFileURLWithPath:[pathInDocumentDirectory(@"") stringByAppendingPathComponent:kBackup]];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    toSave.zipDataContent = data;
    [toSave saveToURL:[toSave fileURL]
     forSaveOperation:UIDocumentSaveForCreating
    completionHandler:^(BOOL success) {
        if (success) {
            DLog(@"backup saved on iCloud.");
            [[NSFileManager defaultManager] removeItemAtPath:[pathInDocumentDirectory(@"") stringByAppendingPathComponent:kBackup] error:nil];
        } else {
            DLog(@"backup saved on device.");
        }
    }];
}

-(void)loadDocument {
    NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
    _query = query; 
    [query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSMetadataItemFSNameKey, kBackup];
    [query setPredicate:predicate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryDidFinishgathering:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:query];
    
    [query startQuery];
}

-(void)loadData:(NSMetadataQuery*)query {
    
    for (NSMetadataItem *item in [query results]) {
        NSString *fileName = [item valueForAttribute:NSMetadataItemFSNameKey];
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        SaveiCloud *saveDocument = [[SaveiCloud alloc] initWithFileURL:url];
        
        if ([fileName isEqualToString:kBackup]) {
            [saveDocument openWithCompletionHandler:^(BOOL success) {
                DLog(@"Backup file open.");
                NSData *file = [NSData dataWithContentsOfURL:url];
                NSString *documentsDirectory = pathInDocumentDirectory(@"");
                NSString *zipFile = [documentsDirectory stringByAppendingPathComponent:kBackup];
                [[NSFileManager defaultManager] createFileAtPath:zipFile contents:file attributes:nil];
                NSString *outputFolder = [documentsDirectory stringByAppendingPathComponent:@"Images"];
                ZipArchive *za = [[ZipArchive alloc] init];
                if ([za UnzipOpenFile:zipFile]) {
                    if ([za UnzipFileTo:outputFolder overWrite:YES]) {
                        DLog(@"Backup successfully unzip.");
                        [[NSFileManager defaultManager] removeItemAtPath:[pathInDocumentDirectory(@"") stringByAppendingPathComponent:kBackup] error:nil];
                        
                        // DB transfer
                        [[NSFileManager defaultManager] removeItemAtPath:[pathInDocumentDirectory(@"") stringByAppendingPathComponent:kDBName] error:nil];
                        
                        [[NSFileManager defaultManager] copyItemAtPath:pathInDocumentDirectory(kDBName)
                                                                toPath:[pathInDocumentDirectory(@"") stringByAppendingPathComponent:kDBName]
                                                                 error:nil];
                        [[NSFileManager defaultManager] removeItemAtPath:pathInDocumentDirectory(kDBName) error:nil];
                        
                    }
                    [za UnzipCloseFile];
                }
            }];
        }
    }
}

-(void)queryDidFinishgathering:(NSNotification*)notification {
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:query];
    _query = nil;
    
    [self loadData:query];
}

@end
