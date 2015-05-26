//
//  GDFilePickerViewController.m
//  GDCloudFileBrowser
//
//  Created by Linto Mathew on 3/21/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import "GDFilePickerViewController.h"
#import "GDCloudFile.h"
#import "GDCloudProviderHelper.h"
#import "GDDropboxHelper.h"
#import "GDGoogleDriveHelper.h"
#import "GDCloudContentBrowserCell.h"
#import "GDQuickPreviewViewController.h"
#import <DropboxSDK/DropboxSDK.h>

static NSString *const kTableViewCellReuseIdentifier = @"TableView Cell Reuse Identifier";

@interface GDFilePickerViewController () <UITableViewDataSource, UITableViewDelegate, GDCloudProviderDelegate, GDQuickPreviewDelegate>

@property (nonatomic) GDCloudProvider provider;
@property (nonatomic, getter = isRoot) BOOL root;
@property (nonatomic, strong) NSString *dropboxPath;
@property (nonatomic, copy) NSString *gDrivePath;
@property (nonatomic, strong, readwrite) NSString *gDriveFileUri;
@property (nonatomic, strong) GDDropboxHelper *dropboxHelper;
@property (nonatomic, strong) GDGoogleDriveHelper *googleDriveHelper;
@property (nonatomic, weak) id <GDFilePickerDelegate> delegate;
@property (weak, nonatomic, readwrite) IBOutlet UITableView *tableView;

@end

@implementation GDFilePickerViewController

#pragma mark - Init methods
- (instancetype)initWithDropboxProvider:(BOOL)isRoot path:(NSString *)path delegate:(id <GDFilePickerDelegate>)delegate {
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil]) {
        self.delegate = delegate;
        self.provider = GDCloudProviderDropbox;
        self.root = isRoot;
        self.dropboxPath = path;
        
        [self commonInit];

        self.dropboxHelper = [[GDDropboxHelper alloc] initWithDelegate:self];
    }
    
    return self;
}

- (instancetype)initWithGoogleDriveProvider:(BOOL)isRoot path:(NSString *)path folderName:(NSString *)folderName delegate:(id <GDFilePickerDelegate>)delegate {
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil]) {
        self.delegate = delegate;
        self.provider = GDCloudProviderGoogleDrive;
        self.root = isRoot;
        self.gDrivePath = path;
        self.gDriveFileUri = folderName;
        
        [self commonInit];
        
        // if it's the root folder, use the sharedManager which retrieve a new access token from the google server
        // if it's no the root folder, use the normal init to instantiate, which will use the accessToken from the sharedManager
        // we could also avoid this and store the accessToken in any static class but to keep everything together, use a static version of the GDGoogleDriveManager
        if (isRoot) {
            self.googleDriveHelper = [GDGoogleDriveHelper sharedManager];
        } else {
            self.googleDriveHelper = [[GDGoogleDriveHelper alloc] init];
        }
        
        self.googleDriveHelper.delegate = self;
    }
    
    return self;
}

