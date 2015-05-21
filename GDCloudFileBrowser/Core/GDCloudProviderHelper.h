//
//  GDCloudProviderHelper.h
//  GDCloudFileBrowser
//
//  Created by Linto Mathew on 3/21/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDCloudFile.h"

typedef void (^CompletionHandler) (BOOL success, NSError *error);

@protocol GDCloudProviderDelegate;

@interface GDCloudProviderHelper : NSObject

/**
 provider A GDCloudProvider enum with which this object was initialized
 */
@property (nonatomic, readonly) GDCloudProvider provider;

/**
 delegate A delegate that implements the <GDCloudProviderDelegate> protocol
 */
@property (nonatomic, weak) id <GDCloudProviderDelegate> delegate;

/**
 contents A list of the current folder files
 */
@property (nonatomic, strong, readonly) NSArray *contents;

/**
 Creates an instance of the GDCloudProviderHelper object.
 @param provider A GDCloudProvider enum
 */
- (instancetype)initWithProvider:(GDCloudProvider)provider;

/**
 Updates the items in the contents array
 */
- (void)updateContentsArray:(NSArray *)contents;

/**
 Downloads files from specified directory.
 @param path An NSString object that represents the location on which it runs the query
 @param completion A completion handler that will be invoked once the process if complete
 */
- (void)downloadFilesFrom:(NSString *)path completion:(CompletionHandler)completion;

@end

@protocol GDCloudProviderDelegate <NSObject>

@optional

/**
 Notifies the delegate that the Google Drive authenticaiton has finished with error
 @param error An NSError object that's populated by GTMOAuth2Authentication
 */
- (void)googleDriveAuthenticationFinishedWithError:(NSError *)error;

/**
 Notifies the delegate that the Dropbox authenticaiton has finished with error
 @param error An NSError object that's populated by DBSession (PS: this is currently nil because DBSessionDelegate doesn't pass the error)
 */
- (void)dropboxAuthenticationFinishedWithError:(NSError *)error;

@end