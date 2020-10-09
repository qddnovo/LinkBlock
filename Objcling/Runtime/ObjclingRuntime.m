//
//  ObjclingRuntime.m
//  Objcling
//
//  Created by meterwhite on 2020/8/15.
//  Copyright © 2020 meterwhite. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ObjclingRuntime.h"
#import "DynamilingInfo.h"
#import <Foundation/Foundation.h>
#import <objc/NSObject.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "AlingAction.h"
#import "TlingErr.h"
#import "Tling.h"

static Class _class_Tling;

typedef id TlingBlock;

Tling *TlingAutoProperty(__kindof Tling *ling, SEL sel);

TlingBlock TlingAutoBlockProperty(__kindof Tling *ling, SEL sel);

bool setValue2Action(AlingAction<TActionParametric, TActionVariableParametric> *act, NSUInteger idx, const char *enc, va_list li);

bool sendMsgWork(id target, NSUInteger index, Tling *ling, SEL sel, Class act_classz);

bool sendMsgWork_va(id target, NSUInteger index, Tling *ling, SEL sel, Class act_classz, va_list li, const char *enc0, va_list li_self);

Class getActionClass(__kindof Tling *ling, SEL sel);

@implementation ObjclingRuntime

+ (void)load {
    _class_Tling = [Tling class];
    @autoreleasepool {
        [self registerActions];
    }
}

+ (void)registerActions {
    unsigned int count    = 0;
    Class    *cLi         = objc_copyClassList(&count);
    Class    cALingAction = [AlingAction class];
    Protocol *pArgsIn     = @protocol(TActionParametric);
    do {
        Class   cAct    = cLi[count - 1];
        if([cAct isSubclassOfClass:cALingAction] && cAct != cALingAction) continue;
        NSArray *infos  = [NSStringFromClass(cAct) componentsSeparatedByString:@"_"];
        if(infos.count != 2) continue;
        Class   cObj    = NSClassFromString([infos firstObject]);
        SEL     selObj  = NSSelectorFromString([infos lastObject]);
        IMP     actImp;
        if(class_conformsToProtocol(cAct, pArgsIn)) {
            actImp = (IMP)TlingAutoBlockProperty;
        } else {
            actImp = (IMP)TlingAutoProperty;
        }
        Method m = class_getInstanceMethod(cObj, selObj);
        method_setImplementation(m, actImp);
    }while(--count);
    free(cLi);
}

/// 所有属性形式方法的实现入口
Tling *TlingAutoProperty(__kindof Aling *ling, SEL sel) {
    /// Error pass
    if(ling->status == AlingStatusReturning || ling->error) {
        return ling;
    }
    if(ling->status != AlingStatusFuture) {
        if(![ling.target isKindOfClass:ling.dependentClass]) {
            [ling pushError:[[TlingErr allocWith:DelingWith(ling)] initForKind:ling.dependentClass sel:sel]];
            return ling;
        }
    }
    Class act_class = getActionClass(ling, sel);
    if(ling.itemCount == 1) {
        if(!sendMsgWork(ling.target, 0, ling, sel, act_class)) {
            return ling;
        }
    } else if(ling.itemCount > 1) {
        NSUInteger i = 0;
        for (id target in ling) {
            if(!sendMsgWork(target, i++, ling, sel, act_class)) {
                return ling;
            }
        }
    }
    ling->step++;
    return ling;
}

