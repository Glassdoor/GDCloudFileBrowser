//
//  LMDropboxHelper.m
//  LMCloudFileBrowser
//
//  Created by Linto Mathew on 3/21/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import "GDDropboxHelper.h"
#import "KeysHelper.h"
#import <DropboxSDK/DropboxSDK.h>

NSString *const kLMDropboxLinkSuccessfull = @"LMDropboxLinkSuccessfull";

@interface GDDropboxHelper () <DBRestClientDelegate, DBSessionDelegate>

@property (nonatomic, copy) CompletionHandler completionHandler;
@property (nonatomic, strong, readwrite) DBRestClient *restClient;

@end

@implementation GDDropboxHelper

@dynamic delegate;

- (instancetype)initWithDelegate:(id <GDCloudProviderDelegate>)delegate {
    if (self = [super initWithProvider:GDCloudProviderDropbox]) {
        self.delegate = delegate;
        
        DBSession *dbSession = [[DBSession alloc]
                                initWithAppKey:[[KeysHelper sharedHelper] dropboxClientId]
                                appSecret:[[KeysHelper sharedHelper] dropboxClientSecret]
                                root:kDBRootDropbox];
        dbSession.delegate = self;
        [DBSession setSharedSession:dbSession];
        
        if ([[DBSession sharedSession] isLinked]) {
            self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
            self.restClient.delegate = self;
        } else {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishLinkingAccount:) name:kLMDropboxLinkSuccessfull object:nil];
        }
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)dropboxAccountLinked {
    return [[DBSession sharedSession] isLinked];
}

- (void)downloadFilesFrom:(NSString *)path completion:(CompletionHandler)completion {
    if ([[DBSession sharedSession] isLinked]) {
        self.completionHandler = completion;
        [self.restClient loadMetadata:path];
    } else {
        NSLog(@"user is not authenticated");
    }
}

#pragma mark - <DBRestClientDelegate>
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        NSArray *processedArray = [self processContents:metadata.contents];
        [super updateContentsArray:processedArray];
        
        if (self.completionHandler) {
            self.completionHandler(YES, nil);
        }
    }
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
    if (self.completionHandler) {
        self.completionHandler(NO, error);
    }
}

#pragma mark - Notification Observers
- (void)didFinishLinkingAccount:(NSNotification *)notification {
    // Dropbox account has been linked successfully. Instantiate the restClient.
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
    if ([[[DBSession sharedSession] userIds] count]) {
        NSString *userId = [[DBSession sharedSession] userIds][0];
        [[DBSession sharedSession] credentialStoreForUserId:userId];
    }
    
    // notify delegate that the authentication has finished
    if ([self.delegate respondsToSelector:@selector(dropboxAuthenticationFinishedWithError:)]) {
        [self.delegate dropboxAuthenticationFinishedWithError:nil];
    }
}

#pragma mark - <DBSessionDelegate>
- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId {
    // notify delegate that the authentication has failed
    if ([self.delegate respondsToSelector:@selector(dropboxAuthenticationFinishedWithError:)]) {
        [self.delegate dropboxAuthenticationFinishedWithError:nil];
    }
}

#pragma mark - Private
- (NSArray *)processContents:(NSArray *)contents {
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:contents.count];
    
    for (DBMetadata *metaData in contents) {
        GDCloudFile *cloudFile = [[GDCloudFile alloc] initWithFile:metaData provider:GDCloudProviderDropbox];
        
        [items addObject:cloudFile];
    }
    
    return [NSArray arrayWithArray:items];
}

@end
