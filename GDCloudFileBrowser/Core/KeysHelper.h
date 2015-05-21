//
//  KeysHelper.h
//  GDCloudFilePicker
//
//  Created by Linto Mathew on 3/23/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeysHelper : NSObject

/**
 @returns The KeysHelper singleton object
 */
+ (KeysHelper *)sharedHelper;

/**
 @returns The dropboxClientId from Keys.plist
 */
- (NSString *)dropboxClientId;

/**
 @returns The dropboxClientSecret from Keys.plist
 */
- (NSString *)dropboxClientSecret;

/**
 @returns The googleDriveClientId from Keys.plist
 */
- (NSString *)googleDriveClientId;

/**
 @returns The googleDriveClientSecret from Keys.plist
 */
- (NSString *)googleDriveClientSecret;

/**
 @returns The googleDriveClientKeychainName from Keys.plist
 */
- (NSString *)googleDriveClientKeychainName;

@end
