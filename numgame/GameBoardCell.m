//
//  GameBoardCell.m
//  LineSum
//
//  Created by Sun Xi on 5/9/14.
//  Copyright (c) 2014 Vtm. All rights reserved.
//

#import "GameBoardCell.h"
@import CoreGraphics;

#define DefalutNumFontSize 30
#define DefalutNumFontFamily @"AppleSDGothicNeo-Thin"

@interface GameBoardCell()<NSCopying>

@property (strong, nonatomic) UILabel* numLabel;
@property (strong, nonatomic) CALayer* effectLayer;
@property (strong,nonatomic)void (^animtionCallback)();

@end

@implementation GameBoardCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //[self setNumber:[self genRandNumber]];
        self.layer.cornerRadius = frame.size.width/2;
        //self.clipsToBounds = YES;
        self.number = [self genRandNumber];
        self.backgroundColor = [self genRandColor];
        _numLabel = [[UILabel alloc] initWithFrame:self.bounds];
        //NSArray* brandArry = @[@"♡",@"♤",@"♧",@"♢"];
        [_numLabel setText:[NSString stringWithFormat:@"%d",_number ]];
        //[_numLabel setFont:[UIFont boldSystemFontOfSize:DefalutNumFontSize]];
        [_numLabel setFont:[UIFont fontWithName:DefalutNumFontFamily size:frame.size.width/2]];
        [_numLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_numLabel];
    }
    return self;
}
- (void)setColor:(int)color
{
    _color = color;
    self.backgroundColor = [GameBoardCell generateColor:color];
}
- (UIColor*)genRandColor {
    //NSArray* colors = @[RGBA(0x3a,0xc5,0x74,1.0), RGBA(0xf1,0x6b,0x52,1.0), RGBA(0x44,0x8e,0xc9,1.0), RGBA(0x8b,0x3e,0xbd,1.0)];
    //return colors[rand()%4];
    int ranNum = rand() % 4;
    self.color = ranNum;
    return [GameBoardCell generateColor:ranNum];
}

- (int)genRandNumber {
    return rand()%4+1;
}
//color scheme from:http://www.colourlovers.com/palette/2584642/Vital_Passion
+ (UIColor*)generateColor:(int)number
{
    switch (number) {
        case 0:
            return UIColorFromRGB(0xFF814F);
        case 1:
            return UIColorFromRGB(0xF9FF4F);
        case 2:
            return UIColorFromRGB(0x34D3FF);
        case 3:
            return UIColorFromRGB(0x46FFAB);
        default:
            return UIColorFromRGB(0xFF814F);
            break;
    }
}

- (void)addRippleEffectToView:(BOOL)animate {
    if (animate) {
        UIView* tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        tmpView.layer.cornerRadius = self.layer.cornerRadius;
        [tmpView setBackgroundColor:self.backgroundColor];
        [tmpView setClipsToBounds:YES];
        [self insertSubview:tmpView belowSubview:self];
        [UIView animateWithDuration:0.4f animations:^{
            tmpView.transform = CGAffineTransformMakeScale(2, 2);
            tmpView.alpha = 0;
        } completion:^(BOOL finished) {
            [tmpView removeFromSuperview];
        }];
    } else {
        _effectLayer = [CALayer layer];
        _effectLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _effectLayer.cornerRadius = self.layer.cornerRadius;
        _effectLayer.backgroundColor = self.backgroundColor.CGColor;
        _effectLayer.opacity = 0.7;
        _effectLayer.transform = CATransform3DMakeScale(1.3, 1.3, 1.0);
        [self.layer insertSublayer:_effectLayer below:self.numLabel.layer];
    }
}

- (void)removeRippleEffectView {
    [_effectLayer removeFromSuperlayer];
    [self.layer setNeedsDisplay];
}

- (void)addFlyEffect:(CGPoint)endPoint callback:(void (^)())callback
{
    //CGPoint curPoint = [self convertPoint:self.frame.origin fromView:self.superview];
    self.animtionCallback = callback;
    CGPoint curPoint = self.frame.origin;
    
   
    CABasicAnimation* opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.fromValue = @(1);
    opacity.toValue = @(0.5);
    
    CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @(1);
    scaleAnimation.toValue = @(0.3);
    
    CAKeyframeAnimation* pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = YES;
    
    CGMutablePathRef curvePath = CGPathCreateMutable();
    CGPathMoveToPoint(curvePath, nil, curPoint.x, curPoint.y);
    CGPoint midPoint = CGPointMake((endPoint.x + curPoint.x)/2 + rand() % 2 * 40 * (rand() % 2 == 1 ? 1 : -1), (endPoint.y + curPoint.y)/2 + rand() % 2 * 40 * (rand() % 2 == 1 ? 1 : -1));
    
    CGPathAddCurveToPoint(curvePath, nil, midPoint.x, midPoint.y, midPoint.x, midPoint.y, endPoint.x, endPoint.y);
    pathAnimation.path = curvePath;
    
    CAAnimationGroup* groupAnimation = [[CAAnimationGroup alloc] init];
    groupAnimation.animations = @[ pathAnimation, scaleAnimation,opacity];
    groupAnimation.duration = 0.3;
    groupAnimation.removedOnCompletion = YES;
    groupAnimation.fillMode = kCAFillModeForwards;
    groupAnimation.delegate = self;
    [self.layer addAnimation:groupAnimation forKey:@"flyCellEffect"];
    self.alpha = 0;
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.animtionCallback();
    [self removeFromSuperview];
}

- (id)copyWithZone:(NSZone *)zone
{
    GameBoardCell* copyCell = [[GameBoardCell alloc]initWithFrame:self.frame];
    copyCell.number = self.number;
    copyCell.backgroundColor = self.backgroundColor;
    [copyCell.numLabel setText:[NSString stringWithFormat:@"%d",_number ]];
    return copyCell;
}
@end
