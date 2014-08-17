//
//  GameBoardCell.m
//  LineSum
//
//  Created by Sun Xi on 5/9/14.
//  Copyright (c) 2014 Vtm. All rights reserved.
//

#import "GameBoardCell.h"
#import  <pop/POP.h>
@import CoreGraphics;

#define DefalutNumFontSize 30
#define DefalutNumFontFamily @"AppleSDGothicNeo-Regular"
#define SubViewBaseTag (2004)
#define kAnimationDelay 0.1

@interface GameBoardCell()<NSCopying>

@property (strong, nonatomic) UILabel* numLabel;

@property (strong, nonatomic) CALayer* effectLayer;

@property (strong,nonatomic)UIImageView* numberImgView;

@property (strong,nonatomic)CALayer* backgroundLayer;

@property (strong,nonatomic)void (^animtionCallback)();
//增加方法

@property (assign, nonatomic) GBTrakingCategory  trakingCategory;
@end

@implementation GameBoardCell

//增加方法
-(id)initWithFrame:(CGRect)frame Position:(GBCellPosition)cellPosition{

    self = [self initWithFrame:frame];
    if (self) {
        self.cellPositon = cellPosition;
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame withNumber:(int)number andColor:(int)color{
    self = [super initWithFrame:frame];
    if (self) {
        self.number = number;
        self.color = color;
        [self initUI:number withFrame:frame andColor:[GameBoardCell generateColor:self.color]];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.number = [self genRandNumber];
        self.color = [self genRandColor];
        [self initUI:self.number withFrame:frame andColor:[GameBoardCell generateColor:self.color]];
        
    }
    return self;
}
- (void)initUI:(int)number withFrame:(CGRect)frame andColor:(UIColor*)color
{
    
    self.layer.cornerRadius = frame.size.width/2;
    self.clipsToBounds = NO;
    
    UIImage* shadowImg = [UIImage imageNamed:@"cell_shadow@2x"];
    CGRect layerFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    //UIImageView* imgView = [[UIImageView alloc]initWithFrame:layerFrame];
    UIImageView* imgView = [[UIImageView alloc]initWithFrame:CGRectInset(layerFrame, -5, -5)];
    imgView.image = shadowImg;
    
    _backgroundLayer = [CALayer layer];
    _backgroundLayer.backgroundColor = color.CGColor;
    _backgroundLayer.cornerRadius = frame.size.width/2;
    _backgroundLayer.frame = layerFrame;
    
    
    UIImage* numberShadowImg = [UIImage imageNamed:[NSString stringWithFormat:@"number%d@2x",number]];
    _numberImgView = [[UIImageView alloc]initWithFrame:layerFrame];
    _numberImgView.image = numberShadowImg;
    
    
    [self.layer insertSublayer:_backgroundLayer atIndex:0];
    [self.layer insertSublayer:imgView.layer below:_backgroundLayer];
    [self.layer insertSublayer:_numberImgView.layer above:_backgroundLayer];
}

- (int)genRandColor {
    return rand() % 4;
}

- (int)genRandNumber {
    return rand()%4+1;
}

-(void)setNumber:(int)number{
    _number = number;
    UIImage* numberShadowImg = [UIImage imageNamed:[NSString stringWithFormat:@"number%d@2x",number]];
    _numberImgView.image = numberShadowImg;
}

- (void)setColor:(int)color
{
    _color = color;
    _backgroundLayer.backgroundColor = [GameBoardCell generateColor:color].CGColor;
}

+ (UIColor*)generateColor:(int)number
{
    switch (number) {
        case 0:
            //红色
            return UIColorFromRGB(0xFC6666);
        case 1:
            //黄色
            return UIColorFromRGB(0xFED531);
        case 2:
            //蓝色
            return UIColorFromRGB(0x4DC9FD);
        case 3:
            //绿色
            return UIColorFromRGB(0x00F3C2);
        default:
            
            return UIColorFromRGB(0xFF814F);
            break;
    }
}

- (void)addRippleEffectToView:(BOOL)animate {
    if (animate) {
        UIView* tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        tmpView.layer.cornerRadius = self.layer.cornerRadius;
        [tmpView setBackgroundColor:self.backgroundColor];
        [tmpView setClipsToBounds:YES];
        [self insertSubview:tmpView belowSubview:self];
        [UIView animateWithDuration:0.4f animations:^{
            tmpView.transform = CGAffineTransformMakeScale(2, 2);
            tmpView.alpha = 0;
        } completion:^(BOOL finished) {
            [tmpView removeFromSuperview];
        }];
    } else {
        _effectLayer = [CALayer layer];
        _effectLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _effectLayer.cornerRadius = self.layer.cornerRadius;
        _effectLayer.backgroundColor = self.backgroundColor.CGColor;
        _effectLayer.opacity = 0.7;
        _effectLayer.transform = CATransform3DMakeScale(1.3, 1.3, 1.0);
        //[self.layer insertSublayer:_effectLayer below:self.numLabel.layer];
        [self.layer insertSublayer:_effectLayer atIndex:0];
    }
}

- (void)removeRippleEffectView {
    [_effectLayer removeFromSuperlayer];
    [self.layer setNeedsDisplay];
}

- (void)addFlyEffect:(CGPoint)endPoint callback:(void (^)())callback
{
    //CGPoint curPoint = [self convertPoint:self.frame.origin fromView:self.superview];
    self.animtionCallback = callback;
    CGPoint curPoint = self.frame.origin;
    
   
    CABasicAnimation* opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.fromValue = @(1);
    opacity.toValue = @(0.5);
    
    CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @(1);
    scaleAnimation.toValue = @(0.3);
    
    CAKeyframeAnimation* pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = YES;
    
    CGMutablePathRef curvePath = CGPathCreateMutable();
    CGPathMoveToPoint(curvePath, nil, curPoint.x, curPoint.y);
    CGPoint midPoint = CGPointMake((endPoint.x + curPoint.x)/2 + rand() % 2 * 40 * (rand() % 2 == 1 ? 1 : -1), (endPoint.y + curPoint.y)/2 + rand() % 2 * 40 * (rand() % 2 == 1 ? 1 : -1));
    
    CGPathAddCurveToPoint(curvePath, nil, midPoint.x, midPoint.y, midPoint.x, midPoint.y, endPoint.x, endPoint.y);
    pathAnimation.path = curvePath;
    
    CAAnimationGroup* groupAnimation = [[CAAnimationGroup alloc] init];
    groupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    groupAnimation.animations = @[ pathAnimation, scaleAnimation,opacity];
    groupAnimation.duration = 0.3;
    groupAnimation.removedOnCompletion = YES;
    groupAnimation.fillMode = kCAFillModeForwards;
    groupAnimation.delegate = self;
    groupAnimation.beginTime = CACurrentMediaTime() + rand() % 3 * 0.1;
    [self.layer addAnimation:groupAnimation forKey:@"flyCellEffect"];
    self.alpha = 0;
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.animtionCallback) {
        self.animtionCallback();
    }
    [self removeFromSuperview];
}

- (id)copyWithZone:(NSZone *)zone
{
    GameBoardCell* copyCell = [[GameBoardCell alloc]initWithFrame:self.frame withNumber:self.number andColor:self.color];
    return copyCell;
}



-(void)addTrickingWithType:(GBTrakingCategory)category{

    self.trakingCategory = category;
    self.accessoryItems = [[NSMutableArray alloc]initWithCapacity:3];
    
    //弹出4个cell
    for (int i = 0; i < 3; i++){
       
        UIView * item = [[UIView alloc]initWithFrame:self.bounds];
        item.layer.cornerRadius = item.frame.size.height/2;
       // item.tag = SubViewBaseTag + i;
        [item.layer setOpacity:1.0];
        UITapGestureRecognizer * gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleActionForNumberTapGesture:)];
        [item addGestureRecognizer:gesture];
        
        [self.accessoryItems addObject:item];
        
        [self addSubview:item];
        [item setClipsToBounds:NO];
     
    }
    
    
    switch (category) {
        case GBTrakingCategoryColor:{
        
            int color =_color;
            
            NSMutableArray * itemArray = [NSMutableArray arrayWithArray:@[@(0),@(1),@(2),@(3)]];
            [itemArray removeObject:@(color)];
            for (int i = 0; i < self.accessoryItems.count; i++) {
                int colorIdx = [itemArray[i] intValue];
                ((UIView*)self.accessoryItems[i]).tag = SubViewBaseTag + colorIdx;
                
                [(UIView*)self.accessoryItems[i] setBackgroundColor:[GameBoardCell generateColor:colorIdx]];
            }
            
            
          break;
        }
          
        case GBTrakingCategoryNum:{
        
            NSMutableArray * itemArray = [NSMutableArray arrayWithArray:@[@"1",@"2",@"3",@"4"]];
            
            [itemArray removeObject: @(self.number)];
  
            for (int i = 0;  i < self.accessoryItems.count; i ++) {
                UILabel * label = [[UILabel alloc]initWithFrame:CGRectZero];
                label.textAlignment = NSTextAlignmentCenter ;
                label.text = itemArray[i];
                label.textColor = [UIColor whiteColor];
                //label.font = [UIFont systemFontOfSize:20];
                label.font = [UIFont fontWithName:DefalutNumFontFamily size:20];
                [(UIView*)self.accessoryItems[i] setBackgroundColor:[GameBoardCell generateColor:self.color]];
                [(UIView*)self.accessoryItems[i] addSubview:label];
                [label sizeToFit];
                label.center =((UIView*)self.accessoryItems[i]).center;
                ((UIView*)self.accessoryItems[i]).tag = SubViewBaseTag + [itemArray[i]intValue];
            }
            break;
        }
        default:
            break;
    }

}

