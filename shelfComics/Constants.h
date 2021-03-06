//
//  Constantes.h
//  shelfComics
//
//  Created by Rémy ALEXANDRE on 19/04/13.
//  Copyright (c) 2013 Rémy ALEXANDRE. All rights reserved.
//

#ifndef shelfComics_Constantes_h
#define shelfComics_Constantes_h

#define PREPROD 0 // 1 for PREPROD and 0 for PROD

#pragma mark -
#pragma mark AWS Constants

#define kService @"AWSECommerceService"

#define kOperation @"ItemLookup"
#define kDomainName @"webservices.amazon.com"
#define kAssociateTag @"mytag-20"
#define kVersion @"2009-03-31"
#define kResponseGroup @"Medium"
#define kLoadingViewTag @"2013"
#define kType @"ISBN"
#define kSearchIndex @"Books"

#define kBackup @"backup.zip"
#define kDBName @"shelfComics.sqlite"

#define kSaveTag 1
#define kImportTag 2
#define kUploadTag 3

#endif