/// 所有闭包属性形式方法的实现入口
TlingBlock TlingAutoBlockProperty(__kindof Tling *ling, SEL sel) {
    do{
        Class act_class = getActionClass(ling, sel);
        if(!act_class) break;
        const char *enc = [act_class encodeAt:0];
        if (enc[0] == _C_CONST) enc++;
        if (enc[0] == _C_ID) { //id and block
            return ^Tling *(id at0, ...) {
                va_list li;
                va_start(li, at0);
                return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
            };
            break;
        } else if (strcmp(enc, @encode(Class)) == 0) { //Class
            return ^Tling *(Class at0, ...) {
                va_list li;
                va_start(li, at0);
                return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
            };
            break;
        } else if (strcmp(enc, @encode(IMP)) == 0) {         //IMP
            return ^Tling *(IMP at0, ...) {
                va_list li;
                va_start(li, at0);
                return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
            };
            break;
        } else if (strcmp(enc, @encode(SEL)) == 0) {         //SEL
            return ^Tling *(SEL at0, ...) {
                va_list li;
                va_start(li, at0);
                return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
            };
            break;
        } else if (strcmp(enc, @encode(double)) == 0) {       //double
            return ^Tling *(double at0, ...) {
                va_list li;
                va_start(li, at0);
                return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
            };
            break;
        } else if (strcmp(enc, @encode(float)) == 0) {       //float
            return ^Tling *(double at0, ...) {
                va_list li;
                va_start(li, at0);
                return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
            };
            break;
        } else if (enc[0] == _C_PTR) {                           //pointer ( and const pointer)
            return ^Tling *(void *at0, ...) {
                va_list li;
                va_start(li, at0);
                return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
            };
            break;
        } else if (strcmp(enc, @encode(char *)) == 0) {      //char* (and const char*)
            return ^Tling *(char *at0, ...) {
                va_list li;
                va_start(li, at0);
                return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
            };
            break;
        } else if (strcmp(enc, @encode(unsigned long)) == 0) {
            return ^Tling *(unsigned long at0, ...) {
                va_list li;
                va_start(li, at0);
                return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
            };
            break;
        } else if (strcmp(enc, @encode(unsigned long long)) == 0) {
            return ^Tling *(unsigned long long at0, ...) {
                va_list li;
                va_start(li, at0);
                return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
            };
            break;
        } else if (strcmp(enc, @encode(long)) == 0) {
            return ^Tling *(long at0, ...) {
                va_list li;
                va_start(li, at0);
                return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
            };
            break;
        } else if (strcmp(enc, @encode(long long)) == 0) {
            return ^Tling *(long long at0, ...) {
                va_list li;
                va_start(li, at0);
                return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
            };
            break;
        } else if (strcmp(enc, @encode(int)) == 0) {
            return ^Tling *(int at0, ...) {
                va_list li;
                va_start(li, at0);
                return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
            };
            break;
        } else if (strcmp(enc, @encode(unsigned int)) == 0) {
            return ^Tling *(unsigned int at0, ...) {
                va_list li;
                va_start(li, at0);
                return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
            };
            break;
        } else if ((strcmp(enc, @encode(bool))  == 0         ||
                   strcmp(enc, @encode(BOOL))  == 0          ||
                   strcmp(enc, @encode(char))  == 0          ||
                   strcmp(enc, @encode(short)) == 0          ||
                   strcmp(enc, @encode(unsigned char)) == 0  ||
                   strcmp(enc, @encode(unsigned short)) == 0)) {
            return ^Tling *(int at0, ...) {
                va_list li;
                va_start(li, at0);
                return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, (short)at0);
            };
            break;
        } else{
            //struct union and array
            if (strcmp(enc, @encode(CGRect)) == 0) {
                return ^Tling *(CGRect at0, ...) {
                    va_list li;
                    va_start(li, at0);
                    return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
                };
                break;
            } else if(strcmp(enc, @encode(CGPoint)) == 0) {
                return ^Tling *(CGPoint at0, ...) {
                    va_list li;
                    va_start(li, at0);
                    return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
                };
                break;
            } else if (strcmp(enc, @encode(CGSize)) == 0) {
                return ^Tling *(CGSize at0, ...) {
                    va_list li;
                    va_start(li, at0);
                    return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
                };
                break;
            } else if (strcmp(enc, @encode(NSRange)) == 0) {
                return ^Tling *(NSRange at0, ...) {
                    va_list li;
                    va_start(li, at0);
                    return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
                };
                break;
            } else if (strcmp(enc, @encode(UIEdgeInsets)) == 0) {
                return ^Tling *(UIEdgeInsets at0, ...) {
                    va_list li;
                    va_start(li, at0);
                    return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
                };
                break;
            } else if (strcmp(enc, @encode(CGVector)) == 0) {
                return ^Tling *(CGVector at0, ...) {
                    va_list li;
                    va_start(li, at0);
                    return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
                };
                break;
            } else if (strcmp(enc, @encode(UIOffset)) == 0) {
                return ^Tling *(UIOffset at0, ...) {
                    va_list li;
                    va_start(li, at0);
                    return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
                };
                break;
            } else if(strcmp(enc, @encode(CATransform3D)) == 0) {
                return ^Tling *(CATransform3D at0, ...) {
                    va_list li;
                    va_start(li, at0);
                    return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
                };
                break;
            } else if(strcmp(enc, @encode(CGAffineTransform)) == 0) {
                return ^Tling *(CGAffineTransform at0, ...) {
                    va_list li;
                    va_start(li, at0);
                    return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
                };
                break;
            }
            if (@available(iOS 11.0, *)) {
                if(strcmp(enc, @encode(NSDirectionalEdgeInsets)) == 0) {
                    return ^Tling *(NSDirectionalEdgeInsets at0, ...) {
                        va_list li;
                        va_start(li, at0);
                        return TlingSubAutoBlockProperty(ling, sel, act_class, li, enc, at0);
                    };
                    break;
                }
            }
        }
    }while(0);
    /// Type error
    return ^Tling *(CATransform3D at0, ...) {
        [ling pushError:[[TlingErr allocWith:ling.target] initForUserDescription:@"Unsupported parameter type"]];
        return ling;
    };
}

/// 所有闭包属性形式方法的实现入口2
Tling *TlingSubAutoBlockProperty(__kindof Tling *ling, SEL sel, Class act_classz, va_list li, const char *enc0 , ...) {
    if(ling->error  || ling->status == AlingStatusReturning) {
        return ling;
    }
    if(ling->status != AlingStatusFuture) {
        if(![ling.target isKindOfClass:ling.dependentClass]) {
            [ling pushError:[[TlingErr allocWith:(ling.itemCount > 1) ? ling.targets : ling.target] initForKind:ling.dependentClass sel:sel]];
            return ling;
        }
    }
    va_list li_at0;
    va_start(li_at0, enc0);
    if(ling.itemCount == 1) {
        if(!sendMsgWork_va(ling.target, 0, ling, sel, act_classz, li, enc0, li_at0)) {
            return ling;
        }
    } else if(ling.itemCount > 1) {
        NSUInteger i = 0;
        for (id target in ling) {
            if(!sendMsgWork_va(target, i++, ling, sel, act_classz, li, enc0, li_at0)) {
                return ling;
            }
        }
    }
    ling->step++;
    return ling;
}

@end

