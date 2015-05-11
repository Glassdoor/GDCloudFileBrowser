//
//  LMCloudProviderHelper.m
//  LMCloudFileBrowser
//
//  Created by Linto Mathew on 3/21/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import "GDCloudProviderHelper.h"

@interface GDCloudProviderHelper ()

@property (nonatomic, readwrite) GDCloudProvider provider;
@property (nonatomic, strong, readwrite) NSArray *contents;

@end

@implementation GDCloudProviderHelper

- (instancetype)initWithProvider:(GDCloudProvider)provider {
    if (self = [super init]) {
        self.provider = provider;
        self.contents = [NSArray new];
    }
    
    return self;
}

#pragma mark - Public
- (void)updateContentsArray:(NSArray *)contents {
    self.contents = [NSArray arrayWithArray:contents];
}

#pragma mark - Setters
- (void)setContents:(NSArray *)contents {
    _contents = contents;
}

@end
