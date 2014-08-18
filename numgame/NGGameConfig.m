//
//  NGGameConfig.m
//  numgame
//
//  Created by Sun Xi on 4/29/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "NGGameConfig.h"

@implementation NGGameConfig

+ (instancetype)sharedGameConfig {
    static NGGameConfig* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NGGameConfig alloc] init];
    });
    return instance;
}

- (NGGameMode)gamemode {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"gamemode"]) {
        [self setGamemode:NGGameModeClassic];
    }
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"gamemode"] intValue];
}

- (void)setGamemode:(NGGameMode)gamemode {
    [[NSUserDefaults standardUserDefaults] setValue:@(gamemode) forKey:@"gamemode"];
}

- (BOOL)unlockEndlessMode {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"endlessmodeunlock"]) {
        [self setUnlockEndlessMode:NO];
    }
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"endlessmodeunlock"] boolValue];
}

- (void)setUnlockEndlessMode:(BOOL)unlockEndlessModegamemode {
    [[NSUserDefaults standardUserDefaults] setValue:@(unlockEndlessModegamemode) forKey:@"endlessmodeunlock"];
}

- (NSString*)sound {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"sound"]) {
        [self setSound:@"J"];
    }
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"sound"];
}

- (void)setSound:(NSString *)sound {
    [[NSUserDefaults standardUserDefaults] setValue:sound forKey:@"sound"];
}

- (float)classicScore {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"classicscore"]) {
        [self setClassicScore:0];
    }
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"classicscore"] floatValue];
}

- (void)setClassicScore:(float)classicScore {
    [[NSUserDefaults standardUserDefaults] setValue:@(classicScore) forKey:@"classicscore"];
}

- (int)timedScore {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"timedscore"]) {
        [self setTimedScore:0];
    }
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"timedscore"] intValue];
}

- (void)setTimedScore:(int)timedScore {
    [[NSUserDefaults standardUserDefaults] setValue:@(timedScore) forKey:@"timedscore"];
}

- (BOOL)isFirstLoad {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        return YES;
    }
    return NO;
}

@end
