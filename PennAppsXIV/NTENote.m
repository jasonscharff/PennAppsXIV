//
//  NTENote.m
//  PennAppsXIV
//
//  Created by Jason Scharff on 9/10/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "NTENote.h"

#import "NTEMarkdownRenderController.h"

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
    self.html = [NTEMarkdownRenderController generateHTMLFromMarkdown:self.rawMarkdown];
}
    
@end
