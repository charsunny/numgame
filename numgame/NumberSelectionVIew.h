//
//  NumberSelectionVIew.h
//  numgame
//
//  Created by apple on 14-7-13.
//  Copyright (c) 2014年 Sun Xi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pop/POP.h>


typedef void(^TouchNumberBlock)(NSInteger idx);

@interface NumberSelectionVIew : UIView

@property (nonatomic ,strong) TouchNumberBlock block;
@property (nonatomic,assign, readonly)BOOL isShow;
@property (nonatomic,assign) CGFloat itemSpaceing;


-(id)initWithNumberItems:(NSArray*)numberItems withTouchBlock: (TouchNumberBlock)block;
-(void)show;
-(void)hide;

@end
