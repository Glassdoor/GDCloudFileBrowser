//
//  LMCloudProviderHelper.h
//  LMCloudFileBrowser
//
//  Created by Linto Mathew on 3/21/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDCloudFile.h"

typedef void (^CompletionHandler) (BOOL success, NSError *error);

@protocol GDCloudProviderDelegate;

@interface GDCloudProviderHelper : NSObject

@property (nonatomic, readonly) GDCloudProvider provider;
@property (nonatomic, weak) id <GDCloudProviderDelegate> delegate;
@property (nonatomic, strong, readonly) NSArray *contents;

- (instancetype)initWithProvider:(GDCloudProvider)provider;
- (void)updateContentsArray:(NSArray *)contents;

@end

@protocol GDCloudProviderDelegate <NSObject>

- (void)googleDriveAuthenticationFinishedWithError:(NSError *)error;

@end