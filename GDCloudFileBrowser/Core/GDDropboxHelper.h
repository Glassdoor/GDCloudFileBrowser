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
@class DBRestClient;
@class DBPath;

@interface GDDropboxHelper : GDCloudProviderHelper

/**
 restClient A handle to the DBRestClient object that's used to fetch the folder contents
 */
@property (nonatomic, strong, readonly) DBRestClient *restClient;

/**
 Creates an instance of the GDDropboxHelper object.
 @param delegate A delegate that implements the <GDCloudProviderDelegate> protocol
 */
- (instancetype)initWithDelegate:(id <GDCloudProviderDelegate>)delegate;

/**
 returns YES if the current Dropbox session is linked to a Dropbox account
 */
- (BOOL)dropboxAccountLinked;

@end
