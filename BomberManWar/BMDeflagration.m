//
//  BMDeflagration.m
//  BomberManWar
//
//  Created by Remy Bardou on 11/18/13.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMDeflagration.h"

@interface BMDeflagration () {
    NSMutableArray *_deflagrationFrames;
    NSMutableArray *_deflagrationSprites;
}

@property (nonatomic, strong) SKAction *deflagrationAction;

@end

@implementation BMDeflagration

- (id) initWithPosition:(CGPoint)position andMaxSize:(NSUInteger)maxSize {
    self = [super init];
    
    if (self) {
        self.deflagrationSprites = [[NSMutableArray alloc] init];
        self.position = position;
        self.maxSize = maxSize;
        
        [self loadAnimations];
    }
    
    return self;
}

- (void) loadAnimations {
    _deflagrationFrames = [[NSMutableArray alloc] init];
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Bombs"];
    for (int i = 1; i < 26; i++) {
        SKTexture *t = [atlas textureNamed:[NSString stringWithFormat:@"explosion_%03d", i]];
        [_deflagrationFrames addObject:t];
    }
}

- (SKTexture *) defaultTexture {
    if (_deflagrationFrames.count > 0) {
        return _deflagrationFrames[0];
    }
    return nil;
}

- (SKAction *) deflagrationAction {
    if (!_deflagrationAction) {
        _deflagrationAction = [SKAction group:@[[SKAction animateWithTextures:_deflagrationFrames timePerFrame:0.1]
                                                   ]];
    }
    return _deflagrationAction;
}

#pragma mark - Public API

- (void) deflagrate {
    [self deflagrateWithCompletionHandler:nil];
}

- (void) deflagrateWithCompletionHandler:(void (^)())onComplete {
    SKTexture *texture = [self defaultTexture];
    CGSize tileSize = texture.size;
    
    // Add the central explosion (bomb location)
    SKSpriteNode *n = [[SKSpriteNode alloc] initWithTexture:texture];
    n.position = CGPointZero;
    [self addChild:n];
    [self.deflagrationSprites addObject:n];
    [n runAction:self.deflagrationAction completion:^{
        if (onComplete) {
            onComplete();
        }
    }];
    
    // Then add all the other explosion sprites
    for (int i = 1; i <= self.maxSize; i++) {
        // left
        n = [n copy];
        n.position = CGPointMake(- i * (tileSize.width), 0);
        [self addChild:n];
        [self.deflagrationSprites addObject:n];
        [n runAction:self.deflagrationAction];
        
        // right
        n = [n copy];
        n.position = CGPointMake(i * (tileSize.width), 0);
        [self addChild:n];
        [self.deflagrationSprites addObject:n];
        [n runAction:self.deflagrationAction];
        
        // up
        n = [n copy];
        n.position = CGPointMake(0, - i * (tileSize.height));
        [self addChild:n];
        [self.deflagrationSprites addObject:n];
        [n runAction:self.deflagrationAction];
        
        // down
        n = [n copy];
        n.position = CGPointMake(0, i * (tileSize.height));
        [self addChild:n];
        [self.deflagrationSprites addObject:n];
        [n runAction:self.deflagrationAction];
    }
}

@end
