//
//  KeysHelper.m
//  GDCloudFilePicker
//
//  Created by Linto Mathew on 3/23/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import "KeysHelper.h"
#import "GDLog.h"

static NSString *const kDropboxClientId = @""; // Set the client Id from your Dropbox developer console and update the Info.plist > URL Types > URL Schemes [db-APP_KEY replacing APP_KEY with the key generated when you created your app)]
static NSString *const kDropboxClientSecret = @""; // Set the client Secret from your Dropbox developer console
static NSString *const kGoogleDriveClientId = @""; // Set the client Id from your Google developer console
static NSString *const kGoogleDriveClientSecret = @""; // Set the client Secret from your Google developer console
static NSString *const kGoogleDriveClientKeychainName = @""; // Set a name for the keychain entry

@interface KeysHelper ()

@property (nonatomic, strong) NSDictionary *keysDictionary;

@end

@implementation KeysHelper

+ (KeysHelper *)sharedHelper {
    static KeysHelper *helper = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[KeysHelper alloc] init];
    });
    
    return helper;
}

- (instancetype)init {
    if (self = [super init]) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
        self.keysDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    }
    
    return self;
}

#pragma mark - Public
- (NSString *)dropboxClientId {
    NSString *value = kDropboxClientId;
    if (![value length]) {
        GDLog(@"Set your Dropbox client id in the KeysHelper.m file");
    }
    
    return value;
}

- (NSString *)dropboxClientSecret {
    NSString *value = kDropboxClientSecret;
    if (![value length]) {
        GDLog(@"Set your Dropbox client secret in the KeysHelper.m file");
    }
    
    return value;
}

- (NSString *)googleDriveClientId {
    NSString *value = kGoogleDriveClientId;
    if (![value length]) {
        GDLog(@"Set your Google Drive client id in the KeysHelper.m file");
    }
    
    return value;
}

- (NSString *)googleDriveClientSecret {
    NSString *value = kGoogleDriveClientSecret;
    if (![value length]) {
        GDLog(@"Set your Google Drive client secret in the KeysHelper.m file");
    }
    
    return value;
}

- (NSString *)googleDriveClientKeychainName {
    NSString *value = kGoogleDriveClientKeychainName;
    if (![value length]) {
        GDLog(@"Set your Google Drive Keychain name in the KeysHelper.m file");
    }
    
    return value;
}

@end
