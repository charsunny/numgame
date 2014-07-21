//
//  GameBoardView.m
//  LineSum
//
//  Created by Sun Xi on 5/9/14.
//  Copyright (c) 2014 Vtm. All rights reserved.
//

#import "GameBoardView.h"
#import "GameBoardCell.h"
#import "MatrixMath.h"
#import "HMSideMenu.h"
#import <pop/pop.h>
#import "GameResultView.h"
#import "NumberSelectionVIew.h"
//#import "NEContainerView.h"
@import CoreGraphics;
@import AVFoundation;

#define EDGE_INSET          (15)

#define CELL_INSET          (10)

#define BOARD_WIDTH         (320)

#define SElECTED_CELL_TAG   (2048)

//score marco
#define Two_Same_Number_Score           10
#define Four_Same_Number_Score          100
#define Four_Diff_Color_Number_Score    50
@interface GameBoardView()<GameboardCellDelegate>
{
    //flag that indicates that 2 cells can be eliminated;
    BOOL canEliminated;
}

@property (nonatomic) int cellNum;

@property (nonatomic) int cellWidth;

@property (strong, nonatomic) NSMutableArray* selectedCell;

@property (nonatomic) CGPoint movePoint;

@property (nonatomic, strong) NSMutableArray* posArray;

@property (nonatomic, strong) NSMutableArray* effectViewArray;

@property (nonatomic, strong) NSMutableDictionary* playerForSound;

@property (nonatomic,strong) HMSideMenu* sideMenu;
@property (nonatomic, assign) int  SelectedCellColor;
@property (nonatomic,strong) NSMutableSet * storeSelectedCellSet;
@property (nonatomic,strong) UIView * maskView;
@property (nonatomic,assign) float boardInset;



@property (nonatomic, strong)NumberSelectionVIew * numberSelectionView;

@end

@implementation GameBoardView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        srand(time(NULL));
        [self setMultipleTouchEnabled:NO];
        _selectedCell = [NSMutableArray new];
        _posArray = [NSMutableArray new];
        _effectViewArray = [NSMutableArray new];
        _playerForSound = [NSMutableDictionary new];
        self.backgroundColor = [UIColor clearColor];
        self.multipleTouchEnabled = NO;
        self.storeSelectedCellSet = [[NSMutableSet alloc]initWithCapacity:1];
        [self setClipsToBounds:YES];
       // [self setUserInteractionEnabled:YES];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([self viewWithTag:101]) {
        return;
    }
    float width = self.frame.size.width/4;
    for (int i = 0; i < 4; i++) {
        UIView* border = [[UIView alloc] initWithFrame:CGRectMake(0 + width*i, 0, width, 5)];
        border.tag = 101 + i;
        [self addSubview:border];
    }
}

- (void)layoutBoardWithCellNum:(int)num {
     _boardInset = (self.frame.size.height - self.frame.size.width)/2;
    if (iPhone5) {
        _boardInset += 28;
    }
    // boardInset
    _cellNum = num;
    int cellInset = CELL_INSET - (num - 3);
    _cellWidth = (BOARD_WIDTH - 2*EDGE_INSET - (num-1)*cellInset)/num;
    for (int i = 0; i < num; i++) {
        for(int j = 0; j < num; j++) {
            GameBoardCell* view = [[GameBoardCell alloc] initWithFrame:CGRectMake(0, 0, _cellWidth, _cellWidth)];
            view.tag = i*num + j + 1;
            CGPoint center = CGPointMake(EDGE_INSET + _cellWidth/2 + j*(_cellWidth+cellInset), _boardInset + EDGE_INSET + _cellWidth/2 + i*(_cellWidth+cellInset));
            _posArray[i*num + j] = [NSValue valueWithCGPoint:center];
            [view setCenter:center];
            [self addSubview:view];
            //+++定义View的Position//四个角弹出动画会出现问题
//            if (view.tag%_cellNum == 1) {
//                [view setCellPositon:GBCellPositionLeft];
//            }
//            else if (view.tag % _cellNum ==0){
//            
//                [view setCellPositon:GBCellPositionRight];
//            }
//            else if (view.tag/_cellNum == 0){
//            
//                [view setCellPositon:GBCellPositionTop];
//                
//            }
//            else {
//            
//                [view setCellPositon:GBCellPositionNormal];
//            }
            
            [self setCellPosition:view];
            [view setDelegate:self];
            
        }
    }

}

