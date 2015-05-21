//
//  GDFilePickerViewController.h
//  GDCloudFileBrowser
//
//  Created by Linto Mathew on 3/21/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GDFilePickerDelegate;

@interface GDFilePickerViewController : UIViewController

@property (nonatomic, strong, readonly) NSString *gDriveFileUri;
@property (weak, nonatomic, readonly) IBOutlet UITableView *tableView;

- (instancetype)initWithDropboxProvider:(BOOL)isRoot path:(NSString *)path delegate:(id <GDFilePickerDelegate>)delegate;
- (instancetype)initWithGoogleDriveProvider:(BOOL)isRoot path:(NSString *)path folderName:(NSString *)folderName delegate:(id <GDFilePickerDelegate>)delegate;

@end

@protocol GDFilePickerDelegate <NSObject>

- (void)userPickedFileWithURL:(NSURL *)fileURL data:(NSData *)data fileUri:(NSString *)fileUri name:(NSString *)name;

@end
