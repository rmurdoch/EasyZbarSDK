//
//  ScanView.m
//  iLearn
//
//  Created by Richard Murdoch on 3/13/14.
//  Copyright (c) 2014 RAM4LLC. All rights reserved.
//

#import "ScanView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ScanView
{
    UIView *scanBoxView, *scanningView, *superView;
    CGPoint scanVelocity;
    BOOL scanMultiple;
    id <ScanViewDelegate> scanDelegate;
    NSMutableArray *scanArray;
    UIImagePickerController *imagePicker;
    UILabel *scannedLabel, *countLabel;
    SVScanCode scanCode;
}

- (id)initWithCode:(SVScanCode)code withDelegate:(id)delegate forMultipleScans:(BOOL)multipleScans inView:(UIView *)view
{
    self = [super init];
    if (self)
    {
        scanVelocity = CGPointMake(0, 4);
        superView = view;
        
        scanMultiple = multipleScans;
        scanDelegate = delegate;
        scanCode = code;
        
        scanArray = [NSMutableArray array];
        
        _zBarReaderVC = [ZBarReaderViewController new];
        _zBarReaderVC.readerDelegate = self;
        _zBarReaderVC.readerView.tracksSymbols = NO;
        _zBarReaderVC.supportedOrientationsMask = ZBarOrientationMask(UIInterfaceOrientationLandscapeLeft) | ZBarOrientationMask(UIInterfaceOrientationLandscapeRight);
        _zBarReaderVC.videoQuality = UIImagePickerControllerQualityTypeHigh;
        ZBarImageScanner *zScanner = _zBarReaderVC.scanner;
        [zScanner setSymbology:ZBAR_I25
                        config:ZBAR_CFG_ENABLE
                            to:0];
        
        _zBarReaderVC.cameraOverlayView = [self mainView];
        
        [self createCustomToolBar];
    }
    return self;
}

- (UIView *)mainView //Main View
{
    float iOS7Adjust = 0;
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0))
        iOS7Adjust = 88;
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, superView.frame.size.width, superView.frame.size.height-iOS7Adjust)];
    mainView.backgroundColor = [UIColor clearColor];
    mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [superView setFrame:mainView.frame];
    
    [mainView addSubview:[self scanBoxLayer]];
    
    if (scanMultiple)
        [self scannedLabel];
    
    return mainView;
}


-(UIView *)scanBoxLayer //Green Box
{
    CGRect frame;
    
    if (scanCode == SVScanBarCode)
        frame = CGRectMake(0, 0, superView.frame.size.width-30, 70);
    else if (scanCode == SVScanQRCode)
        frame = CGRectMake(0, 0, 250, 230);
    
    scanBoxView = [[UIView alloc] initWithFrame:frame];
    CALayer *layer = scanBoxView.layer;
    layer.backgroundColor = [[UIColor clearColor] CGColor];
    layer.borderColor = [[UIColor greenColor] CGColor];
    layer.cornerRadius = 8.0f;
    layer.borderWidth = 2.0f;
    
    scanBoxView.center = CGPointMake(superView.frame.size.width/2, superView.frame.size.height/2);
    
    if (scanCode == SVScanBarCode)
        scanBoxView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    else if (scanCode == SVScanQRCode)
        scanBoxView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [scanBoxView addSubview:[self scrollScanView:scanBoxView]];
    
    return scanBoxView;
}

- (UIView *)scrollScanView:(UIView *)view //Green Scrolling Line
{
    scanningView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width-5, 3)];
    CALayer *layer = scanningView.layer;
    layer.backgroundColor = [[UIColor clearColor] CGColor];
    layer.borderColor = [[UIColor greenColor] CGColor];
    layer.cornerRadius = 15.0f;
    layer.borderWidth = 2.0f;
    
    scanningView.alpha = 0.6;
    scanningView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
    scanningView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    float speed = 0.01;
    if (scanCode == SVScanBarCode)
        speed = 0.04;
    else if (scanCode == SVScanQRCode)
        speed = 0.02;
    
    [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(scrollLoop) userInfo:nil repeats:YES];
    
    return scanningView;
}

- (void)scrollLoop //Animation of Green Scrolling Line
{
    float adj = scanningView.frame.size.height*2;
    
    scanningView.center = CGPointMake(scanningView.center.x, scanningView.center.y + scanVelocity.y);
    
    if(scanningView.center.y > scanBoxView.bounds.size.height - adj || scanningView.center.y < adj)
        scanVelocity.y = -scanVelocity.y;
}