/// 普通属性形式的发消息的工作
/// @param target 目标对象
/// @param index 链的游标
/// @param ling 链
/// @param sel 消息名
/// @param act_class 即将构造方法的类
bool sendMsgWork(id target, NSUInteger index, Tling *ling, SEL sel, Class act_class) {
    /// 参考：sendMsgWork_va()
    AlingAction *act = [[act_class alloc] init];
    [act setTarget:ling.target];
    [act setStep:ling->step];
    if(ling->status == AlingStatusFuture) {
        DynamilingInfo *info = [[DynamilingInfo alloc] init];
        info.dependentClass = ling.dependentClass;
        info.sel            = sel;
        act.dynamilingInfo  = info;
        [ling->dynamicActions addObject:act];
        return false;
    }
    TlingErr *err;
    id newTag = [act sendMsg:&err];
    if(err) {
        [ling pushError:err];
        return false;
    }
    if(newTag) {
        if(ling.itemCount == 1) {
            [ling switchTarget:newTag];
        } else {
            [ling.targets replaceObjectAtIndex:index withObject:newTag];
        }
    }
    return true;
}

/// 普通属性形式的发消息的工作
/// @param target 目标对象
/// @param index 链的游标
/// @param ling 链
/// @param sel 消息名
/// @param act_classz 即将构造方法的类
/// @param li_va 实际的第一个参数之后的参数列表
/// @param enc0 实际的第一个参数的类型编码
/// @param li_at0 实际的第一个参数被构造的参数列表
bool sendMsgWork_va(id target, NSUInteger index, Tling *ling, SEL sel, Class act_classz, va_list li_va, const char *enc0, va_list li_at0) {
    /// 构造方法
    AlingAction<TActionParametric,TActionVariableParametric> *act = [[act_classz alloc] init];
    [act setTarget:target];
    [act setStep:ling->step];
    /// 传参
    for (NSUInteger idx = 0; idx < act.count  ; idx++) {
        if(idx == 0) {
            setValue2Action(act, idx, enc0, li_at0);
        } else {
            const char *code = [act_classz encodeAt:idx];
            if(!code) break;
            setValue2Action(act, idx, code, li_va);
        }
    }
    /// 处理可变参数列表
    if(class_conformsToProtocol(act_classz, @protocol(TActionVariableParametric))) {
        while (setValue2Action(act, -1, @encode(id), li_va));
    }
    /// 动态链则仅存储后返回
    if(ling->status == AlingStatusFuture) {
        DynamilingInfo *info = [[DynamilingInfo alloc] init];
        info.dependentClass = ling.dependentClass;
        info.sel            = sel;
        act.dynamilingInfo  = info;
        [ling->dynamicActions addObject:act];
        return false;
    }
    TlingErr *err;
    /// 执行方法
    id newTag = [act sendMsg:&err];
    /// 处理异常
    if(err) {
        [ling pushError:err];
        return false;
    }
    if(newTag) {
        /// 更新目标对象
        if(ling.itemCount == 1) {
            [ling switchTarget:newTag];
        } else {
            [ling.targets replaceObjectAtIndex:index withObject:newTag];
        }
    }
    return true;
}

