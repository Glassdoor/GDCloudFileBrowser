//
//  LMDropboxHelper.h
//  LMCloudFileBrowser
//
//  Created by Linto Mathew on 3/21/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDCloudProviderHelper.h"

@class DBAccount;
@class DBPath;

@interface GDDropboxHelper : GDCloudProviderHelper

@property (nonatomic, strong, readonly) DBAccount *account;

- (instancetype)initWithDelegate:(id <GDCloudProviderDelegate>)delegate;
- (BOOL)dropboxAccountLinked;
- (void)downloadFilesFrom:(DBPath *)path completion:(CompletionHandler)completion;

@end
