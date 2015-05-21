//
//  GDCloudFile.h
//  GDSalary
//
//  Created by Linto Mathew on 3/17/15.
//  Copyright (c) 2015 Glassdoor Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef  NS_ENUM(NSUInteger, GDCloudProvider) {
    GDCloudProviderDropbox = 1,
    GDCloudProviderGoogleDrive,
};

typedef NS_ENUM(NSUInteger, GDFileType) {
    GDFileTypeDoc = 1,
    GDFileTypeDocx,
    GDFileTypePdf,
    GDFileTypeTxt,
    GDFileTypeRtf,
    GDFileTypeFolder,
    GDFileTypeImage,
    GDFileTypeOther
};

@interface GDCloudFile : NSObject

/**
 provider A readonly property that shows the file type as an 'LMCloudProvider' enum
 */
@property (nonatomic, readonly) GDCloudProvider provider;

/**
 fileName The name of the file
 */
@property (nonatomic, copy, readonly) NSString *fileName;

/**
 lastModifiedDate The last modified date of a LMCloudFile, if available
 @returns a valid NSDate object if data is available. Otherwise nil.
 */
@property (nonatomic, strong, readonly) NSDate *lastModifiedDate;

/**
 lastModifiedTime The last modified date of a LMCloudFile as an NSString object, if available
 @returns a valid NSString object if data is available. Otherwise nil.
 */
@property (nonatomic, copy, readonly) NSString *lastModifiedTime;

/**
 fileExtension The extension of a given 'file' [.docx, .pdf etc]
 */
@property (nonatomic, copy, readonly) NSString *fileExtension;

/**
 pathStr The path to this LMCloudFile object as an NSString object.
 @returns nil if unavailable
 */
@property (nonatomic, copy, readonly) NSString *pathStr;

/**
 path The path object of type id. Dropbox for example, has their own DBPath object
 @returns nil if unavailable
 */
@property (nonatomic, strong, readonly) id path;

/**
 size The size of the LMCloudFile in long long value
 @returns 0 if unavailable
 */
@property (nonatomic, readonly) long long size;

/**
 maxAllowedFileSize Maximum allowed size of a file in Bytes. Use the helper method validFileSize to find out if the file is not over the limit
 */
@property (nonatomic) long long maxAllowedFileSize;

/**
 validFileTypes An array of valid file extensions as NSString. Eg. @[@"docx", @"pdf"] etc.
 */
@property (nonatomic, copy) NSArray *validFileTypes;

/**
 file The original file object (DBMetadata for Dropbox, GTLDriveFile for Google Drive)
 */
@property (nonatomic, strong, readonly) id file;

/**
 initWithProvider:file: Instantiate a LMCloudFile object with a file provide argument and the original file
 @param file The original file or folder
 @param provider A 'LMCloudProvider' enum
 @returns self
 */
- (instancetype)initWithFile:(id)file provider:(GDCloudProvider)provider;

/**
 isFolder A helper method to find out if the given file is a folder or not
 @returns YES if current file is a folder, otherwise NO
 */
- (BOOL)isFolder;

/**
 validFileSize A helper method to find out if the given file's size is within the maxAllowedFileSize (should be set after the object is instantiated)
 @returns YES if file's size is less than the maxAllowedFileSize. Also returns YES if maxAllowedFileSize is never set.
 */
- (BOOL)validFileSize;

/**
 validType A helper method to find out if the given file type is valid. Used in conjuction with validFileTypes
 @returns YES if file's extension is found in the validFileTypes, otherwise NO
 */
- (BOOL)validType;

@end
