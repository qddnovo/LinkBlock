//
//  NSURL+LinkBlock.h
//  LinkBlockProgram
//
//  Created by NOVO on 15/9/3.
//  Copyright (c) 2015年 NOVO. All rights reserved.
//

#import "LinkBlockDefine.h"

@interface NSObject(NSURLLinkBlock)
/** <^()>系统照片url转图像，缩略图 */
LBDeclare UIImage*         (^urlAssetsToUIImageByThumbnail)(void);
/** <^()>系统照片url转图像，高清图 */
LBDeclare UIImage*         (^urlAssetsToUIImageByFullResolution)(void);
/** <^()>系统照片url转图像，全屏相片 */
LBDeclare UIImage*         (^urlAssetsToUIImageByFullScreen)(void);
/** <^()> */
LBDeclare NSData*          (^urlToNSDataFromContents)(void);
@end
