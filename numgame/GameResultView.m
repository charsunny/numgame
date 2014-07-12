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
//        POPSpringAnimation* animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
//        animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.01, 0.01)];
//        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
//        animation.springBounciness  = 10;
//        [_contentView pop_addAnimation:animation forKey:@"fall"];
    }

    return self;
}


-(void) initSubViews{

    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 10, 180, 50)];
    [self.titleLabel setText:@"YOUR  SCORE"];
    [self.titleLabel setTextAlignment: NSTextAlignmentCenter ];
    [self.titleLabel setFont:[UIFont fontWithName: TITLE_FONT size:25]];
    [self addSubview: self.titleLabel];
    
    
    self.scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 70, 260, 70)];
    [self.scoreLabel setText:_score];
    [self.scoreLabel setTextAlignment: NSTextAlignmentCenter];
    [self.scoreLabel setFont:[UIFont fontWithName: NUM_FONT size:30]];
    [self addSubview: self.scoreLabel];
    
    _shareBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _shareBtn.frame = CGRectMake(230, 10, 40, 40);
    [_shareBtn setTitle:@"M" forState:UIControlStateNormal];
    [_shareBtn.titleLabel setFont:[UIFont fontWithName:@"icomoon" size:20]];
    [self addSubview:_shareBtn];
    [_shareBtn addTarget:self action:@selector(shareBtnPressed:) forControlEvents: UIControlEventTouchUpInside];

    
    self.menuBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _menuBtn.frame = CGRectMake(0, 160, 140, 40);
    [_menuBtn setTitle:@"Main Menu" forState:UIControlStateNormal];
    [self addSubview:_menuBtn];
    [_menuBtn.titleLabel setFont:[UIFont fontWithName:TITLE_FONT size:20]];
    [_menuBtn addTarget:self action:@selector(menuBtnPressed:) forControlEvents: UIControlEventTouchUpInside];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _playBtn.frame = CGRectMake(140, 160, 140, 40);
    if (self.isCompleted) {
         [_playBtn setTitle:@"Next Level" forState:UIControlStateNormal];
    }
    else{
        [_playBtn setTitle:@"Try again" forState:UIControlStateNormal];
    }
   
    [_playBtn.titleLabel setFont:[UIFont fontWithName:TITLE_FONT size:20]];
    [self addSubview:_playBtn];
    [_playBtn addTarget:self action:@selector(playBtnPressed:) forControlEvents: UIControlEventTouchUpInside];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)menuBtnPressed:(UIButton*)btn{

   

    
}


-(void)playBtnPressed:(UIButton*)btn{

     [self removeFromSuperview];
}

- (void)shareBtnPressed:(UIButton*)btn {

}

@end
