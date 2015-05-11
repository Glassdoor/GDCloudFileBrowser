//
//  AppDelegate.m
//  LMCloudFIleBrowser
//
//  Created by Linto Mathew on 3/21/15.
//  Copyright (c) 2015 Linto Mathew. All rights reserved.
//

#import "AppDelegate.h"
#import "LMFilePickerViewController.h"
#import <Dropbox/Dropbox.h>

@interface AppDelegate ()

@property (nonatomic, strong) UINavigationController *navController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    LMFilePickerViewController *filePickerVC = [[LMFilePickerViewController alloc] initWithDropboxProvider:YES path:[DBPath root] delegate:self];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:<#(UIViewController *)#>]

    return YES;
}

@end
