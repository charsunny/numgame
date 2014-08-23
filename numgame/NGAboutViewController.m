//
//  NGAboutViewController.m
//  numgame
//
//  Created by Sun Xi on 5/6/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "NGAboutViewController.h"
#import "NGPlayer.h"
#import <pop/pop.h>
@import MessageUI;

@interface NGAboutViewController ()<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIView *panel;

@end

@implementation NGAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_backButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:30]];
    for (UIButton* button in [_panel subviews]) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:40]];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [UIView animateWithDuration:0.3 animations:^{
        _backButton.transform = CGAffineTransformMakeRotation(- M_PI / 2);
    }];
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
    switch (sender.tag) {
        case 1:
            [[[UIAlertView alloc] initWithTitle:@"tips" message:@"@charsunny @lanstonpeng" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            break;
        case 2:
            [[[UIAlertView alloc] initWithTitle:@"tips" message:@"😕" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            break;
        case 3:
            [self sendMail];
            break;
        case 4:
            [[[UIAlertView alloc] initWithTitle:@"tips" message:@"@charsunny @lanstonpeng" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            break;
        default:
            break;
    }
    
    [[NGPlayer player] playSoundFXnamed:@"item_click.mp3" Loop:NO];
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.velocity = [NSValue valueWithCGSize:CGSizeMake(3.f, 3.f)];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
    scaleAnimation.springBounciness = 18.0f;
    [sender.layer pop_addAnimation:scaleAnimation forKey:@"scoreScaleSpring"];
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
