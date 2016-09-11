//
//  NTEImageStoreController.h
//  PennAppsXIV
//
//  Created by Jason Scharff on 9/10/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

@interface NTEImageStoreController : NSObject

+ (instancetype)sharedImageStoreController;
- (void)addImageFromDictionary : (NSDictionary *) dictionary;
- (NSString *)base64ForImageName : (NSString *)imageName;
- (NSString *)base64DataForImage : (UIImage *)image;



@end
