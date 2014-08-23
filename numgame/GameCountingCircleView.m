//
//  GameCountingCircleView.m
//  numgame
//
//  Created by Lanston Peng on 8/13/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "GameCountingCircleView.h"
#import <QuartzCore/QuartzCore.h>


#define DEG2RAD(angle) ( angle )*M_PI/180.0

#define UpdateFrequency 1/30

//CGFloat radius = 30;//半径
//CGFloat startX = 50;//圆心x坐标
//CGFloat startY = 50;//圆心y坐标
//CGFloat pieStart = 270;//起始的角度
//CGFloat pieCapacity = 0;//角度增量值
//int clockwise = 1;//0=逆时针,1=顺时针

@interface GameCountingCircleView()<UIGestureRecognizerDelegate>

@property (strong,nonatomic)CALayer* frontLayer;

@property (strong,nonatomic)CALayer* frontBgLayer;

@property (strong,nonatomic)CAShapeLayer* circleLayer;

@property (strong,nonatomic)NSTimer* timer;

@property (strong,nonatomic)UILabel* countLabel;

@property (strong,nonatomic)UIImageView* contentImageView;

@property (nonatomic)int addCountCurrentNumber;

@property (nonatomic)CGFloat startX;
@property (nonatomic)CGFloat startY;
@property (nonatomic)CGFloat radius;
@property (nonatomic)CGFloat pieStart;

@end

@implementation GameCountingCircleView

- (void)setCurrentCount:(int)currentCount
{
    _currentCount = currentCount;
    _countLabel.text = [NSString stringWithFormat:@"%d",currentCount];
}
- (void)setFrontColor:(UIColor *)frontColor
{
    _frontColor = frontColor;
    _frontLayer.backgroundColor = _frontColor.CGColor;
}
- (void)setCircleColor:(UIColor *)circleColor
{
    _circleColor = circleColor;
    _frontBgLayer.backgroundColor = _circleColor.CGColor;
    _circleLayer.strokeColor = _circleColor.CGColor;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        self.layer.masksToBounds = NO;
        CGRect smallerFrame = CGRectInset(self.bounds, 10, 10);
        
        _frontLayer = [CALayer layer];
        _startX = self.bounds.size.width/2;
        _startY = self.bounds.size.height/2;
        _radius = smallerFrame.size.width/2 + 1;
        _pieStart = 270;
        _pieCapacity = 0;
        _clockwise = 0;
        _frontLayer.frame = smallerFrame;
        _frontLayer.cornerRadius = smallerFrame.size.width / 2;
        
        //Default color
        _frontColor = [UIColor orangeColor];
        _circleColor = [UIColor blackColor];
        
        _frontBgLayer = [CALayer layer];
        _frontBgLayer.opacity = 0.5;
        _frontBgLayer.frame = CGRectInset(smallerFrame, -2, -2);
        _frontBgLayer.cornerRadius = smallerFrame.size.width  / 2 + 1;
        _frontBgLayer.shadowOpacity = 0.4;
        _frontBgLayer.shadowOffset = CGSizeMake(0,2);
        _frontBgLayer.shadowColor = [UIColor blackColor].CGColor;
        _frontBgLayer.shadowRadius = 5;
        _frontBgLayer.masksToBounds = NO;
        
        _circleLayer = [CAShapeLayer layer];
        //_circleLayer.frame = CGRectInset(smallerFrame, -2, -2);
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        _circleLayer.strokeStart = 0;
        _circleLayer.strokeEnd = 1;
        _circleLayer.lineWidth = 5;
        _circleLayer.lineCap = @"round";
        
        [self.layer addSublayer:_frontLayer];
        [self.layer insertSublayer:_frontBgLayer below:_frontLayer];
        [self.layer insertSublayer:_circleLayer above:_frontBgLayer];
        
        
        
    }
    return self;
}


