//
//  NTEDisplayViewController.h
//  PennAppsXIV
//
//  Created by Jason Scharff on 9/10/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NTENote;

@interface NTEDisplayViewController : UIViewController

+ (instancetype)sharedNTEDisplayViewController;
@property (nonatomic) NTENote *note;
    
@end
