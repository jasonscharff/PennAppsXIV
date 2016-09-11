//
//  NTEMarkdownRenderController.h
//  PennAppsXIV
//
//  Created by Jason Scharff on 9/10/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kNTEUploadActionPrefix;

@interface NTEMarkdownRenderController : NSObject

+ (instancetype)sharedRenderController;
- (NSString *)generateHTMLFromMarkdown : (NSString *)markdown;

- (NSString *)replaceButtonAtPosition : (int)position
                            withImage : (NSString *)base64
                              forHTML : (NSString *)html;

    
@end
