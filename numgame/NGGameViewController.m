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
#import "GameBoardCell.h"
#import <pop/pop.h>
#import "GameResultView.h"
@import AudioToolbox;
@import AVFoundation;
@import iAd;
@import GameKit;
@import StoreKit;

@interface NGGameViewController ()<UIAlertViewDelegate,GameBoardViewDelegate>

@property (weak, nonatomic) IBOutlet GameBoardView *gameBoardView;

@property (weak, nonatomic) IBOutlet UILabel *timeTitle;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (nonatomic) int timeSpent;

@property (nonatomic) int currectLevel;

@property (nonatomic, strong) NSArray* levelConfig;

@property (weak, nonatomic) IBOutlet UILabel *scoreTitle;

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@property (weak, nonatomic) IBOutlet UILabel *levelLabel;

@property (nonatomic)int score;

@property (weak, nonatomic) IBOutlet UIView *pauseView;

@property (strong, nonatomic) NSTimer* progressTimer;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (nonatomic) float leftTime;

@property (nonatomic) BOOL haveSound;

@property (nonatomic,strong) GameResultView *gameResultView;

@end

@implementation NGGameViewController

#pragma mark property
- (void)setTimeSpent:(int)timeSpent
{
    _timeSpent = timeSpent;
    NSDictionary* levelInfo = _levelConfig[_currectLevel-1];
    //_timeLabel.text = [NSString stringWithFormat:@"%d/%@",_timeSpent, levelInfo[@"step"]];
    
    NSString* wholeString =[NSString stringWithFormat:@"%d/%@",_timeSpent, levelInfo[@"step"]];
    
    NSMutableAttributedString* mutableAttrString = [[NSMutableAttributedString alloc]initWithString:wholeString];
    [mutableAttrString addAttribute:NSFontAttributeName
                              value:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:30]
                              range:NSMakeRange(0, wholeString.length)];
    
    int delta =[levelInfo[@"step"] intValue]- self.timeSpent;
    if(delta <= 5)
    {
        [mutableAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0, [NSString stringWithFormat:@"%d",_timeSpent].length)];
        if(delta <= 3)
        {
            [mutableAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, [NSString stringWithFormat:@"%d",_timeSpent].length)];
        }
    }
    _timeLabel.attributedText = mutableAttrString;
    [self addPopSpringAnimation:_timeLabel];
}

- (void)setScore:(int)score
{
    _score = score;
    self.timeSpent++;
    NSDictionary* levelInfo = _levelConfig[_currectLevel-1];
    [_scoreLabel setText:[NSString stringWithFormat:@"%d/%@",_score, levelInfo[@"score"]]];
    [self addPopSpringAnimation:_scoreLabel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    srand((unsigned int)time(NULL));
    //init gameconfig
    
    _currectLevel = 1;
    
    NSString* levelPath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    _levelConfig = [NSArray arrayWithContentsOfFile:levelPath];
    
    _timeSpent = 0;
    _leftTime = 10.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResignActive:) name:@"resignactive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive:) name:@"becomeactive" object:nil];
    
    [self initGameData];
    
    _gameBoardView.delegate = self;
    [_gameBoardView layoutBoardWithCellNum:6];
    
    UISwipeGestureRecognizer *recoginizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipePauseView:)];
    recoginizer1.direction = UISwipeGestureRecognizerDirectionRight;
    [_pauseView addGestureRecognizer:recoginizer1];
    
    [_timeLabel setAdjustsFontSizeToFitWidth:YES];
    [_scoreLabel setAdjustsFontSizeToFitWidth:YES];
    self.gameBoardView.isChangeColor = NO;
    [self resumeGame];
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
        case NGGameModeClassic: {
            NSDictionary* levelInfo = _levelConfig[_currectLevel-1];
            _timeSpent = 0;
            [_levelLabel setText:[NSString stringWithFormat:@"%d",_currectLevel]];
            [_scoreLabel setText:[NSString stringWithFormat:@"%d/%@",_score, levelInfo[@"score"]]];
            [_timeLabel setText:[NSString stringWithFormat:@"0/%@",levelInfo[@"step"]]];
            break;
        }
        case NGGameModeTimed:
            _leftTime = 10.0;
            _score = 0;
            [_scoreLabel setText:@"0"];
            [_timeLabel setText:@"0.0"];
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
//    [_progressTimer invalidate];
//    _progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateGameTime) userInfo:nil repeats:YES];
//    [_progressTimer fire];
}

-(void)updateGameTime
{
   if(_gameMode == NGGameModeClassic)
   {
       self.timeSpent++;
   }
   else
   {
        _leftTime -= 0.1f;
        if (_leftTime > 0) {
            [_timeLabel setText:[NSString stringWithFormat:@"%.1f",_leftTime]];
        } else {
            [_timeLabel setText:@"0.0"];
            [_progressTimer invalidate];
            [self showResult:YES];
        }
   }
}

#pragma mark  --IBACTION--

