//
//  LMGoogleDriveManager.m
//  LMCloudFilePicker
//
//  Created by Linto Mathew on 3/22/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import "GDGoogleDriveHelper.h"
#import "GDCloudFile.h"
#import "KeysHelper.h"

static GDGoogleDriveHelper *manager = nil;

@interface GDGoogleDriveHelper ()

@property (nonatomic, strong, readwrite) GTLServiceDrive *driveService;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) GTLServiceTicket *serviceTicket;
@property (nonatomic, strong) GTMOAuth2Authentication *credentials;

@end

@implementation GDGoogleDriveHelper

@dynamic delegate;

+ (GDGoogleDriveHelper *)sharedManager {
    // using a synchronized instead of the dispatch_once token because we want to reset this to nil when the user logs out.
    @synchronized(self) {
        if (!manager) {
            manager = [[GDGoogleDriveHelper alloc] initWithProvider:GDCloudProviderGoogleDrive];
            
            // instantiate the driveService here instead of the init so we don't end up calling the service to get new accesstoken everytime this class is instantiated.
            manager.driveService = [[GTLServiceDrive alloc] init];
            
            GTMOAuth2Authentication *credentials = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:[manager gDriveKeychainName]
                                                                                                         clientID:[manager gDriveClientId]
                                                                                                     clientSecret:[manager gDriveClientSecret]];
            manager.credentials = credentials;
            [manager isAuthorizedWithAuthentication:credentials];
            
            NSString *savedRefreshToken = [credentials refreshToken];
            if ([credentials canAuthorize]) {
                if (savedRefreshToken && [savedRefreshToken length]) {
                    [manager retrieveNewAccessToken:savedRefreshToken]; // the user has granted access in the past, get a new access token
                }
            }
        }
        return manager;
    };
}

- (instancetype)init {
    if (self = [super initWithProvider:GDCloudProviderGoogleDrive]) {
        self.driveService = [[GDGoogleDriveHelper sharedManager] driveService];
        self.credentials = [[GDGoogleDriveHelper sharedManager] credentials];
        self.accessToken = [[GDGoogleDriveHelper sharedManager] accessToken];
        [self isAuthorizedWithAuthentication:self.credentials];
    }
    
    return self;
}

#pragma mark - Public
- (BOOL)driveAccessAuthorized {
    return [((GTMOAuth2Authentication *)self.driveService.authorizer) canAuthorize];
}

// Creates the auth controller for authorizing access to Google Drive.
- (GTMOAuth2ViewControllerTouch *)authController {
    GTMOAuth2ViewControllerTouch *authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDriveReadonly
                                                                                              clientID:[self gDriveClientId]
                                                                                          clientSecret:[self gDriveClientSecret]
                                                                                      keychainItemName:[self gDriveKeychainName]
                                                                                              delegate:self
                                                                                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

- (void)downloadGDriveFilesFrom:(NSString *)path completion:(CompletionHandler)completion {
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    
    // use explicitly set value otherwise use default value '500'
    query.maxResults = self.maxNumberOfResults ?: 500;
    
    query.fields = [self.requiredFields length] ? self.requiredFields : @"kind,items(id,downloadUrl,kind,title,fileExtension,fileSize,modifiedDate)";
    
    query.q = [NSString stringWithFormat:@"'%@' in parents and (%@) and trashed = false", path, [self.mimeTypes length] ? self.mimeTypes : [self defaultMimeTypes]];
    
    __weak GDGoogleDriveHelper *weakSelf = self;
    self.serviceTicket = [self.driveService executeQuery:query
                                       completionHandler:^(GTLServiceTicket *ticket,
                                                           GTLDriveFileList *fileList,
                                                           NSError *error) {
                                           __strong GDGoogleDriveHelper *strongSelf = weakSelf;
                                           
                                           NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:fileList.items.count];
                                           for (GTLDriveFile *file in fileList.items) {
                                               GDCloudFile *cloudFile = [[GDCloudFile alloc] initWithFile:file provider:strongSelf.provider];
                                               
                                               [items addObject:cloudFile];
                                           }
                                           
                                           [strongSelf updateContentsArray:items];
                                           
                                           if (completion) {
                                               completion(YES, error);
                                           }
                                       }];
}

- (BOOL)logoutUser {
    self.driveService.authorizer = nil;
    [self resetSharedInstance];
    return [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:[self gDriveKeychainName]];
}

#pragma mark - Private
- (void)updateContentsArray:(NSArray *)contents {
    [super updateContentsArray:contents];
}

// Handle completion of the authorization process, and updates the Drive service
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)authResult error:(NSError *)error {
    if (error) {
        self.driveService.authorizer = nil;
    } else {
        // a new authorization happens only from sharedManager so set the authResult to the sharedManger's instance and not self
        [GDGoogleDriveHelper sharedManager].credentials = authResult;
        [[GDGoogleDriveHelper sharedManager] isAuthorizedWithAuthentication:authResult];
        [GDGoogleDriveHelper sharedManager].accessToken = authResult.accessToken;
        
        if (![GTMOAuth2ViewControllerTouch saveParamsToKeychainForName:[self gDriveKeychainName] accessibility:kSecAttrAccessibleWhenUnlockedThisDeviceOnly authentication:authResult error:&error]) {
            NSLog(@"failed to authenticate user for google drive with error is %@", error.localizedDescription);
        }
    }
    
    [self.delegate googleDriveAuthenticationFinishedWithError:error];
}

- (NSString *)defaultMimeTypes {
    return @"mimeType ='application/pdf' or mimeType ='text/plain' or mimeType ='application/msword' or mimeType ='application/vnd.google-apps.folder' or mimeType ='application/vnd.google-apps.document' or mimeType='application/vnd.google-apps.file' or mimeType='application/vnd.openxmlformats-officedocument.wordprocessingml.document'";
}


- (void)resetSharedInstance {
    manager = nil; // reset the shared instance to nil since the user logged out.
}

- (void)retrieveNewAccessToken:(NSString *)refreshToken {
    NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/oauth2/v3/token"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    
    NSMutableString *mutableString = [NSMutableString new];
    [mutableString appendString:[NSString stringWithFormat:@"refresh_token=%@", refreshToken]];
    [mutableString appendString:[NSString stringWithFormat:@"&client_id=%@", [self gDriveClientId]]];
    [mutableString appendString:[NSString stringWithFormat:@"&client_secret=%@", [self gDriveClientSecret]]];
    [mutableString appendString:@"&grant_type=refresh_token"];
    
    NSString *params = [NSString stringWithString:mutableString];
    NSData *postData = [params dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *error;
        if (data) {
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            if (!error && results[@"access_token"]) {
                self.accessToken = results[@"access_token"];
            } else {
                NSString *errorMessage = error ? error.localizedDescription : NSLocalizedString(@"Please reauthenticate your Google Account to continue", nil);
                [[[UIAlertView alloc] initWithTitle:@"" message:errorMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
            }
        } else {
            NSString *errorMessage = connectionError ? connectionError.localizedDescription : NSLocalizedString(@"Please reauthenticate your Google Account to continue", nil);

            [[[UIAlertView alloc] initWithTitle:@"" message:errorMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        }
    }];
}

- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth {
    self.driveService.authorizer = auth;
}

- (NSString *)gDriveKeychainName {
    return [[KeysHelper sharedHelper] googleDriveClientKeychainName];
}

- (NSString *)gDriveClientId {
    return [[KeysHelper sharedHelper] googleDriveClientId];
}

- (NSString *)gDriveClientSecret {
    return [[KeysHelper sharedHelper] googleDriveClientSecret];
}

@end