-(void)setCellPosition:(GameBoardCell*)cell{

    if (cell.tag == 1) {
        [cell setCellPositon:GBCellPositionRightDown];
    }
    else if (cell.tag == _cellNum) {
        [cell setCellPositon:GBCellPositionLeftDown];
    }
    else if (cell.tag == _cellNum*(_cellNum-1)+1){
    
        [cell setCellPositon:GBCellPositionRightUp];
    }
    else if (cell.tag == _cellNum*_cellNum){
    
        [cell setCellPositon:GBCellPositionLeftUp];
    }
    else if (cell.tag %_cellNum == 1){
    
        [cell setCellPositon:GBCellPositionLeft];
    }
    else if (cell.tag %_cellNum == 0){
        [cell setCellPositon:GBCellPositionRight];
    }
    else if (cell.tag/_cellNum == 0){
        [cell setCellPositon:GBCellPositionTop];
    }
    else{
    
        [cell setCellPositon:GBCellPositionNormal];
    }

}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];

    
    CGPoint pos = [touch locationInView:self];
    UIView* view = [self hitTest:pos withEvent:nil];
    
    if (touch.tapCount == 1 && self.isChangeColor) {
        
        if ([view isKindOfClass:[GameBoardCell class]]) {
            GameBoardCell * cell = (GameBoardCell*)view;
            //弹出选择颜色的框
            if (!(cell.accessoryItems.count >0)) {
                
                [self.layer.mask removeFromSuperlayer];
            self.maskView = [[UIView alloc]initWithFrame:CGRectMake(0, self.boardInset, self.frame.size.width, _cellNum*(_cellWidth+EDGE_INSET) -EDGE_INSET)];
            
            self.maskView.backgroundColor = [UIColor whiteColor];
            self.maskView.alpha = 0.5;
            [self addSubview:self.maskView];
               
                
//            [UIView animateWithDuration:0.3 animations:^{
//                self.maskView.alpha = 0.5;
//            }];
            [self bringSubviewToFront:cell];
            
  
                [cell addTrickingWithType:GBTrakingCategoryColor];
                [cell showAnimation];
  
            }
        
        }
    }
    
    if (touch.tapCount == 1 && self.isChangeNumer) {
        if ([view isKindOfClass:[GameBoardCell class]]) {
            GameBoardCell * cell = (GameBoardCell*) view;
            
            if (!(cell.accessoryItems.count >0)) {
                [self.layer.mask removeFromSuperlayer];
            self.maskView = [[UIView alloc]initWithFrame:CGRectMake(0, self.boardInset, self.frame.size.width, _cellNum*(_cellWidth+EDGE_INSET) -EDGE_INSET)];
            
            self.maskView.backgroundColor = [UIColor whiteColor];
            self.maskView.alpha = 0.5;
            [self addSubview:self.maskView];
            
//            [UIView animateWithDuration:0.3 animations:^{
//                self.maskView.alpha = 0.5;
//            }];
            [self bringSubviewToFront:cell];
            
            
                [cell addTrickingWithType:GBTrakingCategoryNum];
                [cell showAnimation];
     
            }

//            [self.storeSelectedCellSet addObject:cell];

        }
    }
    
 
    
    if ([view isKindOfClass:[GameBoardCell class]]) {
        GameBoardCell* cell = (GameBoardCell*)view;
        [_selectedCell addObject:cell];
        //add effect
        [self addBorderEffectWithCell:cell eliminated:NO];
        [cell addRippleEffectToView:YES];
        // play sound
        [self playSoundFXnamed:@"1.aif"];
        [self addBouncingAnimation:view];
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    _movePoint = [touch locationInView:self];
    UIView* view = [self hitTest:_movePoint withEvent:nil];
    //canEliminated = NO;
    if ([view isKindOfClass:[GameBoardCell class]]) {
        GameBoardCell* cell = (GameBoardCell*)view;
        GameBoardCell* preCell = [_selectedCell lastObject];
        if (cell == preCell) {
            [self setNeedsDisplay];
            return;
        }
        if ([self view:cell.tag isNearby:preCell.tag]) {
            if ([_selectedCell containsObject:cell]) {
                if([_selectedCell indexOfObject:preCell] -[_selectedCell indexOfObject:cell] == 1) {
                    [self removeEffectView];
                    [_selectedCell removeLastObject];
                    [self removeBorderEffectWithCell:preCell];
                    canEliminated = NO;
                }
            } else {
                [self addBouncingAnimation:view];
                //检测两个数字相同的cell
                if (_selectedCell.count == 1 && cell.number == preCell.number) {
                    [_selectedCell addObject:cell];
                    canEliminated = YES;
                    [self addBorderEffectWithCell:cell eliminated:YES];
                    [_selectedCell enumerateObjectsUsingBlock:^(GameBoardCell* cell, NSUInteger idx, BOOL *stop) {
                        [cell addRippleEffectToView:NO];
                    }];
                }
                else if ( [self validateIfCanLine:cell]&&([self currectNum] + cell.number < 10)) {
                    [cell addRippleEffectToView:YES];
                    [self playSoundFXnamed:[NSString stringWithFormat:@"%d.aif", _selectedCell.count]];
                    [_selectedCell addObject:cell];
                    [self addBorderEffectWithCell:cell eliminated:NO];
                } else if([self validateIfCanLine:cell]&&[self currectNum] + cell.number == 10) {
                    [_selectedCell addObject:cell];
                    [self addBorderEffectWithCell:cell eliminated:NO];
                    [self playSoundFXnamed:[NSString stringWithFormat:@"%d.aif", _selectedCell.count]];
                    if([self eliminatedSameColorCell]) {
                        NSArray* colorArray = [self getAllCellWithColor:cell.color];
                        [colorArray enumerateObjectsUsingBlock:^(GameBoardCell* cell, NSUInteger idx, BOOL *stop) {
                            [cell addRippleEffectToView:NO];
                        }];
                    } else {
                        [_selectedCell enumerateObjectsUsingBlock:^(GameBoardCell* cell, NSUInteger idx, BOOL *stop) {
                            [cell addRippleEffectToView:NO];
                        }];
                    }
                }
            }
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self removeAllBorderEffect];
    if ([self currectNum] == 10 || canEliminated) {
        [self removeEffectView];
        [self performSelector:@selector(playSoundFXnamed:) withObject:[NSString stringWithFormat:@"square_%d.aif", _selectedCell.count]];
        //4个cell是否拥有相同颜色
        if([self eliminatedSameColorCell]) {
            int curColor = ((GameBoardCell*)_selectedCell.firstObject).color;
            [_selectedCell setArray:[self getAllCellWithColor:curColor]];
            __weak typeof(self) weakSelf = self;
            [self addCellFlyAnimation:^{
                [weakSelf addDashBoardScore: [weakSelf getOtherSameColorSocre:curColor] + Four_Same_Number_Score];
            }];
        }
        //消除2个cell所得分数
        else if(canEliminated)
        {
            __weak typeof(self) weakSelf = self;
            [self addCellFlyAnimation:^{
                [weakSelf addDashBoardScore:Two_Same_Number_Score];
            }];
        }
        //消除不同颜色的4个cell所得分数
        else
        {
            __weak typeof(self) weakSelf = self;
            [self addCellFlyAnimation:^{
                [weakSelf addDashBoardScore:Four_Diff_Color_Number_Score];
            }];
        }
        [self relayoutCells];
    }
    
    [_selectedCell removeAllObjects];
    canEliminated = NO;
    [self setNeedsDisplay];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self removeAllBorderEffect];
    [_selectedCell removeAllObjects];
    [self setNeedsDisplay];
}