/// 方法的入参工作
/// @param act 方法
/// @param idx 参数的游标，-1指可变参数列表
/// @param enc 入参参数的类型编码
/// @param li 入参所属的参数列表
bool setValue2Action(AlingAction<TActionParametric, TActionVariableParametric> *act, NSUInteger idx, const char *enc, va_list li) {
    SEL setter = NSSelectorFromString([NSString stringWithFormat:@"setAt%ld:",idx]);
    do{
        if(idx == -1) {
            id v = va_arg(li, id);
            if(v == nil) return false;
            [[act arrayForValist] addObject:v];
            break;
        }
        if (enc[0] == _C_CONST) enc++;
        if (enc[0] == _C_ID) { //id and block
            id v = va_arg(li, id);
            ((void(*)(id,SEL,id))objc_msgSend)(act,setter,v);
            break;
        } else if (strcmp(enc, @encode(Class)) == 0) {       //Class
            Class v = va_arg(li, Class);
            ((void(*)(id,SEL,Class))objc_msgSend)(act,setter,v);
            break;
        } else if (strcmp(enc, @encode(IMP)) == 0 ) {         //IMP
            IMP v = va_arg(li, IMP);
            ((void(*)(id,SEL,IMP))objc_msgSend)(act,setter,v);
            break;
        } else if (strcmp(enc, @encode(SEL)) == 0) {         //SEL
            SEL v = va_arg(li, SEL);
            ((void(*)(id,SEL,SEL))objc_msgSend)(act,setter,v);
            break;
        } else if (strcmp(enc, @encode(double)) == 0) {      //double
            double v = va_arg(li, double);
            ((void(*)(id,SEL,double))objc_msgSend)(act,setter,v);
            break;
        } else if (strcmp(enc, @encode(float)) == 0) {       //float
            float v = va_arg(li, double);
            ((void(*)(id,SEL,float))objc_msgSend)(act,setter,v);
            break;
        } else if (enc[0] == _C_PTR) {                       //pointer ( and const pointer)
            void *v = va_arg(li, void*);
            ((void(*)(id,SEL,void*))objc_msgSend)(act,setter,v);
            break;
        } else if (strcmp(enc, @encode(char *)) == 0) {     //char* (and const char*)
            char *v = va_arg(li, char *);
            ((void(*)(id,SEL,char *))objc_msgSend)(act,setter,v);
            break;
        } else if (strcmp(enc, @encode(unsigned long)) == 0) {
            unsigned long v = va_arg(li, unsigned long);
            ((void(*)(id,SEL,unsigned long))objc_msgSend)(act,setter,v);
            break;
        } else if (strcmp(enc, @encode(unsigned long long)) == 0) {
            unsigned long long v = va_arg(li, unsigned long long);
            ((void(*)(id,SEL,unsigned long long))objc_msgSend)(act,setter,v);
            break;
        } else if (strcmp(enc, @encode(long)) == 0) {
            long v = va_arg(li, long);
            ((void(*)(id,SEL,long))objc_msgSend)(act,setter,v);
            break;
        } else if (strcmp(enc, @encode(long long)) == 0) {
            long long v = va_arg(li, long long);
            ((void(*)(id,SEL,long long))objc_msgSend)(act,setter,v);
            break;
        } else if (strcmp(enc, @encode(int)) == 0) {
            int v = va_arg(li, int);
            ((void(*)(id,SEL,int))objc_msgSend)(act,setter,v);
            break;
        } else if (strcmp(enc, @encode(unsigned int)) == 0) {
            unsigned int v = va_arg(li, unsigned int);
            ((void(*)(id,SEL,unsigned int))objc_msgSend)(act,setter,v);
            break;
        } else if ((strcmp(enc, @encode(bool)) == 0          ||
                   strcmp(enc, @encode(BOOL)) == 0           ||
                   strcmp(enc, @encode(char)) == 0           ||
                   strcmp(enc, @encode(short)) == 0          ||
                   strcmp(enc, @encode(unsigned char)) == 0  ||
                   strcmp(enc, @encode(unsigned short)) == 0)) {
            short v = va_arg(li, int);
            ((void(*)(id,SEL,short))objc_msgSend)(act,setter,v);
            break;
        } else{
            //struct union and array
            if (strcmp(enc, @encode(CGRect)) == 0) {
                CGRect v = va_arg(li, CGRect);
                ((void(*)(id,SEL,CGRect))objc_msgSend)(act,setter,v);
                break;
            } else if(strcmp(enc, @encode(CGPoint)) == 0) {
                CGPoint v = va_arg(li, CGPoint);
                ((void(*)(id,SEL,CGPoint))objc_msgSend)(act,setter,v);
                break;
            } else if (strcmp(enc, @encode(CGSize)) == 0) {
                CGSize v = va_arg(li, CGSize);
                ((void(*)(id,SEL,CGSize))objc_msgSend)(act,setter,v);
                break;
            } else if (strcmp(enc, @encode(NSRange)) == 0) {
                NSRange v = va_arg(li, NSRange);
                ((void(*)(id,SEL,NSRange))objc_msgSend)(act,setter,v);
                break;
            } else if (strcmp(enc, @encode(UIEdgeInsets)) == 0) {
                UIEdgeInsets v = va_arg(li, UIEdgeInsets);
                ((void(*)(id,SEL,UIEdgeInsets))objc_msgSend)(act,setter,v);
                break;
            } else if (strcmp(enc, @encode(CGVector)) == 0) {
                CGVector v = va_arg(li, CGVector);
                ((void(*)(id,SEL,CGVector))objc_msgSend)(act,setter,v);
                break;
            } else if (strcmp(enc, @encode(UIOffset)) == 0) {
                UIOffset v = va_arg(li, UIOffset);
                ((void(*)(id,SEL,UIOffset))objc_msgSend)(act,setter,v);
                break;
            } else if(strcmp(enc, @encode(CATransform3D)) == 0) {
                CATransform3D v = va_arg(li, CATransform3D);
                ((void(*)(id,SEL,CATransform3D))objc_msgSend)(act,setter,v);
                break;
            } else if(strcmp(enc, @encode(CGAffineTransform)) == 0) {
                CGAffineTransform v = va_arg(li, CGAffineTransform);
                ((void(*)(id,SEL,CGAffineTransform))objc_msgSend)(act,setter,v);
                break;
            }
            if (@available(iOS 11.0, *)) {
                if(strcmp(enc, @encode(NSDirectionalEdgeInsets)) == 0) {
                    NSDirectionalEdgeInsets v = va_arg(li, NSDirectionalEdgeInsets);
                    ((void(*)(id,SEL,NSDirectionalEdgeInsets))objc_msgSend)(act,setter,v);
                    break;
                }
            }
        }
    }while(0);
    return true;
}

Class getActionClass(__kindof Tling *ling, SEL sel) {
    Class act_class = nil;
    for (Class lingC = object_getClass(ling); act_class == nil && lingC != _class_Tling ; lingC = class_getSuperclass(lingC)) {
        act_class = NSClassFromString([NSString stringWithFormat:@"%@_%@",NSStringFromClass(lingC),NSStringFromSelector(sel)]);
    }
    return act_class;
}

#pragma mark - Public

NSDecimalNumber *ocling_get_decimal(id x) {
    if([x isKindOfClass:NSNumber.class]) {
        return [NSDecimalNumber decimalNumberWithDecimal:[x decimalValue]];
    }
    if([x isKindOfClass:NSString.class]) {
        return [NSDecimalNumber decimalNumberWithString:x];
    }
    if([x isKindOfClass:NSDecimalNumber.class]) return x;
    return nil;
}

NSSet *ocling_mutable_class_map(void) {
    static NSSet *_value;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _value = [NSSet setWithObjects:
                  NSMutableArray.class,
                  NSMutableDictionary.class,
                  NSMutableSet.class,
                  NSMutableData.class,
                  NSMutableIndexSet.class,
                  NSMutableAttributedString.class,
                  NSMutableParagraphStyle.class,
                  NSMutableOrderedSet.class,
                  NSMutableURLRequest.class,
                  NSMutableCharacterSet.class,
                  nil];
    });
    return _value;
}

/// 常用方法，提速
id ocling_mutablecopy_ifneed(id x) {
    if(!x) return nil;
    Class c = object_getClass(x);
    if([ocling_mutable_class_map() containsObject:c]) {
        return x;
    }
    if([c isSubclassOfClass:NSString.class]) {
        // 可变字符串的特殊判断
        if([x copy] != x) return x;
    }
    return [x mutableCopy];
}

