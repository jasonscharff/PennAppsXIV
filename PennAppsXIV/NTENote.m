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
    self.rawMarkdown = dictionary[@"markdown"];
    if(dictionary[@"images"]) {
        NSArray *images = dictionary[@"images"];
        for (NSDictionary *image in images) {
            [[NTEImageStoreController sharedImageStoreController]addImageFromDictionary:image];
        }
    }
    self.html = [[NTEMarkdownRenderController sharedRenderController]generateHTMLFromMarkdown:self.rawMarkdown];
}
    
@end
