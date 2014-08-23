//
//  NumberSelectionVIew.m
//  numgame
//
//  Created by apple on 14-7-13.
//  Copyright (c) 2014年 Sun Xi. All rights reserved.
//

#import "NumberSelectionVIew.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define kAnimationDelay  0.1

@interface NumberSelectionVIew ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray * items;

@property (nonatomic,assign) CGFloat viewWidth;

@property (nonatomic,assign) CGFloat viewHight;

@property (nonatomic,assign, readwrite)BOOL isShow;


@end


@implementation NumberSelectionVIew

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(id)initWithNumberItems:(NSArray*)numberItems withTouchBlock: (TouchNumberBlock)block{
   
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
        self.items = numberItems;
        self.block = block;
        self.itemSpaceing = 0;
//        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleActionForTapGesture:)];
//        [self addGestureRecognizer:gesture];
    
    }


    return self;
}

//默认的set方法
-(void) setItems:(NSArray *)items{

    for (UIView* item in items) {
        item.layer.opacity = 1;
        [item removeFromSuperview];
    }
    _items = items;
    for (UIView* item in items) {
        UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleActionForNumberTapGesture:)];
        [gesture setDelegate:self];
        [item addGestureRecognizer:gesture];
        [self addSubview:item];
    }
}


//显示
-(void)show{

    _isShow = YES;
    
 //   [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y-40, self.viewWidth, self.viewHight)];
    for (UIView *item in self.items) {
        [self performSelector:@selector(showNumberItem:)
                   withObject:item afterDelay:kAnimationDelay*[self.items indexOfObject:item]];
    }
}

//隐藏
-(void)hide{

    _isShow = NO;
    for (UIView *item in self.items) {
        [self performSelector:@selector(hideItem:) withObject:item afterDelay:kAnimationDelay*[self.items indexOfObject:item]];
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
//显示View的动画
-(void)showNumberItem:(UIView*)item{

        POPSpringAnimation * springAnimation = [POPSpringAnimation animation];
        springAnimation.property = [POPMutableAnimatableProperty propertyWithName:kPOPViewCenter];
        springAnimation.fromValue = [NSValue valueWithCGPoint:item.center];
        springAnimation.toValue =[NSValue valueWithCGPoint:CGPointMake(item.center.x, item.center.y-40)];
        springAnimation.springBounciness = 20;
        springAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(0, 200)];
        [item pop_addAnimation:springAnimation forKey:@"centerA"];
}

-(void)handleActionForNumberTapGesture:(UITapGestureRecognizer*)gesture{

    if (gesture.state == UIGestureRecognizerStateRecognized && gesture.numberOfTouches == 1) {
       
        NSInteger  idx = [self.items indexOfObject:gesture.view];
        
        self.block(idx);
        
    
    }

}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *item in self.items) {
        if (CGRectContainsPoint(item.frame, point))
            return YES;
    }
    return NO;
}


-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

@end
