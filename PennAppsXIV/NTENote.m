//
//  NTENote.m
//  PennAppsXIV
//
//  Created by Jason Scharff on 9/10/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "NTENote.h"

@implementation NTENote
    
- (instancetype)initWithDictonary : (NSDictionary *)dictionary {
    self = [super init];
    if(self) {
        [self setupWithDictionary:dictionary];
    }
    return self;
}
    
- (void)setupWithDictionary : (NSDictionary *)dictionary {
    
}
    
@end