- (BOOL)view:(int)tag1 isNearby:(int)tag2 {
    if ( abs(tag1-tag2) == _cellNum) {
        return YES;
    }
    if (abs(tag1-tag2) == 1) {
        if ((tag1%_cellNum)*(tag2%_cellNum) == 0 && (tag2%_cellNum+tag1%_cellNum == 1)) {
            return NO;
        }
        return YES;
    }
    return NO;
}

- (int)currectNum {
    __block int sum = 0;
    [_selectedCell enumerateObjectsUsingBlock:^(GameBoardCell* cell, NSUInteger idx, BOOL *stop) {
        sum += cell.number;
    }];
    return sum;
}

- (void)addBorderEffectWithCell:(GameBoardCell*)cell eliminated:(BOOL)elimate {
    if (!elimate) {
        UIView* view =  [self viewWithTag:100+_selectedCell.count];
        view.backgroundColor = [GameBoardCell generateColor:cell.color];
    } else {
        GameBoardCell* curCell = [_selectedCell lastObject];
        GameBoardCell* preCell = [_selectedCell firstObject];
        UIView* view =  [self viewWithTag:102];
        view.backgroundColor = [GameBoardCell generateColor:preCell.color];
        for (int i  = 3; i <= 4; i ++ ) {
            UIView* view =  [self viewWithTag:100+i];
            view.backgroundColor = [GameBoardCell generateColor:curCell.color];
        }
    }
}

