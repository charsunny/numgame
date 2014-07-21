//
//  GameBoardCell+NumberChange.h
//  numgame
//
//  Created by apple on 14-7-16.
//  Copyright (c) 2014年 Sun Xi. All rights reserved.
//

#import "GameBoardCell.h"

@interface GameBoardCell (NumberChange)

@property (nonatomic, strong) NSArray* animationArray;


//为当前的GameBoardCell增加NumberCells
-(void)addNumberCellSet:(NSArray*)NumberCells;

-(void)showAnimation;




@end
