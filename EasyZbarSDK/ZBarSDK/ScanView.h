//
//  ScanView.h
//  iLearn
//
//  Created by Richard Murdoch on 3/13/14.
//  Copyright (c) 2014 RAM4LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

@protocol ScanViewDelegate <NSObject>

typedef enum {
    SVScanBarCode,
    SVScanQRCode
} SVScanCode;

- (void)didFinishedScaning:(NSArray *)array;
- (void)cancelPressedForScan;

@end

@interface ScanView : UIView <ZBarReaderDelegate>

@property (nonatomic, strong) ZBarReaderViewController *zBarReaderVC;

- (id)initWithCode:(SVScanCode)code withDelegate:(id)delegate forMultipleScans:(BOOL)multipleScans inView:(UIView *)view;

@end
