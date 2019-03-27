//
//  ViewController.m
//  CustomKVC
//
//  Created by yy on 2019/3/27.
//  Copyright © 2019年 1. All rights reserved.
//

#import "ViewController.h"
#import "CCStudent.h"
#import "NSObject+CCKVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CCStudent * s = [[CCStudent alloc] init];
    [s cc_setValue:@"name" forKey:@"name"];
    
    NSLog(@"%@-%@-%@-%@",s->name,s->isName,s->_name,s->_isName);
    
    s->_name   = @"_name";
    s->_isName = @"_isName";
    s->name    = @"name";
    s->isName  = @"isName";
    NSLog(@"%@",[s cc_valueForKey:@"name"]);
}


@end
