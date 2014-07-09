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

@interface GameBoardCell()

@property (strong, nonatomic) UILabel* numLabel;
@property (strong, nonatomic) UIView* effectView;
@end

@implementation GameBoardCell

- (void)setCellNumber:(int)cellNumber
{
    _cellNumber = cellNumber;
    [_numLabel setText:[NSString stringWithFormat:@"%d",cellNumber ]];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = frame.size.width/2;
        _numLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.cellNumber = [self genRandNumber];
        self.backgroundColor = [self genRandColor];
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
    int ranNum = rand() % 4;
    self.color = ranNum;
    return [GameBoardCell generateColor:ranNum];
}

- (int)genRandNumber {
    return rand()%5+1;
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
    _effectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _effectView.layer.cornerRadius = self.layer.cornerRadius;
    [_effectView setBackgroundColor:self.backgroundColor];
    [_effectView setClipsToBounds:YES];
    [self insertSubview:_effectView belowSubview:self];
    if (animate) {
        [UIView animateWithDuration:0.4f animations:^{
            _effectView.transform = CGAffineTransformMakeScale(2, 2);
            _effectView.alpha = 0;
        } completion:^(BOOL finished) {
            [_effectView removeFromSuperview];
        }];
    } else {
        _effectView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        _effectView.alpha = 0.7;
    }
}

- (void)removeRippleEffectView {
    [_effectView removeFromSuperview];
}

@end
