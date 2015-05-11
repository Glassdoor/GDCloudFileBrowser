//
//  GDCloudContentBrowserCell.m
//  GDSalary
//
//  Created by Linto Mathew on 7/17/14.
//  Copyright (c) 2014 Glassdoor Inc. All rights reserved.
//

#import "GDCloudContentBrowserCell.h"
#import <Dropbox/Dropbox.h>
//#import "GTLDriveFile.h"

@interface GDCloudContentBrowserCell ()

@property (nonatomic, copy, readwrite) NSString *userFriendlyFileSize;
@property (nonatomic, weak) IBOutlet UILabel *fileNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *fileIconImageView;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (nonatomic, weak) IBOutlet UILabel *emptyFolderLabel;

@end

@implementation GDCloudContentBrowserCell

#pragma mark - Setters
- (void)setFileName:(NSString *)fileName {
    _fileName = fileName;
    _fileNameLabel.text = fileName;
}

- (void)setLastModifiedDate:(NSDate *)lastModifiedDate {
    _lastModifiedDate = lastModifiedDate;
    
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd YYYY"];
    }
    
    self.lastModifiedTime = [dateFormatter stringFromDate:self.lastModifiedDate];
}

- (void)setLastModifiedTime:(NSString *)lastModifiedTime {
    _lastModifiedTime = lastModifiedTime;
}

- (void)setSize:(long long)size {
    _size = size;
    self.userFriendlyFileSize = [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}

- (void)setFile:(GDCloudFile *)file {
    _file = file;
    
    GDFileType fileType = [self fileType];
    self.fileIconImageView.image = [UIImage imageNamed:[self imageNameForFileType:fileType]];
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    _detailLabel.text = subtitle;
}

#pragma mark - Public
- (void)resetForReuse {
    [self showEmptyCell:NO];
}

- (void)setupCellForEmptyFolder {
    [self showEmptyCell:YES];
    self.emptyFolderLabel.text = NSLocalizedString(@"No doc, docx or pdf files found.", nil);
}

- (BOOL)showingFolder {
    GDCloudFile *cloudFile = (GDCloudFile *)self.file;
    return [cloudFile isFolder];
}

#pragma mark - Private
- (GDFileType)fileType {
    if ([self showingFolder]) {
        return GDFileTypeFolder;
    } else if ([self.fileName.lowercaseString rangeOfString:@".doc"].location != NSNotFound) {
        return GDFileTypeDoc;
    } else if ([self.fileName.lowercaseString rangeOfString:@".docx"].location != NSNotFound) {
        return GDFileTypeDocx;
    } else if ([self.fileName.lowercaseString rangeOfString:@".pdf"].location != NSNotFound) {
        return GDFileTypePdf;
    } else if ([self.fileName.lowercaseString rangeOfString:@".txt"].location != NSNotFound) {
        return GDFileTypeTxt;
    } else if (([self.fileName.lowercaseString rangeOfString:@".rtf"].location != NSNotFound)) {
        return GDFileTypeRtf;
    } else {
        return GDFileTypeOther;
    }
}

- (NSString *)imageNameForFileType:(GDFileType)fileType {
    NSString *imageName;
    switch (fileType) {
        case GDFileTypeFolder: imageName = @"lm_folder"; break;
        case GDFileTypePdf: imageName = @"lm_page_white_acrobat"; break;
        case GDFileTypeDoc: case GDFileTypeDocx: imageName = @"lm_page_white_word"; break;
        case GDFileTypeRtf: case GDFileTypeTxt: imageName = @"lm_page_white_text"; break;
        default: imageName = @"lm_page_white"; break;
    }
    
    return imageName;
}

// if the cell is empty, we remove the usual labels and show the empty folder message label.
- (void)showEmptyCell:(BOOL)isEmpty {
    self.emptyFolderLabel.hidden = !isEmpty;
    self.fileNameLabel.hidden = isEmpty;
    self.fileIconImageView.hidden = isEmpty;
    self.detailLabel.hidden = isEmpty;
}

@end
