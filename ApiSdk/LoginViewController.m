//
//  LoginViewController.m
//  ApiSdk
//
//  Created by Nguyen Tran Nhan on 12/16/17.
//  Copyright © 2017 nccsoft. All rights reserved.
//

#import "LoginViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKCoreKit/FBSDKProfile.h>
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "Define.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UILabel *btn_register;
@property (weak, nonatomic) IBOutlet UIView *viewRegister;
@property (weak, nonatomic) IBOutlet UIView *viewLogin;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *email_register;
@property (weak, nonatomic) IBOutlet UITextField *password_register;
@property (weak, nonatomic) IBOutlet UITextField *re_password_register;


@end

@implementation LoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLabelWithGesture:)];
    [_btn_register setUserInteractionEnabled:YES];
    [_btn_register addGestureRecognizer:gesture];
}

- (void)didTapLabelWithGesture:(UITapGestureRecognizer *)tapGesture {
    _viewLogin.hidden = true;
    _viewRegister.hidden = false;
    
    
}


- (IBAction)btn_close:(id)sender {
    _viewLogin.hidden = false;
    _viewRegister.hidden = true;
}

- (IBAction)act_login:(id)sender {
    NSString *email = _email.text;
    NSString *password = _password.text;
    if(email.length == 0 || ![self NSStringIsValidEmail:email]){
        [self showAlert:@"Email invalid"];
    }else if(password.length < 6){
        [self showAlert:@"Password invalid"];
    }else{
        [self loginWithAccount:email password:password game_id:_game_id success:^(NSString *result) {
            [self.delegate loginSuccess];
            
        } failure:^(NSString *result) {
            [self showAlert:result];
        }];
    }
    
    
    
}
- (IBAction)act_sigup:(id)sender {
    NSString * name = _name.text;
    NSString * email = _email_register.text;
    NSString *pass = _password_register.text;
    NSString *re_pass = _re_password_register.text;
    if(![self NSStringIsValidEmail:email]){
        [self showAlert:@"Email invalid"];
    }else if(name.length == 0){
        [self showAlert:@"Name invalid"];
    }else if(pass.length < 6 || re_pass.length < 6 || ![pass isEqualToString:re_pass] ){
        [self showAlert:@"Password invalid"];
    }else{
        // call api
        [self registerWithEmail:email name:name password:pass game_id:_game_id os_type:@"IOS" success:^(NSString *result) {
            [self showAlert:@"Register Success"];
            _viewLogin.hidden = false;
            _viewRegister.hidden = true;
            
        } failure:^(NSString *result) {
            [self showAlert:result];
            
        }];
    }
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
-(void)showAlert:(NSString*)contentShow{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notification" message:contentShow preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:actionOk];
    [self presentViewController:alert animated:true completion:nil ];
}

- (IBAction)act_loginfb:(id)sender {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             NSLog(@"Logged in");
             
             NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
             [parameters setValue:@"id,name,email,first_name,last_name" forKey:@"fields"];
             
             [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
              startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                           id result, NSError *error) {
                  if(!error){
                      NSString *fbAccessToken = [FBSDKAccessToken currentAccessToken].tokenString;
                      NSLog(@"token: %@ \n,info profile success: %@",fbAccessToken, result);
                      NSString *first_name = [result objectForKey:@"first_name"];
                      NSString *last_name = [result objectForKey:@"last_name"];
                      NSString *email = [result objectForKey:@"email"];
                      NSString *fbid = [result objectForKey:@"id"];
                      
                      [self loginWithFacebook:fbid fb_token:fbAccessToken last_name:last_name first_name:first_name email:email?email:@"" phone:@"" os_type:@"IOS" game_id:_game_id success:^(NSString *result) {
                          [self.delegate loginSuccess];
                          
                      } failure:^(NSString *result) {
                          [self showAlert:result];
                      }];
                      
                      
                      
                  }else{
                      [self showAlert:@"can't get info profile"];
                      NSLog(@"info profile error: %@",error);
                  }
                 
              }];
             
             
         }
     }];
}

//register
- (void)registerWithEmail:(NSString *)email
                 name:(NSString *)name
                 password:(NSString *)password
                   game_id:(NSString *)game_id
                  os_type:(NSArray*)os_type
                  success:(void (^)(NSString *))success
                  failure:(void (^)(NSString *))failure
{
    NSURL *baseURL = [NSURL URLWithString:API_URL_DOMAIN];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    manager.requestSerializer = requestSerializer;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary *parameters = @{@"game_id" : game_id, @"email": email, @"name": name, @"password": password,@"os_type":os_type};
    
    [manager POST:API_URL_REGISTER parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
                NSString *code = [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"code"]];
                NSLog(@"----code: %@ ,result register %@",code,responseObject);
        
                if ([code isEqualToString:@"1"]) {
                    success(@"register success");
                } else {
                    NSString *message = [responseObject valueForKey:@"message"];
                    failure(message);
                }
        
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure([error localizedDescription]);
        
    }];
}
//login with account
- (void)loginWithAccount:(NSString *)email
                 password:(NSString *)password
                  game_id:(NSString *)game_id
                  success:(void (^)(NSString *))success
                  failure:(void (^)(NSString *))failure
{
    NSURL *baseURL = [NSURL URLWithString:API_URL_DOMAIN];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    manager.requestSerializer = requestSerializer;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary *parameters = @{@"game_id" : game_id, @"email": email, @"password": password};
    
    [manager POST:API_URL_LOGIN parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"code"]];
        NSLog(@"----code: %@ ,result login %@",code,responseObject);
        
        if ([code isEqualToString:@"1"]) {
            NSDictionary *data = [responseObject objectForKey:@"data"];
            NSString *token_login = [data objectForKey:@"token"];
            [[NSUserDefaults standardUserDefaults] setObject:token_login forKey:@"token_login"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"token: %@",token_login);
            
            success(@"login success");
        } else {
            NSString *message = [responseObject valueForKey:@"message"];
            failure(message);
        }
        
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure([error localizedDescription]);
        
    }];
}

//login with facebook
- (void)loginWithFacebook:(NSString *)fb_uid
                fb_token:(NSString *)fb_token
                last_name:(NSString *)last_name
                first_name:(NSString *)first_name
                email:(NSString *)email
                phone:(NSString *)phone
                os_type:(NSString *)os_type
                game_id:(NSString *)game_id
                success:(void (^)(NSString *))success
                failure:(void (^)(NSString *))failure
{
    NSURL *baseURL = [NSURL URLWithString:API_URL_DOMAIN];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    manager.requestSerializer = requestSerializer;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary *parameters = @{@"fb_uid" : fb_uid, @"fb_token": fb_token, @"last_name": last_name,@"first_name":first_name,@"email" : email, @"phone": phone, @"os_type": os_type,@"game_id":game_id};
    
    [manager POST:API_URL_LOGIN_FB parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString *code = [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"code"]];
        NSLog(@"----code: %@ ,result login %@",code,responseObject);
        
        if ([code isEqualToString:@"1"]) {
            NSDictionary *data = [responseObject objectForKey:@"data"];
            NSString *token_login = [data objectForKey:@"token"];
            [[NSUserDefaults standardUserDefaults] setObject:token_login forKey:@"token_login"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"token: %@",token_login);
            
            success(@"login success");
        } else {
            NSString *message = [responseObject valueForKey:@"message"];
            failure(message);
        }
        
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        failure([error localizedDescription]);
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
