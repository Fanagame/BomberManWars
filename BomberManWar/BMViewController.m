//
//  BMViewController.m
//  BomberManWar
//
//  Created by Rémy Bardou on 14/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMViewController.h"
#import "BMGameScene.h"

#define DEFAULT_MAP_NAME @"bomberman-demo"

@implementation BMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
	// Create and configure the scene.
	__weak BMViewController *weakSelf = self;
    [BMGameScene loadSceneAssetsForMapName:DEFAULT_MAP_NAME withCompletionHandler:^{
        BMGameScene * scene = [[BMGameScene alloc] initWithSize:skView.bounds.size andMapName:DEFAULT_MAP_NAME];
        scene.scaleMode = SKSceneScaleModeAspectFill;
		scene.parentViewController = weakSelf;
        
        // Present the scene.
        [skView presentScene:scene];
    }];
	
    // Create and configure the scene.
    SKScene * scene = [BMGameScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[BMGameScene releaseSceneAssetsForMapName:DEFAULT_MAP_NAME];
}

@end
