//
//  TDMapCache.h
//  CoopTD
//
//  Created by Remy Bardou on 10/20/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMTiledMap;

@interface BMMapCache : NSObject

+ (instancetype) sharedCache;

- (void) addMapToCache:(BMTiledMap *)map;
- (BMTiledMap *) cachedMapForMapName:(NSString *)mapName;
- (void) preloadMapNamed:(NSString *)mapName;
- (void) invalidateCacheForMapNamed:(NSString *)mapName;

@end
