//
//  GameBoardCell+NumberChange.m
//  numgame
//
//  Created by apple on 14-7-16.
//  Copyright (c) 2014年 Sun Xi. All rights reserved.
//

#import "GameBoardCell+NumberChange.h"
#import <objc/runtime.h>

#define kNumberSelectionTag (2333)
#define kAnimationDelay (0.1)
static const char kAnimationArray[15] = "kAnumationArray";

@implementation GameBoardCell (NumberChange)
@dynamic animationArray;



//扩展属性animationArray

-(NSArray*)animationArray{

    return objc_getAssociatedObject(self
                                    ,&kAnimationArray);

}


-(void)setAnimationArray:(NSArray *)animationArray{

    objc_setAssociatedObject(self, &kAnimationArray, animationArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}


-(void)addNumberCellSet:(NSArray*)numberCells{
   
    self.animationArray = numberCells;
    
    [self.animationArray enumerateObjectsUsingBlock:^(UIView* item , NSUInteger idx, BOOL *stop) {
        
        UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleActionForNumberTapGesture:)];
        [item addGestureRecognizer:gesture];
        [item setTag:kNumberSelectionTag +idx ];
        [item setFrame:CGRectZero];
        
        
    }];

  
}

//将view加到当前的View上，同时放大View与关键路径
-(void)showAnimation{

    for (UIView * view in self.animationArray) {
        
        [self addSubview:view];
        [self performSelector:@selector(showNumberItem:) withObject:view afterDelay:kAnimationDelay*(view.tag-kNumberSelectionTag) ];
    }
    

}


//判断点击cell的数字，改变cell的数字，同时收起动画
-(void)handleActionForNumberTapGesture:(UITapGestureRecognizer*)tapGesture{



}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{

    for (UIView* item in self.animationArray) {
        if (CGRectContainsPoint(item.frame, point)) {
            return YES;
        }
    }

    return NO;
}

-(void)showNumberItem:(UIView*)item{



}



@end
