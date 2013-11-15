//
//  BMBomb.h
//  BomberManWar
//
//  Created by Rémy Bardou on 15/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMMapObject.h"

typedef enum BMBombState : NSUInteger { kBombStateNormal, kBombStateExploding, kBombStateExploded } BMBombState;

@class BMCharacter;

@interface BMBomb : BMMapObject

@property (nonatomic, assign) BMBombState	state;
@property (nonatomic, assign) NSUInteger	deflagrationRange;
@property (nonatomic, weak) BMCharacter		*owner;

- (void) explode;

@end
