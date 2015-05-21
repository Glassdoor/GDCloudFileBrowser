//
//  LMGoogleDriveManager.h
//  LMCloudFilePicker
//
//  Created by Linto Mathew on 3/22/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDCloudProviderHelper.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"

@interface GDGoogleDriveHelper : GDCloudProviderHelper

/**
 maxNumberOfResults The maximum number of 'items' to be retrieved. GTLQueryDrive ->maxResults. Defaults to 500 if nothing is set explicitly.
 */
@property (nonatomic) NSUInteger maxNumberOfResults;

/**
 requiredFields The file meta data to be retrieved with a file GTLDriveFile. Defaults to 'kind,items(id,downloadUrl,kind,title,fileExtension,fileSize,modifiedDate)'
 */
@property (nonatomic, copy) NSString *requiredFields;

/**
 mimeTypes Set this if you want to filter the folder contents to certain kind of files only.
 For ex. mimeType ='application/pdf' will show only pdf files inside a folder. Defaults to pdf, doc, docx and google docs format
 */
@property (nonatomic, copy) NSString *mimeTypes;

/**
 A handle to the GTLSeriveDrive object that's used to run the query
 */
@property (nonatomic, strong, readonly) GTLServiceDrive *driveService;

/**
 returns YES if the auth object has a refresh or access token for authorizing a request.
 Does not guarantee that the token is valid
 */
- (BOOL)driveAccessAuthorized;

/**
 Creates the auth controller for authorizing access to Google Drive.
 */
- (GTMOAuth2ViewControllerTouch *)authController;

/**
 logoutUser A helper method to remove user's authentication information from Keychain
 @returns YES if it was successful in removing user's info from Keychain
 */
- (BOOL)logoutUser;

/**
 @returns The GDGoogleDriveHelper singleton object
 */
+ (GDGoogleDriveHelper *)sharedManager;

@end
