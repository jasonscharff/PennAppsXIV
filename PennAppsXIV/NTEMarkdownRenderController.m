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

#import "NTEImageStoreController.h"

@interface NTEMarkdownRenderController()
    
@property (nonatomic, strong) GRMustacheTemplate *htmlTemplate;

@end

static NSString * const kNTEStandardHTMLTemplateFilename = @"html_template";
static NSString * const kNTEContentFieldName = @"kNTEContent";
NSString * const kNTEUploadActionPrefix = @"uploadImage";


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
    markdown = [self replaceMissingImagesWithButtons:markdown];
    NSDictionary *replacementsDictionary = [self removeMathematicalFormattingFromMarkdown:markdown];
    NSString *cleanedUpMarkDown = replacementsDictionary[@"markdown"];
    NSDictionary *replacements = replacementsDictionary[@"replacements"];
    NSString *markdownAsHTML = [MMMarkdown HTMLStringWithMarkdown:cleanedUpMarkDown
                                                       extensions:MMMarkdownExtensionsGitHubFlavored
                                                            error:&error];
    
    if(error) {
        NSLog(@"error = %@", error);
        return nil;
        //Show some alert.
    }
    NSString *inHTML = [self embedHTMLContentInTemplate:markdownAsHTML];
    inHTML = [self replaceImagesWithBase64:inHTML];
    return [self addMathematicalFormattingToMarkdown:inHTML withDictionary:replacements];
}

- (NSString *)replaceButtonAtPosition : (int)position
                            withImage : (NSString *)base64
                              forHTML : (NSString *)html {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=([^>])*class=\"nte-upload-button\".*<\\/a>"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if(error) {
        NSLog(@"error with regex %@", error.localizedDescription);
        return html;
    }
    NSArray *instances = [regex matchesInString:html
                                                    options:NSMatchingReportProgress
                                                      range:NSMakeRange(0, html.length)];
    
    NSTextCheckingResult *match = instances[position];
    
    NSString *replacement = [NSString stringWithFormat:@"<img src=%@>", base64];
    
    return [html stringByReplacingCharactersInRange:match.range withString:replacement];
    
}

- (NSString *)replaceImagesWithBase64 : (NSString *)html{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<img[^>]*>"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if(error) {
        NSLog(@"error with regex = %@", error.localizedDescription);
        return html;
    } else {
        NSArray *instances = [regex matchesInString:html
                                            options:NSMatchingReportProgress
                                              range:NSMakeRange(0, html.length)];
        NSString *newHTML = [[NSString alloc]initWithString:html];
        
        for (int i = 0; i < instances.count; i++) {
            NSTextCheckingResult *match = instances[i];
            NSString *original = [html substringWithRange:match.range];
            NSRegularExpression *srcRegex = [NSRegularExpression regularExpressionWithPattern:@"src=\"[^\"]*\""
                                                                                      options:NSRegularExpressionCaseInsensitive
                                                                                        error:&error];
            NSTextCheckingResult *srcResult = [srcRegex firstMatchInString:original options:NSMatchingReportProgress range:NSMakeRange(0, original.length)];
            NSString *src = [original substringWithRange:srcResult.range];
            
    
            NSString *start = @"src=\"";
            NSString *imageName = [src substringWithRange:NSMakeRange(start.length, src.length-start.length-1)];
            if(![imageName hasPrefix:@"data"]) {
                NSString *base64 = [[NTEImageStoreController sharedImageStoreController]base64ForImageName:imageName];
                NSString *replacement = [NSString stringWithFormat:@"<img src=%@>", base64];
                newHTML = [newHTML stringByReplacingOccurrencesOfString:original withString:replacement];
            }
        }
        
        return newHTML;
    }
}