bool ocling_is_mutableobject(id x) {
    Class c = object_getClass(x);
    if([ocling_mutable_class_map() containsObject:c]) {
        return x;
    }
    if([c isSubclassOfClass:NSString.class]) {
        // 可变字符串的特殊判断
        if([x copy] != x) return true;
    }
    return false;
}

NSString *_Nullable ocling_to_string(id x) {
    if(!x) return nil;
    Class c = object_getClass(x);
    if([c isSubclassOfClass:NSString.class]) {
        return x;
    }
    if(class_respondsToSelector(c, @selector(stringValue))) {
        return [x stringValue];
    }
    return [x description];
}

NSNumber *_Nullable ocling_to_number(id x) {
    if(!x) return nil;
    Class c = object_getClass(x);
    if([c isSubclassOfClass:NSNumber.class]) {
        return x;
    }
    if([c isSubclassOfClass:NSString.class]) {
        return [NSDecimalNumber decimalNumberWithString:x];
    }
    return nil;
}

const char *ocling_encForKey(id x, NSString *k) {
    if(!x && !k) return NULL;
    objc_property_t pt = class_getProperty(object_getClass(x), k.UTF8String);
    return property_getAttributes(pt);
}


#pragma mark - ObjclingTypeEnc

static NSMutableDictionary <NSString *, ObjclingTypeEnc*>* _cached_enc_prototype;

@interface ObjclingTypeEnc ()

@property (nullable,nonatomic,weak) ObjclingTypeEnc *prototype;

@end

@implementation ObjclingTypeEnc
@synthesize enc = _enc;
@synthesize clazz = _clazz;
@synthesize isObject = _isObject;
@synthesize isClass = _isClass;
@synthesize isIMP = _isIMP;
@synthesize isSEL = _isSEL;
@synthesize isPointer = _isPointer;
@synthesize isCString = _isCString;
@synthesize isCNumber = _isCNumber;
@synthesize isFloatKind = _isFloatKind;
@synthesize isDouble = _isDouble;
@synthesize isFloat = _isFloat;
@synthesize isIntKind = _isIntKind;
@synthesize isUnsignedLong = _isUnsignedLong;
@synthesize isUnsignedLongLong = _isUnsignedLongLong;
@synthesize isLong = _isLong;
@synthesize isLongLong = _isLongLong;
@synthesize isInt = _isInt;
@synthesize isUnsignedInt = _isUnsignedInt;
@synthesize isShort = _isShort;
@synthesize isBOOL = _isBOOL;
@synthesize isBool = _isBool;
@synthesize isChar = _isChar;
@synthesize isUnsignedChar = _isUnsignedChar;
@synthesize isUnsignedShort = _isUnsignedShort;
@synthesize isStruct = _isStruct;
@synthesize isCGRect = _isCGRect;
@synthesize isCGPoint = _isCGPoint;
@synthesize isCGSize = _isCGSize;
@synthesize isNSRange = _isNSRange;
@synthesize isUIEdgeInsets = _isUIEdgeInsets;
@synthesize isCGVector = _isCGVector;
@synthesize isUIOffset = _isUIOffset;
@synthesize isCATransform3D = _isCATransform3D;
@synthesize isCGAffineTransform = _isCGAffineTransform;
@synthesize isNSDirectionalEdgeInsets = _isNSDirectionalEdgeInsets;
@synthesize protocols = _protocols;

+ (void)initialize {
    if(self != [ObjclingTypeEnc class]) return;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cached_enc_prototype = [NSMutableDictionary dictionary];
    });
}

- (instancetype)initWithEnc:(const char *)enc {
    if(self = [super init]) {
        self.prototype = [self.class getPrototypeWithEnc:enc];
    }
    return self;
}

+ (instancetype)getPrototypeWithEnc:(const char *)enc {
    NSString *k = [NSString.alloc initWithCString:enc encoding:(NSUTF8StringEncoding)];
    ObjclingTypeEnc *prototype  =  _cached_enc_prototype[k];
    if(prototype) {
        return prototype;
    } else {
        prototype = [[self alloc] initPrototypeWithEnc:enc];
    }
    _cached_enc_prototype[k] = prototype;
    return prototype;
}

- (instancetype)initPrototypeWithEnc:(const char *)enc {
    if(self = [super init]) {
        _enc        = enc;
        _isObject   = false;
        _isClass    = false;
        _isIMP      = false;
        _isSEL      = false;
        _isPointer  = false;
        _isCString  = false;
        _isCNumber  = false;
        _isFloatKind= false;
        _isDouble   = false;
        _isFloat    = false;
        _isIntKind  = false;
        _isUnsignedLong = false;
        _isUnsignedLongLong  = false;
        _isLong      = false;
        _isLongLong  = false;
        _isInt      = false;
        _isUnsignedInt = false;
        _isShort    = false;
        _isBOOL      = false;
        _isBool      = false;
        _isChar      = false;
        _isUnsignedChar  = false;
        _isUnsignedShort = false;
        _isStruct   = false;
        _isCGRect   = false;
        _isCGPoint  = false;
        _isCGSize   = false;
        _isNSRange  = false;
        _isUIEdgeInsets = false;
        _isCGVector  = false;
        _isUIOffset  = false;
        _isCATransform3D     = false;
        _isCGAffineTransform = false;
        _isNSDirectionalEdgeInsets = false;
        [self deEnc];
    }
    return self;
}

