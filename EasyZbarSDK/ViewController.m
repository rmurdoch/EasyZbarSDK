//
//  ViewController.m
//  EasyZbarSDK
//
//  Created by Andrew Murdoch on 3/13/14.
//  Copyright (c) 2014 RAM4LLC. All rights reserved.
//

#import "ViewController.h"
#import "ScanResultsTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"QR1"])
    {
        [[segue destinationViewController] setStartScanning:YES];
        [[segue destinationViewController] setScanMultiple:NO];
        [[segue destinationViewController] setScanCode:SVScanQRCode];
    }
    else if ([[segue identifier] isEqualToString:@"QRMultiple"])
    {
        [[segue destinationViewController] setStartScanning:YES];
        [[segue destinationViewController] setScanMultiple:YES];
        [[segue destinationViewController] setScanCode:SVScanQRCode];
    }
    if ([[segue identifier] isEqualToString:@"Bar1"])
    {
        [[segue destinationViewController] setStartScanning:YES];
        [[segue destinationViewController] setScanMultiple:NO];
        [[segue destinationViewController] setScanCode:SVScanBarCode];
    }
    if ([[segue identifier] isEqualToString:@"BarMultiple"])
    {
        [[segue destinationViewController] setStartScanning:YES];
        [[segue destinationViewController] setScanMultiple:YES];
        [[segue destinationViewController] setScanCode:SVScanBarCode];
    }
}


@end
