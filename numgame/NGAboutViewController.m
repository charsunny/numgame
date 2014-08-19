//
//  NGAboutViewController.m
//  numgame
//
//  Created by Sun Xi on 5/6/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "NGAboutViewController.h"
@import MessageUI;

@interface NGAboutViewController ()<MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation NGAboutViewController

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
    [_backButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:30]];
    [_titleLabel setFont:[UIFont fontWithName:TITLE_FONT size:40]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"About Screen";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)onClickButton:(UIButton*)sender {
    if ([sender.titleLabel.text isEqualToString:@"Email"]) {
        [self sendMail];
    } else if([sender.titleLabel.text isEqualToString:@"Facebook"]) {
        [[[UIAlertView alloc] initWithTitle:@"tips" message:@"@charsunny @lanstonpeng" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    } else if([sender.titleLabel.text isEqualToString:@"Twitter"]) {
        [[[UIAlertView alloc] initWithTitle:@"tips" message:@"@charsunny @lanstonpeng" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"tips" message:@"😕" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

- (void)sendMail {
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject: @"[4 Dots]Suggestion"];
    //添加收件人
    NSArray *toRecipients = @[@"charsunny@gmail.com",@"lanstonpeng@gmail.com"];
    [mailPicker setToRecipients: toRecipients];
    
    NSString *emailBody = @"I have some to say about the game: \n";
    
    [mailPicker setMessageBody:emailBody isHTML:YES];
    
    [self presentViewController: mailPicker animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //关闭邮件发送窗口
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
