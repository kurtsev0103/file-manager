//
//  UIView+UITableViewCell.m
//  Homework_UITableView
//
//  Created by Oleksandr Kurtsev on 27.07.17.
//  Copyright © 2017 Oleksandr Kurtsev. All rights reserved.
//

#import "UIView+UITableViewCell.h"

@implementation UIView (UITableViewCell)

- (UITableViewCell*)superCell {

    if (!self.superview) {
        return nil;
    }
    
    if ([self.superview isKindOfClass:[UITableViewCell class]]) {
        return (UITableViewCell*)self.superview;
    }
    
    return [self.superview superCell];
}

@end
