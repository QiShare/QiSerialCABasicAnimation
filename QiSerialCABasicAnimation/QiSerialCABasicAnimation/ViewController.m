//
//  ViewController.m
//  QiSerialCABasicAnimation
//
//  Created by QiShare on 2018/9/26.
//  Copyright © 2018年 qishare. All rights reserved.
//

#import "ViewController.h"
#import "QiGridView.h"

@interface ViewController()

@property (nonatomic, strong) UILabel *label;//!< Demo中移动的方块

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self initViews];
    [self setupButton];//!< 设置按钮
}


#pragma mark - 设置按钮点击事件

- (void)startAnimaButtonClicked:(UIButton *)sender {
    
    /******************* 一、有无Group区别： *****************/
//    [self demo1];//!> 1.无Group：所有动画同时进行
    [self demo2];//!> 2.有Group：group的duration对所有动画产生约束（或者说截取）
    
    
    /******************** 二、动画串行效果： *******************/
//    [self demo3];//!> 3.通过afterDelay控制线程->达到动画串行效果
//    [self demo4];//!> 4.通过GCD控制线程->达到动画串行效果
}

//！ 1.无Group：所有动画同时进行
- (void)demo1 {
    
    NSValue *yFromValue = @(CGRectGetMidY(_label.frame));
    NSValue *xFromValue = @(CGRectGetMidX(_label.frame));
    
    // 如果给某layer添加两个时间不同基础动画
    /**
     * 动画会执行完毕，不同的动画同时执行，然后剩余的时间继续执行剩余动画
     */
    CABasicAnimation *xBasiAnima = [self qiBasicAnimationWithKeyPath:@"position.x" fromValue:xFromValue byValue:@([UIScreen mainScreen].bounds.size.width / 3 * 2) toValue:nil duration:3.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    [_label.layer addAnimation:xBasiAnima forKey:@"postion.x"];
    
    CABasicAnimation *yBasiAnima = [self qiBasicAnimationWithKeyPath:@"position.y" fromValue:yFromValue byValue:@([UIScreen mainScreen].bounds.size.height / 4) toValue:nil duration:1.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    [_label.layer addAnimation:yBasiAnima forKey:@"postion.y"];
    
    CABasicAnimation *opacityAnima = [self qiBasicAnimationWithKeyPath:@"opacity" fromValue:@1.0 byValue:@(-0.5) toValue:nil duration:2.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    [_label.layer addAnimation:opacityAnima forKey:@"opacity"];
}


//! 2.有Group：group的duration对所有动画产生约束（或者说截取）
- (void)demo2 {
    
    NSValue *xFromValue = @(CGRectGetMidX(_label.frame));
    CABasicAnimation *xBasiAnima = [self qiBasicAnimationWithKeyPath:@"position.x" fromValue:xFromValue byValue:@([UIScreen mainScreen].bounds.size.width / 3 * 2) toValue:nil duration:3.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    
    NSValue *yFromValue = @(CGRectGetMidY(_label.frame));
    CABasicAnimation *yBasiAnima = [self qiBasicAnimationWithKeyPath:@"position.y" fromValue:yFromValue byValue:@([UIScreen mainScreen].bounds.size.height / 4) toValue:nil duration:1.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    
    CABasicAnimation *alphaAnima = [self qiBasicAnimationWithKeyPath:@"opacity" fromValue:@(1.0) byValue:@(-0.5) toValue:nil duration:1.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    
    CAAnimationGroup *groupAnima = [CAAnimationGroup animation];
    groupAnima.removedOnCompletion = NO;
    groupAnima.fillMode = kCAFillModeForwards;
    groupAnima.animations = @[xBasiAnima, yBasiAnima, alphaAnima];
    groupAnima.duration = 2.0;
    
    [_label.layer addAnimation:groupAnima forKey:nil];
}

//! 3.通过afterDelay控制线程->达到动画串行效果
- (void)demo3 {
    
    [self toBottom];
    [self performSelector:@selector(toRight) withObject:self afterDelay:1.0];
    [self performSelector:@selector(toTop) withObject:self afterDelay:2.0];
    [self performSelector:@selector(toLeft) withObject:self afterDelay:3.0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.label.text = @"QiShare";
    });
}

//! 4.通过GCD控制线程->达到动画串行效果
- (void)demo4 {
    
    // a)创建串行队列
    dispatch_queue_t serialQue = dispatch_queue_create("com.qishare.serialQueue", DISPATCH_QUEUE_SERIAL);
    
    // 1)动作一：向下
    dispatch_async(serialQue, ^{
        
        [NSThread sleepForTimeInterval:1.0];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self toBottom];
        });
    });
    
    // 2)动作二：向右
    dispatch_async(serialQue, ^{
        
        [NSThread sleepForTimeInterval:1.0];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self toRight];
        });
    });
    
    // 3)动作三：向上
    dispatch_async(serialQue, ^{
        
        [NSThread sleepForTimeInterval:1.0];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self toTop];
        });
    });
    
    // 4)动作四：向左
    dispatch_async(serialQue, ^{
        [NSThread sleepForTimeInterval:1.0];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self toLeft];
        });
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.label.text = @"QiShare";
    });
}


