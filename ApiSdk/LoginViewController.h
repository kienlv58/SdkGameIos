//
//  LoginViewController.h
//  ApiSdk
//
//  Created by Nguyen Tran Nhan on 12/16/17.
//  Copyright © 2017 nccsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDelegate.h"


@interface LoginViewController : UIViewController
@property(nonatomic,assign) id<Mydeledate> delegate;
@property(nonatomic,assign) NSString *game_id;

@end
