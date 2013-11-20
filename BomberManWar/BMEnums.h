//
//  BMEnums.h
//  BomberManWar
//
//  Created by Rémy Bardou on 14/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : uint8_t {
	BMWorldLayerGround = 0,
	BMWorldLayerGrid,
    BMWorldLayerBelowCharacter,
	BMWorldLayerCharacter,
	BMWorldLayerAboveCharacter,
	BMWorldLayerTop,
	kWorldLayerCount
} BMWorldLayer;

typedef enum : uint8_t {
    BMHudButtonShape_Circle,
    BMHudButtonShape_Rectangle
} BMHudButtonShape;

typedef enum : uint8_t {
    BMHudButtonColor_Red,
    BMHudButtonColor_Orange,
    BMHudButtonColor_Green,
    BMHudButtonColor_Yellow,
    BMHudButtonColor_Blue
} BMHudButtonColor;

typedef enum BMDirection : NSInteger {
	kDirectionNone = -1,
	kDirectionDown = 0,
	kDirectionLeft = 1,
	kDirectionUp = 2,
	kDirectionRight = 3
} BMDirection;

typedef enum BMBombState : NSUInteger {
    kBombStateStandby,
    kBombStateTicking,
    kBombStateExploding,
    kBombStateExploded
} BMBombState;

typedef enum : uint8_t {
    kPacketTypeUnknown,
    kPacketTypeGameReadyAnnouncement,
    kPacketTypeGameReadyAcknowledgment,
    kPacketTypeSync,
    kPacketTypeUpdatePosition,
    kPacketTypeBombPlanted
} BMPacketType;
