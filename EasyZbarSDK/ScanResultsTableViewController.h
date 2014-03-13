//
//  ScanResultsTableViewController.h
//  EasyZbarSDK
//
//  Created by Andrew Murdoch on 3/13/14.
//  Copyright (c) 2014 RAM4LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanView.h"

@interface ScanResultsTableViewController : UITableViewController

@property BOOL startScanning;
@property BOOL scanMultiple;
@property (nonatomic) SVScanCode scanCode;

@end
