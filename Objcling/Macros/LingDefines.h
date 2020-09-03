//
//  ObjclingDefines.h
//  Objcling
//
//  Created by meterwhite on 2020/8/21.
//  Copyright © 2020 Meterwhite. All rights reserved.
//

#ifndef LingDefines_h
#define LingDefines_h

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import "LingCoreConnect.h"

@class TObjectling,TArrayling,Tling;

typedef bool(^_Nullable TlingConditionIN)(id _Nonnull x);
typedef id _Nullable(^_Nullable TlingxIN)(id _Nonnull x);
typedef id _Nullable(^_Nullable TlingILoopIN)(NSInteger i, id _Nonnull x);
typedef NSComparisonResult (^_Nullable TlingSortIN)(id _Nonnull x);
typedef Tling* _Nonnull(^_Nullable TlingBranchIN)(Tling *_Nonnull ling);
typedef void(^_Nullable TlingNotifiedIN)(id _Nonnull x, NSNotification * _Nonnull ntf);

#define sub_iloop(from, to, ...) \
OCLING_CORNECT_IF_EQ(2,CORE_CONNECT_ARGCOUNT(__VA_ARGS__)) \
(iloop(from, to, ^id _Nullable (NSInteger i, OCLING_CORNECT_HEAD(__VA_ARGS__) _Nonnull x) { \
    OCLING_CORNECT_TAIL(__VA_ARGS__);\
    return nil; \
})) \
(iloop(from, to, ^id _Nullable (NSInteger i, id _Nonnull x) { \
    __VA_ARGS__;\
    return nil; \
}))


#define sub_loopp(...) \
OCLING_CORNECT_IF_EQ(2, CORE_CONNECT_ARGCOUNT(__VA_ARGS__)) \
(loopp(^id _Nullable (OCLING_CORNECT_HEAD(__VA_ARGS__) _Nonnull x) { \
    OCLING_CORNECT_TAIL(__VA_ARGS__);\
    return nil; \
})) \
(loopp(^id _Nullable (id _Nonnull x) { \
    __VA_ARGS__;\
    return nil; \
}))


#define sub_continuee(...) \
OCLING_CORNECT_IF_EQ(2, CORE_CONNECT_ARGCOUNT(__VA_ARGS__)) \
(continuee(^bool(CORE_CONNECT_ARGCOUNT(__VA_ARGS__) _Nonnull x) { \
    OCLING_CORNECT_TAIL(__VA_ARGS__);\
})) \
(continuee(^bool(id _Nonnull x) { \
    __VA_ARGS__;\
}))


#define sub_sort(...) \
OCLING_CORNECT_IF_EQ(2, CORE_CONNECT_ARGCOUNT(__VA_ARGS__)) \
(sort(^NSComparisonResult(CORE_CONNECT_ARGCOUNT(__VA_ARGS__) _Nonnull x) { \
    OCLING_CORNECT_TAIL(__VA_ARGS__);\
})) \
(sort(^NSComparisonResult(id _Nonnull x) { \
    __VA_ARGS__;\
}))


#define typedes_TlingBranchIN(...) \
OCLING_CORNECT_FOREACH_CXT(typede_TlingBranchIN,,, __VA_ARGS__)

#define typede_TlingBranchIN(INDEX, CONTEXT, T) \
@class T; \
typedef __kindof Tling* _Nonnull(^_Nullable Tling##T##branchIN)(T *_Nonnull ling);

typedes_TlingBranchIN(TObjectling,TArrayling)


//OCLING_CORNECT_IF_EQ
//CORE_CONNECT_ARGCOUNT
//OCLING_CORNECT_HEAD
//OCLING_CORNECT_TAIL

#endif /* LingDefines_h */
