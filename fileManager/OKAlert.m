//
//  OKAlert.m
//  Homework_UITableView
//
//  Created by Oleksandr Kurtsev on 27.07.17.
//  Copyright © 2017 Oleksandr Kurtsev. All rights reserved.
//

#import "OKAlert.h"

@implementation OKAlert

+ (UIAlertController*)nilAlert {
    
    NSString* title = [NSString stringWithFormat:@"Folder name is empty"];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       nil;
                                                   }];
    
    [alert addAction:action];
    return alert;
}

+ (UIAlertController*)nameAlreadyInUseAlert:(NSString*)name {
    
    NSString* title = [NSString stringWithFormat:@"Name ''%@'' is already in use.", name];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       nil;
                                                   }];
    
    [alert addAction:action];
    return alert;
}

+ (UIAlertController*)infoAlertWithPath:(NSString*)path name:(NSString*)name isDerectory:(BOOL)derectory {
    
    NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];

    static NSDateFormatter* dataFormatter = nil;
    if (!dataFormatter) {
        dataFormatter = [NSDateFormatter new];
        [dataFormatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    }
    
    NSString* title;
    NSString* size;
    
    if (derectory) {
        title = @"Folder Info :";
        size = [NSString stringWithFormat:@"Size : %@", [self fileSizeFromValue:[self fastFolderSizeAtFSRef:path]]];
        
    } else {
        title = @"File Info :";
        size = [NSString stringWithFormat:@"Size : %@", [self fileSizeFromValue:[attributes fileSize]]];
    }
    
    NSString* fileName = [NSString stringWithFormat:@"Name : %@", name];
    
    NSString* creationDate = [NSString stringWithFormat:@"Creation Date : %@",
                                  [dataFormatter stringFromDate:[attributes fileCreationDate]]];
                                  
    NSString* modificationDate = [NSString stringWithFormat:@"Modified Date : %@",
                                      [dataFormatter stringFromDate:[attributes fileModificationDate]]];
    
    NSString* allInfo = [NSString stringWithFormat:@"\n%@\n\n%@\n\n%@\n\n%@", fileName, size, creationDate, modificationDate];

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:allInfo
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       nil;
                                                   }];
    
    [alert addAction:action];
    return alert;
}

+ (NSString*)fileSizeFromValue:(unsigned long long) size {
    
    static NSString* units[] = {@"B", @"KB", @"MB", @"GB", @"TB"};
    static int unitsCount = 5;
    
    int index = 0;
    double fileSize = (double)size;
    
    while (fileSize > 1024 && index < unitsCount) {
        fileSize /= 1024;
        index++;
    }
    return [NSString stringWithFormat:@"%.2f %@", fileSize, units[index]];
}

+ (unsigned long long)fastFolderSizeAtFSRef:(NSString *)theFilePath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    unsigned long long totalSize = 0;
    BOOL  isdirectory;
    NSError *error;
    
    if ([fileManager fileExistsAtPath:theFilePath]) {
        
        NSMutableArray* directoryContents = [[fileManager contentsOfDirectoryAtPath:theFilePath error:&error] mutableCopy];
        
        for (NSString *fileName in directoryContents) {
            
            if (([fileName rangeOfString:@".DS_Store"].location != NSNotFound))
                continue;
            
            NSString *path = [theFilePath stringByAppendingPathComponent:fileName];
            
            if ([fileManager fileExistsAtPath:path isDirectory:&isdirectory] && isdirectory) {
                
                totalSize =  totalSize + [self fastFolderSizeAtFSRef:path];
                
            } else {
                unsigned long long fileSize = [[fileManager attributesOfItemAtPath:path error:&error] fileSize];
                totalSize = totalSize + fileSize;
            }
        }
    }
    return totalSize;
}

@end
