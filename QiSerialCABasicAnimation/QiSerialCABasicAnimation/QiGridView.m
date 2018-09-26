//
//  QiGridView.m
//  QiCABasicAnimation
//
//  Created by QiShare on 2018/9/25.
//  Copyright © 2018年 qishare. All rights reserved.
//
// 参考学习网址 : http://www.cocoachina.com/bbs/read.php?tid-109560.html

#import "QiGridView.h"

NSInteger const QiGridViewRow = 4;
NSInteger const QiGridViewCol = 3;

@implementation QiGridView

- (void)drawRect:(CGRect)rect {
    
    CGFloat positionY = .0;
    CGFloat positionX = .0;
    
    CGContextRef currentRef = UIGraphicsGetCurrentContext();
    for (NSInteger j = 1; j < QiGridViewCol; j ++) {
        positionY = rect.size.height;
        positionX += rect.size.width / QiGridViewCol;
        CGContextMoveToPoint(currentRef, positionX, 0);
        CGContextAddLineToPoint(currentRef, positionX, positionY);
        CGContextSetLineWidth(currentRef, 1.0);
        [[UIColor colorWithRed:(arc4random() % 256 / 255.0) green:(arc4random() % 256 / 255.0) blue:(arc4random() % 256 / 255.0) alpha:1.0] setStroke];
        CGContextStrokePath(currentRef);
    }
    
    positionY = .0;
    for (NSInteger i = 1; i < QiGridViewRow; i++) {
        positionY += rect.size.height / QiGridViewRow;
        positionX = rect.size.width;
        CGContextMoveToPoint(currentRef, 0, positionY);
        CGContextAddLineToPoint(currentRef, positionX, positionY);
        [[UIColor colorWithRed:(arc4random() % 256 / 255.0) green:(arc4random() % 256 / 255.0) blue:(arc4random() % 256 / 255.0) alpha:1.0] setStroke];
        CGContextStrokePath(currentRef);
    }
    
    /**
        CGContextSetLineWidth(ref, 1.0);
        [[UIColor grayColor] setStroke];
        CGContextStrokePath(ref);
     */
}


@end
