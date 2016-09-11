//
//  NTEDisplayViewController.m
//  PennAppsXIV
//
//  Created by Jason Scharff on 9/10/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "NTEDisplayViewController.h"

#import "AutolayoutHelper.h"

#import "NTENote.h"
#import "NTEMarkdownRenderController.h"
#import "NTESocketManager.h"

@import WebKit;

@interface NTEDisplayViewController () <WKNavigationDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate>
    
@property (nonatomic) WKWebView *webView;
@property (nonatomic) int order;

@end

@implementation NTEDisplayViewController

+ (instancetype)sharedNTEDisplayViewController {
    static dispatch_once_t onceToken;
    static NTEDisplayViewController *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc]init];
    });
    return _sharedInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webView = [[WKWebView alloc]init];
    self.webView.navigationDelegate = self;
    [AutolayoutHelper configureView:self.view fillWithSubView:self.webView];
    if(self.note) {
        [self setNote:_note];
    }
    // Do any additional setup after loading the view.
}
    

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
- (void)setNote:(NTENote *)note {
    _note = note;
    if(self.viewLoaded) {
        if(note.html) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.webView loadHTMLString:note.html baseURL:nil];
            });
        }
        
    }
}

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if([navigationAction.request.URL.absoluteString isEqualToString:@"about:blank"]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        NSString *url = navigationAction.request.URL.absoluteString;
        if([url hasPrefix:kNTEUploadActionPrefix]) {
            NSRange rangeOfUnderscore = [url rangeOfString:@"_"];
            NSString *substring = [url substringFromIndex:rangeOfUnderscore.location+rangeOfUnderscore.length+1];
            self.order = substring.intValue;
            UIAlertController *imageTypeChooser = [UIAlertController alertControllerWithTitle:nil
                                                                                      message:nil
                                                                               preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *library = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:picker animated:YES completion:nil];
            }];
            
            UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:picker animated:YES completion:nil];
            }];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            
            [imageTypeChooser addAction:camera];
            [imageTypeChooser addAction:library];
            [imageTypeChooser addAction:cancel];
            
            [self presentViewController:imageTypeChooser animated:YES completion:nil];
            
            
        }
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *scaledImage;
    if(image.size.width > 700) {
        scaledImage = [self scaleImage:image toSize:CGSizeMake(700, image.size.width/image.size.height * 700)];
    } else {
        scaledImage = image;
    }
    
    //Show some sort of crop view controller.
    [[NTESocketManager sharedSocket]uploadImage:scaledImage order:self.order];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize {
    CGSize scaledSize = newSize;
    float scaleFactor = 1.0;
    if( image.size.width > image.size.height ) {
        scaleFactor = image.size.width / image.size.height;
        scaledSize.width = newSize.width;
        scaledSize.height = newSize.height / scaleFactor;
    }
    else {
        scaleFactor = image.size.height / image.size.width;
        scaledSize.height = newSize.height;
        scaledSize.width = newSize.width / scaleFactor;
    }
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}


@end