/// 解析
- (void)deEnc {
    NSString *code  = nil;
    NSString *ats   = [NSString.alloc initWithCString:_enc encoding:NSUTF8StringEncoding];
    NSUInteger doc  = [ats rangeOfString:@","].location;
    NSUInteger loc  = 1;
    if (doc == NSNotFound) {
        code = [ats substringFromIndex:loc];
    } else {
        code = [ats substringWithRange:NSMakeRange(loc, doc - loc)];
    }
    /// T@"UIView",
    const char *objcType = [code UTF8String];
    if(strcmp(objcType, @encode(void)) == 0){
        _isVoid = true;
        return;
    }
    //常量则位移到类型符
    if (objcType[0] == _C_CONST) objcType++;
    if (objcType[0] == _C_ID) { //id and block
        _isObject = true;
        NSString *clzzNam;
        if (code.length > 3 && [code hasPrefix:@"@\""]) {
            /// 截取引号内类型部分
            code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
            NSUInteger locPco = [code rangeOfString:@"<"].location;
            if(locPco != NSNotFound) {
                // 1. UIView<UITableViewDelegate><UITableViewDataSource>
                // 2. <UITableViewDelegate><UITableViewDataSource>
                if(locPco > 0) {
                    clzzNam = [code substringToIndex:locPco];
                }
                NSString *pcostr = [code substringFromIndex:locPco];
                NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"<>"];//切协议
                NSMutableArray *pcoarr = [pcostr componentsSeparatedByCharactersInSet:cset].mutableCopy;
                [pcoarr removeObject:@""];
                for (NSInteger i = 0; i < pcoarr.count; i++) {
                    pcoarr[i] = NSProtocolFromString(pcoarr[i]);
                }
                _protocols = [pcoarr copy];
            } else {
                clzzNam = code;
            }
        } /// else { /// @ 或 @? }
        if(clzzNam) {
            _clazz = NSClassFromString(clzzNam);
            _typeName = clzzNam;
        } else {
            _typeName = @"id";
        }
    } else if (strcmp(objcType, @encode(Class)) == 0) {       //Class
        _typeName   = @"Class";
        _isClass    = true;
    } else if (strcmp(objcType, @encode(IMP)) == 0 ) {         //IMP
        _typeName   = @"IMP";
        _isIMP      = true;
    } else if (strcmp(objcType, @encode(SEL)) == 0) {         //SEL
        _typeName   = @"SEL";
        _isSEL      = true;
    } else if (strcmp(objcType, @encode(double)) == 0) {       //double
        _typeName   = @"double";
        _isDouble   = true;
        _isFloatKind= true;
        _isCNumber  = true;
    } else if (strcmp(objcType, @encode(float)) == 0) {       //float
        _typeName   = @"float";
        _isFloat    = true;
        _isFloatKind= true;
        _isCNumber  = true;
    } else if (objcType[0] == '^') {                           //pointer ( and const pointer)
        _typeName   = @"pointer";
        _isPointer  = true;
    } else if (strcmp(objcType, @encode(char *)) == 0) {      //char* (and const char*)
        _typeName   = @"cstring";
        _isCString  = true;
    } else if (strcmp(objcType, @encode(unsigned long)) == 0) {
        _typeName   = @"unsigned long";
        _isUnsignedLong = true;
        _isIntKind  = true;
        _isCNumber  = true;
    } else if (strcmp(objcType, @encode(unsigned long long)) == 0) {
        _typeName   = @"unsigned long long";
        _isUnsignedLongLong = true;
        _isIntKind  = true;
        _isCNumber  = true;
    } else if (strcmp(objcType, @encode(long)) == 0) {
        _typeName   = @"long";
        _isLong     = true;
        _isIntKind  = true;
        _isCNumber  = true;
    } else if (strcmp(objcType, @encode(long long)) == 0) {
        _typeName   = @"long long";
        _isLongLong = true;
        _isIntKind  = true;
        _isCNumber  = true;
    } else if (strcmp(objcType, @encode(int)) == 0) {
        _typeName   = @"int";
        _isInt      = true;
        _isIntKind  = true;
        _isCNumber  = true;
    } else if (strcmp(objcType, @encode(unsigned int)) == 0) {
        _typeName       = @"unsigned int";
        _isUnsignedInt  = true;
        _isIntKind  = true;
        _isCNumber  = true;
    } else if ((strcmp(objcType, @encode(bool)) == 0          ||
               strcmp(objcType, @encode(BOOL)) == 0           ||
               strcmp(objcType, @encode(char)) == 0           ||
               strcmp(objcType, @encode(short)) == 0          ||
               strcmp(objcType, @encode(unsigned char)) == 0  ||
               strcmp(objcType, @encode(unsigned short)) == 0)) {
        _typeName   = @"short";
        _isBOOL     = true;
        _isBool     = true;
        _isShort    = true;
        _isChar     = true;
        _isUnsignedChar = true;
        _isUnsignedShort= true;
        _isIntKind  = true;
        _isCNumber  = true;
    } else{
        //struct union and array
        if (strcmp(objcType, @encode(CGRect)) == 0) {
            _typeName = @"CGRect";
            _isStruct = true;
            _isCGRect = true;
        } else if (strcmp(objcType, @encode(CGPoint)) == 0) {
            _typeName = @"CGPoint";
            _isStruct = true;
            _isCGPoint= true;
        } else if (strcmp(objcType, @encode(CGSize)) == 0) {
            _typeName = @"CGSize";
            _isStruct = true;
            _isCGSize = true;
        } else if (strcmp(objcType, @encode(NSRange)) == 0) {
            _typeName = @"NSRange";
            _isStruct = true;
            _isNSRange= true;
        } else if (strcmp(objcType, @encode(UIEdgeInsets)) == 0) {
            _typeName = @"UIEdgeInsets";
            _isStruct = true;
            _isUIEdgeInsets = true;
        } else if (strcmp(objcType, @encode(CGVector)) == 0) {
            _typeName = @"CGVector";
            _isStruct = true;
            _isCGVector = true;
        } else if (strcmp(objcType, @encode(UIOffset)) == 0) {
            _typeName = @"UIOffset";
            _isStruct = true;
            _isUIOffset = true;
        } else if (strcmp(objcType, @encode(CATransform3D)) == 0) {
            _typeName = @"CATransform3D";
            _isStruct = true;
            _isCATransform3D = true;
        } else if (strcmp(objcType, @encode(CGAffineTransform)) == 0) {
            _typeName = @"CGAffineTransform";
            _isStruct = true;
            _isCGAffineTransform = true;
        }
        if (@available(iOS 11.0, *)) {
            if(strcmp(objcType, @encode(NSDirectionalEdgeInsets)) == 0) {
                _typeName = @"NSDirectionalEdgeInsets";
                _isStruct = true;
                _isNSDirectionalEdgeInsets = true;
            }
        }
    }
}

