//
//  ConfigFacebook.m
//  ApiSdk
//
//  Created by Nguyen Tran Nhan on 12/16/17.
//  Copyright © 2017 nccsoft. All rights reserved.
//

#import "ConfigFacebook.h"
#import "LoginViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@implementation ConfigFacebook
-(void)initFacebook:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
}

-(Boolean)initFacebookIos9:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];
    return handled;
}
-(UIViewController *)callFacebookApi{
    LoginViewController *login = [[LoginViewController alloc]init];
    return login;
}

@end
