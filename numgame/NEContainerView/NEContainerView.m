//
//  NEContainerView.m
//  numgame
//
//  Created by apple on 14-7-13.
//  Copyright (c) 2014年 Sun Xi. All rights reserved.
//

#import "NEContainerView.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <pop/POP.h>

#define kAnimationDelay  0.1
@interface NEContainerView ()

@property (nonatomic, strong) NSArray * items;
@property (nonatomic,assign) CGFloat viewWidth;
@property (nonatomic,assign) CGFloat viewHight;

@property (nonatomic,assign, readwrite)BOOL isShow;

@end

@implementation NEContainerView


-(id)initWithNumberItems:(NSArray *)numberItems{

    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.items = numberItems;
        self.itemSpaceing = 0;
    }

    return self;
}



-(void) setItems:(NSArray *)items{
    
    for (UIView* item in items) {
        item.layer.opacity = 1;
        [item removeFromSuperview];
    }
    _items = items;
    for (UIView* item in items) {
        [self addSubview:item];
    }
}



-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.viewWidth = 0;
    self.viewHight = 0;
    CGFloat __block biggestHeight = 0;
    CGFloat __block biggestWidth = 0;
    
    [self.items enumerateObjectsUsingBlock:^(UIView* view, NSUInteger idx, BOOL *stop) {
        
        self.viewHight = MAX(view.frame.size.height, biggestHeight);
        biggestWidth = MAX(view.frame.size.width, biggestWidth);
    }];
    self.viewWidth = (biggestWidth * self.items.count)+ self.itemSpaceing*(self.items.count -1);
    //计算要菜单要显示的位置
    
    CGFloat x = 0.f;
    CGFloat y = 0.f;
    
    x = self.superview.frame.size.width/2 - self.viewWidth/2;
    y = self.superview.frame.size.height;
    //self.frame = CGRectMake(x, y, self.viewWidth, self.viewHight);
    self.frame = CGRectMake(x, y , self.viewWidth, self.viewHight);
    
    [self.items enumerateObjectsUsingBlock:^(UIView* view , NSUInteger idx, BOOL *stop) {
        
        [view setCenter:CGPointMake(idx * biggestWidth +idx *self.itemSpaceing + biggestWidth/2.f, self.viewHight/2)];
        
    }];
    
}


-(void)show{
    
    _isShow = YES;
    
    //   [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y-40, self.viewWidth, self.viewHight)];
    
    for (UIView *item in self.items) {
        
        [self performSelector:@selector(showNumberItem:)
                   withObject:item afterDelay:kAnimationDelay*[self.items indexOfObject:item]];
    }
    
    
}


-(void)hide{
    
    _isShow = NO;
    for (UIView *item in self.items) {
        [self performSelector:@selector(hideItem:) withObject:item afterDelay:kAnimationDelay*[self.items indexOfObject:item]];
    }
    
}


//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    for (UIView *item in self.items) {
//        if (CGRectContainsPoint(item.frame, point))
//            return YES;
//    }
//    
//    return NO;
//}

//显示View的动画
-(void)showNumberItem:(UILabel*)item{
    
//    POPSpringAnimation * springAnimation = [POPSpringAnimation animation];
//    springAnimation.property = [POPMutableAnimatableProperty propertyWithName:kPOPViewCenter];
//    springAnimation.fromValue = [NSValue valueWithCGPoint:item.center];
//    springAnimation.toValue =[NSValue valueWithCGPoint:CGPointMake(item.center.x, item.center.y-20)];
//    springAnimation.springBounciness = 20;
//    springAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(0, 200)];
//    [item pop_addAnimation:springAnimation forKey:@"centerA"];
    [NSObject cancelPreviousPerformRequestsWithTarget:item.layer];
    [item setFrame:CGRectOffset(item.frame, 0, -30)];
    
}


-(void)hideItem:(UIView*)item{
    
    
}




@end