- (BOOL)isEqual:(ObjclingTypeEnc *)object {
    return strcmp(object.enc, self.prototype.enc) == 0 ? true : false;
}

- (const char *)enc {
    return self.prototype.enc;
}

- (Class)clazz {
    return self.prototype.clazz;
}

- (bool)isObject {
    return self.prototype.isObject;
}

- (bool)isClass {
    return self.prototype.isClass;
}

- (bool)isIMP {
    return self.prototype.isIMP;
}

- (bool)isSEL {
    return self.prototype.isSEL;
}

- (bool)isPointer {
    return self.prototype.isPointer;
}

- (bool)isCString {
    return self.prototype.isCString;
}

- (bool)isCNumber {
    return self.prototype.isCNumber;
}

- (bool)isFloatKind {
    return self.prototype.isFloatKind;
}

- (bool)isDouble {
    return self.prototype.isDouble;
}

- (bool)isFloat {
    return self.prototype.isFloat;
}

- (bool)isIntKind {
    return self.prototype.isIntKind;
}

- (bool)isUnsignedLong {
    return self.prototype.isUnsignedLong;
}

- (bool)isUnsignedLongLong {
    return self.prototype.isUnsignedLongLong;
}

- (bool)isLong {
    return self.prototype.isLong;
}

- (bool)isLongLong {
    return self.prototype.isLongLong;
}

- (bool)isInt {
    return self.prototype.isInt;
}

- (bool)isUnsignedInt {
    return self.prototype.isUnsignedInt;
}

- (bool)isShort {
    return self.prototype.isShort;
}

- (bool)isBOOL {
    return self.prototype.isBOOL;
}

- (bool)isBool {
    return self.prototype.isBool;
}

- (bool)isChar {
    return self.prototype.isChar;
}

- (bool)isUnsignedChar {
    return self.prototype.isUnsignedChar;
}

- (bool)isUnsignedShort {
    return self.prototype.isUnsignedShort;
}

- (bool)isStruct {
    return self.prototype.isStruct;
}

- (bool)isCGRect {
    return self.prototype.isCGRect;
}

- (bool)isCGPoint {
    return self.prototype.isCGPoint;
}

- (bool)isCGSize {
    return self.prototype.isCGSize;
}

- (bool)isNSRange {
    return self.prototype.isNSRange;
}

- (bool)isUIEdgeInsets {
    return self.prototype.isUIEdgeInsets;
}

- (bool)isCGVector {
    return self.prototype.isCGVector;
}

- (bool)isUIOffset {
    return self.prototype.isUIOffset;
}

- (bool)isCATransform3D {
    return self.prototype.isCATransform3D;
}

- (bool)isCGAffineTransform {
    return self.prototype.isCGAffineTransform;
}

- (bool)isNSDirectionalEdgeInsets {
    return self.prototype.isNSDirectionalEdgeInsets;
}

- (void)switchedForCaseVoid:(void(^)(void))caseVoid
                     caseId:(void(^)(void))caseId
                  caseClass:(void(^)(void))caseClass
                    caseIMP:(void(^)(void))caseIMP
                    caseSEL:(void(^)(void))caseSEL
                 caseDouble:(void(^)(void))caseDouble
                  caseFloat:(void(^)(void))caseFloat
                casePointer:(void(^)(void))casePointer
                caseCString:(void(^)(void))caseCString
           caseUnsignedLong:(void(^)(void))caseUnsignedLong
       caseUnsignedLongLong:(void(^)(void))caseUnsignedLongLong
                   caseLong:(void(^)(void))caseLong
               caseLongLong:(void(^)(void))caseLongLong
                    caseInt:(void(^)(void))caseInt
            caseUnsignedInt:(void(^)(void))caseUnsignedInt
          caseBOOLShortChar:(void(^)(void))caseBOOLShortChar
                 caseCGRect:(void(^)(void))caseCGRect
                caseNSRange:(void(^)(void))caseNSRange
                 caseCGSize:(void(^)(void))caseCGSize
                caseCGPoint:(void(^)(void))caseCGPoint
               caseCGVector:(void(^)(void))caseCGVector
           caseUIEdgeInsets:(void(^)(void))caseUIEdgeInsets
               caseUIOffset:(void(^)(void))caseUIOffset
          caseCATransform3D:(void(^)(void))caseCATransform3D
      caseCGAffineTransform:(void(^)(void))caseCGAffineTransform
