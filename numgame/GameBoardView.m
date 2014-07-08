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
@import CoreGraphics;
@import AVFoundation;

#define EDGE_INSET          (15)

#define CELL_INSET          (10)

#define BOARD_WIDTH         (320)

@interface GameBoardView()
{
    //flag that indicates that 2 cells can be eliminated;
    BOOL canEliminated;
    GameBoardCell* currentCell;
    GameBoardCell* prevCell;
}

@property (nonatomic) int cellNum;

@property (nonatomic) int cellWidth;

@property (strong, nonatomic) NSMutableArray* selectedCell;

@property (nonatomic) CGPoint movePoint;

@property (nonatomic, strong) NSMutableArray* posArray;

@property (nonatomic, strong) NSMutableArray* effectViewArray;

@property (nonatomic, strong) NSMutableDictionary* playerForSound;

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
        [self setClipsToBounds:YES];
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
    float boardInset = (self.frame.size.height - self.frame.size.width)/2;
    if (iPhone5) {
        boardInset += 28;
    }
    _cellNum = num;
    int cellInset = CELL_INSET - (num - 3);
    _cellWidth = (BOARD_WIDTH - 2*EDGE_INSET - (num-1)*cellInset)/num;
    for (int i = 0; i < num; i++) {
        for(int j = 0; j < num; j++) {
            GameBoardCell* view = [[GameBoardCell alloc] initWithFrame:CGRectMake(0, 0, _cellWidth, _cellWidth)];
            view.tag = i*num + j + 1;
            CGPoint center = CGPointMake(EDGE_INSET + _cellWidth/2 + j*(_cellWidth+cellInset), boardInset + EDGE_INSET + _cellWidth/2 + i*(_cellWidth+cellInset));
            _posArray[i*num + j] = [NSValue valueWithCGPoint:center];
            [view setCenter:center];
            [self addSubview:view];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self];
    UIView* view = [self hitTest:pos withEvent:nil];
    if ([view isKindOfClass:[GameBoardCell class]]) {
        GameBoardCell* cell = (GameBoardCell*)view;
        [_selectedCell addObject:cell];
        //add effect
        [self addBorderEffectWithCell:cell eliminated:NO];
        [self addEffectToView:cell withAnimation:YES];
        // play sound
        [self playSoundFXnamed:@"1.aif"];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    _movePoint = [touch locationInView:self];
    UIView* view = [self hitTest:_movePoint withEvent:nil];
    if ([view isKindOfClass:[GameBoardCell class]]) {
        GameBoardCell* cell = (GameBoardCell*)view;
        GameBoardCell* preCell = [_selectedCell lastObject];
        if ([self view:cell.tag isNearby:preCell.tag]) {
            if ([_selectedCell containsObject:cell]) {
                if([_selectedCell indexOfObject:preCell] -[_selectedCell indexOfObject:cell] == 1) {
                    [_selectedCell removeLastObject];
                    [self removeBorderEffectWithCell:preCell];
                    [self removeEffectView];
                }
            } else {
                if (_selectedCell.count == 1 && cell.number == preCell.number) {
                    canEliminated = YES;
                    currentCell = cell;
                    prevCell = preCell;
                    [_selectedCell addObject:cell];
                    [self addBorderEffectWithCell:cell eliminated:YES];
                }
                else if ( [self validateIfCanLine:cell]&&([self currectNum] + cell.number < 10)) {
                    [self addEffectToView:cell withAnimation:YES];
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
                            [self addEffectToView:cell withAnimation:NO];
                        }];
                    } else {
                        [_selectedCell enumerateObjectsUsingBlock:^(GameBoardCell* cell, NSUInteger idx, BOOL *stop) {
                            [self addEffectToView:cell withAnimation:NO];
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
    if(canEliminated){
        [self combineCurrentCell:currentCell withPrevCell:prevCell];
    }
    if ([self currectNum] == 10) {
        [self removeEffectView];
        [self performSelector:@selector(playSoundFXnamed:) withObject:[NSString stringWithFormat:@"square_%d.aif", _selectedCell.count]];
        if([self eliminatedSameColorCell]) {
            int curColor = ((GameBoardCell*)_selectedCell.firstObject).color;
            [_selectedCell setArray:[self getAllCellWithColor:curColor]];
        }
        [self relayoutCells];
        NSMutableArray* array = [NSMutableArray new];
        [self.subviews enumerateObjectsUsingBlock:^(UIView* view, NSUInteger idx, BOOL *stop) {
            if ([view isKindOfClass:[GameBoardCell class]]) {
                GameBoardCell* cell = (GameBoardCell*)view;
                [array addObject:@(cell.number)];
            }
        }];
        MatrixMath* matrixMath = [[MatrixMath alloc]initWithArray:array andSize:CGSizeMake(_cellNum, _cellNum)];
        if ([matrixMath isSumExist:10]) {
            NSLog(@"%d",matrixMath.result.count);
        }
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
//        CGRect rect = view.frame;
        view.backgroundColor = [GameBoardCell generateColor:cell.color];
//        view.frame = CGRectMake(view.frame.origin.x, 0, 0, view.frame.size.height);
//        [UIView animateWithDuration:0.3 animations:^{
//            view.frame = rect;
//        }];
    } else {
        UIView* view =  [self viewWithTag:102];
//        CGRect rect = view.frame;
        view.backgroundColor = [GameBoardCell generateColor:prevCell.color];
//        view.frame = CGRectMake(view.frame.origin.x, 0, 0, view.frame.size.height);
//        [UIView animateWithDuration:0.3 animations:^{
//            view.frame = rect;
//        }];
        for (int i  = 3; i <= 4; i ++ ) {
            UIView* view =  [self viewWithTag:100+i];
//            CGRect rect = view.frame;
            view.backgroundColor = [GameBoardCell generateColor:currentCell.color];
//            view.frame = CGRectMake(view.frame.origin.x, 0, 0, view.frame.size.height);
//            [UIView animateWithDuration:0.3 animations:^{
//                view.frame = rect;
//            }];
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
    [_effectViewArray enumerateObjectsUsingBlock:^(UIView* view, NSUInteger idx, BOOL *stop) {
        [view removeFromSuperview];
    }];
    [_effectViewArray removeAllObjects];
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

#pragma mark layout cell after combining cells
- (void)combineCurrentCell:(GameBoardCell*)curCell withPrevCell:(GameBoardCell*)preCell
{
    curCell.color = preCell.color;
    [_selectedCell removeLastObject];
    [self relayoutCells];
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



-(BOOL)eliminatedSameColorCell{

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
    
    NSMutableDictionary* moveDict = [NSMutableDictionary new];
    NSMutableSet* addArray = [NSMutableSet new];
    for (int posx = 0; posx < _cellNum; posx++) {
        int delIdx = 0;
        for (int posy = _cellNum -1; posy >= 0; posy--) {
            int tag = posx+posy*_cellNum+1;
            GameBoardCell* cell = (GameBoardCell*)[self viewWithTag:tag];
            if ([_selectedCell containsObject:cell]) {
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
    [UIView animateWithDuration:0.8f animations:^{
        [_selectedCell enumerateObjectsUsingBlock:^(GameBoardCell* cell, NSUInteger idx, BOOL *stop) {
            //cell.frame = CGRectMake(cell.center.x, cell.center.y, 0, 0);
            cell.transform = CGAffineTransformMakeScale(0,0);
        }];
    } completion:^(BOOL finished) {
        [_selectedCell enumerateObjectsUsingBlock:^(GameBoardCell* cell, NSUInteger idx, BOOL *stop) {
            [cell removeFromSuperview];
        }];
    }];
    
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
    }];
    
    [UIView animateWithDuration:0.3f animations:^{
        [moveDict enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, NSNumber* obj, BOOL *stop) {
            GameBoardCell* moveCell = (GameBoardCell*)[self viewWithTag:obj.intValue];
            NSValue* value = _posArray[obj.intValue-1];
            CGPoint desPos = [value CGPointValue];
            moveCell.center = desPos;
        }];
        
        [addArray enumerateObjectsUsingBlock:^(NSNumber* obj, BOOL *stop) {
            NSValue* value = _posArray[obj.intValue-1];
            CGPoint desPos = [value CGPointValue];
            GameBoardCell* addCell = (GameBoardCell*)[self viewWithTag:obj.intValue];
            addCell.center = desPos;
        }];

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

@end
