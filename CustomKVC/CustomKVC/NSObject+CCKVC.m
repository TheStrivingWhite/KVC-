//
//  NSObject+CCKVC.m
//  CustomKVC
//
//  Created by yy on 2019/3/27.
//  Copyright © 2019年 1. All rights reserved.
//

#import "NSObject+CCKVC.h"
#import <objc/runtime.h>

@implementation NSObject (CCKVC)

- (void)cc_setValue:(nullable id)value forKey:(NSString *)key{
    
    // 1:刷选key 判断非空
    if (key == nil  || key.length == 0) {
        return;
    }
    
    // 2:找到相关方法 set<Key> _set<Key> setIs<Key>
    // key 要大写
    NSString *Key = key.capitalizedString;
    // 拼接方法
    NSString *setKey = [NSString stringWithFormat:@"set%@:",Key];
    NSString *_setKey = [NSString stringWithFormat:@"_set%@:",Key];
    NSString *setIsKey = [NSString stringWithFormat:@"setIs%@:",Key];
    
    if ([self performSelectorWithMethodName:setKey value:value]) {
        NSLog(@"*********%@**********",setKey);
        // map
        return;
    }else if ([self performSelectorWithMethodName:_setKey value:value]) {
        NSLog(@"*********%@**********",_setKey);
        return;
    }else if ([self performSelectorWithMethodName:setIsKey value:value]) {
        NSLog(@"*********%@**********",setIsKey);
        return;
    }
    
    // 3:判断是否能够直接赋值实例变量
    if (![self.class accessInstanceVariablesDirectly] ) {
        @throw [NSException exceptionWithName:@"CCUnknownKeyException" reason:[NSString stringWithFormat:@"****[%@ valueForUndefinedKey:]: this class is not key value coding-compliant for the key name.****",self] userInfo:nil];
    }
    
    
    
    // 4.找相关实例变量进行赋值
    // 4.1 定义一个收集实例变量的可变数组
    NSMutableArray *mArray = [self getIvarListName];
    // _<key> _is<Key> <key> is<Key>
    NSString *_key = [NSString stringWithFormat:@"_%@",key];
    NSString *_isKey = [NSString stringWithFormat:@"_is%@",Key];
    NSString *isKey = [NSString stringWithFormat:@"is%@",Key];
    if ([mArray containsObject:_key]) {
        Ivar ivar = class_getInstanceVariable([self class], _key.UTF8String);
        object_setIvar(self , ivar, value);
        return;
    }else if ([mArray containsObject:_isKey]) {
        Ivar ivar = class_getInstanceVariable([self class], _isKey.UTF8String);
        object_setIvar(self , ivar, value);
        return;
    }else if ([mArray containsObject:key]) {
        Ivar ivar = class_getInstanceVariable([self class], key.UTF8String);
        object_setIvar(self , ivar, value);
        return;
    }else if ([mArray containsObject:isKey]) {
        Ivar ivar = class_getInstanceVariable([self class], isKey.UTF8String);
        object_setIvar(self , ivar, value);
        return;
    }
    
    // 5:如果找不到相关实例
    @throw [NSException exceptionWithName:@"CCUnknownKeyException" reason:[NSString stringWithFormat:@"****[%@ %@]: this class is not key value coding-compliant for the key name.****",self,NSStringFromSelector(_cmd)] userInfo:nil];
    
}

- (nullable id)cc_valueForKey:(NSString *)key{
    
    // 1:刷选key 判断非空
    if (key == nil  || key.length == 0) {
        return nil;
    }
    // 2:找到相关方法 get<Key> <key> countOf<Key>  objectIn<Key>AtIndex
    // key 要大写
    NSString *Key = key.capitalizedString;
    // 拼接方法
    NSString *getKey = [NSString stringWithFormat:@"get%@",Key];
    NSString *countOfKey = [NSString stringWithFormat:@"countOf%@",Key];
    NSString *objectInKeyAtIndex = [NSString stringWithFormat:@"objectIn%@AtIndex:",Key];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self respondsToSelector:NSSelectorFromString(getKey)]) {
        return [self performSelector:NSSelectorFromString(getKey)];
    }else if ([self respondsToSelector:NSSelectorFromString(key)]){
        return [self performSelector:NSSelectorFromString(key)];
    }else if ([self respondsToSelector:NSSelectorFromString(countOfKey)]){
        if ([self respondsToSelector:NSSelectorFromString(objectInKeyAtIndex)]) {
            int num = (int)[self performSelector:NSSelectorFromString(countOfKey)];
            NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:1];
            for (int i = 0; i<num-1; i++) {
                num = (int)[self performSelector:NSSelectorFromString(countOfKey)];
            }
            for (int j = 0; j<num; j++) {
                id objc = [self performSelector:NSSelectorFromString(objectInKeyAtIndex) withObject:@(num)];
                [mArray addObject:objc];
            }
            return mArray;
        }
    }
#pragma clang diagnostic pop
    
    // 3:判断是否能够直接赋值实例变量
    if (![self.class accessInstanceVariablesDirectly] ) {
        @throw [NSException exceptionWithName:@"CCUnknownKeyException" reason:[NSString stringWithFormat:@"****[%@ valueForUndefinedKey:]: this class is not key value coding-compliant for the key name.****",self] userInfo:nil];
    }
    
    // 4.找相关实例变量进行赋值
    // 4.1 定义一个收集实例变量的可变数组
    NSMutableArray *mArray = [self getIvarListName];
    // _<key> _is<Key> <key> is<Key>
    // _name -> _isName -> name -> isName
    NSString *_key = [NSString stringWithFormat:@"_%@",key];
    NSString *_isKey = [NSString stringWithFormat:@"_is%@",Key];
    NSString *isKey = [NSString stringWithFormat:@"is%@",Key];
    if ([mArray containsObject:_key]) {
        Ivar ivar = class_getInstanceVariable([self class], _key.UTF8String);
        return object_getIvar(self, ivar);;
    }else if ([mArray containsObject:_isKey]) {
        Ivar ivar = class_getInstanceVariable([self class], _isKey.UTF8String);
        return object_getIvar(self, ivar);;
    }else if ([mArray containsObject:key]) {
        Ivar ivar = class_getInstanceVariable([self class], key.UTF8String);
        return object_getIvar(self, ivar);;
    }else if ([mArray containsObject:isKey]) {
        Ivar ivar = class_getInstanceVariable([self class], isKey.UTF8String);
        return object_getIvar(self, ivar);;
    }
    
    return @"";
}

#pragma mark - 相关方法
- (BOOL)performSelectorWithMethodName:(NSString *)methodName value:(id)value{
    
    if ([self respondsToSelector:NSSelectorFromString(methodName)]) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:NSSelectorFromString(methodName) withObject:value];
#pragma clang diagnostic pop
        return YES;
    }
    return NO;
}

- (id)performSelectorWithMethodName:(NSString *)methodName{
    if ([self respondsToSelector:NSSelectorFromString(methodName)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [self performSelector:NSSelectorFromString(methodName) ];
#pragma clang diagnostic pop
    }
    return nil;
}

- (NSMutableArray *)getIvarListName{
    
    NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:1];
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i<count; i++) {
        Ivar ivar = ivars[i];
        const char *ivarNameChar = ivar_getName(ivar);
        NSString *ivarName = [NSString stringWithUTF8String:ivarNameChar];
        NSLog(@"ivarName == %@",ivarName);
        [mArray addObject:ivarName];
    }
    free(ivars);
    return mArray;
}


@end