//
//  UIViewController+LinkBlock.h
//  LinkBlockProgram
//
//  Created by NOVO on 15/9/8.
//  Copyright (c) 2015年 NOVO. All rights reserved.
//

#import "LinkBlockDefine.h"

#ifndef UIViewControllerNew
#define UIViewControllerNew ([UIViewController new])
#endif
@interface NSObject(UIViewControllerLinkBlock)

#pragma mark - Foundation Mirror/镜像
@property LB_BK UIViewController*    (^vcAddChildVC)(UIViewController* childVC);
@property LB_BK UIViewController*    (^vcTitle)(NSString* title);
@property LB_BK UIViewController*    (^vcNavigationControllerPushVC)(UIViewController* vc);
@property LB_BK UIViewController*    (^vcNavigationControllerPopTo)(UIViewController* vc);
@property LB_BK UIViewController*    (^vcNavigationControllerPop)(void);
@property LB_BK UIViewController*    (^vcHidesBottomBarWhenPushed)(BOOL b);
@property LB_BK UIViewController*    (^vcHidesBottomBarWhenPushedYES)(void);

#pragma mark - Foundation Speed/速度
@property LB_BK UIViewController*    (^vcViewAddSubview)(UIView* view);

@end
