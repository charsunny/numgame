//
//  NGGameModeViewController.m
//  numgame
//
//  Created by Sun Xi on 4/28/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "NGGameModeViewController.h"
#import "NGGameConfig.h"
#import "NGGameViewController.h"
#import "GADBannerView.h"
#import "NGGuideViewController.h"
@import GameKit;
@import StoreKit;

@interface NGGameModeViewController ()<GKGameCenterControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *classicButton;

@property (weak, nonatomic) IBOutlet UIButton *leaderButton;

@property (weak, nonatomic) IBOutlet UIButton *timedButton;

@property (weak, nonatomic) IBOutlet UIButton *settingButton;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet GADBannerView* gADBannerView;

@end

@implementation NGGameModeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [_gADBannerView setAdUnitID:@"a1535f4e3f36f4b"];
//    _gADBannerView.rootViewController = self;
//    [self.view addSubview:_gADBannerView];
//    [_gADBannerView loadRequest:[GADRequest request]];
    // Do any additional setup after loading the view.
    
    for (int i = 0; i < 4; i++) {
        UILabel* label = (UILabel*)[_containerView viewWithTag:i+1];
        [label setFont:[UIFont fontWithName:TITLE_FONT size:20]];
    }
    [_classicButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:44]];
    [_leaderButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:44]];
    [_timedButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:44]];
    [_settingButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:44]];
    [_titleLabel setFont:[UIFont fontWithName:TITLE_FONT size:50]];
    if ([[NGGameConfig sharedGameConfig] isFirstLoad]) {
        [self performSegueWithIdentifier:@"guidesegue" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onClickMode:(UIButton *)sender {
    [UIView animateWithDuration:0.15f animations:^{
        [sender setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    }];
    
//    //go to leader board
//    if ([sender isEqual:_leaderButton]) {
//        [sender setEnabled:YES];
//        GKGameCenterViewController *leaderboardController = [[GKGameCenterViewController alloc] init];
//        leaderboardController.viewState = GKGameCenterViewControllerStateLeaderboards;
//        leaderboardController.gameCenterDelegate = self;
//        [self presentViewController:leaderboardController animated:YES completion:nil];
//    }
}

- (IBAction)touchDown:(UIButton*)sender {
    
}

- (IBAction)touchCanceled:(UIButton*)sender {
    [UIView animateWithDuration:0.15f animations:^{
        [sender setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    }];
}

- (IBAction)touchUpOutSide:(UIButton*)sender {
    [UIView animateWithDuration:0.15f animations:^{
        [sender setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"classicsegue"]) {
        NGGameViewController* destVC = (NGGameViewController*)segue.destinationViewController;
        destVC.gameMode = NGGameModeClassic;
    } else if ([segue.identifier isEqualToString:@"timedsegue"]) {
        NGGameViewController* destVC = (NGGameViewController*)segue.destinationViewController;
        destVC.gameMode = NGGameModeTimed;
    } else if ([segue.identifier isEqualToString:@"stepedsegue"]) {
        NGGameViewController* destVC = (NGGameViewController*)segue.destinationViewController;
        destVC.gameMode = NGGameModeSteped;
    } else if ([segue.identifier isEqualToString:@"endlesssegue"]) {
        NGGameViewController* destVC = (NGGameViewController*)segue.destinationViewController;
        destVC.gameMode = NGGameModeEndless;
    }
}

#pragma mark -- leaderboarddelegate --
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
    if (![[GKLocalPlayer localPlayer] isAuthenticated]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];
    }
}




@end