- (void)removeBorderEffectWithCell:(GameBoardCell*)cell {
    for (int i = _selectedCell.count; i < 4; i++) {
        UIView* view =  [self viewWithTag:101+i];
        view.backgroundColor = [UIColor clearColor];
    }
}

- (void)removeAllBorderEffect {
    for (int i = 0; i < 4; i++) {
        UIView* view =  [self viewWithTag:101+i];
        view.backgroundColor = [UIColor clearColor];
    }
}

- (void)addEffectToView:(GameBoardCell*)view withAnimation:(BOOL)animate {
    UIView* effectView = [[UIView alloc] initWithFrame:view.frame];
    effectView.layer.cornerRadius = view.layer.cornerRadius;
    [effectView setBackgroundColor:view.backgroundColor];
    [effectView setClipsToBounds:YES];
    [self insertSubview:effectView belowSubview:view];
    if (animate) {
        //effectView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        [UIView animateWithDuration:0.5f animations:^{
            effectView.transform = CGAffineTransformMakeScale(2, 2);
            effectView.alpha = 0;
        } completion:^(BOOL finished) {
            [effectView removeFromSuperview];
        }];
    } else {
        [_effectViewArray addObject:effectView];
        effectView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        effectView.alpha = 0.7;
    }
}

- (void)removeEffectView {
    [_selectedCell enumerateObjectsUsingBlock:^(GameBoardCell* cell, NSUInteger idx, BOOL *stop) {
        [cell removeRippleEffectView];
    }];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    if (_selectedCell.count) {
        CGContextRef ref = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(ref, 5.0);
        CGContextSetStrokeColorWithColor(ref, [UIColor redColor].CGColor);
        CGPoint point[_selectedCell.count+1];
        for (int i = 0; i < _selectedCell.count; i++) {
            UIView* cell = _selectedCell[i];
            point[i] = cell.center;
        }
        point[_selectedCell.count] = _movePoint;
        if ([self currectNum] == 10) {
            CGContextAddLines(ref, point, _selectedCell.count);
        } else {
            CGContextAddLines(ref, point, _selectedCell.count+1);
        }
        CGContextStrokePath(ref);
    }
}


-(BOOL)validateIfCanLine:(GameBoardCell*)cell{

    if (self.selectedCell.count <= _cellNum) {
        
        if (self.selectedCell.count >0) {
            
            //判断是否已经有两个相连在cell中
            
            if (self.selectedCell.count ==2) {
                
                if (((GameBoardCell*)self.selectedCell[0]).number == ((GameBoardCell*)self.selectedCell[1]).number ) {
                    return NO;
                }
                
            }
            
            
            
            NSMutableArray * mutableArray = [[NSMutableArray alloc]initWithCapacity:self.selectedCell.count];
            for (GameBoardCell * iterCell in self.selectedCell) {
                [mutableArray addObject: [NSNumber numberWithInt:iterCell.number]];
            }
            
            if ([mutableArray containsObject:[NSNumber numberWithInt:cell.number]])
                return NO;

            else
                return YES;
            
        }

    }
 
    return NO;
}


