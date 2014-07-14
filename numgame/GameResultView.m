//
//  GameResultView.m
//  numgame
//
//  Created by apple on 14-7-12.
//  Copyright (c) 2014年 Sun Xi. All rights reserved.
//

#import "pop/pop.h"
#import "GameResultView.h"

@import CoreGraphics;

@interface GameResultView ()

@property (nonatomic ,strong)UIToolbar *toolbar;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *nextLevelLabel;
@property (nonatomic, strong) UILabel *nextScoreLabel;
@property (nonatomic, strong) UIButton *menuBtn;
@property (nonatomic ,strong) UIButton *playBtn;
@property (nonatomic ,strong) UIButton *shareBtn;
@property (nonatomic, strong) NSString* score;
@property (nonatomic,assign) BOOL isCompleted;

@end

@implementation GameResultView

-(id)initGameResultViewWithScore:(NSInteger)score Completion:(BOOL)isPass{

    CGRect rect = [[UIApplication sharedApplication] keyWindow].frame;
    self = [self initWithFrame:rect];
    self.isCompleted = isPass;
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:127 green:127 blue:127 alpha:0.8]];
        
        _score = [NSString stringWithFormat:@"%d",score];
        
        _toolbar = [[UIToolbar alloc] initWithFrame:self.frame];
        
        [_toolbar setTranslatesAutoresizingMaskIntoConstraints:NO];

        [self insertSubview:_toolbar atIndex:0];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolbar]|"
                                                                     options:0
                                                                     metrics:0
                                                                       views:NSDictionaryOfVariableBindings(_toolbar)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_toolbar]|"
                                                                     options:0
                                                                     metrics:0
                                                                       views:NSDictionaryOfVariableBindings(_toolbar)]];

        [_toolbar setTranslucent:YES];
        
        [self initSubViews];
    }

    return self;
}


-(void) initSubViews{
    
    int margin = 0;
    if (iPhone5) {
        margin = 50;
    }

    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, margin + 80, 220, 40)];
    [self.titleLabel setText:@"CURRECT SCORE"];
    [self.titleLabel setTextAlignment: NSTextAlignmentCenter ];
    [self.titleLabel setFont:[UIFont fontWithName: TITLE_FONT size:25]];
    [self addSubview: self.titleLabel];
    
    self.scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, margin + 130, 300, 40)];
    [self.scoreLabel setText:_score];
    [self.scoreLabel setTextAlignment: NSTextAlignmentCenter];
    [self.scoreLabel setFont:[UIFont fontWithName: NUM_FONT size:40]];
    [self addSubview: self.scoreLabel];
    
    self.nextLevelLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, margin + 200, 220, 40)];
    [self.nextLevelLabel setText:@"NEXT TARGET"];
    [self.nextLevelLabel setTextAlignment: NSTextAlignmentCenter ];
    [self.nextLevelLabel setFont:[UIFont fontWithName: TITLE_FONT size:25]];
    [self addSubview: self.nextLevelLabel];
    
    
    self.nextScoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, margin + 250, 300, 40)];
    [self.nextScoreLabel setText:_score];
    [self.nextScoreLabel setTextAlignment: NSTextAlignmentCenter];
    [self.nextScoreLabel setFont:[UIFont fontWithName: NUM_FONT size:40]];
    [self addSubview: self.nextScoreLabel];
    
    _shareBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _shareBtn.frame = CGRectMake(0, 0, 50, 50);
    _shareBtn.layer.cornerRadius = 25;
    _shareBtn.backgroundColor = [UIColor colorWithRed:245/255.0 green:151/255.0 blue:77/255.0 alpha:1];
    _shareBtn.center = CGPointMake(self.frame.size.width/2, 40);
    [_shareBtn setTitle:@"M" forState:UIControlStateNormal];
    [_shareBtn.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:25]];
    [self addSubview:_shareBtn];
    [_shareBtn addTarget:self action:@selector(shareBtnPressed:) forControlEvents: UIControlEventTouchUpInside];

    
    self.menuBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _menuBtn.frame = CGRectMake(0, 0, 200, 40);
    _menuBtn.layer.cornerRadius = 20;
    _menuBtn.backgroundColor = [UIColor colorWithRed:68/255.0 green:207/255.0 blue:76/255.0 alpha:1];
    _menuBtn.center = CGPointMake(self.center.x, self.frame.size.height - 60);
    [_menuBtn setTitle:@"Main Menu" forState:UIControlStateNormal];
    [self addSubview:_menuBtn];
    [_menuBtn.titleLabel setFont:[UIFont fontWithName:TITLE_FONT size:20]];
    [_menuBtn.titleLabel setTextColor:[UIColor whiteColor]];
    [_menuBtn addTarget:self action:@selector(menuBtnPressed:) forControlEvents: UIControlEventTouchUpInside];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _playBtn.frame = CGRectMake(0, 0, 200, 40);
    _playBtn.center = CGPointMake(self.center.x, self.frame.size.height - 120);
    _playBtn.backgroundColor = [UIColor colorWithRed:132/255.0 green:69/255.0 blue:189/255.0 alpha:1];
    _playBtn.layer.cornerRadius = 20;
    [_playBtn setTitle:self.isCompleted ? @"Next Level" : @"Try again"forState:UIControlStateNormal];
    [_playBtn.titleLabel setFont:[UIFont fontWithName:TITLE_FONT size:20]];
    [_playBtn.titleLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:_playBtn];
    [_playBtn addTarget:self action:@selector(playBtnPressed:) forControlEvents: UIControlEventTouchUpInside];
}


-(void)menuBtnPressed:(UIButton*)btn{

    
}


-(void)playBtnPressed:(UIButton*)btn{

     [self removeFromSuperview];
}

- (void)shareBtnPressed:(UIButton*)btn {

}

@end
