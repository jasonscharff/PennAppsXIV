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
    
- (instancetype)initWithDictonary : (NSDictionary *)dictionary {
    self = [super init];
    if(self) {
        [self setupWithDictionary:dictionary];
    }
    return self;
}
    
- (void)setupWithDictionary : (NSDictionary *)dictionary {
    if(dictionary[@"images"]) {
        NSArray *images = dictionary[@"images"];
        for (NSDictionary *image in images) {
            [[NTEImageStoreController sharedImageStoreController]addImageFromDictionary:image];
        }
    }
    //This should be after to the html generated has images!
    self.rawMarkdown = dictionary[@"markdown"];
    
}

- (void)setRawMarkdown:(NSString *)rawMarkdown {
    _rawMarkdown = rawMarkdown;
    self.html = [[NTEMarkdownRenderController sharedRenderController]generateHTMLFromMarkdown:self.rawMarkdown];
}
    
@end
