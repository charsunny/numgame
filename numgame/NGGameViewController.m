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
#import "NGResultViewController.h"
#import "GameBoardView.h"
#import "GameBoardCell.h"
#import <pop/pop.h>
#import "GameResultView.h"
#import "NGGameUtil.h"
#import "GameCountingCircleView.h"
#import "NGPlayer.h"

@import AudioToolbox;
@import AVFoundation;
@import iAd;
@import GameKit;
@import StoreKit;


#define TOOL_BAR_COLOR 0xF7F7F7

@interface NGGameViewController ()<UIAlertViewDelegate,GameBoardViewDelegate,GameCountingCircleDelegate>

@property (weak, nonatomic) IBOutlet UIButton *hammerBtn;
@property (weak, nonatomic) IBOutlet UILabel *hammerLabel;

@property (weak, nonatomic) IBOutlet UIButton *fireBtn;
@property (weak, nonatomic) IBOutlet UILabel *fireLabel;

@property (weak, nonatomic) IBOutlet UIButton *wandBtn;
@property (weak, nonatomic) IBOutlet UILabel *wandLabel;

@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UIView *toolBarContainerView;

@property (weak, nonatomic) IBOutlet GameBoardView *gameBoardView;


@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (nonatomic) int timeSpent;

@property (nonatomic) int currectLevel;

@property (nonatomic, strong) NSArray* levelConfig;


@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@property (weak, nonatomic) IBOutlet UILabel *levelLabel;

@property (nonatomic)int score;

@property (weak, nonatomic) IBOutlet UIView *pauseView;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (nonatomic) float leftTime;

@property (nonatomic) BOOL haveSound;

@property (nonatomic,strong) GameResultView *gameResultView;

@property (nonatomic)BOOL unwindFromResultVC;

@property (nonatomic)BOOL changeTrickBtn;

@property (nonatomic)BOOL isCompleted;

@property (strong,nonatomic)GameCountingCircleView* stepCountingView;

@property (strong,nonatomic)GameCountingCircleView* scoreCountingView;

@property (strong,nonatomic)GameCountingCircleView* timeCountingView;

@property (strong,nonatomic)GameCountingCircleView* colorToolCountingView;

@property (strong,nonatomic)GameCountingCircleView* numberToolCountingView;
@end

@implementation NGGameViewController

//well,this's the legacy code,timeSpent seems related to step count
#pragma mark property
- (void)setTimeSpent:(int)timeSpent
{
    _timeSpent = timeSpent;
    //setting the attribute string to indicate the current status,legacy
    /*
    if (_gameMode == NGGameModeClassic) {
        
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
     */
    if (_gameMode == NGGameModeSteped || _gameMode == NGGameModeClassic) {
        [_stepCountingView addCount:-1 isReverse:YES];
    }
    
}

- (void)setScore:(int)score
{
    int deltaCount = score - _score;
    _score = score;
    self.timeSpent++;
    
    //the score label's text is prepared for result view controller
    NSDictionary* levelInfo = _levelConfig[_currectLevel-1];
    if (_gameMode == NGGameModeClassic) {
        [_scoreLabel setText:[NSString stringWithFormat:@"%d/%@",_score, levelInfo[@"score"]]];
    } else {
        [_scoreLabel setText:[NSString stringWithFormat:@"%d",_score]];
    }
    
    [_scoreCountingView addCount:deltaCount isReverse:NO];
    [self addPopSpringAnimation:_scoreCountingView];
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
    _leftTime = 60;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onResignActive:) name:@"resignactive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBecomeActive:) name:@"becomeactive" object:nil];
    
    self.view.layer.cornerRadius = 50;
    //init counting circle view
    [self initHeaderView];
    [self initToolBarView];
    [self initGameData];
    
    
    _gameBoardView.delegate = self;
    [_gameBoardView layoutBoardWithCellNum:6];
    
    UISwipeGestureRecognizer *recoginizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipePauseView:)];
    recoginizer1.direction = UISwipeGestureRecognizerDirectionRight;
    [_pauseView addGestureRecognizer:recoginizer1];
    [_timeLabel setAdjustsFontSizeToFitWidth:YES];
    [_scoreLabel setAdjustsFontSizeToFitWidth:YES];
    self.gameBoardView.isChangeColor = NO;
    self.changeTrickBtn = NO; //用来改变切换的TrickBtn
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_unwindFromResultVC) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    if ([[[NGGameConfig sharedGameConfig] sound] isEqualToString:@"J"]) {
        _haveSound = YES;
    } else {
        _haveSound = NO;
    }
}


