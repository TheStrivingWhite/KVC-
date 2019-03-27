//
//  NSObject+CCKVC.h
//  CustomKVC
//
//  Created by yy on 2019/3/27.
//  Copyright © 2019年 1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CCKVC)

- (void)cc_setValue:(nullable id)value forKey:(NSString *)key;

- (nullable id)cc_valueForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
