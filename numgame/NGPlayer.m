//
//  NGPlayer.m
//  numgame
//
//  Created by Sun Xi on 8/14/14.
//  Copyright (c) 2014 Sun Xi. All rights reserved.
//

#import "NGPlayer.h"
@import AVFoundation;

@interface NGPlayer()

@property (strong, nonatomic) NSMutableArray* playerArray;

@end

@implementation NGPlayer

- (id)init {
    if (self = [super init]) {
        _playerArray = [NSMutableArray new];
    }
    return self;
}

+ (instancetype) player {
    static NGPlayer* player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [NGPlayer new];
    });
    return player;
}

-(void) playSoundFXnamed:(NSString*) vSFXName Loop:(BOOL) vLoop
{
    [_playerArray enumerateObjectsUsingBlock:^(AVAudioPlayer* obj, NSUInteger idx, BOOL *stop) {
        if (![obj isPlaying]) {
            [_playerArray removeObject:obj];
        }
    }];
    NSError *error;
    
    NSBundle* bundle = [NSBundle mainBundle];
    
    NSString* bundleDirectory = (NSString*)[bundle bundlePath];
    
    NSURL *url = [NSURL fileURLWithPath:[bundleDirectory stringByAppendingPathComponent:vSFXName]];
    
    AVAudioPlayer* _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (_audioPlayer) {
        [_playerArray addObject:_audioPlayer];
    }
    if(vLoop)
        _audioPlayer.numberOfLoops = -1;
    else
        _audioPlayer.numberOfLoops = 0;
    
    [_audioPlayer play];
}

@end
