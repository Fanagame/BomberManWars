//
//  BMConstants.h
//  BomberManWar
//
//  Created by Rémy Bardou on 14/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

static const uint32_t kPhysicsCategory_Wall         = 0x1 << 0; // 1
static const uint32_t kPhysicsCategory_Character    = 0x1 << 1; // 2
static const uint32_t kPhysicsCategory_Bomb         = 0x1 << 2; // 4
static const uint32_t kPhysicsCategory_Deflagration = 0x1 << 3; // 8

#define SHOW_JOYSTICK
//#define CHAR_AI_CHOOSE_SPAWN_SEQUENCE
//#define CHAR_PLACE_BOMB_BEHIND
//#define CHAR_LOCAL_PLAYER_IS_INVINCIBLE
#define HUD_ALWAYS_SHOW_PLAYERS_OVERLAY
