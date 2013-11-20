//
//  BMPlayer.h
//  BomberManWar
//
//  Created by Rémy Bardou on 15/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMJoystick.h"

@class BMCharacter;

@interface BMPlayer : NSObject<BMJoystickDelegate>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *gameCenterId;

@property (nonatomic, assign) BOOL isAI;

@property (nonatomic, assign) NSInteger remainingLives;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, readonly) BOOL hasPendingUpdates;

@property (nonatomic, strong) BMCharacter *character;

+ (instancetype) localPlayer;
- (NSDictionary *) dictionaryRepresentation;
- (void) updateWithBlob:(NSDictionary *)blob;

@end
