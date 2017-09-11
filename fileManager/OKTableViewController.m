//
//  OKTableViewController.m
//  Homework_UITableView
//
//  Created by Oleksandr Kurtsev on 26.07.17.
//  Copyright © 2017 Oleksandr Kurtsev. All rights reserved.
//

#import "OKTableViewController.h"
#import "UIView+UITableViewCell.h"
#import "OKFolderCell.h"
#import "OKFileCell.h"
#import "OKAlert.h"

@interface OKTableViewController ()

@property (nonatomic, strong) NSArray* contents;
@property (nonatomic, strong) NSString* selectedPath;

@end

@implementation OKTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.path) {
        self.path = @"/Users/kurtsev";
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem* itemRoot = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                                              target:self
                                                                              action:@selector(actionBackToRoot:)];
    
    UIBarButtonItem* itemAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                             target:self
                                                                             action:@selector(actionAddNewFolder:)];
    
    if ([self.navigationController.viewControllers count] > 1) {
   
        NSArray* items = [NSArray arrayWithObjects:itemAdd, itemRoot, nil];
        self.navigationItem.rightBarButtonItems = items;
        
    } else {
        
        self.navigationItem.rightBarButtonItem = itemAdd;
        
    }
}

- (void)setPath:(NSString *)path {
    _path = path;
    NSError* error = nil;
    
    self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [self.tableView reloadData];
    self.navigationItem.title = [self.path lastPathComponent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (BOOL)isDerectoryAtIndexPath:(NSIndexPath*)indexPath {
    
    NSString* fileName = [self.contents objectAtIndex:indexPath.row];
    NSString* filePath = [self.path stringByAppendingPathComponent:fileName];
    
    BOOL isDirectory = NO;
    
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    
    return isDirectory;
}

- (void)createNewFolderWithName:(NSString*)name {
    
    NSString* path = [self.path stringByAppendingPathComponent:name];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
        
        NSMutableArray* tempArray = [NSMutableArray arrayWithArray:self.contents];
        [tempArray addObject:name];
        self.contents = tempArray;
        [self sortedArray];
        
        NSInteger indexFolder = [self.contents indexOfObject:name];
        NSIndexPath* newIndexPath = [NSIndexPath indexPathForItem:indexFolder inSection:0];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        
    } else {
        
        [self presentViewController:[OKAlert nameAlreadyInUseAlert:name] animated:YES completion:nil];
        
    }
}

- (void)deleteFolderOrFileWithName:(NSString*)name andIndexPath:(NSIndexPath*)indexPath {
    
    NSString* path = [self.path stringByAppendingPathComponent:name];
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    
    NSMutableArray* tempArray = [NSMutableArray arrayWithArray:self.contents];
    [tempArray removeObjectAtIndex:indexPath.row];
    self.contents = tempArray;
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
    
}

- (void)sortedArray {
    
    NSMutableArray* folders = [NSMutableArray new];
    NSMutableArray* files = [NSMutableArray new];
    NSMutableArray* array = [NSMutableArray new];
    
    for (int i = 0; i < self.contents.count; i++) {
 
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        BOOL isFolder = [self isDerectoryAtIndexPath:indexPath];
        NSObject* obj = [self.contents objectAtIndex:i];
        
        NSRange range = [(NSString*)obj rangeOfString:@"."];
        
        if (range.location == NSNotFound || range.location != 0) {
            
            if (isFolder) {
                [folders addObject:obj];
            } else {
                [files addObject:obj];
            }
            
        }
    
    }
    
    [array addObjectsFromArray:folders];
    [array addObjectsFromArray:files];
    self.contents = array;
}

#pragma mark - Actions

- (void)actionBackToRoot:(UIBarButtonItem*)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)actionAddNewFolder:(UIBarButtonItem*)sender {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"New Folder"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* createAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        if ([alert.textFields objectAtIndex:0].text.length != 0) {
            [self createNewFolderWithName:[alert.textFields objectAtIndex:0].text];
        } else {
            [self presentViewController:[OKAlert nilAlert] animated:YES completion:nil];
        }
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        nil;
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:createAction];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Enter folder name";
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)actionInfoCell:(UIButton *)sender {
    
    UITableViewCell* cell = [sender superCell];
    
    if (cell) {
        
        NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
        NSString* fileName = [self.contents objectAtIndex:indexPath.row];
        NSString* path = [self.path stringByAppendingPathComponent:fileName];
        
        [self presentViewController:[OKAlert infoAlertWithPath:path
                                                          name:fileName
                                                   isDerectory:[self isDerectoryAtIndexPath:indexPath]]
                           animated:YES
                         completion:nil];
        
    }
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self sortedArray];
    return self.contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self sortedArray];
    
    static NSString* fileIdentifier = @"FileCell";
    static NSString* folderIdentifier = @"FolderCell";
    
    NSString* fileName = [self.contents objectAtIndex:indexPath.row];
    
    if ([self isDerectoryAtIndexPath:indexPath]) {
        
        OKFolderCell* cell = [tableView dequeueReusableCellWithIdentifier:folderIdentifier];
        
        cell.nameLabel.text = fileName;

        return cell;

    } else {
        
        OKFileCell *cell = [tableView dequeueReusableCellWithIdentifier:fileIdentifier];

        cell.nameLabel.text = fileName;
        
        return cell;
        
    }
    
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to delete ?"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        
        NSString* fileName = [self.contents objectAtIndex:indexPath.row];

        [self deleteFolderOrFileWithName:fileName andIndexPath:indexPath];
        
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        
        [tableView reloadData];
        
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    
    [self presentViewController:alert animated:YES completion:nil];

}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self isDerectoryAtIndexPath:indexPath]) {
        
        NSString* fileName = [self.contents objectAtIndex:indexPath.row];
        NSString* path = [self.path stringByAppendingPathComponent:fileName];
        
        self.selectedPath = path;
        [self performSegueWithIdentifier:@"navigateDeep" sender:nil];
    }
    
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    OKTableViewController* vc = segue.destinationViewController;
    vc.path = self.selectedPath;
}

@end
