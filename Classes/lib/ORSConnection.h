//
//  ORSConnection.h
//  
//
//  Created by Ryan Daigle on 7/30/08.
//  Copyright 2008 yFactorial, LLC. All rights reserved.
//

@class ORSResponse;

@interface ORSConnection : NSObject
+ (void) setTimeout:(float)timeout;
+ (float) timeout;
+ (ORSResponse *)post:(NSString *)body to:(NSString *)url;
+ (ORSResponse *)post:(NSString *)body to:(NSString *)url withUser:(NSString *)user andPassword:(NSString *)password;
+ (ORSResponse *)get:(NSString *)url withUser:(NSString *)user andPassword:(NSString *)password;
+ (ORSResponse *)get:(NSString *)url;
+ (ORSResponse *)put:(NSString *)body to:(NSString *)url withUser:(NSString *)user andPassword:(NSString *)password;
+ (ORSResponse *)delete:(NSString *)url withUser:(NSString *)user andPassword:(NSString *)password;

+ (void) cancelAllActiveConnections;

@end
