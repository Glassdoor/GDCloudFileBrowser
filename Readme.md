# GDCloudFileBrowser

GDCloudFileBrowser is an iOS drop-in class that can be used with existing or new projects to access a user's Dropbox or Google Drive content.

### Requirements

**TLDR:** Include QuartzCore, CoreGraphics, SystemConfiguration and Security.framework

* GDCloudFileBrowser is tested only for iOS 7 or above and will work only with ARC projects.
* GDCloudFileBrowser uses UIKit, CoreGraphics.
* GDCloudFileBrowser uses the DropboxSDK (Core SDK) v1.3.13 which requires QuartzCore, Security.framework
* GDCloudFileBrowser uses the GTL (google-api-objectivec-client) project last updated on Dec-6th-2012 (http://google-api-objectivec-client.googlecode.com/svn/trunk/ google-api-objectivec-client-read-only) which uses Security, SystemConfiguration.

### Adding GDCloudFileBrowser to your project

Download the Source project and drag and drop the contents of Core folder into your project.

#### Instantiating the *DropboxHelper*
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
 Your View Controller must conform to the `GDFilePickerDelegate` protocol to receive callbacks.


#### Instantiating the *GDDropboxHelper*

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

If you would like to see detailed logs, enable it in the GDLog.h file. Set ENABLE_LOG flag to YES

### License
This code is distributed under the terms and conditions of the MIT license. 