//判断是否是4个cell相连 且 颜色相同
-(BOOL)eliminatedSameColorCell{

    if (_selectedCell.count < 4) {
        return NO;
    }
  // 判断相同颜色
   int cellColorNum = ((GameBoardCell*)_selectedCell[0]).color;
    for (int i =1 ; i < _selectedCell.count ; i++) {
        if (cellColorNum != ((GameBoardCell*)_selectedCell[i]).color) {
            return NO;
        }
    }
    return YES;
}

- (NSArray*)getAllCellWithColor:(int)color {
    NSMutableArray* array = [NSMutableArray new];
    for (int posx = 0; posx < _cellNum; posx++) {
        for (int posy = 0; posy <_cellNum ; posy++) {
            int tag = posx + posy*_cellNum + 1;
            GameBoardCell* cell = (GameBoardCell*)[self viewWithTag:tag];
            if (cell.color == color) {
                [array addObject:cell];
            }
        }
    }
    return array;
}




#pragma mark relayout cell after eliminating cells
- (void)relayoutCells {
    
    NSMutableArray* selCells = [_selectedCell mutableCopy];

    NSMutableDictionary* moveDict = [NSMutableDictionary new];
    NSMutableSet* addArray = [NSMutableSet new];
    for (int posx = 0; posx < _cellNum; posx++) {
        int delIdx = 0;
        for (int posy = _cellNum -1; posy >= 0; posy--) {
            int tag = posx+posy*_cellNum+1;
            GameBoardCell* cell = (GameBoardCell*)[self viewWithTag:tag];
            if ([selCells containsObject:cell]) {
                int desTag = delIdx*_cellNum + 1 + posx ;
                [addArray addObject:@(desTag)];
                delIdx++;
            } else {
                int desTag = (posy+delIdx)*_cellNum + 1 + posx;
                if (desTag != tag) {
                    [moveDict setObject:@(desTag) forKey:@(tag)];
                }
            }
        }
    }
    
    //delete the selected cells that combining the correct sum
    [selCells enumerateObjectsUsingBlock:^(GameBoardCell* cell, NSUInteger idx, BOOL *stop) {
        [cell removeFromSuperview];
    }];
    //[prevCell removeFromSuperview];
    [moveDict enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, NSNumber* obj, BOOL *stop) {
        GameBoardCell* moveCell = (GameBoardCell*)[self viewWithTag:key.intValue];
        moveCell.tag = obj.intValue;
    }];
    
    
    [addArray enumerateObjectsUsingBlock:^(NSNumber* obj, BOOL *stop) {
        GameBoardCell* cell = [[GameBoardCell alloc] initWithFrame:CGRectMake(0, 0, _cellWidth, _cellWidth)];
        [cell setTag:obj.intValue];
        NSValue* value = _posArray[obj.intValue-1];
        CGPoint desPos = [value CGPointValue];
        cell.center = CGPointMake(desPos.x, -25);
        [self addSubview:cell];
        [self setCellPosition:cell];
        [cell setDelegate:self];
        
      //增加cell
    }];
    
    NSMutableDictionary * xdim = [[NSMutableDictionary alloc]initWithCapacity:6];
    //初始化数组
    for (int i =1; i <= _cellNum; i++) {
        [xdim setObject:@(0) forKey:[NSNumber numberWithInt:i]];
    }
    
    
    [moveDict enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, NSNumber* obj, BOOL *stop) {
    
      NSNumber * tmp =[xdim objectForKey:[NSNumber numberWithInt:(key.intValue) %_cellNum]];
        
        if ((obj.intValue/_cellNum) > tmp.intValue) {
            [xdim setObject:[NSNumber numberWithInt:(obj.intValue/_cellNum)] forKey:[NSNumber numberWithInt:(key.intValue) %_cellNum]];
        }
 
    }];
    
    int baseIntNumber = _cellNum;
    [moveDict enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, NSNumber* obj, BOOL *stop) {
        POPSpringAnimation* animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        animation.toValue = _posArray[obj.intValue-1];
        animation.springBounciness = 10;
        
        
        NSNumber * baseNum = [xdim objectForKey: [NSNumber numberWithInt:obj.intValue%_cellNum]];
        int baseIntNumber  = baseNum.intValue;
        
        
        int level = baseIntNumber- (obj.intValue - 0.5)/_cellNum;
        
        
        
        animation.beginTime = CACurrentMediaTime() + 0.1*level;
        GameBoardCell* moveCell = (GameBoardCell*)[self viewWithTag:obj.intValue];
        [moveCell pop_addAnimation:animation forKey:@"move"];
        
    }];
    
    [addArray enumerateObjectsUsingBlock:^(NSNumber* obj, BOOL *stop) {
        POPSpringAnimation* animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        animation.velocity = [NSValue valueWithCGPoint:CGPointMake(0, 10*obj.intValue/6)];
        animation.springBounciness = 10;
        int level = baseIntNumber - (obj.intValue - 0.5)/_cellNum;
        animation.beginTime = CACurrentMediaTime() + 0.1*level;
        animation.toValue = _posArray[obj.intValue-1];
        GameBoardCell* addCell = (GameBoardCell*)[self viewWithTag:obj.intValue];
        [addCell pop_addAnimation:animation forKey:@"addmove"];
    }];
}

