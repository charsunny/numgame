//
//  NGViewController.m
//  numgame
//
//  Created by Sun Xi on 4/17/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "NGGameViewController.h"
#import "NGOptionViewController.h"
#import "NGGameModeViewController.h"
#import "NGGameConfig.h"
#import "GADBannerView.h"
#import "GADInterstitial.h"
#import "NGResultViewController.h"
#import "GameBoardView.h"
@import AudioToolbox;
@import AVFoundation;
@import iAd;
@import GameKit;
@import StoreKit;

@interface NGGameViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIAlertViewDelegate,ADBannerViewDelegate, GADInterstitialDelegate, GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet GameBoardView *gameBoardView;

@property (weak, nonatomic) IBOutlet UILabel *timeTitle;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *scoreTitle;

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@property (weak, nonatomic) IBOutlet UILabel *bestLabel;

@property (weak, nonatomic) IBOutlet UIView *pauseView;


@property (strong, nonatomic) NSTimer* progressTimer;

@property (weak, nonatomic) IBOutlet GADBannerView* gADBannerView;

@property (strong, nonatomic) GADInterstitial* gADInterstitial;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (nonatomic) int score;

@property (nonatomic) float leftTime;

@property (nonatomic) BOOL loadADSuccess;

@property (nonatomic) BOOL haveSound;

@end

@implementation NGGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    srand((unsigned int)time(NULL));
	// Do any additional setup after loading the view, typically from a nib.
    [_gADBannerView setAdUnitID:@"a1535f4e3f36f4b"];
    [_gADBannerView setBackgroundColor:[UIColor colorWithRed:59/255.0 green:188/255.0 blue:229/255.0 alpha:1.0]];
    _gADBannerView.rootViewController = self;
    _gADBannerView.delegate = self;
    [self.view addSubview:_gADBannerView];
    [_gADBannerView loadRequest:[GADRequest request]];
    
    _gADInterstitial = [[GADInterstitial alloc] init];
    _gADInterstitial.adUnitID = @"a1535f4e3f36f4b";
    [_gADInterstitial setDelegate:self];
    [_gADInterstitial loadRequest:[GADRequest request]];

    _leftTime = 10.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResignActive:) name:@"resignactive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive:) name:@"becomeactive" object:nil];
    
    [self initGameData];
    
    [_gameBoardView layoutBoardWithCellNum:4];
    
    UISwipeGestureRecognizer *recoginizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipePauseView:)];
    recoginizer1.direction = UISwipeGestureRecognizerDirectionRight;
    [_pauseView addGestureRecognizer:recoginizer1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[[NGGameConfig sharedGameConfig] sound] isEqualToString:@"J"]) {
        _haveSound = YES;
    } else {
        _haveSound = NO;
    }
}

- (void)initGameData {
    switch (_gameMode) {
        case NGGameModeClassic:
            _leftTime = 0;
            _score = 0;
            [_scoreLabel setText:@"0/10"];
            [_timeLabel setText:@"0.0"];
            [_scoreTitle setText:@"target"];
            [_timeTitle setText:@"time"];
            [_bestLabel setText:[NSString stringWithFormat:@"%.1f",[[NGGameConfig sharedGameConfig] classicScore]]];
            break;
        case NGGameModeTimed:
            _leftTime = 10.0;
            _score = 0;
            [_scoreLabel setText:@"0"];
            [_timeLabel setText:@"0.0"];
            [_scoreTitle setText:@"score"];
            [_timeTitle setText:@"time"];
            [_bestLabel setText:[NSString stringWithFormat:@"%d",[[NGGameConfig sharedGameConfig] timedScore]]];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)resumeGame {
    [_progressTimer invalidate];
    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateState) userInfo:nil repeats:YES];
    [_progressTimer fire];
    //[self genRandomNumberWithAnimate:NO];
}

- (void)updateState {
    if (_gameMode == NGGameModeClassic) {
        _leftTime += 0.1f;
        [_timeLabel setText:[NSString stringWithFormat:@"%.1f",_leftTime]];
    } else {
        _leftTime -= 0.1f;
        if (_leftTime > 0) {
            [_timeLabel setText:[NSString stringWithFormat:@"%.1f",_leftTime]];
        } else {
            [_timeLabel setText:@"0.0"];
            [_progressTimer invalidate];
            [self showResult];
        }
    }
}


#pragma mark  --IBACTION--

- (void)showResult {
    [self performSegueWithIdentifier:@"resultsegue" sender:self];
}

#pragma mark -- background handler --
- (void)onBecomeActive:(NSNotification*)notif {
   
}

