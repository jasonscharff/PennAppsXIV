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


//Remove
#import "NTEMarkdownRenderController.h"

@import WebKit;

@interface NTEDisplayViewController () <WKNavigationDelegate>
    
@property (nonatomic) WKWebView *webView;

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
            [self.webView loadHTMLString:note.html baseURL:nil];
        }
        
    }
}

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString *url = navigationAction.request.URL.absoluteString;
    if([url hasPrefix:kNTEUploadActionPrefix]) {
        //show the image picker.
    }
    
    decisionHandler(WKNavigationActionPolicyCancel);
}


@end