-(void)removeTricking{

//    for (UIView* item in self.accessoryItems) {
//        [item removeFromSuperview];
//        
//    }
    self.accessoryItems = nil;

}


//为增加手势
-(void)handleActionForNumberTapGesture:(UITapGestureRecognizer*)tapGesture{
    
    if (tapGesture.state == UIGestureRecognizerStateRecognized && tapGesture.numberOfTouches ==1) {
        
  
    switch (self.trakingCategory) {
        case GBTrakingCategoryNum:
        {
            NSInteger tag = tapGesture.view.tag - SubViewBaseTag;
            
            self.number = tag;
            
         
        }
            break;
        case GBTrakingCategoryColor:
        {
            NSInteger colorIdx = tapGesture.view.tag -SubViewBaseTag;
            self.color = colorIdx;
            
        }
        default:
            break;
    }

      }
    
    [self hideAnimation];
    if (_delegate && [_delegate respondsToSelector:@selector(gameBoardCell: withCategory:)]) {
        
        [_delegate gameBoardCell:self withCategory:self.trakingCategory];
    }
    //调用收起来的动画
}


-(void)performNumberPopAnimation:(UIView*)item toPoint:(CGPoint)point withName:(NSString*)name
{
    POPSpringAnimation * springAnimation = [POPSpringAnimation animation];
    springAnimation.property = [POPMutableAnimatableProperty propertyWithName:kPOPViewCenter];
    springAnimation.fromValue = [NSValue valueWithCGPoint:item.center];
    springAnimation.toValue =[NSValue valueWithCGPoint: point];
    springAnimation.springBounciness = 20;
    [item  pop_addAnimation:springAnimation forKey:name];
}


