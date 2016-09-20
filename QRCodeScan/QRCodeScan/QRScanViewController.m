//
//  QRScanViewController.m
//  QRCodeScan
//  https://github.com/FreakLee/QRCodeScan
//  Created by Lyman on 16/9/19.
//  Copyright © 2016年 Lyman. All rights reserved.
//

@import AVFoundation;
#import "QRScanViewController.h"
#import "UIView+LMExtension.h"

static const CGFloat kScanWindowWidth  = 260.0;
static const CGFloat kScanWindowHeight = 260.0;
static const CGFloat kCornerImageWidth = 20.0;
static const CGFloat kCornerImageHeight= 20.0;
static const CGFloat kScanLineImageHeight= 3.0;

#define kMaskColor       [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]
#define kScreenWidth     [[UIScreen mainScreen]bounds].size.width
#define kScreenHeight    [[UIScreen mainScreen]bounds].size.height

@interface QRScanViewController ()
<
    AVCaptureMetadataOutputObjectsDelegate,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate
>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) UIView *scanWindow;
@property (nonatomic, strong) UIImageView *scanLineImageView;

@end

@implementation QRScanViewController

#pragma mark - life cycle
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EnterForeground" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.clipsToBounds=YES;
    
    [self setupOverlayView];
    [self setupTipTitleView];
    [self setupNavigationBarView];
    [self beginScanning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeAnimation) name:@"EnterForeground" object:nil];
    self.navigationController.navigationBar.hidden=YES;
    [self resumeAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setup
- (void)setupNavigationBarView {
    
    // back
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, 30, 25, 25);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_titlebar_back_nor"] forState:UIControlStateNormal];
    backBtn.contentMode=UIViewContentModeScaleAspectFit;
    [backBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    // album
    UIButton * albumBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    albumBtn.frame = CGRectMake(0, 0, 35, 49);
    albumBtn.center=CGPointMake(self.view.lm_width/2, 20+49/2.0);
    [albumBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_btn_photo_down"] forState:UIControlStateNormal];
    albumBtn.contentMode=UIViewContentModeScaleAspectFit;
    [albumBtn addTarget:self action:@selector(myAlbum) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:albumBtn];
    
    // flash
    UIButton * flashBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    flashBtn.frame = CGRectMake(self.view.lm_width-55,20, 35, 49);
    [flashBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_down"] forState:UIControlStateNormal];
    flashBtn.contentMode=UIViewContentModeScaleAspectFit;
    [flashBtn addTarget:self action:@selector(openFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashBtn];
}

- (void)setupOverlayView {
    
    CGFloat topHeight = (kScreenHeight - kScanWindowHeight) / 2;
    CGFloat bottomHeight = kScreenHeight - kScanWindowHeight - topHeight;
    CGFloat leftWidth = (kScreenWidth - kScanWindowWidth) / 2;
    CGFloat rightWidth = kScreenWidth - kScanWindowWidth - leftWidth;
    
    // maskView
    UIView *topMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, topHeight)];
    topMaskView.backgroundColor = kMaskColor;
    [self.view addSubview:topMaskView];
    
    UIView *bottomMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, topHeight + kScanWindowHeight, kScreenWidth, bottomHeight)];
    bottomMaskView.backgroundColor = kMaskColor;
    [self.view addSubview:bottomMaskView];
    
    UIView *leftMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, topHeight, leftWidth, kScanWindowHeight)];
    leftMaskView.backgroundColor = kMaskColor;
    [self.view addSubview:leftMaskView];
    
    UIView *rightMaskView = [[UIView alloc] initWithFrame:CGRectMake(leftWidth + kScanWindowWidth, topHeight, rightWidth, kScanWindowWidth)];
    rightMaskView.backgroundColor = kMaskColor;
    [self.view addSubview:rightMaskView];
    
    _scanWindow = [[UIView alloc] initWithFrame:CGRectMake(leftMaskView.lm_x + leftMaskView.lm_width, topMaskView.lm_y + topMaskView.lm_height, kScanWindowWidth, kScanWindowHeight)];
//    borderView.layer.borderWidth = 0.5f;
//    borderView.clipsToBounds = YES;
//    borderView.layer.borderColor = [[UIColor whiteColor] CGColor];
//    borderView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_scanWindow];
    
    
    // cornerImageView
    UIImageView *topLeftImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kCornerImageWidth, kCornerImageHeight)];
    [topLeftImage setImage:[UIImage imageNamed:@"qrCorner-top-left"]];
    [_scanWindow addSubview:topLeftImage];
    
    UIImageView *topRightImage = [[UIImageView alloc] initWithFrame:CGRectMake(kScanWindowWidth - kCornerImageWidth, 0, kCornerImageWidth, kCornerImageHeight)];
    [topRightImage setImage:[UIImage imageNamed:@"qrCorner-top-right"]];
    [_scanWindow addSubview:topRightImage];
    
    UIImageView *bottomLeftImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, kScanWindowHeight - kCornerImageHeight, kCornerImageWidth, kCornerImageHeight)];
    [bottomLeftImage setImage:[UIImage imageNamed:@"qrCorner-bottom-left"]];
    [_scanWindow addSubview:bottomLeftImage];
    
    UIImageView *bottomRightImage = [[UIImageView alloc] initWithFrame:CGRectMake(topRightImage.lm_x, bottomLeftImage.lm_y, kCornerImageWidth, kCornerImageHeight)];
    [bottomRightImage setImage:[UIImage imageNamed:@"qrCorner-bottom-right"]];
    [_scanWindow addSubview:bottomRightImage];
    
    // scanLineImageView
    _scanLineImageView = [[UIImageView alloc] init];
    _scanLineImageView.image = [UIImage imageNamed:@"qrScan-liner"];
}

