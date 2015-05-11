//
//  GDCloudFile.m
//  GDSalary
//
//  Created by Linto Mathew on 3/17/15.
//  Copyright (c) 2015 Glassdoor Inc. All rights reserved.
//

#import "GDCloudFile.h"
#import "GTLDriveFile.h"
#import <Dropbox/Dropbox.h>

@interface GDCloudFile ()

@property (nonatomic, readwrite) GDCloudProvider provider;
@property (nonatomic, copy, readwrite) NSString *fileName;
@property (nonatomic, strong, readwrite) NSDate *lastModifiedDate;
@property (nonatomic, copy, readwrite) NSString *lastModifiedTime;
@property (nonatomic, copy, readwrite) NSString *fileExtension;
@property (nonatomic, copy, readwrite) NSString *pathStr;
@property (nonatomic, strong, readwrite) id path;
@property (nonatomic, readwrite) long long size;
@property (nonatomic, strong, readwrite) id file;

@end

@implementation GDCloudFile

- (instancetype)initWithFile:(id)file provider:(GDCloudProvider)provider {
    if (self = [super init]) {
        self.provider = provider;
        self.file = file;
    }
    
    return self;
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

#pragma mark - Setters
- (void)setFile:(id)file {
    if (_file != file) {
        _file = file;
        
        switch (self.provider) {
            case GDCloudProviderDropbox:
                [self processDropboxFile:file];
                break;
            case GDCloudProviderGoogleDrive:
                [self processGoogleDriveFile:file];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Getters
- (NSString *)fileExtension {
    if (!_fileExtension) {
        // try to separate the fileName by '.' and return the last object.
        NSArray *components = [_fileName componentsSeparatedByString:@"."];
        _fileExtension = [components count] ? [components lastObject] : @"";
    }
    
    return _fileExtension;
}

#pragma mark - Public
- (BOOL)isFolder {
    BOOL isFolder = NO;
    if (self.provider == GDCloudProviderDropbox) {
        DBFileInfo *fileInfo = (DBFileInfo *)self.file;
        isFolder = [fileInfo isFolder];
    } else if (self.provider == GDCloudProviderGoogleDrive) {
        GTLDriveFile *driveFile = (GTLDriveFile *)self.file;
        isFolder = ![driveFile fileExtension];
    }
    
    return isFolder;
}

- (BOOL)validFileSize {
    if (_maxAllowedFileSize > 0) {
        return (self.size <= _maxAllowedFileSize);
    }
    
    return YES;
}

- (BOOL)validType {
    if ([_validFileTypes count]) {
        return [_validFileTypes containsObject:_fileExtension];
    }
    
    return YES;
}

#pragma mark - Private
- (void)processDropboxFile:(DBFileInfo *)fileInfo {
    self.fileName = [[fileInfo path] name];
    self.lastModifiedDate = [fileInfo modifiedTime];
    self.size = [fileInfo size];
    self.path = [fileInfo path];
}

- (void)processGoogleDriveFile:(GTLDriveFile *)file {
    self.fileName = file.title;
    self.lastModifiedDate = file.modifiedDate.date;
    self.size = [file.fileSize longLongValue];
    self.pathStr = file.identifier;
    self.fileExtension = file.fileExtension;
    self.file = file;
}

@end
