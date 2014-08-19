//
//  NGGameLogger.m
//  numgame
//
//  Created by Lanston Peng on 8/19/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "NGGameLogger.h"

@implementation NGGameLogger


+(void)logChangeCellNumber
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"game_action"     // Event category (required)
                                                          action:@"change_cell_number"  // Event action (required)
                                                           label:@"game_log"          // Event label
                                                           value:nil] build]];    // Event value
}

+(void)logChangeColor
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"game_action"     // Event category (required)
                                                          action:@"change_cell_color"  // Event action (required)
                                                           label:@"game_log"          // Event label
                                                           value:nil] build]];    // Event value
}
+(void)logGameLevel:(int)level inGameMode:(NGGameMode)gameMode
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    NSString* action = [NSString stringWithFormat:@"game_success_%d",level];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"game_action"     // Event category (required)
                                                          action:@"next_level"  // Event action (required)
                                                           label:@"game_log"          // Event label
                                                           value:@(level)
                                                                   ] build]];    // Event value
    
}
+ (void)logGameFail:(int)level inGameMode:(NGGameMode)gameMode{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    NSString* action = [NSString stringWithFormat:@"game_fail_%d",level];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"game_action"     // Event category (required)
                                                          action:action  // Event action (required)
                                                           label:@"game_log"          // Event label
                                                           value:@(level)
                                                                   ] build]];    // Event value
    
    
}

+ (void)logGameEachScore:(int)score{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    NSString* action;
    
    if (score <= 100) {
        
        action = [NSString stringWithFormat:@"game_each_score_%d",score];
    }
    else{
        action = @"game_each_score_bigger_100";
    }
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"game_action"     // Event category (required)
                                                          action:action  // Event action (required)
                                                           label:@"game_log"          // Event label
                                                           value:@(score)
                                                                   ] build]];    // Event value
}

+ (void)logGameData:(NGGameMode)gameMode
{
    
    NSString* gameModeStr;
    switch (gameMode) {
        case NGGameModeClassic:
            gameModeStr = @"NGGameModeClassic";
            break;
        case NGGameModeEndless:
            gameModeStr = @"NGGameModeEndless";
            break;
        case NGGameModeSteped:
            gameModeStr = @"NGGameModeSteped";
            break;
        case NGGameModeTimed:
            gameModeStr = @"NGGameModeTimed";
            break;
        default:
            break;
    }
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"game_action"     // Event category (required)
                                                          action:gameModeStr  // Event action (required)
                                                           label:@"game_log"          // Event label
                                                           value:nil] build]];    // Event value
}
@end