- (UIBezierPath*)getCurrentPath
{
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(_startX, _startY) radius:_radius startAngle:DEG2RAD(_pieStart) endAngle:DEG2RAD(_pieStart + _pieCapacity) clockwise:!_clockwise];
    return path;
}
- (void)initShapeLayer
{
    _circleLayer.path = [self getCurrentPath].CGPath;
}

- (void)initData:(int)destinationCount withStart:(int)startCount
{
    _countLabel = [[UILabel alloc]initWithFrame:self.bounds];
    self.currentCount = startCount;
    _destinationCount = destinationCount;
    _addCountCeiling = 30;
    _countStep = 1;
    _deltaCount = abs(_destinationCount - startCount);
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.font =[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:20];
    _countLabel.adjustsFontSizeToFitWidth = YES;
    _countLabel.layer.shadowOpacity = 0.5;
    _countLabel.layer.shadowOffset = CGSizeMake(0,2);
    _countLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _countLabel.layer.shadowRadius = 1.5;
    _countLabel.layer.masksToBounds = NO;
    //TODO: add shadow
    [self addSubview:_countLabel];
}

- (void)setContentImage:(UIImage*)image{
    _countLabel.alpha = 0;
    _contentImageView = [[UIImageView alloc]initWithFrame:CGRectInset(self.bounds, 10, 10)];
    _contentImageView.layer.shadowOpacity = 0.3;
    _contentImageView.layer.shadowOffset = CGSizeMake(0,2);
    _contentImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _contentImageView.layer.shadowRadius = 3;
    _contentImageView.layer.masksToBounds = NO;
    _contentImageView.image = image;
    [self addSubview:_contentImageView];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showCurrentCountNum)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
}
- (void)showCurrentCountNum
{
    [UIView animateWithDuration:0.2 animations:^{
        _contentImageView.alpha = 0;
        _countLabel.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}
- (void)showContentImageView
{
    [UIView animateWithDuration:0.2 delay:0.8 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _contentImageView.alpha = 1;
        _countLabel.alpha = 0;
    } completion:nil];
}

- (void)addCount:(int)deltaNum
{
    self.currentCount += deltaNum;
    _pieCapacity = 1.0 * _currentCount / _deltaCount * 360;
    
    if (_currentCount == _destinationCount) {
        if([self.delegate respondsToSelector:@selector(GameCoutingCircleDidEndCount:)]){
            [self.delegate GameCoutingCircleDidEndCount:self.circleKey];
        }
    }
    [self setNeedsDisplay];
}

- (void)addCount:(int)deltaNum isReverse:(BOOL)isReverse
{
    CAKeyframeAnimation* circleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    self.currentCount += deltaNum;
    _pieCapacity = 1.0 * _currentCount / _deltaCount * 360;
    _circleLayer.path = [self getCurrentPath].CGPath;
    
    if (isReverse) {
        circleAnimation.values = @[@(1),@(0.9),@(1)];
        circleAnimation.keyTimes = @[@(0),@(0.3),@(1)];
    }
    else
    {
        circleAnimation.values = @[@(1),@(0.9),@(1)];
        circleAnimation.keyTimes = @[@(0),@(0.3),@(1)];
    }
    
    circleAnimation.duration = 0.3;
    circleAnimation.removedOnCompletion = NO;
    circleAnimation.fillMode = kCAFillModeForwards;
    circleAnimation.delegate = self;
    
    [_circleLayer addAnimation:circleAnimation forKey:@"sucker"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (_currentCount == _destinationCount) {
        if([self.delegate respondsToSelector:@selector(GameCoutingCircleDidEndCount:)]){
            [self.delegate GameCoutingCircleDidEndCount:self.circleKey];
        }
    }
}

- (void)updateSector
{
    [self addCount:-1 isReverse:YES];
}

- (void)startCounting
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateSector) userInfo:nil repeats:YES];
}
- (void)pauseCounting
{
}
- (void)stopCounting
{
    [_timer invalidate];
}

#pragma mark Gesture Recognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
@end
