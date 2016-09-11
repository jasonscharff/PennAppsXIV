//
//  NTESocketManager.m
//  PennAppsXIV
//
//  Created by Jason Scharff on 9/10/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "NTESocketManager.h"

#import "NTEDisplayViewController.h"
#import "NTENote.h"
#import "NTEImageStoreController.h"


@import SocketIO;

@interface NTESocketManager()

@property (nonatomic, strong) SocketIOClient *socketIOClient;

@end

NSString * const kNTEDidLoseSocketConnection = @"com.nte.socket.lost";

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
    if(self.socketIOClient &&
       (self.socketIOClient.status == SocketIOClientStatusConnected ||
       self.socketIOClient.status == SocketIOClientStatusConnecting)) {
        
        [self.socketIOClient disconnect];
    }
    NSDictionary *options = @{@"secure" : @NO,
                              @"log" : @NO};
    
    self.socketIOClient = [[SocketIOClient alloc]initWithSocketURL:_baseURL config:options];
    
    [self.socketIOClient on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"data onc = %@", data);
        NSDictionary *dictionary = data[0];
        NTENote *note = [[NTENote alloc]initWithDictonary:dictionary];
        [NTEDisplayViewController sharedNTEDisplayViewController].note = note;
    }];
    
    [self.socketIOClient on:@"data" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        NSLog(@"data update = %@", data);
    }];
    
    [self.socketIOClient on:@"disconnect" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
       //Go back to the qr code manager.
        
    }];
    
    [self.socketIOClient connect];
    
}

- (void)uploadImage : (UIImage *)image
              order : (int)order{
    NSString *base64 = [[NTEImageStoreController sharedImageStoreController]base64DataForImage:image];
    NSDictionary *parameters = @{@"image" : base64,
                                 @"order" : @(order)};
    [self.socketIOClient emit:@"imageUpdate" with:@[parameters]];
}

@end
