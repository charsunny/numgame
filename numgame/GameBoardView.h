//
//  GameBoardView.h
//  LineSum
//
//  Created by Sun Xi on 5/9/14.
//  Copyright (c) 2014 Vtm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GameBoardViewDelegate <NSObject>
@optional
-(void)increaseScore:(int)deltaScore;
-(void)decreaseScore:(int)deltaScore;
@end
@interface GameBoardView : UIView

@property (weak,nonatomic)id<GameBoardViewDelegate>delegate;
@property (nonatomic ,assign) BOOL isChangeColor;
- (void)layoutBoardWithCellNum:(int)num;
-(void)addDashBoardScore:(int)score;


@end
