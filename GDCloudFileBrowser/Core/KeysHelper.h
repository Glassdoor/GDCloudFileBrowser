//
//  KeysHelper.h
//  GDCloudFilePicker
//
//  Created by Linto Mathew on 3/23/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeysHelper : NSObject

+ (KeysHelper *)sharedHelper;

- (NSString *)dropboxClientId;
- (NSString *)dropboxClientSecret;
- (NSString *)googleDriveClientId;
- (NSString *)googleDriveClientSecret;
- (NSString *)googleDriveClientKeychainName;

@end
