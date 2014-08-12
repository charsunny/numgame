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
#import <pop/pop.h>
@import GameKit;
@import StoreKit;

@interface NGGameModeViewController ()<GKGameCenterControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray* modeButtons;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UILabel *modeLabel;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIButton *rankButton;

@property (weak, nonatomic) IBOutlet UIButton *settingButton;

@end

@implementation NGGameModeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_rankButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:24]];
    [_settingButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:24]];
    
    NGGameMode gameMode = [[NGGameConfig sharedGameConfig] gamemode];
    [_modeLabel setText:[self getModeString:gameMode]];
    [_modeButtons enumerateObjectsUsingBlock:^(UIButton* button, NSUInteger idx, BOOL *stop) {
        [button setAlpha:(gameMode == idx)?1.0f:0.5f];
        [button.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:40]];
        [_playButton setBackgroundColor:button.backgroundColor];
    }];
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

- (NSString*)getModeString:(NGGameMode)mode {
    switch (mode) {
        case NGGameModeClassic:
            return NSLocalizedString(@"classic mode", @"classic");
        case NGGameModeTimed:
            return NSLocalizedString(@"timed mode", @"classic");
        case NGGameModeSteped:
            return NSLocalizedString(@"stepped mode", @"classic");
        case NGGameModeEndless:
            return NSLocalizedString(@"endless mode", @"classic");
        default:
            break;
    }
    return nil;
}

- (IBAction)onTouchDownMode:(UIButton*)button {
    [button setAlpha:1.0f];
    POPSpringAnimation* animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.2, 1.2)];
    animation.springBounciness = 3;
    [button pop_addAnimation:animation forKey:@"bouces"];
    [animation setCompletionBlock:^(POPAnimation *animation, BOOL finish) {
        POPSpringAnimation* animate = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        animate.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
        animate.springBounciness = 20;
        [button pop_addAnimation:animate forKey:@"bouces1"];
    }];
}

- (IBAction)onClickMode:(UIButton *)sender {
    [_modeButtons enumerateObjectsUsingBlock:^(UIButton* button, NSUInteger idx, BOOL *stop) {
        [button setAlpha:(sender == button)?1.0f:0.5f];
        if (sender == button) {
            [_modeLabel setText:[self getModeString:idx]];
            [_playButton setBackgroundColor:button.backgroundColor];
            CATransition* moveAnimation = [CATransition animation];
            [moveAnimation setType:kCATransitionMoveIn];
            [moveAnimation setSubtype:kCATransitionFromRight];
            [moveAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [_modeLabel.layer addAnimation:moveAnimation forKey:@"xxx"];
            
        }
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
