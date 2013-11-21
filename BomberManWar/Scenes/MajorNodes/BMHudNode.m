//
//  TDHudNode.m
//  CoopTD
//
//  Created by Remy Bardou on 11/2/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "BMHudNode.h"
#import "BMHudButton.h"
#import "BMGameScene.h"
#import "BMPlayer.h"
#import "BMConstants.h"
#import "BMGameCenterManager.h"

#define PADDING 20
#define OVERLAY_WIDTH 200
#define OVERLAY_HEIGHT 300

NSString * const kHUDDropBombButtonPressedNotificationName = @"kHUDDropBombButtonPressedNotificationName";

@interface BMHudNode ()

@property (nonatomic, strong) BMHudButton *exitButton;
@property (nonatomic, strong) UIButton *dropBombButton;

@property (nonatomic, strong) SKLabelNode *playerNameLabel;
@property (nonatomic, strong) SKLabelNode *playerSoftCurrencyLabel;
@property (nonatomic, strong) SKLabelNode *playerLivesLabel;

@property (nonatomic, readonly) BMGameScene *gameScene;
@property (nonatomic, strong) SKShapeNode *topOverlayNode;
@property (nonatomic, strong) SKShapeNode *playersOverlayNode;

@end

@implementation BMHudNode

#pragma mark - Readonly props

- (BMGameScene *) gameScene {
    return (BMGameScene *)self.scene;
}

- (CGFloat) topOverlayHeight {
    return 30 / [UIScreen mainScreen].scale;
}

#pragma mark - Init

- (id) init {
    self = [super init];
    
    if (self) {
        self.name = @"hud";
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSoftCurrency) name:kLocalPlayerCurrencyUpdatedNotificationName object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLives) name:kLocalPlayerLivesUpdatedNotificationName object:nil];
    }
    
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) didMoveToScene {
    BMGameScene *scene = self.gameScene;
    
    CGPoint origin = CGPointMake(- scene.size.width / 2, - scene.size.height / 2);
    
    // add top overlay for scores
    self.topOverlayNode = [[SKShapeNode alloc] init];
    self.topOverlayNode.fillColor = [UIColor blackColor];
    self.topOverlayNode.strokeColor = [UIColor clearColor];
    CGPathRef path = CGPathCreateWithRect(CGRectMake(origin.x, origin.y + scene.size.height - self.topOverlayHeight, scene.size.width, self.topOverlayHeight), NULL);
    self.topOverlayNode.path = path;
    CGPathRelease(path);
    [self addChild:self.topOverlayNode];
    
    // local player name in top left
    self.playerNameLabel = [[SKLabelNode alloc] initWithFontNamed:@"Helvetica Neue Ultralight"];
    if ([BMPlayer localPlayer].gameCenterId) {
        self.playerNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", [BMPlayer localPlayer].displayName, [BMPlayer localPlayer].gameCenterId];
    } else {
        self.playerNameLabel.text = [NSString stringWithFormat:@"%@", [BMPlayer localPlayer].displayName];
    }
    self.playerNameLabel.color = [UIColor whiteColor];
    self.playerNameLabel.fontSize = 20.0 / [UIScreen mainScreen].scale;
    self.playerNameLabel.position = CGPointMake(origin.x + self.playerNameLabel.calculateAccumulatedFrame.size.width * 0.5, -origin.y - self.topOverlayHeight + 5 / [UIScreen mainScreen].scale);
    [self.topOverlayNode addChild:self.playerNameLabel];
    
    // Total lives on top
    self.playerLivesLabel = [self.playerNameLabel copy];
    [self updateLives];
    self.playerLivesLabel.position = CGPointMake(0, self.playerNameLabel.position.y);
    [self.topOverlayNode addChild:self.playerLivesLabel];
    
    // add buttons
    self.exitButton = [[BMHudButton alloc] initWithTitle:@"Exit"];
    self.exitButton.position = CGPointMake(10, 50);
    [self.exitButton addTarget:self action:@selector(didTapExit) forControlEvents:UIControlEventTouchUpInside];
    [self.gameScene.view addSubview:self.exitButton];
    
    // Drop bomb buttons
    self.dropBombButton = [[UIButton alloc] init];
    [self.dropBombButton setImage:[UIImage imageNamed:@"btn_bomb"] forState:UIControlStateNormal];
    self.dropBombButton.frame = CGRectMake(self.gameScene.size.width - 64 - 20, self.gameScene.size.height - 64 - 20, 64, 64);
    [self.dropBombButton addTarget:self action:@selector(didTapDropBomb) forControlEvents:UIControlEventTouchUpInside];
    [self.gameScene.view addSubview:self.dropBombButton];
}

- (void) updateLives {
    self.playerLivesLabel.text = [NSString stringWithFormat:@"Lives: %d", 0];
}

- (void) updateScores {
    BMGameScene *scene = self.gameScene;
    
    [self.playersOverlayNode removeAllChildren];
    [self.playersOverlayNode removeFromParent];
    
#ifndef HUD_ALWAYS_SHOW_PLAYERS_OVERLAY
    if (self.gameScene.multiplayerEnabled) {
#endif
        // add top overlay for scores
        self.playersOverlayNode = [[SKShapeNode alloc] init];
        self.playersOverlayNode.fillColor = [UIColor blackColor];
        self.playersOverlayNode.strokeColor = [UIColor clearColor];
        self.playersOverlayNode.alpha = 0.7;
        self.playersOverlayNode.position = CGPointMake((scene.size.width * 0.5) - OVERLAY_WIDTH/ [UIScreen mainScreen].scale - PADDING, 0);
        CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, OVERLAY_WIDTH/ [UIScreen mainScreen].scale, OVERLAY_HEIGHT/ [UIScreen mainScreen].scale), NULL);
        self.playersOverlayNode.path = path;
        CGPathRelease(path);
        [self addChild:self.playersOverlayNode];
        
        CGFloat currentY = 0;
        for (BMPlayer *p in self.players) {
            // Add a line
            SKLabelNode *label = [[SKLabelNode alloc] initWithFontNamed:self.playerNameLabel.fontName];
            label.color = self.playerNameLabel.color;
            label.fontSize = 18.0 / [UIScreen mainScreen].scale;
            label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
            label.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
            label.text = [NSString stringWithFormat:@"%@: %ld pts", p.displayName, (long)p.score];
            label.position = CGPointMake(0, currentY + self.playersOverlayNode.frame.size.height);
            [self.playersOverlayNode addChild:label];
            
            currentY -= 30;
        }
        
        // Add a line
        SKLabelNode *label = [[SKLabelNode alloc] initWithFontNamed:self.playerNameLabel.fontName];
        label.color = self.playerNameLabel.color;
        label.fontSize = 18.0 / [UIScreen mainScreen].scale;
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        label.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        label.text = (self.gameScene.isClient ? @"CLIENT" : @"HOST");
        label.position = CGPointMake(0, currentY + self.playersOverlayNode.frame.size.height);
        [self.playersOverlayNode addChild:label];
#ifndef HUD_ALWAYS_SHOW_PLAYERS_OVERLAY
    }
#endif
}

#pragma mark - Buttons actions

- (void) didTapExit {
    [[BMGameCenterManager currentSession] endGame];
	[self.gameScene.parentViewController.navigationController popViewControllerAnimated:YES];
}

- (void) didTapDropBomb {
    [[NSNotificationCenter defaultCenter] postNotificationName:kHUDDropBombButtonPressedNotificationName object:nil];
}

@end
