//
//  NTEMarkdownRenderController.m
//  PennAppsXIV
//
//  Created by Jason Scharff on 9/10/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "NTEMarkdownRenderController.h"

#import <HTMLReader/HTMLReader.h>

#import <MMMarkdown/MMMarkdown.h>
#import <GRMustache/GRMustache.h>

@interface NTEMarkdownRenderController()
    
@property (nonatomic, strong) GRMustacheTemplate *htmlTemplate;

@end

static NSString * const kNTEStandardHTMLTemplateFilename = @"html_template";
static NSString * const kNTEContentFieldName = @"kNTEContent";


@implementation NTEMarkdownRenderController
    
+ (instancetype)sharedRenderController {
    static dispatch_once_t onceToken;
    static NTEMarkdownRenderController * _sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc]init];

    });
    return _sharedInstance;
}
    
- (instancetype)init {
    return [self initWithTemplateFilename:kNTEStandardHTMLTemplateFilename
                                     inBundle:[NSBundle mainBundle]];
}
    
- (instancetype)initWithTemplateFilename:(NSString *)filename inBundle:(NSBundle *)bundle {
    self = [super init];
    NSError *error;
    self.htmlTemplate = [GRMustacheTemplate templateFromResource:filename
                                                           bundle:bundle error:&error];
    if(!self.htmlTemplate || error) {
        return nil;
    }
    return self;
}
    
- (NSString *)generateHTMLFromMarkdown : (NSString *)markdown {
    //For now we'll do this.
    //Next step is to do some regex on it first.
    NSError *error;
    NSString *markdownAsHTML = [MMMarkdown HTMLStringWithMarkdown:markdown extensions:MMMarkdownExtensionsGitHubFlavored error:&error];
    if(error) {
        NSLog(@"error = %@", error);
        return nil;
        //Show some alert.
    }
    return [self embedHTMLContentInTemplate:markdownAsHTML];
}
    
- (NSString *)embedHTMLContentInTemplate : (NSString *)content {
    NSDictionary *parameters = @{kNTEContentFieldName : content};
    NSError *error;
    NSString *html = [self.htmlTemplate renderObject:parameters error:&error];
    html = [html html_stringByUnescapingHTML];
    if(error) {
        return nil;
    } else {
        return html;
    }
    
}
    



@end
