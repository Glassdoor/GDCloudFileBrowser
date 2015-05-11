//
//  GDQuickPreviewViewController.h
//  GDSalary
//
//  Created by Linto Mathew on 7/23/14.
//  Copyright (c) 2014 Glassdoor Inc. All rights reserved.
//

#import "GDCloudFile.h"
#import <UIKit/UIKit.h>

@protocol GDQuickPreviewDelegate;

@interface GDQuickPreviewViewController : UIViewController

- (instancetype)initWithFile:(GDCloudFile *)cloudFile provider:(GDCloudProvider)provider delegate:(id <GDQuickPreviewDelegate>)delegate;

@end

@protocol GDQuickPreviewDelegate <NSObject>

@optional
- (void)userSelectedDropboxFileWithURL:(NSString *)url data:(NSData *)fileData relativePath:(NSString *)relativePath name:(NSString *)fileName;
- (void)userSelectedGoogleDriveFileWithURL:(NSString *)url data:(NSData *)fileData name:(NSString *)fileName;

@end