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
#import "NTEMarkdownRenderController.h"


@import SocketIO;

@interface NTESocketManager()

@property (nonatomic, strong) SocketIOClient *socketIOClient;
@property (nonatomic) dispatch_queue_t socketQueue;

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

- (instancetype)init {
    self = [super init];
    if(self) {
        self.socketQueue = dispatch_queue_create("com.notebook.socket", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)setBaseURL:(NSURL *)baseURL {
    _baseURL = baseURL;
    [self configureSocket];
}

- (void)configureSocket {
    dispatch_async(self.socketQueue, ^{
        if(self.socketIOClient &&
           (self.socketIOClient.status == SocketIOClientStatusConnected ||
            self.socketIOClient.status == SocketIOClientStatusConnecting)) {
               
               [self.socketIOClient disconnect];
           }
        
        self.socketIOClient = [[SocketIOClient alloc]initWithSocketURL:_baseURL config:nil];
        
        [self.socketIOClient on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
            
        }];
        
        [self.socketIOClient on:@"init" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
            if(data.count > 0) {
                NSDictionary *dictionary = data[0];
                [[NTENote sharedNote]setupWithDictionary:dictionary];
                [NTEDisplayViewController sharedNTEDisplayViewController].note = [NTENote sharedNote];
            }
        }];
        
        [self.socketIOClient on:@"data" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
            NSLog(@"data update = %@", data);
            if(data.count > 0) {
                NSDictionary *dictionary = data[0];
                [[NTENote sharedNote]setupWithDictionary:dictionary];
                [NTEDisplayViewController sharedNTEDisplayViewController].note = [NTENote sharedNote];
            }
        }];
        
        [self.socketIOClient on:@"disconnect" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
            //Go back to the qr code manager.
            
        }];
        
        [self.socketIOClient on:@"error" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
            NSLog(@"ERROR");
        }];
        
        [self.socketIOClient connect];
    });
}

- (void)uploadImage : (UIImage *)image
              order : (int)order {
    dispatch_async(self.socketQueue, ^{
        NSString *base64 = [[NTEImageStoreController sharedImageStoreController]base64DataForImage:image];
        NSDictionary *parameters = @{@"image" : base64,
                                     @"order" : @(order)};
        [self.socketIOClient emit:@"imageUpdate" with:@[parameters]];
    });
}

@end
