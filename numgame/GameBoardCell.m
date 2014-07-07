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

@end

@implementation GameBoardCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setNumber:[self genRandNumber]];
        self.layer.cornerRadius = frame.size.width/2;
        self.clipsToBounds = YES;
        self.number = [self genRandNumber];
        self.backgroundColor = [self generateColor:_number];
        _numLabel = [[UILabel alloc] initWithFrame:self.bounds];
        //NSArray* brandArry = @[@"♡",@"♤",@"♧",@"♢"];
        NSArray* brandArry = @[@"1",@"2",@"3",@"4"];
        [_numLabel setText:brandArry[rand()%4]];
        //[_numLabel setFont:[UIFont boldSystemFontOfSize:DefalutNumFontSize]];
        [_numLabel setFont:[UIFont fontWithName:DefalutNumFontFamily size:frame.size.width/2]];
        [_numLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_numLabel];
    }
    return self;
}

- (UIColor*)genRandColor {
    NSArray* colors = @[RGBA(0x3a,0xc5,0x74,1.0), RGBA(0xf1,0x6b,0x52,1.0), RGBA(0x44,0x8e,0xc9,1.0), RGBA(0x8b,0x3e,0xbd,1.0)];
    return colors[rand()%4];
}

- (int)genRandNumber {
    return rand()%4+1;
}
- (UIColor*)generateColor:(int)number
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


@end