- (void)commonInit {
    
}

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *cloudContentCell = [UINib nibWithNibName:NSStringFromClass([GDCloudContentBrowserCell class]) bundle:nil];
    [self.tableView registerNib:cloudContentCell forCellReuseIdentifier:kTableViewCellReuseIdentifier];
    self.tableView.rowHeight = 65.0f;
    self.tableView.separatorInset = UIEdgeInsetsMake(0.0f, 45.0f, 0.0f, 0.0f);
    
    if (self.provider == GDCloudProviderDropbox) {
        if (![self.dropboxHelper dropboxAccountLinked]) { // no accounts are currently linked.
            [[DBSession sharedSession] linkFromController:self];
        } else {
            [self downloadDropboxFiles];
        }
    } else if (self.provider == GDCloudProviderGoogleDrive) {
        if (![self.googleDriveHelper driveAccessAuthorized]) {
            // Not yet authorized, request authorization and push the login UI onto the navigation stack.
            // include a delay otherwise it wouldn't work on iOS 7 (complain about nested push). 2sec is plenty of time to reach viewDidAppear
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:[self.googleDriveHelper authController] animated:YES];
            });
        } else {
            [self downloadGDriveFiles];
        }
    }
}

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView willDisplayCell:(GDCloudContentBrowserCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *contents = [[self cloudProviderManager] contents];
    if ([contents count]) {
        if (indexPath.row == 0) {
            // we show a 'Folder is empty' label in the first row of the tableView if the folder's contents are nil
            // so reset that cell if it's reused.
            [cell resetForReuse];
        }
        
        GDCloudFile *cloudFile = contents[indexPath.row];
        cell.fileName = cloudFile.fileName;
        cell.lastModifiedTime = cloudFile.lastModifiedTime;
        cell.size = cloudFile.size;
        cell.file = cloudFile;
        
        NSString *detailText;
        if ([cell showingFolder]) {
            detailText = [NSString stringWithFormat:@"%@ %@", @"Modified", cell.lastModifiedTime];
        } else {
            detailText = [NSString stringWithFormat:@"%@, %@ %@", cell.userFriendlyFileSize, @"Modified", cell.lastModifiedTime];
        }
        
        cell.subtitle = detailText;
    } else {
        [cell setupCellForEmptyFolder];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GDCloudContentBrowserCell *cell = (GDCloudContentBrowserCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    NSArray *contents = self.cloudProviderManager.contents;
    if ([contents count]) {
        GDCloudFile *cloudFile = contents[indexPath.row];
        if ([cloudFile isFolder]) {
            GDFilePickerViewController *filePickerViewController;
            if (self.provider == GDCloudProviderDropbox) {
                filePickerViewController = [[GDFilePickerViewController alloc] initWithDropboxProvider:NO path:[cloudFile path] delegate:self.delegate];
            } else if (self.provider == GDCloudProviderGoogleDrive) {
                NSString *fileUri = [NSString stringWithFormat:@"%@/%@", self.gDriveFileUri, cloudFile.fileName];
                filePickerViewController = [[GDFilePickerViewController alloc] initWithGoogleDriveProvider:NO path:cloudFile.pathStr folderName:fileUri  delegate:self.delegate];
            }
            
            [self.navigationController pushViewController:filePickerViewController animated:YES];
        } else {
            [self previewFile:cloudFile];
        }
    }
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(1, [self.cloudProviderManager.contents count]); // use 1 row to show the error message if there's no content.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GDCloudContentBrowserCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellReuseIdentifier];
    if ([self.cloudProviderManager.contents count]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.provider = self.provider;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

#pragma mark - <GDCloudProviderDelegate>
- (void)googleDriveAuthenticationFinishedWithError:(NSError *)error {
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    } else {
        [self downloadGDriveFiles];
    }
}

- (void)dropboxAuthenticationFinishedWithError:(NSError *)error {
    if (!error) {
        [self downloadDropboxFiles];
    } else {
        NSLog(@"Dropbox authentication failed with error %@", error.localizedDescription);
    }
}

#pragma mark - <GDQuickPreviewDelegate>
- (void)userSelectedDropboxFileWithURL:(NSString *)url data:(NSData *)fileData relativePath:(NSString *)relativePath name:(NSString *)fileName {
    if ([self.delegate respondsToSelector:@selector(userPickedFileWithURL:data:fileUri:name:)]) {
        [self.delegate userPickedFileWithURL:[NSURL URLWithString:url] data:fileData fileUri:relativePath name:fileName];
    }
}

- (void)userSelectedGoogleDriveFileWithURL:(NSString *)url data:(NSData *)fileData name:(NSString *)fileName {
    if ([self.delegate respondsToSelector:@selector(userPickedFileWithURL:data:fileUri:name:)]) {
        NSString *fileUri = [NSString stringWithFormat:@"%@/%@", self.gDriveFileUri, fileName];
        [self.delegate userPickedFileWithURL:[NSURL URLWithString:url] data:fileData fileUri:fileUri name:fileName];
    }
}

#pragma mark - Private
- (void)downloadGDriveFiles {
    __weak GDFilePickerViewController *weakSelf = self;
    [self.googleDriveHelper downloadFilesFrom:self.gDrivePath completion:^(BOOL success, NSError *error) {
        __strong GDFilePickerViewController *strongSelf = weakSelf;
        
        if (success && !error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![strongSelf.googleDriveHelper.contents count]) {
                    strongSelf.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                    strongSelf.tableView.tableHeaderView = nil;
                } else {
                    strongSelf.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                }
                [strongSelf.tableView reloadData];
            });
        } else {
            [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Unable to download files", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        }
    }];
}

- (void)previewFile:(GDCloudFile *)cloudFile {
    BOOL isValidSize = [cloudFile validFileSize];
    if (isValidSize && [cloudFile validType]) {
        GDQuickPreviewViewController *quickPreviewViewController = [[GDQuickPreviewViewController alloc] initWithFile:cloudFile provider:self.provider delegate:self];

        [self.navigationController pushViewController:quickPreviewViewController animated:YES];
    } else if (isValidSize) {
        [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"You can only import .docx, .doc, .pdf or .txt files", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"The file exceeds maximum size.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
}

- (void)downloadDropboxFiles {
    __weak GDFilePickerViewController *weakSelf = self;
    [self.dropboxHelper downloadFilesFrom:self.dropboxPath completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            GDFilePickerViewController *strongSelf = weakSelf;
            if (![strongSelf.dropboxHelper.contents count]) {
                strongSelf.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                strongSelf.tableView.tableHeaderView = nil;
            } else {
                strongSelf.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            }
            
            [strongSelf.tableView reloadData];
        });
    }];
}

#pragma mark - Getters
- (GDCloudProviderHelper *)cloudProviderManager {
    switch (self.provider) {
        case GDCloudProviderDropbox:
            return self.dropboxHelper;
            break;
        case GDCloudProviderGoogleDrive:
            return self.googleDriveHelper;
            break;
        default:
            NSAssert(0, @"Unknown provider");
            break;
    }
    
    return nil;
}

@end
