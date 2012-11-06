//
//  LoginViewController.m
//  misawa
//
//  Created by Shinya Akiba on 12/11/02.
//  Copyright (c) 2012年 Shinya Akiba. All rights reserved.
//

#import "LoginViewController.h"
#import "TabBarController.h"
#import "HttpClient.h"
#import "ASIFormDataRequest.h"

@interface LoginViewController ()
{
    NSString *userName;
    NSString *uuID;
    UITextField *textField;
}
@end

@implementation LoginViewController

@synthesize btnLogin;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLogin setImage:[UIImage imageNamed:@"login_with_twitter.png"] forState:UIControlStateNormal];
    [btnLogin setTitle:@"login" forState:UIControlStateNormal];
    [btnLogin addTarget:self action:@selector(getUuid) forControlEvents:UIControlEventTouchUpInside];
    btnLogin.frame = CGRectMake(20, 100, 280, 45);
    [self.view addSubview:btnLogin];
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(30, 30, 260, 35)];
    textField.delegate = self;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:textField];
    
    
    NSLog(@"LoginViewController_viewDidLoad");
}

-(BOOL)textFieldShouldReturn:(UITextField*)txField {
    [txField resignFirstResponder];
    return YES;
}

- (void) getUuid {
    if (![textField.text length]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"タイトル"
                                                        message:@"ユーザー名が入力されていません。"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil
                              ];
        [alert show];
    } else {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        NSLog(@"uuid:%@", uuidStr);
        
        uuID = uuidStr;
        userName = textField.text;
        
        NSString *getURL = [NSString stringWithFormat:@"%@%@", MISAWA_URL, @"/api/user"];
        NSString *encURL = [getURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:encURL]];

        [request setPostValue:textField.text forKey:@"name"];
        [request setPostValue:uuidStr forKey:@"uuid"];
        [request setDelegate:self];
        SEL mysel = @selector(requestDone:);
        [request setDidFinishSelector: mysel];
        [request setDidFailSelector:@selector(requestWentWrong:)];
        [request startAsynchronous];
    }
}

- (void) requestDone:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"isLogined"]) {
        [defaults setObject:userName forKey:@"user_name"];
        [defaults setObject:uuID forKey:@"uuID"];
    }
    [defaults setObject:@"YES" forKey:@"isLogined"];
    [defaults synchronize];
//    NSLog(@"heey%@:", [defaults objectForKey:@"uuID"]);
    [self nextView];
}

- (void) nextView {
    TabBarController *tabViewController = [[TabBarController alloc] init];
//    [self presentModalViewController:tabViewController animated:YES];
    [self presentViewController:tabViewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