-(void)setupTipTitleView {

    UILabel * tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, _scanWindow.lm_bottom+10, self.view.lm_width-40, 40)];
    tipLabel.text = @"将取景框对准二维码，即可自动扫描";
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    tipLabel.numberOfLines = 2;
    tipLabel.font=[UIFont systemFontOfSize:14];
    tipLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tipLabel];
}

#pragma mark - button action
- (void)dismiss {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)myAlbum {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        [self alertUpgradeSystem];
        return;
    }
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
        controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        controller.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:controller animated:YES completion:NULL];
        
    } else {
        [self alertNoAlbumPermission];
    }
}

- (void)openFlash:(UIButton*)button {
    button.selected = !button.selected;
    
    if (button.selected) {
        [self turnTorchOn:YES];
    } else {
        [self turnTorchOn:NO];
    }
}

- (void)turnTorchOn:(BOOL)on {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    
    if (captureDeviceClass != nil) {
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            
            [device unlockForConfiguration];
        }
    }
}

#pragma mark - alertMessages
- (void)alertUpgradeSystem {

    NSString *message = @"您的手机系统尚不支持从相册中识别二维码，请升级到iOS8.0及其以上版本";
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"提示"
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"确定"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               
                           }];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)alertNoAlbumPermission {
    
    NSString *message = @"设备不支持访问相册，请在设置->隐私->照片中进行设置！";
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"提示"
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"确定"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               
                           }];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)alertScanfailed {
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"扫描结果"
                                        message:@"尚未识别"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *exit =
    [UIAlertAction actionWithTitle:@"退出"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               [self dismiss];
                           }];
    [alertController addAction:exit];
    
    UIAlertAction *scanAgain =
    [UIAlertAction actionWithTitle:@"再次扫描"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               [_session startRunning];
                           }];
    [alertController addAction:scanAgain];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)alertNoQRCode {

    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:@"提示"
                                        message:@"该图片没有包含一个二维码！"
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"确定"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               
                           }];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - animation
- (void)resumeAnimation {
    CAAnimation *animation = [_scanLineImageView.layer animationForKey:@"translationAnimation"];
    
    if (animation) {
        
        CFTimeInterval pauseTime = _scanLineImageView.layer.timeOffset;
        CFTimeInterval beginTime = CACurrentMediaTime() - pauseTime;
        
        [_scanLineImageView.layer setTimeOffset:0.0];
        [_scanLineImageView.layer setBeginTime:beginTime];
        [_scanLineImageView.layer setSpeed:1.0];
        
    } else {
        
        CGFloat scanLineImageWidth = _scanWindow.lm_width;
        CGFloat scanLineImageHeight = _scanWindow.lm_height;
        
        _scanLineImageView.frame = CGRectMake(0, -kScanLineImageHeight, scanLineImageWidth,kScanLineImageHeight);
        CABasicAnimation *scanLineAnimation = [CABasicAnimation animation];
        scanLineAnimation.keyPath = @"transform.translation.y";
        scanLineAnimation.byValue = @(scanLineImageHeight);
        scanLineAnimation.duration = 3.0;
        scanLineAnimation.repeatCount = MAXFLOAT;
        [_scanLineImageView.layer addAnimation:scanLineAnimation forKey:@"translationAnimation"];
        [_scanWindow addSubview:_scanLineImageView];
    }
}

#pragma mark - scanning
- (void)beginScanning {
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!input) return;

    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];

    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    CGRect scanCrop=[self getScanCrop:_scanWindow.bounds readerViewBounds:self.view.frame];
    output.rectOfInterest = scanCrop;

    _session = [[AVCaptureSession alloc]init];

    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [_session addInput:input];
    [_session addOutput:output];
 
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    [_session startRunning];
}

#pragma mark - getScanCrop
-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    CGFloat x,y,width,height;
    
    x = (CGRectGetHeight(readerViewBounds)-CGRectGetHeight(rect))/2/CGRectGetHeight(readerViewBounds);
    y = (CGRectGetWidth(readerViewBounds)-CGRectGetWidth(rect))/2/CGRectGetWidth(readerViewBounds);
    width = CGRectGetHeight(rect)/CGRectGetHeight(readerViewBounds);
    height = CGRectGetWidth(rect)/CGRectGetWidth(readerViewBounds);
    
    return CGRectMake(x, y, width, height);
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        
        [_session stopRunning];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex :0];
        
        if ([self.delegate respondsToSelector:@selector(QRScanViewController:didScanContent:)]) {
            [self.delegate QRScanViewController:self didScanContent:metadataObject.stringValue];
        }
        
        [self dismiss];
    } else {
        [self alertScanfailed];
    }
}

#pragma mark - imagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    [picker dismissViewControllerAnimated:YES completion:^{

        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        if (features.count >=1) {
            
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            
            if ([self.delegate respondsToSelector:@selector(QRScanViewController:didScanContent:)]) {
                [self.delegate QRScanViewController:self didScanContent:scannedResult];
            }
            [self dismiss];
        } else {
            [self alertNoQRCode];
        }
    }];
}
@end
