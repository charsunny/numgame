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
#import "NGPlayer.h"
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[[NGPlayer player] playSoundFXnamed:@"game_mode_bg.mp3" Loop:YES];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[[NGGameConfig sharedGameConfig] sound] isEqualToString:@"J"]) {
        _haveSound = YES;
    } else {
        _haveSound = NO;
    }
}

- (NSString*)getModeString:(NGGameMode)mode {
    switch (mode) {
        case NGGameModeClassic:
            return NSLocalizedString(@"Classic Mode", @"classic");
        case NGGameModeTimed:
            return NSLocalizedString(@"Time Mode", @"classic");
        case NGGameModeSteped:
            return NSLocalizedString(@"Step Mode", @"classic");
        case NGGameModeEndless:
            return NSLocalizedString(@"Endless Mode", @"classic");
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
    if([SKPaymentQueue canMakePayments])
    {
//        SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"EMUT0"]];
//        request.delegate = self;
//        [request start];
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:@"EMUT0"];
        [[SKPaymentQueue defaultQueue] addPayment: payment];
    }
    else
    {
        //Warn the user that purchases are disabled.
    }
    
    [_modeButtons enumerateObjectsUsingBlock:^(UIButton* button, NSUInteger idx, BOOL *stop) {
        [button setAlpha:(sender == button)?1.0f:0.5f];
        if (sender == button) {
            [[NGPlayer player] playSoundFXnamed:[NSString stringWithFormat:@"square_%d.aif",idx+2] Loop:NO];
            [[NGGameConfig sharedGameConfig] setGamemode:idx];
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
    if ([segue.destinationViewController isKindOfClass:[NGGameViewController class]]) {
        [_audioPlayer stop];
        NGGameViewController* destVC = (NGGameViewController*)segue.destinationViewController;
        destVC.gameMode = [[NGGameConfig sharedGameConfig] gamemode];
    }
}

- (void)onClickRankButton {
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
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
        NSLog(@"%@", product.localizedTitle);
}

- (void)paymentQueue: (SKPaymentQueue *)queue updatedTransactions: (NSArray *)transactions
{
    for(SKPaymentTransaction * transaction in transactions)
    {
        switch(transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                //[self completeTransaction: transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //[self failedTransaction: transaction];
                break;
            case SKPaymentTransactionStateRestored:
                //[self restoreTransaction: transaction];
            default:
                break;
        }
    }
}



@end