- (UILabel *)countLabel //Label in ToolBar to count number of scans
{
    if (countLabel)
    {
        countLabel.text = [NSString stringWithFormat:@"Scans: %i", scanArray.count];
        return countLabel;
    }
    
    countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.textColor = [UIColor whiteColor];
    countLabel.textAlignment = NSTextAlignmentCenter;
    
    return countLabel;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    id <NSFastEnumeration> result = [info objectForKey:ZBarReaderControllerResults];
    ZBarSymbol *zSymbol = nil;
    for (zSymbol in result)
        break;
    
    if (scanMultiple)
    {
        if (![scanArray containsObject:zSymbol.data]) //Make sure to not keep duplicate scans when scanning multiple items
            [scanArray addObject:zSymbol.data];
        
        [self showScannedLabel];
        [self countLabel];
    }

    else
        [picker dismissViewControllerAnimated:YES completion:^{
            [scanDelegate didFinishedScaning:[NSArray arrayWithObject:zSymbol.data]];
        }];
}

- (void)showScannedLabel //Animates Label to show a scan was successful
{
    [UIView animateWithDuration:0.7
                     animations:^
    {
        scannedLabel.hidden = NO;
        scannedLabel.transform = CGAffineTransformMakeScale(2, 2);
        scannedLabel.alpha = 0.3;
    }
                     completion:^(BOOL finished){
        if (finished)
            [self scannedLabel];
    }];
}

- (void)scannedLabel //Successful scanned label
{
    if (scannedLabel)
    {
        scannedLabel.hidden = YES;
        scannedLabel.alpha = 1.0;
        scannedLabel.transform = CGAffineTransformMakeScale(1, 1);
        return;
    }
    
    scannedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, scanBoxView.frame.size.width, scanBoxView.frame.size.height)];
    scannedLabel.backgroundColor = [UIColor clearColor];
    [scannedLabel setFont:[UIFont boldSystemFontOfSize:27]];
    scannedLabel.text = @"Scanned";
    scannedLabel.textColor = [UIColor greenColor];
    scannedLabel.textAlignment = NSTextAlignmentCenter;
    scannedLabel.alpha = 1.0f;
    scannedLabel.layer.borderColor = [UIColor greenColor].CGColor;
    scannedLabel.layer.borderWidth = 2.0f;
    scannedLabel.layer.cornerRadius = 15.0f;
    scannedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [scanBoxView addSubview:scannedLabel];
    scannedLabel.hidden = YES;
}

- (void)createCustomToolBar //Searches for ZBar toolbar and uses frame
{
    for (UIView *view in _zBarReaderVC.view.subviews)
    {
        for (UIView *subView in view.subviews)
        {
            if ([subView isKindOfClass:[UIToolbar class]])
            {
                [_zBarReaderVC.view addSubview:[self customToolBar:(UIToolbar *)subView]];
                break;
            }
        }
    }
    _zBarReaderVC.showsZBarControls = NO;
}

- (UIToolbar *)customToolBar:(UIToolbar *)toolBar //Creates our custom toolbar with our own functions
{
    CGRect frame = toolBar.frame;
    frame.origin.y = superView.frame.size.height - frame.size.height;
    
    UIToolbar *newToolBar = [[UIToolbar alloc] initWithFrame:frame];
    newToolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    newToolBar.tintColor = [UIColor blackColor];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed)];

    if (scanMultiple)
    {
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *countButton = [[UIBarButtonItem alloc] initWithCustomView:[self countLabel]];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed)];
        
        [newToolBar setItems:[NSArray arrayWithObjects:cancelButton, flexSpace, countButton, flexSpace, doneButton, nil]];
        return newToolBar;
    }
    
    [newToolBar setItems:[NSArray arrayWithObjects:cancelButton, nil]];
    return newToolBar;
}


- (void)donePressed
{
    [scanDelegate didFinishedScaning:scanArray];

    [_zBarReaderVC dismissViewControllerAnimated:YES
                                      completion:^
    {
    }];
}

- (void)cancelPressed
{
    [scanDelegate cancelPressedForScan];

    [_zBarReaderVC dismissViewControllerAnimated:YES
                                      completion:^
    {
    }];
}

@end
