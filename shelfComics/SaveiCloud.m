//
//  SaveiCloud.m
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 27/05/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import "SaveiCloud.h"
#import "AppDelegate.h"
#import "Constants.h"

@implementation SaveiCloud

@synthesize zipDataContent;

#pragma mark - iCloud methods


-(BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    self.zipDataContent = [[NSData alloc] initWithBytes:[contents bytes] length:[contents length]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noteModified" object:self];
    
    return YES;
}

-(id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    
    return self.zipDataContent;
}


#pragma mark - Tools

-(void)testiCloudAvailability {
    NSString *iCloudAuth = [[NSUserDefaults standardUserDefaults] objectForKey:@"iCloudAuth"];
    
    NSString *iCloudAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"iCloudAccount"];
    
    if ([iCloudAccount isEqualToString:@"KO"]) {
        UIAlertView *noiCloudAccount = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"iCloudAccount Title", nil)
                                                                  message:NSLocalizedString(@"iCloudAccount Msg", nil)
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"iCloudAccount Close", nil)
                                                        otherButtonTitles:nil];
        [noiCloudAccount show];
    } else {
        if (![iCloudAuth isEqualToString:@"OK"]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"iCloud Auth Title", nil)
                                                         message:NSLocalizedString(@"iCloud Auth Message2", nil)
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"iCloud Cancel", nil)
                                               otherButtonTitles:NSLocalizedString(@"iCloud OK", nil), nil];
            [av show];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            // No sync
            break;
            
        case 1:
            [[NSUserDefaults standardUserDefaults] setObject:@"OK" forKey:@"iCloudAuth"];
            // to sync
            break;
            
        default:
            break;
    }
}

@end
