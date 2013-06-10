//
//  AppDelegate.m
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 18/04/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"

@implementation AppDelegate

@synthesize managedObjectContext=__managedObjectContext;
@synthesize managedObjectModel=__managedObjectModel;
@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;

@synthesize backup = _backup;
@synthesize query = _query;


+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"b3bcdce93e4c5843db8eb73320637a4294753e88"];
    
    NSString *iCloudAuth = [[NSUserDefaults standardUserDefaults] objectForKey:@"iCloudAuth"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentsFile = [fileManager contentsOfDirectoryAtPath:pathInDocumentDirectory(@"") error:nil];
    
    for (NSString *file in documentsFile) {
        /*
         if ([file isEqualToString:kOriginalDB]) {
            NSString *urlSrc = pathInDocumentDirectory(kOriginalDB);
            NSString *urlDest = pathInDocumentDirectory(kBackup);
            [[NSFileManager defaultManager] copyItemAtPath:urlSrc toPath:urlDest error:nil];
        }*/
        if ([file isEqualToString:@"Images"]) {
            NSArray *imagesContent = [fileManager contentsOfDirectoryAtPath:[pathInDocumentDirectory(@"") stringByAppendingPathComponent:@"Images"]
                                                                      error:nil];
            for (NSString *name in imagesContent) {
                DLog(@"FILE --> Images/%@", name);
            }
        }
        /*
        if ([file isEqualToString:kBackup]) {
            [[NSFileManager defaultManager] removeItemAtPath:[pathInDocumentDirectory(@"") stringByAppendingPathComponent:kBackup] error:nil];
        }
         */
        DLog(@"FILE --> %@", file);
    }
    
    NSString *imagesPath = [pathInDocumentDirectory(@"") stringByAppendingPathComponent:@"Images"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagesPath]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:imagesPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:&error];
    }
    
    
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    
    if (iCloudAuth == nil) {
        UIAlertView *iCloudAV = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"iCloud Auth Title", nil)
                                                           message:NSLocalizedString(@"iCloud Auth Message", nil)
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"iCloud Cancel", nil)
                                                 otherButtonTitles:NSLocalizedString(@"iCloud OK", nil), nil];
        [iCloudAV show];
    } else {
        if ([iCloudAuth isEqualToString:@"OK"]) {
            if (ubiq) {
                DLog(@"iCloud access at %@", ubiq);
                //[self loadDocument];
            } else {
                DLog(@"No iCloud access");
                UIAlertView *iClouKO = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"iCloud Auth Title2", nil)
                                                                  message:NSLocalizedString(@"iCloud Auth Message3", nil)
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"iCloud Close", nil)
                                                        otherButtonTitles:nil];
                [iClouKO show];
            }
        } else {
            DLog(@"iCloud Authorization KO");
        }
    }
    
    if (self.managedObjectContext == nil)
        self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextChanged:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    */
    
#if PREPROD
    
    /************************************************************/
    /*          START - Cleaning the DB from all datas          */
    /************************************************************/
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *toDelete = [NSEntityDescription entityForName:@"Comics" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:toDelete];
    //[request setIncludesPropertyValues:NO];
    NSError *err = nil;
    
    NSArray *comicsArray = [self.managedObjectContext executeFetchRequest:request error:&err];
    for (NSManagedObject *comics in comicsArray)
        [self.managedObjectContext deleteObject:comics];

    if (![self.managedObjectContext save:&err])
        DLog(@"Core Data Error %@", err);
    
    /************************************************************/
    /*          END - Cleaning the DB from all datas            */
    /************************************************************/
    
    /************************************************************/
    /*          START - Cleaning Sandbox from files             */
    /************************************************************/
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentDirectory error:nil];
    
    for (int i=0; i< [filePathsArray count]; i++)
        [[NSFileManager defaultManager] removeItemAtPath:pathInDocumentDirectory([filePathsArray objectAtIndex:i]) error:nil];
    
    /************************************************************/
    /*          END - Cleaning Sandbox from files             */
    /************************************************************/
    
#endif

    
    self.networkEngine = [[NetworkEngine alloc] initWithHostName:kDomainName];
    [self.networkEngine useCache];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// Explicitly write Core Data accessors
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"shelfComics" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"shelfComics.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}

/***********************/
/* MEGA TEST */

-(void)resetDB {
    __managedObjectModel = nil;
    __persistentStoreCoordinator = nil;
    __managedObjectContext = nil;
}


#pragma mark - Application's Documents directory

/*
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - iCloud methods

#pragma mark - AlertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setObject:@"KO" forKey:@"iCloudAuth"];
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults] setObject:@"OK" forKey:@"iCloudAuth"];
            break;
            
        default:
            break;
    }
}


@end