-(void)showNumberItem:(UIView*)item withDirection:(NSInteger) direction{

    [NSObject cancelPreviousPerformRequestsWithTarget:item.layer];
    item.layer.opacity = 1.0f;
    int offset = 50;
    switch (direction) {
        case 0:
        {
            [self performNumberPopAnimation:item toPoint:CGPointMake(item.center.x - offset, item.center.y) withName:@"centerLeft"];
            break;
        }
        case 1:
        {
            [self performNumberPopAnimation:item toPoint:CGPointMake(item.center.x + offset, item.center.y) withName:@"centerRight"];
            break;
        }
        case 2:
        {
            [self performNumberPopAnimation:item toPoint:CGPointMake(item.center.x, item.center.y - offset) withName:@"centerTop"];
            break;
        }
        case 3:{
            [self performNumberPopAnimation:item toPoint:CGPointMake(item.center.x, item.center.y + offset) withName:@"centerBottom"];
            break;
        }
             //右下
        case 4:{
            [self performNumberPopAnimation:item toPoint:CGPointMake(item.center.x + offset, item.center.y + offset) withName:@"centerRightDown"];
            break;
        }
           //左下
        case 5:{
            [self performNumberPopAnimation:item toPoint:CGPointMake(item.center.x - offset, item.center.y + offset) withName:@"centerLeftDown"];
            break;
        }
         // 右上
        case 6:{
            [self performNumberPopAnimation:item toPoint:CGPointMake(item.center.x + offset, item.center.y - offset) withName:@"centerRightUp"];
            break;
        }
         //左上
        case 7:{
            [self performNumberPopAnimation:item toPoint:CGPointMake(item.center.x - offset, item.center.y - offset) withName:@"centerLeftUp"];
            break;
        }
        default:
            break;
    }
     
    

}

