//
//  OKAlert.h
//  Homework_UITableView
//
//  Created by Oleksandr Kurtsev on 27.07.17.
//  Copyright © 2017 Oleksandr Kurtsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OKAlert : NSObject

+ (UIAlertController*)nilAlert;
+ (UIAlertController*)nameAlreadyInUseAlert:(NSString*)name;
+ (UIAlertController*)infoAlertWithPath:(NSString*)path name:(NSString*)name isDerectory:(BOOL)derectory;

@end