- (NSString *)replaceMissingImagesWithButtons : (NSString *)markdown {
    NSError *error;
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"!\\[[\\s\\S]*?\\]!" options:NSRegularExpressionCaseInsensitive error:&error];
    if(error) {
        NSLog(@"error with regex %@", error.localizedDescription);
        return markdown;
    }
    NSArray *instances = [regularExpression matchesInString:markdown
                                               options:NSMatchingReportProgress
                                                 range:NSMakeRange(0, markdown.length)];
    
    
    int rangeOffset = 0;
    
    NSMutableString *mutableMarkdown = [[NSMutableString alloc]initWithString:markdown];
    
    for (int i =0; i<instances.count; i++) {
        NSTextCheckingResult *match = instances[i];
        NSString *replacement = [NSString stringWithFormat:@"<a href=\"%@_%i\" class=\"nte-upload-button\">Upload Image</a>", kNTEUploadActionPrefix, i];
        NSString *originalString = [markdown substringWithRange:match.range];
        NSRange offsetRange = NSMakeRange(match.range.location-rangeOffset, match.range.length);
        rangeOffset += (originalString.length - replacement.length);
        [mutableMarkdown replaceCharactersInRange:offsetRange withString:replacement];
    }
    return [NSString stringWithString:mutableMarkdown];
}

- (NSString *)addMathematicalFormattingToMarkdown : (NSString *)markdown withDictionary : (NSDictionary *)replacements {
    for (NSString *key in replacements) {
        markdown = [markdown stringByReplacingOccurrencesOfString:key withString:replacements[key]];
    }
    return markdown;
}

- (NSDictionary *)removeMathematicalFormattingFromMarkdown : (NSString *)markdown {
    NSDictionary *outline = [self removeRegex:@"\\$\\$([\\s\\S]*?)\\$\\$" fromMarkdown:markdown withIdOffset:0];
    NSDictionary *firstLevelDictionary = outline[@"replacements"];
    NSString *firstTierMarkdown = outline[@"markdown"];
    NSDictionary *inlineMath = [self removeRegex:@"\\$([\\s\\S]*?)\\$" fromMarkdown:firstTierMarkdown withIdOffset:(int)firstLevelDictionary.count];
    NSDictionary *secondLevelDictionary = inlineMath[@"replacements"];
    NSMutableDictionary *combinedReplacements = [NSMutableDictionary dictionary];
    NSString *finalMarkdown = inlineMath[@"markdown"];
    [combinedReplacements addEntriesFromDictionary:firstLevelDictionary];
    [combinedReplacements addEntriesFromDictionary:secondLevelDictionary];
    return @{@"replacements" : combinedReplacements,
             @"markdown" : finalMarkdown};
    
}


- (NSDictionary *)removeRegex: (NSString *)pattern
                fromMarkdown : (NSString *)markdown
                withIdOffset : (int)idOffset {
    NSMutableString *mutableMarkdown = [[NSMutableString alloc]initWithString:markdown];
    NSError *error;
    NSRegularExpression *regularRegex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *instances = [regularRegex matchesInString:markdown
                                               options:NSMatchingReportProgress
                                                 range:NSMakeRange(0, markdown.length)];
    
    NSMutableDictionary *replacements = [NSMutableDictionary dictionaryWithCapacity:instances.count];
    
    int rangeOffset = 0;
    
    for (int i =0; i<instances.count; i++) {
        NSTextCheckingResult *match = instances[i];
        NSString *replacement = [NSString stringWithFormat:@"<div class=\"notebook-replacement\" id=replacement-%i></div>", i+idOffset];
        NSString *originalString = [markdown substringWithRange:match.range];
        replacements[replacement] = originalString;
        NSRange offsetRange = NSMakeRange(match.range.location-rangeOffset, match.range.length);
        rangeOffset += (originalString.length - replacement.length);
        [mutableMarkdown replaceCharactersInRange:offsetRange withString:replacement];
    }
    
    
    NSDictionary *returnDict = @{@"replacements" : replacements,
                                 @"markdown" : mutableMarkdown};
    return returnDict;
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
