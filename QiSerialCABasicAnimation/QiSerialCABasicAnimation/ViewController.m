//
//  ViewController.m
//  QiSerialCABasicAnimation
//
//  Created by QiShare on 2018/9/26.
//  Copyright © 2018年 qishare. All rights reserved.
//

#import "ViewController.h"
#import "QiGridView.h"

@implementation ViewController {
    
    UILabel *_basicAniLabel; //!> 用于展示基础动画的label
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}


- (void)setupUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat ScreenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat ScreenW = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat lblW = ScreenW / QiGridViewCol;
    CGFloat lblH = ScreenH / QiGridViewRow;
    
    QiGridView *gridView = [[QiGridView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:gridView];
    gridView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    
    _basicAniLabel = [[UILabel alloc] initWithFrame:CGRectMake(.0, .0, lblW, lblH)];
    [self.view addSubview:_basicAniLabel];
    
    _basicAniLabel.backgroundColor = [UIColor redColor];
    _basicAniLabel.text = @"Q·i Share";
    _basicAniLabel.textAlignment = NSTextAlignmentCenter;
    _basicAniLabel.font = [UIFont systemFontOfSize:20.0];
    
    UIButton *startAnimaBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 50.0, ScreenH - 60.0, 100.0, 40.0)];
    [self.view addSubview:startAnimaBtn];
    [startAnimaBtn addTarget:self action:@selector(startAnimaButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    startAnimaBtn.backgroundColor = [UIColor grayColor];
    [startAnimaBtn setTitle:@"开始动画" forState:UIControlStateNormal];
}

- (void)serialQueueAnima {
    
    dispatch_queue_t serialQue = dispatch_queue_create("com.qishare.serialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(serialQue, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self toBottomAnimation];
        });
    });
    dispatch_async(serialQue, ^{
        sleep(2.0);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self toRightAnimation];
        });
    });
    dispatch_async(serialQue, ^{
        sleep(3.0);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self toTopAnimation];
        });
    });
    dispatch_async(serialQue, ^{
        sleep(1.0);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self toLeftAnimation];
        });
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_basicAniLabel.text = @"Q·i Share";
    });
}

/**
 串行动画performSelectorafterDelay
 */
- (void)serialAfterSelectorAnimation {
    
    // 串行实现 围绕着整个屏幕做一圈转圈的动画
    /**
     * 1. performSelectorAfter
     * 2. 串行队列
     */
    [self toBottomAnimation];
    [self performSelector:@selector(toRightAnimation) withObject:self afterDelay:1.0];
    [self performSelector:@selector(toTopAnimation) withObject:self afterDelay:2.0];
    [self performSelector:@selector(toLeftAnimation) withObject:self afterDelay:3.0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_basicAniLabel.text = @"Q·i Share";
    });
}

