//
//  DynamicLink.m
//  LinkBlockProgram
//
//  Created by NOVO on 2017/12/15.
//  Copyright © 2017年 NOVO. All rights reserved.
//

#import "DynamicLink.h"
#import "DynamicLinkAction.h"
#import "DynamicLinkArgument.h"
#import "LinkHelper.h"
#import "NSObject+LinkBlock.h"

@interface DynamicLink()
@property (nonatomic,strong) NSMutableArray<DynamicLinkAction*>* items;
@end

@implementation DynamicLink

- (id)invoke:(id)origin args:(va_list)list
{
    //无code返回对象本身
    if(!self.code) return origin;
    
    //包装起始对象
    origin = _LB_MakeObj(origin);
    
    BOOL isEnd = NO;
    id currentOrigin = origin;
    for (NSUInteger idx_bk = 0; idx_bk < self.countOfItems; idx_bk++) {
        
        DynamicLinkAction* block = self.items[idx_bk];
        currentOrigin = [block invoke:currentOrigin args:list end:&isEnd];
        if(isEnd == YES){
            break;
        }
        if(!currentOrigin){
            //void返回类型后不能再有链条
            NSLog(@"DynamicLink Error:%@不可接受的返回类型",self.items[idx_bk].actionName);
            break;
        }
    }
    
    return currentOrigin;
}

#pragma mark - 构造
- (instancetype)initWithCode:(NSString*)code
{
    self = [super init];
    if (self) {
        
        _code = code;
        
        NSArray* blockStrings = [[LinkHelper help:_code] actionCommandSplitFromLinkCode];
        [blockStrings enumerateObjectsUsingBlock:^(NSString*  _Nonnull blockString, NSUInteger idx, BOOL * _Nonnull stop) {
            
            //构造block
            DynamicLinkAction* dyLinkBlock = [DynamicLinkAction dynamicLinkBlockWithCode:blockString index:idx];
            if(!dyLinkBlock){
                *stop = YES;
                return;
            }
            [self.items addObject:dyLinkBlock];
        }];
    }
    return self;
}
+ (instancetype)dynamicLinkWithCode:(NSString *)code
{
    return [[self alloc] initWithCode:code];
}
- (NSUInteger)countOfItems
{
    return self.items.count;
}
- (DynamicLinkAction *)blockAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger idx = [indexPath indexAtPosition:0];
    if(idx > self.items.count-1 ) return nil;
    return self.items[idx];
}
- (DynamicLinkArgument *)argumentAtIndexPath:(NSIndexPath *)indexPath
{
    DynamicLinkAction* block = [self blockAtIndexPath:indexPath];
    if(!block) return nil;
    return  [block argumentAtIndexPath:indexPath];
}
- (NSMutableArray<DynamicLinkAction *> *)items
{
    if(!_items){
        _items = [NSMutableArray new];
    }
    return _items;
}
@end
