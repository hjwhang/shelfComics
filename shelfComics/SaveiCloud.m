//
//  SaveiCloud.m
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 27/05/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import "SaveiCloud.h"
#import "AppDelegate.h"

@implementation SaveiCloud

@synthesize managedObjectContext;
@synthesize comics;

-(id)init {
    if (self = [super init]) {
        AppDelegate *appDelegate = [AppDelegate sharedAppDelegate];
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        NSString *urlSrc = pathInDocumentDirectory(@"AppWithCoreData.sqlite");
        NSString *urlDest = pathInDocumentDirectory(@"db_backup.sqlite");
        
        [[NSFileManager defaultManager] copyItemAtPath:urlSrc toPath:urlDest error:nil];
        
        
        
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
        
        DLog(@"COMICS RETRIEVED --> %@", self.comics);
    }
    return self;
}

-(void)createJSON {
    
}

@end
