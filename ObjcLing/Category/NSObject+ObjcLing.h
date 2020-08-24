//
//  NSObject+ObjcLing.h
//  ObjcLing
//
//  Created by MeterWhite on 2020/8/17.
//  Copyright © 2020 meterwhite. All rights reserved.
//

#import "NSObjectling.h"

NS_ASSUME_NONNULL_BEGIN

#define TLing(obj) ((typeof(ling.T)<typeof(obj)>*)obj.ling)

/// obj.ling

@interface NSObject(ObjcLing)

/**
 * <#...#>
 */
@property (readonly) NSObjectling* ling;

/**
 * <#...#>
 */
@property (readonly) NSObjectling* lings;

@end

NS_ASSUME_NONNULL_END