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
#import "AppDelegate.h"
#import "SaveiCloud.h"
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
    return 7;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 64.0f;
    } else {
        return 44.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    switch (indexPath.row) {
        case 0:
            CellIdentifier = @"empty";
            break;
        case 1:
            CellIdentifier = @"titleShelf";
            break;
        case 2:
            CellIdentifier = @"shelfAdd";
            break;
        case 3:
            CellIdentifier = @"shelfCheck";
            break;
        case 4:
            CellIdentifier = @"titleSync";
            break;
        case 5:
            CellIdentifier = @"syncSave";
            break;
        case 6:
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
        BOOL ok =[[Reachability reachabilityForInternetConnection] isReachable];
        
        if (!ok) {
            UIAlertView *noNetwork = [[UIAlertView  alloc] initWithTitle:NSLocalizedString(@"noNetwork Title", nil)
                                                                 message:NSLocalizedString(@"noNetwork Msg", nil)
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"noNetwork Close", nil)
                                                       otherButtonTitles:nil];
            [noNetwork show];
            return;
        } else {
            UIAlertView *toSync = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"save Title", nil)
                                                             message:NSLocalizedString(@"save Msg", nil)
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"Save", nil];
            [toSync setTag:kSaveTag];
            [toSync show];
        }
    }
    
    if ([cellTaped.reuseIdentifier isEqualToString:@"syncImport"]) {
        BOOL ok =[[Reachability reachabilityForInternetConnection] isReachable];
        
        if (!ok) {
            UIAlertView *noNetwork = [[UIAlertView  alloc] initWithTitle:NSLocalizedString(@"noNetwork Title", nil)
                                                                 message:NSLocalizedString(@"noNetwork Msg", nil)
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"noNetwork Close", nil)
                                                       otherButtonTitles:nil];
            [noNetwork show];
            return;
        } else {
            UIAlertView *toImport = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"import Title", nil)
                                                               message:NSLocalizedString(@"import Msg", nil)
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Import", nil];
            [toImport setTag:kImportTag];
            [toImport show];
        }
    }
}

#pragma mark - Alert View delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case kSaveTag:
            if (buttonIndex == 1) {
                [self backupDatas];
            }
            break;
            
        case kImportTag:
            if (buttonIndex == 1) {
                [self loadDocument];
            }
            break;
        case kUploadTag:
            if (buttonIndex == 1) {
                [self uploadDatas];
            }
            
        default:
            break;
    }
}

-(void)backupDatas {
    [self printLoadingView];
    
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
        DLog(@"Compressing directory succeeded");
    } else {
        DLog(@"Compressing directory failed.");
        [self hideLoadingView];
        UIAlertView *koSave = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"koSave Title", nil)
                                                         message:NSLocalizedString(@"koSave Msg", nil)
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"koSaveClose", nil)
                                               otherButtonTitles:nil];
        [koSave show];
    }
    
    uint64_t fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:zipFilePath error:nil] fileSize];
    
    if ((fileSize > 5300000) && ![[Reachability reachabilityForInternetConnection] isReachableViaWiFi]) {
        UIAlertView *fileWeight = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"fileWeight Title", nil)
                                                             message:NSLocalizedString(@"fileWeight Msg", nil)
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"fileWeight Cancel", nil)
                                                   otherButtonTitles:NSLocalizedString(@"fileWeight OK", nil), nil];
        [fileWeight setTag:kUploadTag];
        [fileWeight show];
    } else {
        [self uploadDatas];
    }
}

-(void)uploadDatas {
    /********************************************************************/
    /*                      Sync backup.zip                             */
    /********************************************************************/
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSURL *ubiquitousPackage = [[ubiq URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:kBackup];
    SaveiCloud *toSave = [[SaveiCloud alloc] initWithFileURL:ubiquitousPackage];
    
    NSURL *url = [[NSURL alloc] initFileURLWithPath:[pathInDocumentDirectory(@"") stringByAppendingPathComponent:kBackup]];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    toSave.zipDataContent = data;
    [toSave saveToURL:[toSave fileURL]
     forSaveOperation:UIDocumentSaveForCreating
    completionHandler:^(BOOL success) {
        if (success) {
            DLog(@"backup saved on iCloud.");
            [self hideLoadingView];
            UIAlertView *okSave = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"okSave Title", nil)
                                                             message:NSLocalizedString(@"okSave Msg", nil)
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"okSave Close", nil)
                                                   otherButtonTitles:nil];
            [okSave show];
            [[NSFileManager defaultManager] removeItemAtPath:[pathInDocumentDirectory(@"") stringByAppendingPathComponent:kBackup] error:nil];
        } else {
            DLog(@"backup saved on device.");
            UIAlertView *koSave = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"koSave Title", nil)
                                                             message:NSLocalizedString(@"koSave Msg 1", nil)
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"koSave Close", nil)
                                                   otherButtonTitles:nil];
            [koSave show];
        }
    }];
}

