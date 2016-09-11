//
//  NTEImageStoreController.m
//  PennAppsXIV
//
//  Created by Jason Scharff on 9/10/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "NTEImageStoreController.h"

@import UIKit;

@interface NTEImageStoreController()

@property (nonatomic) NSMutableDictionary *imageDirectory;

@end


@implementation NTEImageStoreController

+ (instancetype)sharedImageStoreController {
    static dispatch_once_t onceToken;
    static NTEImageStoreController *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc]init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        self.imageDirectory = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addImageFromDictionary : (NSDictionary *) dictionary {
    NSString *imageName = dictionary[@"name"];
    NSString *base64 = dictionary[@"base64_string"];
    self.imageDirectory[imageName] = base64;
}

- (NSString *)base64ForImageName : (NSString *)imageName {
    return self.imageDirectory[imageName];
}

- (NSString *)base64DataForImage : (UIImage *)image {
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

@end
