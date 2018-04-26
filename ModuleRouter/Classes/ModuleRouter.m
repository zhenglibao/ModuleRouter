/**
 * Copyright (c) 2018-present, zhenglibao, Inc.
 * email: 798393829@qq.com
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */


#import "ModuleRouter.h"
#import <YYModel/YYModel.h>


@interface ModuleServer : NSObject
@property(nonatomic,copy) ModuleFunc func;
@property(nonatomic,assign) Class paramClass;
@end

@implementation ModuleServer
@end

@interface ModuleRouter()
{
    NSMutableDictionary<NSString*,ModuleServer*>* _moduleFuncs;
}
@end

@implementation ModuleRouter

-(instancetype)init{
    self=[super init];
    if(self){
        _moduleFuncs = [NSMutableDictionary dictionary];
    }
    return self;
}
+(instancetype)instance
{
    static dispatch_once_t once;
    static ModuleRouter* inst=nil;
    dispatch_once(&once, ^{
        inst = [[ModuleRouter alloc] init];
    });
    return inst;
}
-(void)registerFunc:(NSString*)moduleName
           funcName:(NSString*)funcName
         paramClass:(Class)paramClass
               func:(ModuleFunc)func
{
    NSAssert(moduleName!=nil, @"moduleName must be non-nil");
    NSAssert(funcName!=nil, @"funcName must be non-nil");
    NSAssert(func!=nil, @"func must be non-nil");
    
    NSString* key = [moduleName stringByAppendingString:@"/"];
    key = [key stringByAppendingString:funcName];
    
    ModuleServer* server = [ModuleServer new];
    server.func = func;
    server.paramClass = paramClass;
    
    @synchronized(self){
        [_moduleFuncs setValue:server forKey:key];
    }
}

-(void)callFunc:(NSString*)moduleName
       funcName:(NSString*)funcName
          param:(NSDictionary*)param
           func:(ModuleClientResult)func
{
    NSAssert(moduleName!=nil, @"moduleName must be non-nil");
    NSAssert(funcName!=nil, @"funcName must be non-nil");
    
    ModuleServer* moduleServer = nil;
    {
        NSString* key = [moduleName stringByAppendingString:@"/"];
        key = [key stringByAppendingString:funcName];
     
        @synchronized(self){
            moduleServer = [_moduleFuncs valueForKey:key];
        }
        if(moduleServer==nil)
            return;
    }
        
    ModuleServerResult callback = ^(id result,NSError* error)
    {
        if(func==nil)
            return ;
        
        NSDictionary* dicResult = nil;
        if(result!=nil){
            dicResult = [result yy_modelToJSONObject];
        }
        func(dicResult,error);
    };
    id modelParam = param;
    if(moduleServer.paramClass!=nil &&
       param!=nil)
    {
        modelParam = [moduleServer.paramClass yy_modelWithDictionary:param];
    }
    
    moduleServer.func(modelParam, callback);
}

+(void)registerFunc:(NSString*)moduleName
           funcName:(NSString*)funcName
         paramClass:(Class)paramClass
               func:(ModuleFunc)func
{
    [[ModuleRouter instance]registerFunc:moduleName
                                funcName:funcName
                              paramClass:paramClass
                                    func:func];
}
+(void)callFunc:(NSString*)moduleName
       funcName:(NSString*)funcName
          param:(NSDictionary*)param
           func:(ModuleClientResult)func
{
    [[ModuleRouter instance]callFunc:moduleName
                            funcName:funcName
                               param:param
                                func:func];
}
@end
