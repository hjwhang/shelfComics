//
//  AppDelegate.h
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 18/04/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkEngine.h"
#import <CoreData/CoreData.h>
#import <Crashlytics/Crashlytics.h>

#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NetworkEngine *networkEngine;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void)saveContext;
-(NSURL *)applicationDocumentsDirectory;

+(AppDelegate *)sharedAppDelegate;

@end