#pragma mark - 基本动作：上下左右

- (void)toTop {
    
    _label.text = @"QiShare向上";
    NSValue *fromValue = @(CGRectGetMidY(_label.frame) + (CGRectGetHeight(self.view.frame) / QiGridViewRow * (QiGridViewRow - 1)));
    NSValue *byValue = @(-(CGRectGetHeight(self.view.frame) / QiGridViewRow * (QiGridViewRow - 1)));
    CABasicAnimation *topAnima = [self qiBasicAnimationWithKeyPath:@"position.y" fromValue:fromValue byValue:byValue toValue:nil duration:1.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    [_label.layer addAnimation:topAnima forKey:@"position.y"];
}

- (void)toBottom {
    
    _label.text = @"QiShare向下";
    NSValue *fromValue = @(CGRectGetMidY(_label.frame));
    NSValue *byValue = @(CGRectGetHeight(self.view.frame) / QiGridViewRow * (QiGridViewRow - 1));
    CABasicAnimation *downAnima = [self qiBasicAnimationWithKeyPath:@"position.y" fromValue:fromValue byValue:byValue toValue:nil duration:1.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    [_label.layer addAnimation:downAnima forKey:@"position.y"];
}

- (void)toLeft {
    
    _label.text = @"QiShare向左";
    NSValue *fromValue = @(CGRectGetMidX(_label.frame) + CGRectGetWidth(self.view.frame) / QiGridViewCol * (QiGridViewCol - 1));
    NSValue *byValue = @(-(CGRectGetWidth(self.view.frame) / QiGridViewCol * (QiGridViewCol - 1)));
    CABasicAnimation *leftAnimation = [self qiBasicAnimationWithKeyPath:@"position.x" fromValue:fromValue byValue:byValue toValue:nil duration:1.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    [_label.layer addAnimation:leftAnimation forKey:@"position.x"];
}

- (void)toRight {
    
    _label.text = @"QiShare向右";
    NSValue *fromValue = @(CGRectGetMidX(_label.frame));
    NSValue *byValue = @(CGRectGetWidth(self.view.frame) / QiGridViewCol * (QiGridViewCol - 1));
    CABasicAnimation *rightAnima = [self qiBasicAnimationWithKeyPath:@"position.x" fromValue:fromValue byValue:byValue toValue:nil duration:1.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    [_label.layer addAnimation:rightAnima forKey:@"position.x"];
}


#pragma mark - UTils

//! 快速创建CABasicAnimation
- (CABasicAnimation *)qiBasicAnimationWithKeyPath:(NSString *)keypath fromValue:(id)fromValue byValue:(id)byValue toValue:(id)toValue duration:(NSTimeInterval)duration fillMode:(NSString *)fillMode removeOnCompletion:(BOOL)removeOnCompletion{
    
    CABasicAnimation *basicAnima = [CABasicAnimation animationWithKeyPath:keypath];
    basicAnima.fromValue = fromValue;
    basicAnima.toValue = toValue;
    basicAnima.byValue = byValue;
    basicAnima.duration = duration;
    basicAnima.fillMode = fillMode;
    basicAnima.removedOnCompletion = removeOnCompletion;
    return basicAnima;
}

- (void)initViews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat lblW = [UIScreen mainScreen].bounds.size.width / QiGridViewCol;
    CGFloat lblH = [UIScreen mainScreen].bounds.size.height / QiGridViewRow;
    
    QiGridView *gridView = [[QiGridView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:gridView];
    gridView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(.0, .0, lblW, lblH)];
    [self.view addSubview:_label];
    
    _label.backgroundColor = [UIColor redColor];
    _label.text = @"QiShare";
    _label.textAlignment = NSTextAlignmentCenter;
    _label.font = [UIFont systemFontOfSize:20.0];
}

- (void)setupButton {
    
    UIButton *startAnimaBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 50.0, [UIScreen mainScreen].bounds.size.height - 60.0, 100.0, 40.0)];
    startAnimaBtn.backgroundColor = [UIColor grayColor];
    [startAnimaBtn setTitle:@"开始动画" forState:UIControlStateNormal];
    [self.view addSubview:startAnimaBtn];
    [startAnimaBtn addTarget:self action:@selector(startAnimaButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}


@end