#pragma mark Init ToolBar Circle View
- (void)initToolBarView
{
    CGRect sFrame = self.view.frame;
    
    _toolBarContainerView.layer.shadowOpacity = 0.15;
    _toolBarContainerView.layer.shadowOffset = CGSizeMake(0,-2);
    _toolBarContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
    _toolBarContainerView.layer.shadowRadius = 3.5;
    _toolBarContainerView.layer.masksToBounds = NO;
    switch (self.gameMode) {
        case NGGameModeTimed:
        case NGGameModeSteped:
        case NGGameModeEndless:
        case NGGameModeClassic:
        {
            
            _colorToolCountingView = [[GameCountingCircleView alloc]initWithFrame:CGRectMake(50, sFrame.size.height - 50 - 5 , 50, 50)];
            [_colorToolCountingView initData:0 withStart:5];
            _colorToolCountingView.pieCapacity = 360;
            _colorToolCountingView.circleKey = @"colorCount";
            _colorToolCountingView.delegate = self;
            [self registerToolTapGesture:_colorToolCountingView withSelector:@selector(changeCellColor:)];
            
            _colorToolCountingView.circleColor = UIColorFromRGB(0xFFC53F);
            _colorToolCountingView.frontColor = UIColorFromRGB(0x00CE61);
            [_colorToolCountingView setContentImage:[UIImage imageNamed:@"wand"]];

            [_colorToolCountingView initShapeLayer];
            
            [self.view addSubview:_colorToolCountingView];
            
            
            _numberToolCountingView = [[GameCountingCircleView alloc]initWithFrame:CGRectMake(220, sFrame.size.height - 50 - 5 , 50, 50)];
            [_numberToolCountingView initData:0 withStart:5];
            _numberToolCountingView.pieCapacity = 360;
            _numberToolCountingView.circleKey = @"numCount";
            _numberToolCountingView.delegate = self;
            [self registerToolTapGesture:_numberToolCountingView withSelector:@selector(changeCellNumber:)];
            
            _numberToolCountingView.circleColor = UIColorFromRGB(0xFFC53F);
            _numberToolCountingView.frontColor = UIColorFromRGB(0x00CE61);
            [_numberToolCountingView setContentImage:[UIImage imageNamed:@"hammer"]];
            [_numberToolCountingView initShapeLayer];
            
            [self.view addSubview:_numberToolCountingView];
            break;
        }
        default:
            break;
    }
    
}
- (void)registerToolTapGesture:(GameCountingCircleView*)circleView withSelector:(SEL)selector
{
    UITapGestureRecognizer* changeSomethingTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:selector];
    [circleView addGestureRecognizer:changeSomethingTap];
}

