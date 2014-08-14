//
//  GameCountingCircleView.m
//  numgame
//
//  Created by Lanston Peng on 8/13/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "GameCountingCircleView.h"


#define DEG2RAD(angle) ( angle )*M_PI/180.0

#define UpdateFrequency 1/30

CGFloat radius = 30;//半径
CGFloat startX = 50;//圆心x坐标
CGFloat startY = 50;//圆心y坐标
CGFloat pieStart = 270;//起始的角度
//CGFloat pieCapacity = 0;//角度增量值
//int clockwise = 1;//0=逆时针,1=顺时针

@interface GameCountingCircleView()

@property (strong,nonatomic)CALayer* frontLayer;

@property (strong,nonatomic)NSTimer* timer;

@property (strong,nonatomic)UILabel* countLabel;

@property (nonatomic)int addCountCurrentNumber;

@property (nonatomic)int currentCount;

@property (nonatomic)int deltaCount;
@end

@implementation GameCountingCircleView

- (void)drawRect:(CGRect)rect {

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0, 1, 1, 1);
    CGContextSetLineWidth(context, 5);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextAddArc(context, startX, startY, radius, DEG2RAD(pieStart), DEG2RAD( pieStart + _pieCapacity), _clockwise);
    
    CGContextStrokePath(context);
}

- (void)setCurrentCount:(int)currentCount
{
    _currentCount = currentCount;
    _countLabel.text = [NSString stringWithFormat:@"%d",currentCount];
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
        startX = self.bounds.size.width/2;
        startY = self.bounds.size.height/2;
        radius = smallerFrame.size.width/2 + 1;
        _pieCapacity = 0;
        _clockwise = 0;
        _frontLayer.frame = smallerFrame;
        _frontLayer.cornerRadius = smallerFrame.size.width / 2;
        _frontLayer.backgroundColor = [UIColor orangeColor].CGColor;
        [self.layer addSublayer:_frontLayer];
        
    }
    return self;
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
    //TODO: add shadow
    [self addSubview:_countLabel];
}

- (void)addCount:(int)deltaNum
{
    self.currentCount += deltaNum;
    _pieCapacity = 1.0 * _currentCount / _deltaCount * 360;
    
    if (_currentCount == _destinationCount) {
        if ([self.delegate respondsToSelector:@selector(GameCoutingCircleDidEndCount:)]) {
            [self.delegate GameCoutingCircleDidEndCount:self.circleKey];
        }
    }
    [self setNeedsDisplay];
}
- (void)updateSector
{
    _pieCapacity += 360 / ( _destinationCount / (1.0 / 30 ));
    
    _addCountCurrentNumber += 1;
    
    if (_addCountCurrentNumber >= _addCountCeiling) {
        _addCountCurrentNumber = 0;
        self.currentCount += self.countStep;
    }
    [self setNeedsDisplay];
}

- (void)startCounting
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.032 target:self selector:@selector(updateSector) userInfo:nil repeats:YES];
}

- (void)stopCounting
{
    [_timer invalidate];
}
@end
