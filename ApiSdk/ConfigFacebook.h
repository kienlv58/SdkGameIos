//
//  ConfigFacebook.h
//  ApiSdk
//
//  Created by Nguyen Tran Nhan on 12/16/17.
//  Copyright © 2017 nccsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ConfigFacebook : NSObject
-(void)initFacebook:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
-(Boolean)initFacebookIos9:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
-(void)callFacebookApi:(UIView *)viewParrent;
@end
