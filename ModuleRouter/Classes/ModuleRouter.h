/**
 * Copyright (c) 2018-present, zhenglibao, Inc.
 * email: 798393829@qq.com
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */


#import <Foundation/Foundation.h>

// 调用方使用的回调
typedef void (^ModuleClientResult)(NSDictionary* result,NSError* error);

// 被调用方(功能提供者）使用的回调
typedef void (^ModuleServerResult)(id result,NSError* error);

// 被调用方注册时使用的block
typedef void (^ModuleFunc)(id data,ModuleServerResult onResult);

@interface ModuleRouter : NSObject

// 被调用者（功能提供者注册要提供的功能）
+(void)registerFunc:(NSString*)moduleName
           funcName:(NSString*)funcName
         paramClass:(Class)paramClass
               func:(ModuleFunc)func;

// 调用者调用模块中的方法
+(void)callFunc:(NSString*)moduleName
       funcName:(NSString*)funcName
          param:(NSDictionary*)param
           func:(ModuleClientResult)func;

@end
