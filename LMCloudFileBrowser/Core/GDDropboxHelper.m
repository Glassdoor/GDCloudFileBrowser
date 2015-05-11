//
//  LMDropboxHelper.m
//  LMCloudFileBrowser
//
//  Created by Linto Mathew on 3/21/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import "GDDropboxHelper.h"
#import <Dropbox/Dropbox.h>

@interface GDDropboxHelper ()

@end

@implementation GDDropboxHelper

@dynamic delegate;

- (instancetype)initWithDelegate:(id <GDCloudProviderDelegate>)delegate {
    if (self = [super initWithProvider:GDCloudProviderDropbox]) {
        self.delegate = delegate;
    }
    
    return self;
}

- (BOOL)dropboxAccountLinked {
    return self.account;
}

- (void)downloadFilesFrom:(DBPath *)path completion:(CompletionHandler)completion {
    __block NSError *error = nil;
    if (![[DBFilesystem sharedFilesystem] isShutDown]) {
        if ([[DBFilesystem sharedFilesystem] completedFirstSync]) {
            NSArray *contents = [[DBFilesystem sharedFilesystem] listFolder:path error:&error];
            if (!error) {
                NSArray *processedArray = [self processContents:contents];
                [super updateContentsArray:processedArray];
                
                if (completion) {
                    completion(YES, nil);
                }
            }
        } else {
            // initial sync could take seconds / minutes so do it in the background.
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue addOperationWithBlock:^{
                NSArray *contents = [[DBFilesystem sharedFilesystem] listFolder:path error:&error];
                if (!error) {
                    NSArray *processedArray = [self processContents:contents];
                    [super updateContentsArray:processedArray];
                    
                    if (completion) {
                        completion(YES, nil);
                    }
                }
            }];
        }
    }
}

#pragma mark - Private
- (NSArray *)processContents:(NSArray *)contents {
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:contents.count];
    
    for (DBFileInfo *fileInfo in contents) {
        GDCloudFile *cloudFile = [[GDCloudFile alloc] initWithFile:fileInfo provider:GDCloudProviderDropbox];
        
        [items addObject:cloudFile];
    }
    
    return [NSArray arrayWithArray:items];
}

#pragma mark - Getters
- (DBAccount *)account {
    return [[DBAccountManager sharedManager] linkedAccount];
}

@end
