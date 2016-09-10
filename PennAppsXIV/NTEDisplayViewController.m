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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webView = [[WKWebView alloc]init];
    self.webView.navigationDelegate = self;
    [AutolayoutHelper configureView:self.view fillWithSubView:self.webView];
    if(self.note) {
        [self setNote:_note];
    }
    //Temporary
    NTENote *note = [[NTENote alloc]init];
    note.rawMarkdown = @"# test";
    
    note.html = [[NTEMarkdownRenderController sharedRenderController]generateHTMLFromMarkdown:note.rawMarkdown];
    
    self.note = note;
    
    // Do any additional setup after loading the view.
}
    

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
- (void)setNote:(NTENote *)note {
    _note = note;
    if(self.viewLoaded) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [paths objectAtIndex:0];
        if(note.html) {
            [self.webView loadHTMLString:note.html baseURL:nil];
        }
        
    }
}



@end
