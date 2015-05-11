//
//  GDQuickPreviewViewController.m
//  GDSalary
//
//  Created by Linto Mathew on 7/23/14.
//  Copyright (c) 2014 Glassdoor Inc. All rights reserved.
//

#import "GDQuickPreviewViewController.h"
#import <Dropbox/Dropbox.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "GTLDrive.h"
#import "GDGoogleDriveHelper.h"

@interface GDQuickPreviewViewController () <UIWebViewDelegate>

@property (nonatomic) GDCloudProvider provider;
@property (nonatomic, strong) GDCloudFile *cloudFile;
@property (nonatomic, strong) NSString *relativePath;
@property (nonatomic, strong) NSString *userFriendlyName;
@property (nonatomic, strong) NSString *shareUrl;
@property (nonatomic, strong) NSString *cacheDirectoryPath;
@property (nonatomic, strong) DBFileInfo *dbFileInfo;
@property (nonatomic, weak) id <GDQuickPreviewDelegate> delegate;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIBarButtonItem *confirmBarButton;
@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation GDQuickPreviewViewController

- (instancetype)initWithFile:(GDCloudFile *)cloudFile provider:(GDCloudProvider)provider delegate:(id <GDQuickPreviewDelegate>)delegate {
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil]) {
        self.provider = provider;
        self.cloudFile = cloudFile;
        self.delegate = delegate;
        self.cacheDirectoryPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    confirmButton.frame = CGRectMake(0.0f, 0.0f, 80.0f, 40.0f);
    [confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(didTapConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.confirmBarButton = [[UIBarButtonItem alloc] initWithCustomView:confirmButton];
    self.confirmBarButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.confirmBarButton;
    
    if (self.provider == GDCloudProviderDropbox) {
        [self openDropboxFile];
    } else if (self.provider == GDCloudProviderGoogleDrive) {
        [self openGoogleDriveFile];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.title = self.cloudFile.fileName;
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.webView stopLoading];
}

#pragma mark - <UIWebViewDelegate>
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    webView.scalesPageToFit = YES;
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.confirmBarButton.enabled = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Unable to open file.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
}

#pragma mark - Private
- (void)didTapConfirmButton:(id)sender {
    if (self.provider == GDCloudProviderDropbox) {
        if ([self.delegate respondsToSelector:@selector(userSelectedDropboxFileWithURL:data:relativePath:name:)]) {
            NSData *fileData = [NSData dataWithContentsOfFile:[self fileUri]];
            [self.delegate userSelectedDropboxFileWithURL:self.shareUrl data:fileData relativePath:self.relativePath name:self.userFriendlyName];
        } else {
            NSLog(@"delegate doesn't respond to @selector(userSelectedDropboxFileWithURL:data:relativePath:name:)");
        }
    } else if (self.provider == GDCloudProviderGoogleDrive) {
        if ([self.delegate respondsToSelector:@selector(userSelectedGoogleDriveFileWithURL:data:name:)]) {
            NSData *fileData = [NSData dataWithContentsOfFile:[self fileUri]];
            [self.delegate userSelectedGoogleDriveFileWithURL:self.shareUrl data:fileData name:self.userFriendlyName];
        } else {
            NSLog(@"delegate doesn't respond to @selector(userSelectedGoogleDriveFileWithURL:data:name:)");
        }
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)openFileWithData:(NSData *)fileData {
    @autoreleasepool {
        [fileData writeToFile:[self fileUri] atomically:YES]; // write to a file location and use the url to the file to open it instead of dealing with NSData and various mimeTypes.
    }
    
    self.url = [NSURL fileURLWithPath:[self fileUri]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    });
}

- (NSString *)fileUri {
    return [self.cacheDirectoryPath stringByAppendingPathComponent:self.userFriendlyName];
}

- (void)openDropboxFile {
    // Linto..share url and openFile: must be called from a background thread.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        DBPath *path = [self.dbFileInfo path];
        DBFile *file = [[DBFilesystem sharedFilesystem] openFile:path error:&error];
        
        self.relativePath = [path stringValue];
        self.userFriendlyName = [path name];
        self.shareUrl = [[DBFilesystem sharedFilesystem] fetchShareLinkForPath:path shorten:NO error:&error];
       

        NSData *fileData = [file readData:&error];
        if (!error && fileData) {
            [self openFileWithData:fileData];
        } else {
            [self showUnableToOpenFile];
        }
    });
}

- (void)openGoogleDriveFile {
    GTLServiceDrive *drive = [[GDGoogleDriveHelper sharedManager] driveService];
    GTLDriveFile *file = (GTLDriveFile *)self.cloudFile.file;
    GTMHTTPFetcher *fetcher = [drive.fetcherService fetcherWithURLString:file.downloadUrl];
    
    self.shareUrl = file.downloadUrl;
    self.userFriendlyName = file.title;
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        if (!error && data) {
            [self openFileWithData:data];
        } else {
            [self showUnableToOpenFile];
        }
    }];
}

- (void)showUnableToOpenFile {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Unable to open file.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    });
}

#pragma mark - Getters
- (DBFileInfo *)dbFileInfo {
    if (!_dbFileInfo) {
        _dbFileInfo = (DBFileInfo *)self.cloudFile.file;
    }
    
    return _dbFileInfo;
}

@end
