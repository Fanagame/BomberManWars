//
//  TDObject.h
//  CoopTD
//
//  Created by Remy Bardou on 10/19/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "BMMapObject.h"

@class BMArtificialIntelligence;

@interface BMTMXObject : BMMapObject

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)setup;

@end