- (void)showResult:(BOOL)completed {
    self.gameResultView = [[GameResultView alloc]initGameResultViewWithScore:self.score Completion:completed];
    [self.view addSubview:self.gameResultView];
   
    if (completed) {
        self.timeSpent = 0;
        _currectLevel +=1;
     
    }
    else{
        self.timeSpent = 0;
        self.score = 0;
    
    }

    NSDictionary* levelInfo = _levelConfig[_currectLevel-1];
    [_scoreLabel setText:[NSString stringWithFormat:@"%d/%@",_score, levelInfo[@"score"]]];
    [_levelLabel setText:[NSString stringWithFormat:@"%d",_currectLevel]];
    [self addPopSpringAnimation:_scoreLabel];
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
        controller.gameMode = _gameMode;
        if (_gameMode == NGGameModeClassic) {
            controller.time = _timeLabel.text;
            controller.score = _scoreLabel.text;
            NSDictionary* levelInfo = _levelConfig[_currectLevel-1];
            if ([levelInfo[@"score"] intValue] <= self.score) {
                float shorttime = [[NGGameConfig sharedGameConfig] classicScore];
                if(_leftTime < shorttime || shorttime == 0) {
                    [[NGGameConfig sharedGameConfig] setClassicScore:_leftTime];
                    controller.isHighScore = YES;
                    [self playSoundFXnamed:@"cheer.m4a" Loop:NO];
                    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:@"mintime"];
                    scoreReporter.value = _leftTime*10;
                    [GKScore reportScores:@[scoreReporter] withCompletionHandler:nil];
                }
                controller.completed = YES;
                _currectLevel++;
            } else {
                controller.completed = NO;
            }
            [self initGameData];
        } else if (_gameMode == NGGameModeTimed) {
            controller.time = _timeLabel.text;
            controller.score = _scoreLabel.text;
            controller.completed = YES;
            if(_score > [[NGGameConfig sharedGameConfig] timedScore]) {
                [[NGGameConfig sharedGameConfig] setTimedScore:_score];
                controller.isHighScore = YES;
                
                GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:@"scorewithlimittime"];
                scoreReporter.value = _score;
                [GKScore reportScores:@[scoreReporter] withCompletionHandler:nil];
            }
        }
    }
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

#pragma mark GameBoardViewDelegate
- (void)increaseScore:(int)deltaScore
{
    self.score+=deltaScore;
    NSDictionary* levelInfo = _levelConfig[_currectLevel-1];
    UILabel* scoreDeltaLabel = [[UILabel alloc]initWithFrame:CGRectMake(_scoreLabel.frame.origin.x - 20 , _scoreLabel.frame.origin.y, 50, 50)];
    scoreDeltaLabel.text =[NSString stringWithFormat:@"+%d",deltaScore ];
    scoreDeltaLabel.font = [UIFont fontWithName:@"Apple SD Gothic Neo" size:14];
    scoreDeltaLabel.textAlignment = NSTextAlignmentCenter;
    scoreDeltaLabel.textColor = [UIColor grayColor];
    scoreDeltaLabel.alpha = 0;
    [self.view addSubview:scoreDeltaLabel];
    
    CAKeyframeAnimation* keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    keyFrameAnimation.values = @[@0,@1,@1,@0];
    keyFrameAnimation.keyTimes = @[@0, @(0.2),@(0.7), @(0.8)];
    keyFrameAnimation.duration = 0.8;
    keyFrameAnimation.additive = YES;
    [scoreDeltaLabel.layer addAnimation:keyFrameAnimation forKey:@"opacityAnimation"];
    
    [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        scoreDeltaLabel.transform = CGAffineTransformMakeTranslation(0, -50);
    } completion:^(BOOL finished) {
        [scoreDeltaLabel removeFromSuperview];
    }];
    
    if ([levelInfo[@"score"] intValue] <= self.score) {
        [self showResult:YES];
    } else if ([levelInfo[@"step"] intValue] <= self.timeSpent) {
        [self showResult:NO];
    }
}
-(void)decreaseScore:(int)deltaScore
{
    self.score-=deltaScore;
}
#pragma makr pop animation 
-(void)addPopSpringAnimation:(UIView*)view
{
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.velocity = [NSValue valueWithCGSize:CGSizeMake(3.f, 3.f)];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
    scaleAnimation.springBounciness = 18.0f;
    [view.layer pop_addAnimation:scaleAnimation forKey:@"scoreScaleSpring"];
}


-(IBAction)changeCellColor:(id)sender{

    [self.progressTimer invalidate];
    //让所有cell处于激活状态
       //当点击了cell识别这个cell在这个view上弹出一个popView，有4种颜色
    
    
    //点击popView的颜色改变cell的颜色，popView移除
    
    
    //
    
    self.gameBoardView.isChangeColor = YES;
    [self.gameBoardView performSelector:@selector(changeCellColor:) withObject:sender];
  


}

-(IBAction)changeCellNumber:(id)sender{
 
    [self.progressTimer invalidate];
   // self.gameBoardView.isChangeNumer = YES;
    self.gameBoardView.isChangeColor = NO;
    [self.gameBoardView performSelector:@selector(changeCellNumber:) withObject:sender ];
    


}



@end
