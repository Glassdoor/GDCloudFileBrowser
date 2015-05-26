//
//  KeysHelper.m
//  GDCloudFilePicker
//
//  Created by Linto Mathew on 3/23/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import "KeysHelper.h"
#import "GDLog.h"

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
    NSString *value = self.keysDictionary[@"Dropbox_Client_Id"];
    if (![value length]) {
        GDLog(@"Set your Dropbox client id in the Keys.plist (if the file doesn't exist, either create a Keys.plist file or rename Keys-example.plist and fill in the required fields)");
    }
    
    return value;
}

- (NSString *)dropboxClientSecret {
    NSString *value = self.keysDictionary[@"Dropbox_Client_Secret"];
    if (![value length]) {
        GDLog(@"Set your Dropbox client secret in the Keys.plist (if the file doesn't exist, either create a Keys.plist file or rename Keys-example.plist and fill in the required fields)");
    }
    
    return value;
}

- (NSString *)googleDriveClientId {
    NSString *value = self.keysDictionary[@"Google_Drive_Client_Id"];
    if (![value length]) {
        GDLog(@"Set your Google Drive client id in the Keys.plist (if the file doesn't exist, either create a Keys.plist file or rename Keys-example.plist and fill in the required fields)");
    }
    
    return value;
}

- (NSString *)googleDriveClientSecret {
    NSString *value = self.keysDictionary[@"Google_Drive_Client_Secret"];
    if (![value length]) {
        GDLog(@"Set your Google Drive client secret in the Keys.plist (if the file doesn't exist, either create a Keys.plist file or rename Keys-example.plist and fill in the required fields)");
    }
    
    return value;
}

- (NSString *)googleDriveClientKeychainName {
    NSString *value = self.keysDictionary[@"Google_Drive_Keychain_Name"];
    if (![value length]) {
        GDLog(@"Set your Google Drive Keychain name in the Keys.plist (if the file doesn't exist, either create a Keys.plist file or rename Keys-example.plist and fill in the required fields)");
    }
    
    return value;
}

@end
