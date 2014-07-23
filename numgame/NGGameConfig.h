//
//  NGGameConfig.h
//  numgame
//
//  Created by Sun Xi on 4/29/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NGGameModeClassic = 0,
    NGGameModeTimed,
    NGGameModeSteped,
    NGGameModeEndless
} NGGameMode;

@interface NGGameConfig : NSObject

+ (instancetype)sharedGameConfig;

@property (nonatomic,readonly) BOOL isFirstLoad;

@property (nonatomic) NGGameMode gamemode;

@property (nonatomic) float classicScore;

@property (nonatomic) int timedScore;

@property (nonatomic, strong) NSString* sound;

@property (nonatomic) int streetHighscore;

@property (nonatomic) int rushSpeed;

@property (nonatomic) int zenHighScore;

@end
