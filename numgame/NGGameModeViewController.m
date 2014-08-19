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
#import "NGGuideViewController.h"
#import <pop/pop.h>
#import <objc/runtime.h>
#import "NGPlayer.h"
#import "SKProduct+LocalizedPrice.h"
#import "NGGameLogger.h"

@import GameKit;
@import StoreKit;
@import AVFoundation;

@interface NGGameModeViewController ()<GKGameCenterControllerDelegate,SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) NSMutableArray *playerArray;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (nonatomic) BOOL haveSound;

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
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    [_rankButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:24]];
    [_settingButton.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:24]];
    [_rankButton addTarget:self action:@selector(onClickRankButton) forControlEvents:UIControlEventTouchUpInside];
    
    NGGameMode gameMode = [[NGGameConfig sharedGameConfig] gamemode];
    [_modeLabel setText:[self getModeString:gameMode]];
    [_modeButtons enumerateObjectsUsingBlock:^(UIButton* button, NSUInteger idx, BOOL *stop) {
        [button setAlpha:(gameMode == idx)?1.0f:0.65f];
        [button.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:40]];
        if (gameMode == idx) {
             [_playButton setBackgroundColor:button.backgroundColor];
        }
    }];
    [_titleLabel setFont:[UIFont fontWithName:TITLE_FONT size:50]];
    if ([[NGGameConfig sharedGameConfig] isFirstLoad]) {
        [self performSegueWithIdentifier:@"guidesegue" sender:self];
    }
    _playerArray = [NSMutableArray new];
    [[NGPlayer player] playSoundFXnamed:@"game_mode_bg.mp3" Loop:YES];
    if (![[NGGameConfig sharedGameConfig] unlockEndlessMode] && [[NGGameConfig sharedGameConfig] gamemode] == NGGameModeEndless) {
        [_playButton setTitle:NSLocalizedString(@"Unlock", @"UnLock") forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[[NGPlayer player] playSoundFXnamed:@"tuitorial.mp3" Loop:NO];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[[NGGameConfig sharedGameConfig] sound] isEqualToString:@"J"]) {
        _haveSound = YES;
    } else {
        _haveSound = NO;
    }
    self.screenName = @"Game Mode Screen";
}

- (NSString*)getModeString:(NGGameMode)mode {
    switch (mode) {
        case NGGameModeClassic:
            return NSLocalizedString(@"Classic Mode", @"classic");
        case NGGameModeTimed:
            return NSLocalizedString(@"Time Mode", @"timed");
        case NGGameModeSteped:
            return NSLocalizedString(@"Step Mode", @"steped");
        case NGGameModeEndless:
            return NSLocalizedString(@"Endless Mode", @"endless");
        default:
            break;
    }
    return nil;
}

- (IBAction)onTouchDownMode:(UIButton*)button {
    [button setAlpha:1.0f];
    [[NGPlayer player] playSoundFXnamed:@"item_click.mp3" Loop:NO];
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

- (IBAction)onPlay:(UIButton*)sender {
    if ([[NGGameConfig sharedGameConfig] gamemode] == NGGameModeEndless && ![[NGGameConfig sharedGameConfig] unlockEndlessMode]) {
        if([SKPaymentQueue canMakePayments])
        {
            SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"EMUT0"]];
            request.delegate = self;
            [request start];
        }
    } else {
        [self performSegueWithIdentifier:@"playsegue" sender:sender];
    }
}

- (IBAction)onClickMode:(UIButton *)sender {
    [_modeButtons enumerateObjectsUsingBlock:^(UIButton* button, NSUInteger idx, BOOL *stop) {
        [button setAlpha:(sender == button)?1.0f:0.5f];
        if (sender == button) {
            [[NGPlayer player] playSoundFXnamed:[NSString stringWithFormat:@"square_%d.aif",idx+2] Loop:NO];
            [[NGGameConfig sharedGameConfig] setGamemode:idx];
            [_modeLabel setText:[self getModeString:idx]];
            [_playButton setBackgroundColor:button.backgroundColor];
            CATransition* moveAnimation = [CATransition animation];
            [moveAnimation setType:kCATransitionReveal];
            [moveAnimation setSubtype:kCATransitionFromRight];
            
            [moveAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [_modeLabel.layer addAnimation:moveAnimation forKey:@"moveModeText"];
        }
    }];
    if (![[NGGameConfig sharedGameConfig] unlockEndlessMode] && [[NGGameConfig sharedGameConfig] gamemode] == NGGameModeEndless) {
        [_playButton setTitle:NSLocalizedString(@"Unlock", @"UnLock") forState:UIControlStateNormal];
    } else {
        [_playButton setTitle:NSLocalizedString(@"Play", @"Play") forState:UIControlStateNormal];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[NGGameViewController class]]) {
        [_audioPlayer stop];
        [[NGPlayer player]stopPlaySoundFXnamed:@"game_mode_bg.mp3"];
        NGGameViewController* destVC = (NGGameViewController*)segue.destinationViewController;
        destVC.gameMode = [[NGGameConfig sharedGameConfig] gamemode];
        [NGGameLogger logGameData:destVC.gameMode];
    }
}

- (void)onClickRankButton {
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    [[NGPlayer player] playSoundFXnamed:@"item_click.mp3" Loop:NO];
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        [self presentViewController:gameCenterController animated:YES completion:nil];
    }
}

#pragma mark -- leaderboarddelegate --
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
    if (![[GKLocalPlayer localPlayer] isAuthenticated]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];
    }
}

#pragma mark -- buy item delegate -- 
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    SKProduct *product = [[response products] firstObject];
    UIAlertView* alertView;
    if (product != nil) {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment: payment];
    } else {
        NSString* string = NSLocalizedString(@"This Mode is temporarily unreachable, wait for a second", @"unreachable staff");
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Tip", @"Tip") message:string delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
    }
    alertView.tag = 100;
    [alertView show];
    

}


- (void)paymentQueue: (SKPaymentQueue *)queue updatedTransactions: (NSArray *)transactions
{
    for(SKPaymentTransaction * transaction in transactions)
    {
        switch(transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [_playButton setTitle:NSLocalizedString(@"Play", @"Play") forState:UIControlStateNormal];
                [[NGGameConfig sharedGameConfig] setUnlockEndlessMode:YES];
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                [[[UIAlertView alloc] initWithTitle:@"Tip" message:@"Buy failed, please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                break;
            case SKPaymentTransactionStateRestored:
                [[NGGameConfig sharedGameConfig] setUnlockEndlessMode:YES];
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
            default:
                break;
        }
    }
}



@end
