GDCloudFileBrowser

GDCloudFileBrowser is an iOS drop-in class that can be used with existing or new projects to access a user's Dropbox or Google Drive content.

Requirements

TLDR: Include QuartzCore, CoreGraphics, SystemConfiguration and Security.framework

GDCloudFileBrowser is tested only for iOS 7 or above and will work only with ARC projects.
GDCloudFileBrowser uses UIKit, CoreGraphics.
GDCloudFileBrowser uses the DropboxSDK (Core SDK) v1.3.13 which requires QuartzCore, Security.framework
GDCloudFileBrowser uses the GTL (google-api-objectivec-client) project last updated on Dec-6th-2012 (http://google-api-objectivec-client.googlecode.com/svn/trunk/ google-api-objectivec-client-read-only) which uses Security, SystemConfiguration.

Adding GDCloudFileBrowser to your project

Download the Source file and drag and drop the contents of Core folder into your project.
Additionaly you can import the Image.xcassets unless you choose to your own images.

If you would like to see detailed logs, enable it in the GDLog.h file. Set ENABLE_LOG flag to YES