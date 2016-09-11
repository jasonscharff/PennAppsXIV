//
//  NTESocketManager.m
//  PennAppsXIV
//
//  Created by Jason Scharff on 9/10/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "NTESocketManager.h"

@import SocketIO;

@interface NTESocketManager()

@property (nonatomic, strong) SocketIOClient *socketIOClient;

@end

@implementation NTESocketManager

+ (instancetype)sharedSocket {
    static dispatch_once_t once;
    static NTESocketManager *_sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (void)setBaseURL:(NSURL *)baseURL {
    _baseURL = baseURL;
    [self configureSocket];
}

- (void)configureSocket {
    if(self.socketIOClient) {
        [self.socketIOClient disconnect];
    }
    NSDictionary *options = @{@"secure" : @NO,
                              @"log" : @NO};
    
    self.socketIOClient = [[SocketIOClient alloc]initWithSocketURL:_baseURL config:options];
    
    [self.socketIOClient on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"connect data = %@", data);
    }];
    
    [self.socketIOClient on:@"diff" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
    }];
    
    
    
}

@end
