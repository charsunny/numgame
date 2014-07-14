//
//  NEContainerView.h
//  numgame
//
//  Created by apple on 14-7-13.
//  Copyright (c) 2014年 Sun Xi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NEContainerView : UIView


@property (nonatomic,assign, readonly)BOOL isShow;
@property (nonatomic,assign) CGFloat itemSpaceing;


-(id)initWithNumberItems:(NSArray*)numberItems;
-(void)show;
-(void)hide;

@end
