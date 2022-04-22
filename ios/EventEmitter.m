//
//  EventEmitter.m
//  Chess032Wallet
//
//  Created by Marcos Rodriguez on 12/25/20.
//  Copyright © 2020 Chess032Wallet. All rights reserved.
//

#import "EventEmitter.h"

static EventEmitter *sharedInstance;

@implementation EventEmitter


RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

+ (EventEmitter *)sharedInstance {
    return sharedInstance;
}

- (instancetype)init {
    sharedInstance = [super init];
    return sharedInstance;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"onNotificationReceived",@"openSettings"];
}

- (void)sendNotification:(NSDictionary *)userInfo
{
  [sharedInstance sendEventWithName:@"onNotificationReceived" body:userInfo];
}


- (void)openSettings
{
  [sharedInstance sendEventWithName:@"openSettings" body:nil];
}


@end
