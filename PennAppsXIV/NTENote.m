//
//  NTENote.m
//  PennAppsXIV
//
//  Created by Jason Scharff on 9/10/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "NTENote.h"

#import "NTEMarkdownRenderController.h"
#import "NTEImageStoreController.h"

@implementation NTENote
    
+ (instancetype)sharedNote {
    static dispatch_once_t onceToken;
    static NTENote * _sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc]init];
    });
    return _sharedInstance;
}
    
- (void)setupWithDictionary : (NSDictionary *)dictionary {
    if(dictionary[@"images"]) {
        NSArray *images = dictionary[@"images"];
        for (NSDictionary *image in images) {
            [[NTEImageStoreController sharedImageStoreController]addImageFromDictionary:image];
        }
    }
    //This should be after to the html generated has images!
    if(dictionary[@"markdown"]) {
        self.rawMarkdown = dictionary[@"markdown"];
    }
    
    
}

- (void)setRawMarkdown:(NSString *)rawMarkdown {
    _rawMarkdown = rawMarkdown;
    if(rawMarkdown) {
        self.html = [[NTEMarkdownRenderController sharedRenderController]generateHTMLFromMarkdown:self.rawMarkdown];
    }
}
    
@end