-(void) playSoundFXnamed:(NSString*)vSFXName
{
    NSBundle* bundle = [NSBundle mainBundle];
    
    NSString* bundleDirectory = (NSString*)[bundle bundlePath];
    
    NSURL *url = [NSURL fileURLWithPath:[bundleDirectory stringByAppendingPathComponent:vSFXName]];
    AVAudioPlayer* player = [_playerForSound objectForKey:vSFXName];
    if (!player) {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [_playerForSound setObject:player forKey:vSFXName];
    }
    [player prepareToPlay];
    [player play];
}

#pragma mark touch cell poping animation
-(void)addBouncingAnimation:(UIView*)view
{
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.velocity = [NSValue valueWithCGSize:CGSizeMake(3.f, 3.f)];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
    scaleAnimation.springBounciness = 18.0f;
    [view.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleSpringAnimation"];
}


#pragma mark 分数相关 score related
-(void)addDashBoardScore:(int)score
{
    if([self.delegate respondsToSelector:@selector(increaseScore:)])
    {
        [self.delegate increaseScore:score];
    }
}

//获取相同颜色的其它cell分数(即其自身数字)
- (int)getOtherSameColorSocre:(int)curColor
{
    NSArray* arr = [self getAllCellWithColor:curColor];
    
    return (arr.count - _selectedCell.count)*10;
    
    int sum = 0;
    for (int i = 0 ; i<arr.count; i++) {
        sum+=((GameBoardCell*)arr[i]).number;
    }
    for(int k=0;k<_selectedCell.count;k++)
    {
        sum-=((GameBoardCell*)_selectedCell[k]).number;
    }
    return sum;
}




-(void)changeCellColor:(id)sender{

    if (!self.isChangeColor) {
        CALayer* layer = [CALayer layer];
        layer.frame = CGRectMake(0, self.boardInset, self.frame.size.width, _cellNum*(_cellWidth+EDGE_INSET) -EDGE_INSET);
        layer.backgroundColor = [UIColor blueColor].CGColor;
        [layer setOpacity:0.3];
        [self.layer setMask:layer];
        
        self.isChangeColor = YES;
    }
   


}

///增加停顿时候的效果
-(void) showPauseCellEffective{
    
    NSArray * subcells = [self subviews];
    
    for (UIView * view in subcells) {
        if ( [view isKindOfClass:[GameBoardCell class]]) {
            
            //TODO 给view加图层
         //   [((GameBoardCell *)view)addRippleEffectToView:NO];
            
        }
    }
    
    
}


-(void)initSelectionCells{

    NSMutableArray * cellArray = [[NSMutableArray alloc]initWithCapacity:4];
    NSArray * colorArray = @[UIColorFromRGB(0xFF814F),UIColorFromRGB(0xF9FF4F),UIColorFromRGB(0x34D3FF),UIColorFromRGB(0x46FFAB)];
    
    for (int i = 0; i < 4; i++) {

        
        UIView * cell = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _cellWidth, _cellWidth)];
        cell.layer.cornerRadius = _cellWidth/2.0f;
        [cell setBackgroundColor:colorArray[i]];
        [cell setTag:i + SElECTED_CELL_TAG ];
        __block UIView* weak_cell = cell;
        [cell setMenuActionWithBlock:^{
            
            [self.sideMenu close];
            
            self.SelectedCellColor = weak_cell.tag- SElECTED_CELL_TAG;
            //改变点击celll的颜色
        //    [self performSelectorOnMainThread:@selector(changeCellColor) withObject:nil waitUntilDone:YES];
            
                    }];
        
        [cellArray addObject: cell];
    }
  
    self.sideMenu = [[HMSideMenu alloc]initWithItems:cellArray];
    [self.sideMenu setItemSpacing:_cellWidth/3.0];
    [self addSubview:self.sideMenu];

    

}