-(void)loadDocument {
    NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
    _query = query; 
    [query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", NSMetadataItemFSNameKey, kBackup];
    [query setPredicate:predicate];
    
    [query setValueListAttributes:@[NSMetadataUbiquitousItemPercentDownloadedKey, NSMetadataUbiquitousItemIsDownloadedKey]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queryDidFinishgathering:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:query];
    
    [query startQuery];
    [self printLoadingView];
}

-(void)loadData:(NSMetadataQuery*)query {
    
    if ([query resultCount] == 0) {
        [self hideLoadingView];
        UIAlertView *noBackupView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noBackup Title", nil)
                                                               message:NSLocalizedString(@"noBackup Msg", nil)
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"noBackup Close", nil)
                                                     otherButtonTitles:nil];
        [noBackupView show];
        return;
    }
    
    for (NSMetadataItem *item in [query results]) {
        NSString *fileName = [item valueForAttribute:NSMetadataItemFSNameKey];
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        SaveiCloud *saveDocument = [[SaveiCloud alloc] initWithFileURL:url];
        
        if ([fileName isEqualToString:kBackup]) {
            [saveDocument openWithCompletionHandler:^(BOOL success) {
                if (success) {
                    DLog(@"Backup file open.");
                    NSData *file = [NSData dataWithContentsOfURL:url];
                    NSString *zipFile = [pathInDocumentDirectory(@"") stringByAppendingPathComponent:kBackup];
                    [[NSFileManager defaultManager] createFileAtPath:zipFile contents:file attributes:nil];
                    NSString *outputFolder = [pathInDocumentDirectory(@"") stringByAppendingPathComponent:@"Images"];
                    ZipArchive *za = [[ZipArchive alloc] init];
                    if ([za UnzipOpenFile:zipFile]) {
                        if ([za UnzipFileTo:outputFolder overWrite:YES]) {
                            DLog(@"Backup successfully unzip.");
                            [[NSFileManager defaultManager] removeItemAtPath:[pathInDocumentDirectory(@"") stringByAppendingPathComponent:kBackup] error:nil];
                            
                            // DB transfer
                            [[NSFileManager defaultManager] removeItemAtPath:[pathInDocumentDirectory(@"") stringByAppendingPathComponent:kDBName] error:nil];
                            
                            AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
                            [appDelegate resetDB];
                            
                            [[NSFileManager defaultManager] copyItemAtPath:pathInDocumentDirectory(kDBName)
                                                                    toPath:[pathInDocumentDirectory(@"") stringByAppendingPathComponent:kDBName]
                                                                     error:nil];
                            [[NSFileManager defaultManager] removeItemAtPath:pathInDocumentDirectory(kDBName) error:nil];
                            
                            // Everything went right
                            [self hideLoadingView];
                            UIAlertView *okView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"okView Title", nil)
                                                                             message:NSLocalizedString(@"okView Msg", nil)
                                                                            delegate:self
                                                                   cancelButtonTitle:NSLocalizedString(@"okView Close", nil)
                                                                   otherButtonTitles:nil];
                            [okView show];
                            
                        }
                        [za UnzipCloseFile];
                    } else {
                        DLog(@"Unable to unzip backup.");
                        [[NSFileManager defaultManager] removeItemAtPath:pathInDocumentDirectory(kDBName) error:nil];
                        [self hideLoadingView];
                        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Import Title", nil)
                                                                                 message:NSLocalizedString(@"Error Import Msg", nil)
                                                                                delegate:self
                                                                       cancelButtonTitle:NSLocalizedString(@"okView Close", nil)
                                                                       otherButtonTitles:nil];
                        [errorAlertView show];
                    }
                } else {
                    [self hideLoadingView];
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Import Title", nil)
                                                                             message:NSLocalizedString(@"Error Import Msg", nil)
                                                                            delegate:self
                                                                   cancelButtonTitle:NSLocalizedString(@"okView Close", nil)
                                                                   otherButtonTitles:nil];
                    [errorAlertView show];
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

-(void)printLoadingView {
    UIView *loadingView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [loadingView setBackgroundColor:[UIColor lightGrayColor]];
    [loadingView setAlpha:0.8];
    
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 220, 100, 100)];
    [loadingLabel setText:NSLocalizedString(@"Loading", nil)];
    [loadingLabel setTextAlignment:NSTextAlignmentCenter];
    [loadingLabel setTextColor:[UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:1.0f]];
    [loadingLabel setBackgroundColor:[UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.0]];
    [loadingView addSubview:loadingLabel];
    
    UIActivityIndicatorView *loadingActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadingActivity startAnimating];
    [loadingActivity setCenter:CGPointMake(160, 225)];
    [loadingView addSubview:loadingActivity];
    
    [loadingView setTag:[kLoadingViewTag intValue]];
    
    //[self.view addSubview:loadingView];
    [self.view.window.rootViewController.view addSubview:loadingView];
}

-(void)hideLoadingView {
    for (UIView *subview in [self.view.window.rootViewController.view subviews]) {
        if (subview.tag == [kLoadingViewTag intValue]) {
            [subview removeFromSuperview];
        }
    }
}

@end
