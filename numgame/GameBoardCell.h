//
//  GameBoardCell.h
//  LineSum
//
//  Created by Sun Xi on 5/9/14.
//  Copyright (c) 2014 Vtm. All rights reserved.
//

#import <UIKit/UIKit.h>





//定义cell的位置
typedef NS_ENUM(NSUInteger, GBCellPosition) {
    GBCellPositionNormal = 0,
    GBCellPositionLeft,
    GBCellPositionRight,
    GBCellPositionTop,
    GBCellPositionRightDown,
    GBCellPositionLeftDown,
    GBCellPositionRightUp,
    GBCellPositionLeftUp
};

//定义道具的显示
typedef NS_ENUM(NSUInteger, GBTrakingCategory) {
    GBTrakingCategoryNum,
    GBTrakingCategoryColor
};

@class GameBoardCell;
@protocol GameboardCellDelegate <NSObject>

@optional

-(void)gameBoardCell:(GameBoardCell*)cell withCategory:(GBTrakingCategory)category;

@end


@interface GameBoardCell : UIView

@property (nonatomic) int number;

@property (nonatomic) int color;

@property (nonatomic) int desTag;
@property (nonatomic, assign)id<GameboardCellDelegate> delegate;
//初始化cell的位置
@property (nonatomic,assign) GBCellPosition  cellPositon;

@property (strong ,nonatomic) NSMutableArray * accessoryItems;

+ (UIColor*)generateColor:(int)number;

- (id)initWithFrame:(CGRect)frame;
- (void)addRippleEffectToView:(BOOL)animate;
- (void)removeRippleEffectView;
- (void)addFlyEffect:(CGPoint)endPoint callback:(void (^)())callback;

//增加方法
-(id)initWithFrame:(CGRect)frame Position:(GBCellPosition)cellPosition;
-(void)addTrickingWithType:(GBTrakingCategory) category;
-(void)showAnimation;
-(void)hideAnimation;
-(void)removeTricking;
@end
