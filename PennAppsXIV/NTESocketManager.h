//
//  NTESocketManager.h
//  PennAppsXIV
//
//  Created by Jason Scharff on 9/10/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

@interface NTESocketManager : NSObject

+ (instancetype)sharedSocket;

- (void)uploadImage : (UIImage *)image
              order : (int)order;

@property (nonatomic, strong) NSURL *baseURL;



@end