-(void)toggeSelectionCells{

    
    if (!self.sideMenu.isOpen) {
        [self.sideMenu open];
        [self bringSubviewToFront:self.sideMenu];
        self.isChangeColor = NO;
        }
    
    
}



//-(void) changeCellColor{
//
////  GameBoardCell * cell =[self.storeSelectedCellSet anyObject];
////    [cell setColor:self.SelectedCellColor];
////    [self.storeSelectedCellSet removeAllObjects];
////    [self.maskView removeFromSuperview];
//    
//   
//}


- (void)changeCellNumber:(id)btn{
    if (!self.isChangeNumer) {
        CALayer* layer = [CALayer layer];
        layer.frame = CGRectMake(0, self.boardInset, self.frame.size.width, _cellNum*(_cellWidth+EDGE_INSET) -EDGE_INSET);
        layer.backgroundColor = [UIColor blueColor].CGColor;
        [layer setOpacity:0.3];
        [self.layer setMask:layer];
         self.isChangeNumer = YES;
    }
 
   
}


#pragma mark fly cell animtion
- (void)addCellFlyAnimation:(void (^)())callback
{
    UILabel* scoreLabel = (UILabel*)[self.superview viewWithTag:1898];
    __weak typeof(self) weakSelf = self;
    [_selectedCell enumerateObjectsUsingBlock:^(GameBoardCell* cell, NSUInteger idx, BOOL *stop) {
        GameBoardCell* copyCell = [cell copy];
        CGPoint newPoint = [self convertPoint:copyCell.frame.origin toView:self.superview];
        copyCell.frame = CGRectMake(newPoint.x, newPoint.y, copyCell.frame.size.width, copyCell.frame.size.height);
        [weakSelf.superview addSubview:copyCell];
        if (idx == 0) {
            [copyCell addFlyEffect:scoreLabel.center callback:^{
                callback();
            }];
        } else {
            [copyCell addFlyEffect:scoreLabel.center callback:nil];
        }
    }];
}




-(void)gameBoardCell:(GameBoardCell *)cell withCategory:(GBTrakingCategory)category{

    switch (category) {
        case GBTrakingCategoryColor:
        {
             [UIView animateWithDuration:0.25 animations:^{
                 
                 [self.maskView setAlpha:0.0];
             } completion:^(BOOL finished) {
                 
                 [self.maskView removeFromSuperview];
                 self.maskView = nil;
             }];
            self.isChangeColor = NO;
        }
            break;
        case GBTrakingCategoryNum:
        {
        
            [UIView animateWithDuration:0.25 animations:^{
                
                [self.maskView setAlpha:0.0];
            } completion:^(BOOL finished) {
                
                [self.maskView removeFromSuperview];
                self.maskView = nil;
            }];
            self.isChangeNumer = NO;
        
        }
            break;
        default:
            break;
    }

}

@end