- (void)toBottomAnimation {
    
    _basicAniLabel.text = @"Q·i Share向下";
    NSValue *fromValue = @(CGRectGetMidY(_basicAniLabel.frame));
    NSValue *byValue = @(CGRectGetHeight(self.view.frame) / QiGridViewRow * (QiGridViewRow - 1));
    CABasicAnimation *downAnima = [self qiBasicAnimationWithKeyPath:@"position.y" fromValue:fromValue byValue:byValue toValue:nil duration:1.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    [_basicAniLabel.layer addAnimation:downAnima forKey:@"position.y"];
}

- (void)toRightAnimation {
    
    _basicAniLabel.text = @"Q·i Share向右";
    NSValue *fromValue = @(CGRectGetMidX(_basicAniLabel.frame));
    NSValue *byValue = @(CGRectGetWidth(self.view.frame) / QiGridViewCol * (QiGridViewCol - 1));
    CABasicAnimation *rightAnima = [self qiBasicAnimationWithKeyPath:@"position.x" fromValue:fromValue byValue:byValue toValue:nil duration:1.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    [_basicAniLabel.layer addAnimation:rightAnima forKey:@"position.x"];
}

- (void)toTopAnimation {
    
    _basicAniLabel.text = @"Q·i Share向上";
    // fromValue的写法 动画是假象
    NSValue *fromValue = @(CGRectGetMidY(_basicAniLabel.frame) + (CGRectGetHeight(self.view.frame) / QiGridViewRow * (QiGridViewRow - 1)));
    NSValue *byValue = @(-(CGRectGetHeight(self.view.frame) / QiGridViewRow * (QiGridViewRow - 1)));
    CABasicAnimation *topAnima = [self qiBasicAnimationWithKeyPath:@"position.y" fromValue:fromValue byValue:byValue toValue:nil duration:1.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    [_basicAniLabel.layer addAnimation:topAnima forKey:@"position.y"];
}

- (void)toLeftAnimation {
    
    _basicAniLabel.text = @"Q·i Share向左";
    NSValue *fromValue = @(CGRectGetMidX(_basicAniLabel.frame) + CGRectGetWidth(self.view.frame) / QiGridViewCol * (QiGridViewCol - 1));
    NSValue *byValue = @(-(CGRectGetWidth(self.view.frame) / QiGridViewCol * (QiGridViewCol - 1)));
    CABasicAnimation *leftAnimation = [self qiBasicAnimationWithKeyPath:@"position.x" fromValue:fromValue byValue:byValue toValue:nil duration:1.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    [_basicAniLabel.layer addAnimation:leftAnimation forKey:@"position.x"];
}



/**
 @brief 给同一个layer添加组动画
 */
- (void)addGroupAnimationToSameLayer {
    
    // 如果给某layer添加两个时间不同基础动画 这个最好有个复位
    /**
     * 动画会执行完毕，不同的动画同时执行，然后剩余的时间继续执行剩余动画
     */
    NSValue *yFromValue = @(CGRectGetMidY(_basicAniLabel.frame));
    CABasicAnimation *yBasiAnima = [self qiBasicAnimationWithKeyPath:@"position.y" fromValue:yFromValue byValue:@([UIScreen mainScreen].bounds.size.height / 4) toValue:nil duration:1.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    
    CABasicAnimation *alphaAnima = [self qiBasicAnimationWithKeyPath:@"opacity" fromValue:@(1.0) byValue:@(-0.5) toValue:nil duration:1.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    
    NSValue *xFromValue = @(CGRectGetMidX(_basicAniLabel.frame));
    CABasicAnimation *xBasiAnima = [self qiBasicAnimationWithKeyPath:@"position.x" fromValue:xFromValue byValue:@([UIScreen mainScreen].bounds.size.width / 3 * 2) toValue:nil duration:2.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    
    CAAnimationGroup *groupAnima = [CAAnimationGroup animation];
    groupAnima.removedOnCompletion = NO;
    groupAnima.fillMode = kCAFillModeForwards;
    groupAnima.animations = @[xBasiAnima, yBasiAnima, alphaAnima];
    groupAnima.duration = 2.0;
    
    [_basicAniLabel.layer addAnimation:groupAnima forKey:nil];
}

/**
 @brief 给同一个layer添加不同时长的动画
 */
- (void)addServeralBasicAnimationToSameLayer {
    
    NSValue *yFromValue = @(CGRectGetMidY(_basicAniLabel.frame));
    NSValue *xFromValue = @(CGRectGetMidX(_basicAniLabel.frame));
    // 如果给某layer添加两个时间不同基础动画
    /**
     * 动画会执行完毕，不同的动画同时执行，然后剩余的时间继续执行剩余动画
     */
    CABasicAnimation *yBasiAnima = [self qiBasicAnimationWithKeyPath:@"position.y" fromValue:yFromValue byValue:@([UIScreen mainScreen].bounds.size.height / 4) toValue:nil duration:1.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    [_basicAniLabel.layer addAnimation:yBasiAnima forKey:@"postion.y"];
    
    CABasicAnimation *xBasiAnima = [self qiBasicAnimationWithKeyPath:@"position.x" fromValue:xFromValue byValue:@([UIScreen mainScreen].bounds.size.width / 3 * 2) toValue:nil duration:2.0 fillMode:kCAFillModeForwards removeOnCompletion:NO];
    [_basicAniLabel.layer addAnimation:xBasiAnima forKey:@"postion.x"];
}


#pragma mark - Actions

- (void)startAnimaButtonClicked:(UIButton *)sender {
    
    // 给layer添加组动画
//    [self addGroupAnimationToSameLayer];
//    return;
    
    // 添加多个到同一个layer
//    [self addServalBasicAnimationToSameLayer];
//    return;
    
    // 串行队列动画
//    [self serialQueueAnima];
//    return;
    
    // 串行动画afterSelector
    [self serialAfterSelectorAnimation];
}

#pragma mark - UTils

/**
 @brief 快速创建基础动画
 */
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


@end
