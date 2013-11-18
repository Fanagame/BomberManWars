//
//  BMBomb.h
//  BomberManWar
//
//  Created by Rémy Bardou on 15/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMMapObject.h"

typedef enum BMBombState : NSUInteger { kBombStateStandby, kBombStateTicking, kBombStateExploding, kBombStateExploded } BMBombState;

@class BMCharacter, BMDeflagration;

extern NSString * const kBombExplodedNotificationName;

@interface BMBomb : BMMapObject

@property (nonatomic, assign) BMBombState	state;
@property (nonatomic, assign) NSUInteger	deflagrationRange;
@property (nonatomic, assign) CFTimeInterval timeBeforeExploding;
@property (nonatomic, weak) BMCharacter		*owner;
@property (nonatomic, strong) BMDeflagration *deflagration;

- (void) startTicking;
- (void) cancelTicking;
- (void) explode;

@end
