//
//  NumberLabel.h
//  numgame
//
//  Created by apple on 14-7-13.
//  Copyright (c) 2014年 Sun Xi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^NumberLabelTouched)(NSInteger idx);
@interface NumberLabel : UILabel


//初始化数字
-(id)initWithNumber:(int)number CallBack:(NumberLabelTouched)block;


@end
