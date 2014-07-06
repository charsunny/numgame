//
//  GameBoardCell.m
//  LineSum
//
//  Created by Sun Xi on 5/9/14.
//  Copyright (c) 2014 Vtm. All rights reserved.
//

#import "GameBoardCell.h"
@import CoreGraphics;

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
        self.backgroundColor = [self genRandColor];
        self.number = [self genRandNumber];
        _numLabel = [[UILabel alloc] initWithFrame:self.bounds];
        NSArray* brandArry = @[@"♡",@"♤",@"♧",@"♢"];
        [_numLabel setText:brandArry[rand()%4]];
        [_numLabel setFont:[UIFont boldSystemFontOfSize:30]];
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


@end
