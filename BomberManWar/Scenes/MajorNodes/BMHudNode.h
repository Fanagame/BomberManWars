//
//  TDHudNode.h
//  CoopTD
//
//  Created by Remy Bardou on 11/2/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class BMHudButton;

@interface BMHudNode : SKNode

@property (nonatomic, strong, readonly) BMHudButton *exitButton;

@property (nonatomic, strong, readonly) SKLabelNode *playerNameLabel;
@property (nonatomic, strong, readonly) SKLabelNode *playerLivesLabel;

@property (nonatomic, readonly) CGFloat topOverlayHeight;

- (void) didMoveToScene;

@end