- (void)onResignActive:(NSNotification*)notif {
    if (_pauseView.center.x > 320) {
        [self onTapHeaderView:nil];
    }
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController* destinationViewController = [segue destinationViewController];
    [_progressTimer invalidate];
    if([destinationViewController isKindOfClass:[NGResultViewController class]]) {
        NGResultViewController* controller = (NGResultViewController*)destinationViewController;
        if (_loadADSuccess) {
            [controller setGADInterstitial:_gADInterstitial];
        }
        controller.gameMode = _gameMode;
        if (_gameMode == NGGameModeClassic) {
            controller.time = _timeLabel.text;
            controller.score = _scoreLabel.text;
            if (_score == 10) {
                float shorttime = [[NGGameConfig sharedGameConfig] classicScore];
                if(_leftTime < shorttime || shorttime == 0) {
                    [[NGGameConfig sharedGameConfig] setClassicScore:_leftTime];
                    controller.isHighScore = YES;
                    [self playSoundFXnamed:@"cheer.m4a" Loop:NO];
                    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:@"mintime"];
                    scoreReporter.value = _leftTime*10;
                    [scoreReporter reportScoreWithCompletionHandler: ^(NSError *error)
                     {
                         if(error != nil)
                         {
                             [scoreReporter reportScoreWithCompletionHandler:nil];
                         }
                     }];
                }
                controller.completed = YES;
            } else {
                controller.completed = NO;
            }
        } else if (_gameMode == NGGameModeTimed) {
            controller.time = _timeLabel.text;
            controller.score = _scoreLabel.text;
            controller.completed = YES;
            if(_score > [[NGGameConfig sharedGameConfig] timedScore]) {
                [[NGGameConfig sharedGameConfig] setTimedScore:_score];
                controller.isHighScore = YES;
                
                GKScore *scoreReporter = [[GKScore alloc] initWithCategory:@"scorewithlimittime"];
                scoreReporter.value = _score;
                [scoreReporter reportScoreWithCompletionHandler: ^(NSError *error)
                 {
                     if(error != nil)
                     {
                         [scoreReporter reportScoreWithCompletionHandler:nil];
                     }
                 }];
            }
        }
    }
}

#pragma mark -- ads -- 

- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    [_progressTimer invalidate];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    _loadADSuccess = YES;
}

- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error {
    _loadADSuccess = NO;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    _gADInterstitial = [[GADInterstitial alloc] init];
    _gADInterstitial.adUnitID = @"a1535f4e3f36f4b";
    [_gADInterstitial setDelegate:self];
    [_gADInterstitial loadRequest:[GADRequest request]];
    [self showResult];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    [self showResult];
    [self initGameData];
}

#pragma mark -- play sound -- 

- (void)playRandomKey {
    if (!_haveSound) {
        return;
    }
    NSString* soundStr = [NSString stringWithFormat:@"sound%c.mp3",'T'+rand()%7];
    [self playSoundFXnamed:soundStr Loop:NO];
}

-(void) playSoundFXnamed:(NSString*) vSFXName Loop:(BOOL) vLoop
{
    if (!_haveSound) {
        return;
    }
    NSError *error;
    
    NSBundle* bundle = [NSBundle mainBundle];
    
    NSString* bundleDirectory = (NSString*)[bundle bundlePath];
    
    NSURL *url = [NSURL fileURLWithPath:[bundleDirectory stringByAppendingPathComponent:vSFXName]];
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if(vLoop)
        _audioPlayer.numberOfLoops = -1;
    else
        _audioPlayer.numberOfLoops = 0;
    
    [_audioPlayer play];
}

- (IBAction)onButtonClick:(UIButton *)sender {
    if (sender.tag == 1) {
        [self onSwipePauseView:nil];
    } else if (sender.tag == 2) {
        [UIView animateWithDuration:0.3f animations:^{
            _gameBoardView.center = CGPointMake(_gameBoardView.center.x + 320, _gameBoardView.center.y);
            _pauseView.center = CGPointMake(_pauseView.center.x + 320, _pauseView.center.y);
        } completion:^(BOOL finished) {
            
        }];
        [self initGameData];
    } else if (sender.tag == 3) {
        [_gameBoardView setHidden:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)onTapHeaderView:(UITapGestureRecognizer*)recognizer {
    [_progressTimer invalidate];
    if (_pauseView.center.x < 320) {
        return;
    }
    [UIView animateWithDuration:0.3f animations:^{
        _gameBoardView.center = CGPointMake(_gameBoardView.center.x - 320, _gameBoardView.center.y);
        _pauseView.center = CGPointMake(_pauseView.center.x - 320, _pauseView.center.y);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)onSwipePauseView:(UISwipeGestureRecognizer*)recognizer {
    [self resumeGame];
    [UIView animateWithDuration:0.3f animations:^{
        _gameBoardView.center = CGPointMake(_gameBoardView.center.x + 320, _gameBoardView.center.y);
        _pauseView.center = CGPointMake(_pauseView.center.x + 320, _pauseView.center.y);
    } completion:^(BOOL finished) {
        
    }];
}

@end
