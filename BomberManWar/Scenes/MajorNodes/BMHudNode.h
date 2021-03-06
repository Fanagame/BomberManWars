//
//  TDHudNode.h
//  CoopTD
//
//  Created by Remy Bardou on 11/2/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class BMHudButton;

extern NSString * const kHUDDropBombButtonPressedNotificationName;

@interface BMHudNode : SKNode

@property (nonatomic, strong, readonly) BMHudButton *exitButton;
@property (nonatomic, strong, readonly) UIButton *dropBombButton;

@property (nonatomic, strong, readonly) SKLabelNode *playerNameLabel;
@property (nonatomic, strong, readonly) SKLabelNode *playerLivesLabel;

@property (nonatomic, readonly) CGFloat topOverlayHeight;

@property (nonatomic, strong) NSArray *players;

- (void) didMoveToScene;
- (void) updateScores;

@end
