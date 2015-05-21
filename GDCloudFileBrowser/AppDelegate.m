//
//  AppDelegate.m
//  GDCloudFileBrowser
//
//  Created by Linto Mathew on 3/21/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import "AppDelegate.h"
#import "GDLandingViewController.h"
#import <DropboxSDK/DropboxSDK.h>

extern NSString *const kGDDropboxLinkSuccessfull;

@interface AppDelegate ()

@property (nonatomic, strong) UINavigationController *navController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    GDLandingViewController *landingViewControlelr = [[GDLandingViewController alloc] init];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:landingViewControlelr];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navController;

    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            [[NSNotificationCenter defaultCenter] postNotificationName:kGDDropboxLinkSuccessfull object:nil];
        } else {
            NSLog(@"failed to link Dropbox. Check your Dropbox Client Id and Secret");
        }
        
        return YES;
    }
    
    // Add whatever other url handling code your app requires here
    return NO;
}

@end