-(void)hideNumberItem:(UIView*)item{

    POPBasicAnimation * anim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewCenter];
    anim.fromValue = [NSValue  valueWithCGPoint:item.center];
    
   // CGPoint toPoint = [item convertPoint:self.center toView:self];
    anim.toValue = [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [item pop_addAnimation:anim forKey:nil];
    [anim setCompletionBlock:^(POPAnimation * ani, BOOL finish) {
        [item removeFromSuperview];
    }];
}





-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{

    for (UIView * item in self.accessoryItems) {
        if (CGRectContainsPoint(item.frame, point)) {
            return YES;
        }
    }
    CGPoint tmpPoint = [ self convertPoint:point toView:self.superview];
    
    if (CGRectContainsPoint(self.frame, tmpPoint)) {
        return YES;
    }
    return NO;
 
}

-(void)showAnimation{

    NSMutableArray * directions = nil;
    switch (self.cellPositon) {
            
        case GBCellPositionNormal : {
             //三个方向：左右上
            directions = [NSMutableArray arrayWithArray:@[@(0),@(1),@(2)]];
            break;
        }
        case  GBCellPositionLeft:{
            //三个方向：上下右
             directions = [NSMutableArray arrayWithArray:@[@(1),@(2),@(3)]];
            break;
        }
            
        case  GBCellPositionRight:{
           //三个方向上下左
             directions = [NSMutableArray arrayWithArray:@[@(0),@(2),@(3)]];
            break;
        }
        
        case  GBCellPositionTop:{
          //三个方向左右下
             directions = [NSMutableArray arrayWithArray:@[@(0),@(1),@(3)]];
            break;
        }
        case GBCellPositionRightDown:
        {
            directions = [NSMutableArray arrayWithArray:@[@(1),@(4),@(3)]];
            break;
        }
        case GBCellPositionLeftDown:{
           
            directions = [NSMutableArray arrayWithArray:@[@(0),@(5),@(3)]];
            break;
        }
        case GBCellPositionLeftUp:{
        
             directions = [NSMutableArray arrayWithArray:@[@(0),@(2),@(7)]];
            break;
        
        }
        case GBCellPositionRightUp:{
        
             directions = [NSMutableArray arrayWithArray:@[@(1),@(6),@(2)]];
            break;
        }
        default:
            break;
    }

      [self.accessoryItems enumerateObjectsUsingBlock:^(UIView* items, NSUInteger idx, BOOL *stop) {
          
          [self showNumberItem:items withDirection: [directions[idx] intValue]];
      }];
    
}


-(void)hideAnimation{

    [self.accessoryItems enumerateObjectsUsingBlock:^(UIView* item, NSUInteger idx, BOOL *stop) {
        [self hideNumberItem:item];
    }];
    [self.accessoryItems removeAllObjects];
    
}

@end