#pragma --mark init header UI
- (void)initHeaderView
{
    _headView.backgroundColor = UIColorFromRGB(TOOL_BAR_COLOR);
    _headView.alpha = 1;
    
    _headView.layer.shadowOpacity = 0.15;
    _headView.layer.shadowOffset = CGSizeMake(0,2);
    _headView.layer.shadowColor = [UIColor blackColor].CGColor;
    _headView.layer.shadowRadius = 3.5;
    _headView.layer.masksToBounds = NO;
    
    switch (self.gameMode) {
        case NGGameModeClassic:
        {
            [self initStepCircleView];
            [self initScoreCircleView];
            break;
        }
        case NGGameModeTimed:
        {
            _timeCountingView = [[GameCountingCircleView alloc]initWithFrame:CGRectMake(50, 5, 60, 60)];
            [_timeCountingView initData:0 withStart: 60];
            _timeCountingView.pieCapacity = 360;
            _timeCountingView.frontColor = UIColorFromRGB(0x00CE61);
            _timeCountingView.circleColor = UIColorFromRGB(0xFFC53F);
            _timeCountingView.clockwise = 0;
            _timeCountingView.circleKey = @"timeCount";
            _timeCountingView.delegate = self;
            [_timeCountingView addCount:0 isReverse:YES];
            
            [_headView addSubview:_timeCountingView];
            [self initScoreCircleView];
            break;
        }
        case NGGameModeSteped:
        {
            [self initStepCircleView];
            [self initScoreCircleView];
            _stepCountingView.delegate = self;
            break;
        }
        case NGGameModeEndless:
        {
            [self initScoreCircleView];
            _scoreCountingView.center = CGPointMake(160, 30);
            break;
        }
        default:
            break;
    }
}
- (void)initStepCircleView
{
    NSDictionary* levelInfo = _levelConfig[_currectLevel-1];
    _stepCountingView = [[GameCountingCircleView alloc]initWithFrame:CGRectMake(50, 2, 60, 60)];
    
    [_stepCountingView initData:0 withStart:[levelInfo[@"step"] integerValue] ];
    //we'll reset the currentCount in initGameData
    _stepCountingView.currentCount = 0;
    _stepCountingView.pieCapacity = 360;
    _stepCountingView.circleKey = @"stepCount";
    //we don't set delegate here cause we've already have it done in the legacy code
    _stepCountingView.delegate = nil;
    
    _stepCountingView.frontColor = UIColorFromRGB(0x4DC9FD);
    _stepCountingView.circleColor = UIColorFromRGB(0xF56363);
    
    //[_stepCountingView initShapeLayer];
    [_headView addSubview:_stepCountingView];
}
- (void)initScoreCircleView
{
    NSDictionary* levelInfo = _levelConfig[_currectLevel-1];
    _scoreCountingView = [[GameCountingCircleView alloc]initWithFrame:CGRectMake(210, 2, 60, 60)];
    
    [_scoreCountingView initData:[levelInfo[@"score"] integerValue] withStart:0];
    _scoreCountingView.pieCapacity = 0;
    _scoreCountingView.frontColor = UIColorFromRGB(0x00CE61);
    _scoreCountingView.circleColor = UIColorFromRGB(0xFFC53F);
    _scoreCountingView.circleKey = @"scoreCount";
    _scoreCountingView.clockwise = 0;
    _scoreCountingView.tag = 1989;
    //we don't set delegate here cause we've already have it done in the legacy code
    //_scoreCountingView.delegate = self;
    [_headView addSubview:_scoreCountingView];
}

- (void)initGameData {
    NSDictionary* levelInfo = _levelConfig[_currectLevel-1];
    switch (_gameMode) {
        case NGGameModeClassic: {
            _timeSpent = 0;
            [_levelLabel setText:[NSString stringWithFormat:@"%d",_currectLevel]];
            [_scoreLabel setText:[NSString stringWithFormat:@"%d/%@",_score, levelInfo[@"score"]]];
            [_timeLabel setText:[NSString stringWithFormat:@"0/%@",levelInfo[@"step"]]];
            
            _stepCountingView.destinationCount = 0;
            _stepCountingView.deltaCount = [levelInfo[@"step"] integerValue] + _stepCountingView.currentCount;
            _stepCountingView.currentCount = _stepCountingView.deltaCount;
            //update circle
            [_stepCountingView addCount:0 isReverse:YES];
            
            _scoreCountingView.destinationCount = [levelInfo[@"score"] integerValue];
            _scoreCountingView.deltaCount = [levelInfo[@"score"] integerValue];
            [_scoreCountingView addCount:0 isReverse:NO];
            
            break;
        }
        case NGGameModeTimed:
            _leftTime = 60;
            _score = 0;
            [_scoreLabel setText:@"0"];
            [_timeLabel setText:@"60"];
            _timeCountingView.currentCount = _leftTime;
            [_timeCountingView startCounting];
            _scoreCountingView.currentCount = 0;
            [_scoreCountingView addCount:0 isReverse:NO];
            break;
        case NGGameModeSteped:
            _score = 0;
            _leftTime = 30;
            [_scoreLabel setText:@"0"];
            [_timeLabel setText:@"30"];
            //hell yeah,duplicated code here
            _stepCountingView.destinationCount = 0;
            _stepCountingView.deltaCount = [levelInfo[@"step"] integerValue] + _stepCountingView.currentCount;
            _stepCountingView.currentCount = _stepCountingView.deltaCount;
            [_stepCountingView addCount:0 isReverse:YES];
            
            _scoreCountingView.destinationCount = [levelInfo[@"score"] integerValue];
            _scoreCountingView.deltaCount = [levelInfo[@"score"] integerValue];
            _scoreCountingView.currentCount = 0;
            [_scoreCountingView addCount:0 isReverse:NO];
            
            break;
        case NGGameModeEndless:
            _score = 0;
            _leftTime = 0;
            [_scoreLabel setText:@"0"];
            [_timeLabel setText:@"0"];
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


#pragma mark  --IBACTION--

- (void)showResult:(BOOL)completed {
    
    self.isCompleted = completed;
    [self performSegueWithIdentifier:@"resultsegue" sender:self];
    return;
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
        [self performSelector:@selector(onTapHeaderView:) withObject:nil afterDelay:0.3f];
    }
    [_timeCountingView stopCounting];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController* destinationViewController = [segue destinationViewController];
    [_timeCountingView stopCounting];
    if([destinationViewController isKindOfClass:[NGResultViewController class]]) {
        NGResultViewController* controller = (NGResultViewController*)destinationViewController;
        controller.prevBgImageView = [[UIImageView alloc]initWithImage:[NGGameUtil screenshot:self.view]];
        controller.gameMode = _gameMode;
        if (_gameMode == NGGameModeClassic) {
            controller.time = _timeLabel.text;
            controller.score = _scoreLabel.text;
            NSDictionary* levelInfo = _levelConfig[_currectLevel-1];
            if ([levelInfo[@"score"] intValue] <= self.score) {
                [[NGPlayer player] playSoundFXnamed:@"cheer.m4a" Loop:NO];
                controller.completed = YES;
                _currectLevel++;
            } else {
                controller.completed = NO;
                if(_score > [[NGGameConfig sharedGameConfig] classicScore]) {
                    controller.isHighScore = YES;
                    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:@"CMHS"];
                    scoreReporter.value = _score;
                    [GKScore reportScores:@[scoreReporter] withCompletionHandler:nil];
                }
            }
        } else if (_gameMode == NGGameModeTimed || _gameMode == NGGameModeSteped) {
            controller.time = _timeLabel.text;
            controller.score = _scoreLabel.text;
            controller.completed = self.isCompleted;
            if(_score > [[NGGameConfig sharedGameConfig] timedScore]) {
                [[NGGameConfig sharedGameConfig] setTimedScore:_score];
                controller.isHighScore = YES;
                GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:@"scorewithlimittime"];
                scoreReporter.value = _score;
                [GKScore reportScores:@[scoreReporter] withCompletionHandler:nil];
            }
        }
        //reset data for next round
        [self initGameData];
    }
}

