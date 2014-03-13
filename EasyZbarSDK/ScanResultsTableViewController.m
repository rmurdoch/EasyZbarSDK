//
//  ScanResultsTableViewController.m
//  EasyZbarSDK
//
//  Created by Andrew Murdoch on 3/13/14.
//  Copyright (c) 2014 RAM4LLC. All rights reserved.
//

#import "ScanResultsTableViewController.h"

@interface ScanResultsTableViewController ()

@end

@implementation ScanResultsTableViewController
{
    NSMutableArray *scanArray;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.startScanning)
        [self startScan];
}

- (void)startScan
{
    self.startScanning = NO;
    scanArray = [NSMutableArray array];
    
    ScanView *scanView = [[ScanView alloc] initWithCode:self.scanCode
                                           withDelegate:self
                                       forMultipleScans:self.scanMultiple
                                                 inView:self.view];
    
    [self presentViewController:scanView.zBarReaderVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return scanArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [scanArray objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma Scan Delegates
- (void)didFinishedScaning:(NSArray *)array
{
    scanArray = [NSMutableArray arrayWithArray:array];
    [self.tableView reloadData];
}

- (void)cancelPressedForScan
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
