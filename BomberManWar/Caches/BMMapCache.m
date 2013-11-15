//
//  TDMapCache.m
//  CoopTD
//
//  Created by Remy Bardou on 10/20/13.
//  Copyright (c) 2013 Remy Bardou Corp. All rights reserved.
//

#import "BMMapCache.h"
#import "BMTiledMap.h"

@interface BMMapCache () {
    NSMutableDictionary *_dataMap;
}

@end

@implementation BMMapCache

static BMMapCache *_sharedCache;

+ (instancetype) sharedCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCache = [[BMMapCache alloc] init];
    });
    
    return _sharedCache;
}

- (id) init {
    self = [super init];
    
    if (self) {
        _dataMap = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void) addMapToCache:(BMTiledMap *)map {
    if (map && !_dataMap[map.mapName]) {
        _dataMap[map.mapName] = map;
    }
}

- (BMTiledMap *) cachedMapForMapName:(NSString *)mapName {
    return _dataMap[mapName];
}

- (void) preloadMapNamed:(NSString *)mapName {
    if (![self cachedMapForMapName:mapName]) {
        BMTiledMap *map = [[BMTiledMap alloc] initWithMapNamed:mapName];
        [self addMapToCache:map];
    }
}

- (void) invalidateCacheForMapNamed:(NSString *)mapName {
	[_dataMap removeObjectForKey:mapName];
}

@end
