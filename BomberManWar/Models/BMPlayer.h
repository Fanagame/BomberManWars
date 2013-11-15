//
//  BMPlayer.h
//  BomberManWar
//
//  Created by Rémy Bardou on 15/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMPlayer : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *gameCenterId;

@property (nonatomic, assign) NSInteger remainingLives;
@property (nonatomic, assign) NSInteger score;

@end