caseNSDirectionalEdgeInsets:(void(^)(void))caseNSDirectionalEdgeInsets
                    defaule:(void(^)(void))defaule {
    ObjclingTypeEnc *pro = self.prototype;
    if(caseId && pro.isObject)  { caseId();     return; }
    
    if(pro.isCNumber) {
        if(pro.isFloatKind) {
            if(caseDouble && pro.isDouble) { caseDouble();   return; }
            if(caseFloat && pro.isFloat)   { caseFloat();    return; }
        } else {
            if(caseUnsignedLong && pro.isUnsignedLong) { caseUnsignedLong();   return; }
            if(caseUnsignedLongLong && pro.isUnsignedLongLong) { caseUnsignedLongLong();   return; }
            if(caseLong && pro.isLong)     { caseLong();   return; }
            if(caseLongLong && pro.isLongLong) { caseLongLong();   return; }
            if(caseInt && pro.isInt) { caseInt();   return; }
            if(caseUnsignedInt && pro.isUnsignedInt) { caseUnsignedInt();   return; }
            if(caseBOOLShortChar && pro.isShort) { caseBOOLShortChar();   return; }
        }
    }
    
    if(pro.isStruct) {
        if(caseCGRect && pro.isCGRect) { caseCGRect();   return; }
        if(caseNSRange && pro.isNSRange) { caseNSRange();   return; }
        if(caseCGSize && pro.isNSRange) { caseCGSize();   return; }
        if(caseCGPoint && pro.isCGPoint) { caseCGPoint();   return; }
        if(caseCGVector && pro.isCGVector) { caseCGVector();   return; }
        if(caseUIEdgeInsets && pro.isUIEdgeInsets) { caseUIEdgeInsets();   return; }
        if(caseUIOffset && pro.isUIOffset) { caseUIOffset();   return; }
        if(caseCATransform3D && pro.isCATransform3D) { caseCATransform3D();   return; }
        if(caseCGAffineTransform && pro.isCGAffineTransform) { caseCGAffineTransform();   return; }
        if(caseNSDirectionalEdgeInsets && pro.isNSDirectionalEdgeInsets) { caseNSDirectionalEdgeInsets();   return; }
    }
    
    if(caseCString && pro.isCString) { caseCString();   return; }
    if(caseClass && pro.isClass){ caseClass();  return; }
    if(caseIMP && pro.isIMP)    { caseIMP();    return; }
    if(caseSEL && pro.isSEL)    { caseSEL();    return; }
    if(casePointer && pro.isPointer) { casePointer();   return; }
    if(caseVoid && pro.isVoid)  { caseVoid();   return; }
    if(defaule) defaule();
}

- (void)switchUsingBlocks {
    ObjclingTypeEnc *pro = self.prototype;
    if(_casedId && pro.isObject)  { _casedId();     return; }
    
    if(pro.isCNumber) {
        if(_casedCNumber) _casedCNumber();
        if(pro.isFloatKind) {
            if(_casedFloatKind) _casedFloatKind();
            if(_casedDouble && pro.isDouble) { _casedDouble();   return; }
            if(_casedFloat && pro.isFloat)   { _casedFloat();    return; }
        } else {
            if(_casedIntKind) _casedIntKind();
            if(_casedUnsignedLong && pro.isUnsignedLong) { _casedUnsignedLong();   return; }
            if(_casedUnsignedLongLong && pro.isUnsignedLongLong) { _casedUnsignedLongLong();   return; }
            if(_casedLong && pro.isLong)     { _casedLong();   return; }
            if(_casedLongLong && pro.isLongLong) { _casedLongLong();   return; }
            if(_casedInt && pro.isInt) { _casedInt();   return; }
            if(_casedUnsignedInt && pro.isUnsignedInt) { _casedUnsignedInt();   return; }
            if(_casedBOOLShortChar && pro.isShort) { _casedBOOLShortChar();   return; }
        }
    }
    
    if(pro.isStruct) {
        if(_casedStruct) _casedStruct();
        if(_casedCGRect && pro.isCGRect) { _casedCGRect();   return; }
        if(_casedNSRange && pro.isNSRange) { _casedNSRange();   return; }
        if(_casedCGSize && pro.isNSRange) { _casedCGSize();   return; }
        if(_casedCGPoint && pro.isCGPoint) { _casedCGPoint();   return; }
        if(_casedCGVector && pro.isCGVector) { _casedCGVector();   return; }
        if(_casedUIEdgeInsets && pro.isUIEdgeInsets) { _casedUIEdgeInsets();   return; }
        if(_casedUIOffset && pro.isUIOffset) { _casedUIOffset();   return; }
        if(_casedCATransform3D && pro.isCATransform3D) { _casedCATransform3D();   return; }
        if(_casedCGAffineTransform && pro.isCGAffineTransform) { _casedCGAffineTransform();   return; }
        if(_casedNSDirectionalEdgeInsets && pro.isNSDirectionalEdgeInsets) { _casedNSDirectionalEdgeInsets();   return; }
    }
    
    if(_casedCString && pro.isCString) { _casedCString();   return; }
    if(_casedClass && pro.isClass){ _casedClass();  return; }
    if(_casedIMP && pro.isIMP)    { _casedIMP();    return; }
    if(_casedSEL && pro.isSEL)    { _casedSEL();    return; }
    if(_casedPointer && pro.isPointer) { _casedPointer();   return; }
    if(_casedVoid && pro.isVoid)  { _casedVoid();   return; }
    if(_casedDefault) _casedDefault();
}
@end
