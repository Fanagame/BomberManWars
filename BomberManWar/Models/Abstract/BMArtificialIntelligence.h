//
//  TDArtificialIntelligence.h
//  CoopTD
//
//  Created by Remy Bardou on 10/20/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMMapObject;

@interface BMArtificialIntelligence : NSObject

@property (nonatomic, weak) BMMapObject *character;
@property (nonatomic, weak) BMMapObject *target;

- (id) initWithCharacter:(BMMapObject *)character andTarget:(BMMapObject *)target;
- (void) changeTarget:(BMMapObject *)target;

- (void) updateWithTimeSinceLastUpdate:(CFTimeInterval)interval;

@end
