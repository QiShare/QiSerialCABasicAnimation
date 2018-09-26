//
//  AppDelegate.m
//  QiSerialCABasicAnimation
//
//  Created by QiShare on 2018/9/26.
//  Copyright © 2018年 qishare. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    _window.rootViewController = [ViewController new];
    [_window makeKeyAndVisible];
    
    return YES;
}


@end
