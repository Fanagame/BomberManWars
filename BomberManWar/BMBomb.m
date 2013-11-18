//
//  BMBomb.m
//  BomberManWar
//
//  Created by Rémy Bardou on 15/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMBomb.h"
#import "BMDeflagration.h"

#define TICKING_ANIMATION_SPEED 0.25

NSString * const kBombExplodedNotificationName = @"kBombExplodedNotificationName";

@interface BMBomb () {
    NSMutableArray *_tickingAnimationFrames;
    NSMutableArray *_explosionAnimationFrames;
}

@property (nonatomic, strong) SKAction *tickingAction;

@end

@implementation BMBomb

- (id) init {
    self = [super init];
    
    if (self) {
        [self loadAnimations];
        
        //
        // DYNAMIC DATA
        //
        
        self.deflagrationRange = 3;
        self.timeBeforeExploding = 1;
        self.state = kBombStateStandby;
        
        //
        // END DYNAMIC DATA
        //
        
        [self resetDefaultTexture];
        self.size = self.texture.size;
    }
    
    return self;
}

- (void) loadAnimations {
    _tickingAnimationFrames = [[NSMutableArray alloc] init];
    _explosionAnimationFrames = [[NSMutableArray alloc] init];
    
    SKTextureAtlas *bombAtlas = [SKTextureAtlas atlasNamed:@"Bombs"];
    for (int i = 1; i <= 26; i++) {
        SKTexture *t = nil;
        
        if (i <= 3) {
            t = [bombAtlas textureNamed:[NSString stringWithFormat:@"bomb_%03d", i]];
            if (t)
                [_tickingAnimationFrames addObject:t];
        }
        
        t = [bombAtlas textureNamed:[NSString stringWithFormat:@"explosion_%03d", i]];
        if (t)
            [_explosionAnimationFrames addObject:t];
    }
}

- (SKTexture *) defaultTexture {
    if (_tickingAnimationFrames.count > 0) {
        return _tickingAnimationFrames[0];
    }
    return nil;
}

- (void) resetDefaultTexture {
    [self removeAllActions];
    self.texture = [self defaultTexture];
}

#pragma mark - Action cache

- (SKAction *) tickingAction {
    if (!_tickingAction) {
        _tickingAction = [SKAction repeatActionForever:[SKAction animateWithTextures:_tickingAnimationFrames timePerFrame:TICKING_ANIMATION_SPEED]];
        
        // Make it explode in a few seconds
        __weak BMBomb *weakSelf = self;
        double delayInSeconds = self.timeBeforeExploding;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf explode];
        });
    }
    return _tickingAction;
}

#pragma mark - Public API

- (void) startTicking {
    if (self.state == kBombStateStandby) {
        self.state = kBombStateTicking;
        
        [self runAction:self.tickingAction];
    } else {
        NSLog(@"Can't start ticking. Current state is: %d", self.state);
    }
}

- (void) cancelTicking {
    if (self.state == kBombStateTicking) {
        [self resetDefaultTexture];
        self.state = kBombStateStandby;
    } else {
        NSLog(@"Can't cancel ticking. Current state is: %d", self.state);
    }
}

- (void) explode {
    if (self.state == kBombStateTicking || self.state == kBombStateStandby) {
        [self resetDefaultTexture];
        self.state = kBombStateExploding;
        
        self.texture = nil;
        self.deflagration = [[BMDeflagration alloc] initWithPosition:CGPointZero andMaxSize:self.deflagrationRange];
        [self addChild:self.deflagration];
        
        __weak BMBomb *weakSelf = self;
        [self.deflagration deflagrateWithCompletionHandler:^{
            [weakSelf didExplode];
        }];
    } else {
        NSLog(@"Can't explode. Current state is: %d", self.state);
    }
}

- (void) didExplode {
    if (self.state == kBombStateExploding) {
        // let's remove ourselves from the game!
        [self removeFromParent]; // bye bye world
        [[NSNotificationCenter defaultCenter] postNotificationName:kBombExplodedNotificationName object:self];
    } else {
        NSLog(@"didExplode can't be invoked! Current state is: %d", self.state);
    }
}

@end
