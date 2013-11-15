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

@interface BMHudNode ()

@property (nonatomic, strong) BMHudButton *exitButton;
@property (nonatomic, strong) BMHudButton *placeGroundBuildingButton;
@property (nonatomic, strong) BMHudButton *placeAirBuildingButton;

@property (nonatomic, strong) SKLabelNode *playerNameLabel;
@property (nonatomic, strong) SKLabelNode *playerSoftCurrencyLabel;
@property (nonatomic, strong) SKLabelNode *playerLivesLabel;

@property (nonatomic, readonly) BMGameScene *gameScene;
@property (nonatomic, strong) SKShapeNode *topOverlayNode;

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
    self.playerNameLabel.text = @"PlayerName";
    self.playerNameLabel.color = [UIColor whiteColor];
    self.playerNameLabel.fontSize = 16.0 / [UIScreen mainScreen].scale;
    self.playerNameLabel.position = CGPointMake(origin.x + 60, -origin.y - self.topOverlayHeight + 5 / [UIScreen mainScreen].scale);
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
}

- (void) updateLives {
    self.playerLivesLabel.text = [NSString stringWithFormat:@"Lives: %d", 0];
}

#pragma mark - Buttons actions

- (void) didTapExit {
	[self.gameScene.parentViewController.navigationController popViewControllerAnimated:YES];
}

@end
