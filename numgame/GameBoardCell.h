//
//  GameBoardCell.h
//  LineSum
//
//  Created by Sun Xi on 5/9/14.
//  Copyright (c) 2014 Vtm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameBoardCell : UIView

@property (nonatomic) int cellNumber;

@property (nonatomic) int color;

@property (nonatomic) int desTag;

+ (UIColor*)generateColor:(int)number;

- (id)initWithFrame:(CGRect)frame;
- (void)addRippleEffectToView:(BOOL)animate;
- (void)removeRippleEffectView;
@end
