//
//  NGGameLogger.h
//  numgame
//
//  Created by Lanston Peng on 8/19/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NGGameConfig.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@interface NGGameLogger : NSObject

+ (void)logChangeCellNumber;

+ (void)logChangeColor;

+ (void)logGameData:(NGGameMode)gameMode;

+ (void)logGameLevel:(int)level inGameMode:(NGGameMode)gameMode;

+ (void)logGameFail:(int)level inGameMode:(NGGameMode)gameMode;

+ (void)logGameEachScore:(int)score;
@end
