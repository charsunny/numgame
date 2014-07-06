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

- (id)initWithFrame:(CGRect)frame andNum:(int)num
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = frame.size.width/2;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor greenColor];
        _numLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [_numLabel setText:[NSString stringWithFormat:@"%d",num]];
        [_numLabel setFont:[UIFont boldSystemFontOfSize:30]];
        [_numLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_numLabel];
        self.number = num;
    }
    return self;
}

- (void)setNumber:(int)number {
    _number = number;
    switch (number) {
        case 1:{
            self.backgroundColor =  RGBA(0x3a,0xc5,0x74,1.0);
            break;
        }
        case 5:{
            self.backgroundColor =  RGBA(0xc9,0x37,0x56,1.0);
            break;
        }
        case 3:{
            self.backgroundColor =  RGBA(0x44,0x8e,0xc9,1.0);
            break;
        }
        case 4:{
            self.backgroundColor =  RGBA(0xf1,0x6b,0x52,1.0);
            break;
        }
        case 2:{
            self.backgroundColor =  RGBA(0x8b,0x3e,0xbd,1.0);
            break;
        }
    }
}

@end
