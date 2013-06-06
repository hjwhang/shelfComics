//
//  FileHelpers.m
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 20/05/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#import "FileHelpers.h"

NSString *pathInDocumentDirectory(NSString *fileName) {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    if ([fileName isEqualToString:@""])
        return documentDirectory;
    else
        return [[documentDirectory stringByAppendingPathComponent:@"Images"] stringByAppendingPathComponent:fileName];
}