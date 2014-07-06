//
//  NGResultViewController.m
//  numgame
//
//  Created by Sun Xi on 4/29/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "NGResultViewController.h"
@import Social;

@interface NGResultViewController ()

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet
UILabel *modeLabel;

@end

@implementation NGResultViewController

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
    [_shareButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:30]];
    [_titleLabel setFont:[UIFont fontWithName:TITLE_FONT size:40]];
    if (_gameMode == NGGameModeClassic) {
        if (_isHighScore) {
            [_highScoreLabel setText:@"new best record!"];
            [_scoreLabel setText:[_time stringByAppendingString:@"s"]];
        } else {
            if (_completed) {
                [_highScoreLabel setText:@"time this round :"];
                [_scoreLabel setText:[_time stringByAppendingString:@"s"]];
            } else {
                [_highScoreLabel setText:@"fail to finish! "];
                [_scoreLabel setText:@"😕"];
            }
        }
        [_modeLabel setText:@"classic mode"];
    } else if (_gameMode == NGGameModeTimed) {
        if (_isHighScore) {
            [_highScoreLabel setText:@"new high score!"];
            [_scoreLabel setText:_score];
        } else {
            [_highScoreLabel setText:@"score this round :"];
            [_scoreLabel setText:_score];
        }
        [_modeLabel setText:@"timed mode"];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[_gADInterstitial presentFromRootViewController:self];
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
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onBack:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onShare:(UIButton*)sender {
    
    NSString *textToShare = @"A really good game to play!";
    
    if (_gameMode == NGGameModeClassic){
        if (_isHighScore) {
            textToShare = @"I just have got my new record in game tap tap number!";
        }
    } else if (_gameMode == NGGameModeTimed) {
        if (_isHighScore) {
            textToShare = @"I just have got my new high score in game tap tap number!";
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