-(IBAction)unwindViewControllerForNextLevel:(UIStoryboardSegue *)unwindSegue
{
    /*
    NGResultViewController* gameResultViewController = (NGResultViewController*)unwindSegue.sourceViewController;
    
    if ([gameResultViewController isKindOfClass:[NGResultViewController class]])
    {
        
    }
     */
}
-(IBAction)unwindViewControllerForMainPage:(UIStoryboardSegue *)unwindSegue
{
    
    [_gameBoardView setHidden:YES];
    NSLog(@"%@",self.navigationController.viewControllers[0]);
    NSLog(@"%@",self.navigationController.viewControllers[1]);
    _unwindFromResultVC = YES;
    //[self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark -- play sound -- 

- (void)playRandomKey {
    if (!_haveSound) {
        return;
    }
    NSString* soundStr = [NSString stringWithFormat:@"sound%c.mp3",'T'+rand()%7];
    [[NGPlayer player] playSoundFXnamed:soundStr Loop:NO];
}

- (IBAction)onButtonClick:(UIButton *)sender {
    [[NGPlayer player] playSoundFXnamed:@"item_click.mp3" Loop:NO];
    if (sender.tag == 1) {
        [self onSwipePauseView:nil];
        if (_gameMode == NGGameModeTimed) {
            [_timeCountingView startCounting];
        }
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
    [_timeCountingView stopCounting];
    if (_pauseView.center.x < 320) {
        return;
    }
    [[NGPlayer player] playSoundFXnamed:@"item_click.mp3" Loop:NO];
    [UIView animateWithDuration:0.3f delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _gameBoardView.center = CGPointMake(_gameBoardView.center.x - 320, _gameBoardView.center.y);
        _pauseView.center = CGPointMake(_pauseView.center.x - 320, _pauseView.center.y);
    } completion:nil];
}

- (void)onSwipePauseView:(UISwipeGestureRecognizer*)recognizer {
    [UIView animateWithDuration:0.3f animations:^{
        _gameBoardView.center = CGPointMake(_gameBoardView.center.x + 320, _gameBoardView.center.y);
        _pauseView.center = CGPointMake(_pauseView.center.x + 320, _pauseView.center.y);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark Game Counting Circle Delegate
- (void)GameCoutingCircleDidEndCount:(NSString *)circleKey
{
    NSLog(@"%@",circleKey);
    if ([circleKey isEqualToString:@"colorCount"]) {
        _colorToolCountingView.alpha = 0.6;
        _colorToolCountingView.gestureRecognizers = nil;
    }
    else if([circleKey isEqualToString:@"numCount"])
    {
        _numberToolCountingView.alpha = 0.6;
        _numberToolCountingView.gestureRecognizers = nil;
    }
    else if([circleKey isEqualToString:@"timeCount"])
    {
        [_timeCountingView stopCounting];
        [self showResult:NO];
    }
    else if([circleKey isEqualToString:@"stepCount"])
    {
        [self showResult:NO];
    }
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
    //[scoreDeltaLabel.layer addAnimation:keyFrameAnimation forKey:@"opacityAnimation"];
    //[_scoreCountingView.layer addAnimation:keyFrameAnimation forKey:@"opacityAnimation"];
    
    [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        scoreDeltaLabel.transform = CGAffineTransformMakeTranslation(0, -50);
    } completion:^(BOOL finished) {
        [scoreDeltaLabel removeFromSuperview];
    }];
    
    if (_gameMode == NGGameModeClassic) {
        if ([levelInfo[@"score"] intValue] <= self.score) {
            [self showResult:YES];
        } else if ([levelInfo[@"step"] intValue] <= self.timeSpent) {
            [self showResult:NO];
        }
    } else if (_gameMode == NGGameModeSteped) {
        _leftTime--;
        [_timeLabel setText:[NSString stringWithFormat:@"%.0f",_leftTime]];
        if (_leftTime == 0) {
            [self showResult:YES];
        }
    } else if (_gameMode == NGGameModeEndless) {
        _leftTime++;
        [_timeLabel setText:[NSString stringWithFormat:@"%.0f",_leftTime]];
    }
    else if (_gameMode == NGGameModeTimed){
        _leftTime--;
        [_timeLabel setText:[NSString stringWithFormat:@"%.0f",_leftTime]];
        if (_leftTime == 0) {
            [self showResult:YES];
        }
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

//- (IBAction)showMenu:(id)sender {
//    [self onTapHeaderView:nil];
//}

- (IBAction)burnCell:(id)sender {
    NSLog(@"burning");
}


-(IBAction)changeCellColor:(id)sender{

    [_timeCountingView stopCounting];
    [[NGPlayer player] playSoundFXnamed:@"item_click.mp3" Loop:NO];
    self.gameBoardView.isChangeColor = YES;
    //__block UIBarButtonItem* barBtnItem = (UIBarButtonItem*)sender;
    __weak typeof(self) weakself = self;
    [self.gameBoardView performSelector:@selector(changeCellColor:) withObject:^(){
        //[barBtnItem setEnabled:YES];
        weakself.changeTrickBtn = NO;
        [weakself.colorToolCountingView addCount:-1 isReverse:YES];
        [weakself.timeCountingView startCounting];
    }];
  
    if (!self.changeTrickBtn) {
        //[barBtnItem setEnabled:NO];
        self.changeTrickBtn = YES;
    }
    

}

-(IBAction)changeCellNumber:(id)sender{
    [_timeCountingView stopCounting];
    [[NGPlayer player] playSoundFXnamed:@"item_click.mp3" Loop:NO];
    self.gameBoardView.isChangeColor = NO;
    __weak typeof(self) weakself = self;
    //__block UIBarButtonItem* barBtnItem = (UIBarButtonItem*)sender;
    [self.gameBoardView performSelector:@selector(changeCellNumber:) withObject:^(){
        //[barBtnItem setEnabled:YES];
        weakself.changeTrickBtn = NO;
        [weakself.numberToolCountingView addCount:-1 isReverse:YES];
        [weakself.timeCountingView startCounting];
    } ];
    
    if (!self.changeTrickBtn) {
        //[barBtnItem setEnabled:NO];
        self.changeTrickBtn = YES;
    }
}


-(UIImage*)drawMaskImagofBtnItem:(UIBarButtonItem*)btnItem{

    UIGraphicsBeginImageContext(btnItem.image.size);
    UIImageView *imgView = [[UIImageView alloc]initWithImage:btnItem.image];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [imgView.layer renderInContext:context];
    CGFloat radius = MIN(btnItem.image.size.height, btnItem.image.size.width)/2;
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1 alpha:0.8].CGColor);
    CGContextAddArc(context, radius, radius, radius, 0, 2*M_PI, YES);
    CGContextFillPath(context);
    UIImage * retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return retImage;
}


@end
