//
//  NGResultViewController.m
//  numgame
//
//  Created by Sun Xi on 4/29/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "NGResultViewController.h"
#import "NGGameViewController.h"
@import Social;

@interface NGResultViewController ()

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;

@end

@implementation NGResultViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_shareButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:30]];
    [_titleLabel setFont:[UIFont fontWithName:TITLE_FONT size:40]];
    UIToolbar* blurView = [[UIToolbar alloc]initWithFrame:self.view.bounds];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:self.prevBgImageView atIndex:0];
    [self.view insertSubview:blurView atIndex:1];
    _highScoreLabel.adjustsFontSizeToFitWidth = YES;
    if (_gameMode == NGGameModeClassic) {
        if (_isHighScore) {
            [_highScoreLabel setText:NSLocalizedString(@"New Best Record!",@"xx")];
            if( !_completed)
            {
                [_highScoreLabel setText:NSLocalizedString(@"New Best Record!",@"xx")];
                //[_backButton setTitle:@"Try Again" forState:UIControlStateNormal];
                _backButton.hidden = YES;
            }
        } else {
            if (_completed) {
                [_highScoreLabel setText:NSLocalizedString(@"Score at this round",@"xx")];
            } else {
                [_highScoreLabel setText:NSLocalizedString(@"Fail!",@"xx")];
                [_backButton setTitle:NSLocalizedString(@"Try Again",@"xx") forState:UIControlStateNormal];
            }
        }
        [_scoreLabel setText:_score];
        [_modeLabel setText:NSLocalizedString(@"Classic Mode", @"xx")];
    } else if (_gameMode == NGGameModeTimed || _gameMode == NGGameModeSteped) {
        [_backButton setTitle:NSLocalizedString(@"Try Again",@"xx") forState:UIControlStateNormal];
        if (_isHighScore) {
            [_highScoreLabel setText:NSLocalizedString(@"New Best Record!",@"xx")];
            [_scoreLabel setText:_score];
        } else {
            [_highScoreLabel setText:NSLocalizedString(@"Score at this round",@"xx")];
            [_scoreLabel setText:_score];
        }
        [_modeLabel setText:NSLocalizedString(@"Time Mode",@"xx")];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[_gADInterstitial presentFromRootViewController:self];
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

- (IBAction)onPlayAgain:(UIButton *)sender {
    //[self.navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onBack:(UIButton*)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        //[self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

- (IBAction)onShare:(UIButton*)sender {
    
    NSString *textToShare = NSLocalizedString(@"A really good game to play :)",@"xx");
    
    if (_gameMode == NGGameModeClassic){
        if (_isHighScore) {
            textToShare = NSLocalizedString(@"I just have got my new record in game Num Dots!",@"xx");
        }
    } else if (_gameMode == NGGameModeTimed) {
        if (_isHighScore) {
            textToShare = NSLocalizedString(@"I just have got my new high score in game Num Dots!",@"xx");
        }
    }
    
    CGRect rect = [self.view bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage *capturedScreen = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *imageToShare = capturedScreen?:[UIImage new];
    
    NSURL *urlToShare = [NSURL URLWithString:@"https://itunes.apple.com/us/app/tap-tap-num/id870428896?ls=1&mt=8"];
    
    NSArray *activityItems = @[textToShare, imageToShare, urlToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    
    //不出现在活动项目
    
//    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
    
    [self presentViewController:activityVC animated:TRUE completion:nil];
}

@end
