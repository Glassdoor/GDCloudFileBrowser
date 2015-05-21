//
//  GDCloudContentBrowserCell.h
//
//  Created by Linto Mathew on 7/17/14.
//  Copyright (c) 2014 Glassdoor Inc. All rights reserved.
//

#import "GDCloudProviderHelper.h"
#import <UIKit/UIKit.h>

@interface GDCloudContentBrowserCell : UITableViewCell

@property (nonatomic) long long size;
@property (nonatomic) GDCloudProvider provider;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, strong) NSDate *lastModifiedDate;
@property (nonatomic, copy) NSString *lastModifiedTime;
@property (nonatomic, copy) NSString *thumbnailImageName;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy, readonly) NSString *userFriendlyFileSize;
@property (nonatomic, strong) GDCloudFile *file;

- (void)setupCellForEmptyFolder;
- (void)resetForReuse;
- (BOOL)showingFolder;

@end
