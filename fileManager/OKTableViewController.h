//
//  OKTableViewController.h
//  Homework_UITableView
//
//  Created by Oleksandr Kurtsev on 26.07.17.
//  Copyright © 2017 Oleksandr Kurtsev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OKTableViewController : UITableViewController

@property (nonatomic, strong) NSString* path;

- (IBAction)actionInfoCell:(UIButton *)sender;

@end
