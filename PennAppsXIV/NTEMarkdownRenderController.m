//
//  NTEMarkdownRenderController.m
//  PennAppsXIV
//
//  Created by Jason Scharff on 9/10/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "NTEMarkdownRenderController.h"

#import <MMMarkdown/MMMarkdown.h>


@implementation NTEMarkdownRenderController
    
+ (NSString *)generateHTMLFromMarkdown : (NSString *)markdown {
    //For now we'll do this.
    //Next step is to do some regex on it first.
    NSError *error;
    NSString *html = [MMMarkdown HTMLStringWithMarkdown:markdown extensions:MMMarkdownExtensionsGitHubFlavored error:&error];
    if(error) {
        NSLog(@"error = %@", error);
        //Show some alert.
    }
    return html;
}


@end
