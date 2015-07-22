# GDCloudFileBrowser

GDCloudFileBrowser is an iOS drop-in wrapper class that can be used with existing or new projects to access a user's Dropbox or Google Drive content.

### Requirements

**TLDR:** Include QuartzCore, CoreGraphics, SystemConfiguration and Security.framework

* GDCloudFileBrowser is tested only for iOS 7 or above and will work only with ARC projects.
* GDCloudFileBrowser uses UIKit, CoreGraphics.
* GDCloudFileBrowser uses the DropboxSDK [Core SDK](https://www.dropbox.com/developers/downloads/sdks/core/ios/dropbox-ios-sdk-1.3.13.zip) last updated on Sep-15th-2014 (v1.3.13) which requires QuartzCore, Security.framework
* GDCloudFileBrowser uses the GTL [google-api-objectivec-client](http://google-api-objectivec-client.googlecode.com/svn/trunk/) last updated on Dec-6th-2012 which uses Security, SystemConfiguration.
* Run ```pod install``` to install Google Drive project

### Adding GDCloudFileBrowser to your project

Download the Source project and drag and drop the contents of Core folder into your project. Run ```pod install``` from your projects root folder.

Your View Controller must conform to the `GDFilePickerDelegate` protocol to receive callbacks.

If you would like to see detailed logs, enable it in the GDLog.h file. Set ENABLE_LOG flag to YES

#### Update constants in `KeysHelper.m` with your developer account info
##### If you're using Dropbox update your app's Supported URL Schemes in your Info.plist file. Info.plist > URL Types > URL Schemes [db-APP_KEY replacing APP_KEY with the key generated when you created your app]
```
static NSString *const kDropboxClientId = @""; // Set the client Id from your Dropbox developer console and update the Info.plist (see above for instructions)
static NSString *const kDropboxClientSecret = @""; // Set the client Secret from your Dropbox developer console
static NSString *const kGoogleDriveClientId = @""; // Set the client Id from your Google developer console
static NSString *const kGoogleDriveClientSecret = @""; // Set the client Secret from your Google developer console
static NSString *const kGoogleDriveClientKeychainName = @""; // Set a name for the keychain entry
```

#### Using *GDDropboxHelper* to download Dropbox files
```
GDDropboxHelper *dropboxHelper = [[GDDropboxHelper alloc] initWithDelegate:self];
```

##### Linking to the controller if the user's account is not linked
```
if (![self.dropboxHelper dropboxAccountLinked]) { // no accounts are currently linked.
    [[DBSession sharedSession] linkFromController:self];
} 
```

##### Downloading the files
```
@property (nonatomic, copy) NSString *dropboxPath; // use `@"\"` to indicate root folder

    [self.dropboxHelper downloadFilesFrom:self.dropboxPath completion:^(BOOL success, NSError *error) {
        /* custom logic upon downloading the files */
    }];
```


#### Using *GDGoogleDriveHelper* to download Google Drive files

If it's the root folder (Read comments in `GDFilePickerViewController` to find why it's done this way)
```
@property (nonatomic, strong) GDGoogleDriveHelper *googleDriveHelper;

self.googleDriveHelper = [GDGoogleDriveHelper sharedManager];
self.googleDriveHelper.delegate = self;
```
If it's not the root folder
```
@property (nonatomic, strong) GDGoogleDriveHelper *googleDriveHelper;

self.googleDriveHelper = [[GDGoogleDriveHelper alloc] init];
self.googleDriveHelper.delegate = self;
```

##### Linking to the controller if the user's account is not linked
```
if (![self.googleDriveHelper driveAccessAuthorized]) {
    [self.navigationController pushViewController:[self.googleDriveHelper authController] animated:YES];
}
```

##### Downloading the files
```
@property (nonatomic, copy) NSString *gDrivePath; //  use `@"root"` to indicate root folder
    [self.googleDriveHelper downloadFilesFrom:self.gDrivePath completion:^(BOOL success, NSError *error) {
        /* custom logic upon downloading the files */
    }];
```

#### Using `GDQuickPreviewDelegate` to retrieve user's picked file data

##### Dropbox file selection
```
- (void)userSelectedDropboxFileWithURL:(NSString *)url data:(NSData *)fileData relativePath:(NSString *)relativePath name:(NSString *)fileName {
    /* custom logic to handle user's file selection */
}
```

##### Google Drive file selection
```
- (void)userSelectedGoogleDriveFileWithURL:(NSString *)url data:(NSData *)fileData name:(NSString *)fileName {
    /* custom logic to handle user's file selection */
```

### License
This code is distributed under the terms and conditions of the MIT license. 

