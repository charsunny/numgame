//
//  GameCountingCircleView.h
//  numgame
//
//  Created by Lanston Peng on 8/13/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GameCountingCircleDelegate <NSObject>

@optional

- (void)GameCoutingCircleDidEndCount:(NSString*)circleKey;

@end

@interface GameCountingCircleView : UIView

@property (nonatomic)int destinationCount;

@property (strong,nonatomic)NSString* circleKey;

@property (nonatomic)int countStep;

@property (nonatomic)int addCountCeiling;

@property (nonatomic)CGFloat pieCapacity;//角度增量值

@property (nonatomic)int clockwise;//0=逆时针,1=顺时针

@property (nonatomic)int currentCount;

@property (nonatomic)int deltaCount;

@property (strong,nonatomic)id<GameCountingCircleDelegate> delegate;

- (void)addCount:(int)deltaNum;

- (void)startCounting;

- (void)stopCounting;

- (void)initData:(int)destinationCount withStart:(int)startCount;
@end
