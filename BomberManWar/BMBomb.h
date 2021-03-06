//
//  BMBomb.h
//  BomberManWar
//
//  Created by Rémy Bardou on 15/11/2013.
//  Copyright (c) 2013 GREE International Inc. All rights reserved.
//

#import "BMMapObject.h"
#import "BMEnums.h"

@class BMCharacter, BMDeflagration;

extern NSString * const kBombExplodedNotificationName;

@interface BMBomb : BMMapObject

@property (nonatomic, assign) BMBombState	state;
@property (nonatomic, assign) NSUInteger	deflagrationRange;
@property (nonatomic, assign) CFTimeInterval timeBeforeExploding;
@property (nonatomic, strong) NSDate *tickingStartDate;
@property (nonatomic, weak) BMCharacter		*owner;
@property (nonatomic, strong) BMDeflagration *deflagration;

- (void) startTicking;
- (void) cancelTicking;
- (void) explode;

- (NSDictionary *) dictionaryRepresentation;
- (void) updateFromDictionary:(NSDictionary *)dictionary;

@end
