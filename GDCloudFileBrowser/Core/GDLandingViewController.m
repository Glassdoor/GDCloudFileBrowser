//
//  LMLandingViewController.m
//  LMCloudFilePicker
//
//  Created by Linto Mathew on 3/21/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import "GDLandingViewController.h"
#import "GDFilePickerViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface GDLandingViewController () <GDFilePickerDelegate>

@end

@implementation GDLandingViewController

- (instancetype)init {
    return [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - <GDFilePickerDelegate>
- (void)userPickedFileWithURL:(NSURL *)fileURL data:(NSData *)data fileUri:(NSString *)fileUri name:(NSString *)name {
    if ([data length]) {
        NSLog(@"the file share url is %@, fileData length is %lld fileUri is %@ and the file name is %@", fileURL, (long long)[data length], fileUri, name);
    }
}

#pragma mark - IBActions
- (IBAction)didTapDropboxButton:(id)sender {
    GDFilePickerViewController *pickerViewController = [[GDFilePickerViewController alloc] initWithDropboxProvider:YES path:@"/" delegate:self];
    [self.navigationController pushViewController:pickerViewController animated:YES];
}

- (IBAction)didTapGoogleDriveButton:(id)sender {
    GDFilePickerViewController *pickerViewController = [[GDFilePickerViewController alloc] initWithGoogleDriveProvider:YES path:@"root" folderName:@"root" delegate:self];
    [self.navigationController pushViewController:pickerViewController animated:YES];
}

@end
