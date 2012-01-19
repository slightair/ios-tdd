//
//  TwitterClientTest.m
//  TDD
//
//  Created by KAZUMA Ukyo on 12/01/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TwitterClientTest.h"
#import "TwitterClient.h"
#import <objc/runtime.h>

@interface NSURLRequest (mock)
- (NSURL *)publicTimeLineURL;
- (NSURL *)searchWithWordURL;
- (NSURL *)searchWithWordTwitterBugsURL;
- (NSURL *)tweetForIndexPathURL;
@end

@implementation NSURLRequest (mock)
- (NSURL *)publicTimeLineURL
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"public_time_line" ofType:@"json"];
    return [NSURL URLWithString:path];
}

- (NSURL *)searchWithWordURL
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"search_yaakaito" ofType:@"json"];
    return [NSURL URLWithString:path];
}

- (NSURL *)searchWithWordTwitterBugsURL
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"search_ios" ofType:@"json"];
    return [NSURL URLWithString:path];
}

- (NSURL *)tweetForIndexPathURL
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"public_time_line" ofType:@"json"];
    return [NSURL URLWithString:path];
}

@end

@implementation TwitterClientTest

//- (void)testMock
//{
//    TwitterClient *noMock = [[TwitterClient alloc] init];
//    
//    STAssertEqualObjects(@"モックしない", [noMock __response:@"モックしない"], @"モックしないはずなので モックしない になってほしい");
//    
//    [noMock release];
//    
//    TwitterClient *mock = [[TwitterClient alloc] init];
//    [mock __setMockResponse:@"モック"];
//    
//    STAssertEqualObjects(@"モック", [mock __response:@"モックできていない"], @"モックするので モック になってほしい");
//    
//    [mock release];
//}

- (void)testRequestPublicTimeline
{
    TwitterClient *client = [[TwitterClient alloc] init];

    __block BOOL calledBack = NO;
    
//    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"public_time_line" ofType:@"json"];
//    NSData *jsonData = [NSData dataWithContentsOfFile:path];
//    NSError *error=nil;
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];    
//    STAssertNil(error, @"jsonの読み込みに失敗");
//
//    [client __setMockResponse:json];
    
    Method originalURL = class_getInstanceMethod([NSURLRequest class], @selector(URL));
    Method mockURL = class_getInstanceMethod([NSURLRequest class], @selector(publicTimelineURL));
    method_exchangeImplementations(originalURL, mockURL);
    
    [client requestPublicTimeline:^(TwitterClientResponseStatus status) {

        calledBack = YES;
    }];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while (calledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    STAssertEquals(20U, [[client tweets] count], @"20件取得するはずなのでcountが20になってほしい");
    
    [client release];
    
    method_exchangeImplementations(mockURL, originalURL);
}

- (void)testSearchWithWord
{
    TwitterClient *client = [[TwitterClient alloc] init];
    
    __block BOOL calledBack = NO;
    
//    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"search_yaakaito" ofType:@"json"];
//    NSData *jsonData = [NSData dataWithContentsOfFile:path];
//    NSError *error=nil;
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];    
//    STAssertNil(error, @"jsonの読み込みに失敗");
//    
//    [client __setMockResponse:json];
    
    Method originalURL = class_getInstanceMethod([NSURLRequest class], @selector(URL));
    Method mockURL = class_getInstanceMethod([NSURLRequest class], @selector(searchWithWordURL));
    method_exchangeImplementations(originalURL, mockURL);
    
    [client searchWithString:@"yaakaito" callback:^(TwitterClientResponseStatus status){
        calledBack = YES;
    }];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while (calledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    STAssertTrue([[client tweets] count] <= 20, @"20件以下で検索結果を取得してほしい");
    
    [client release];
    
    method_exchangeImplementations(mockURL, originalURL);
}

- (void)testSearchWithWord_TwittersBug
{
    TwitterClient *client = [[TwitterClient alloc] init];
    
    __block BOOL calledBack = NO;
    
//    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"search_ios" ofType:@"json"];
//    NSData *jsonData = [NSData dataWithContentsOfFile:path];
//    NSError *error=nil;
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];    
//    STAssertEquals(23U, [[json objectForKey:@"results"] count], @"23個あるか確認");
//    STAssertNil(error, @"jsonの読み込みに失敗");
//    
//    [client __setMockResponse:json];
    
    Method originalURL = class_getInstanceMethod([NSURLRequest class], @selector(URL));
    Method mockURL = class_getInstanceMethod([NSURLRequest class], @selector(searchWithWordTwittersBugURL));
    method_exchangeImplementations(originalURL, mockURL);
    
    [client searchWithString:@"iOS" callback:^(TwitterClientResponseStatus status){
        calledBack = YES;
    }];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while (calledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    STAssertEquals(20U, [[client tweets] count], @"20件以上取得するはずなので20個にまるめてほしい :-|");
    
    [client release];
    
    method_exchangeImplementations(mockURL, originalURL);
}

- (void)testTweetForIndexPath
{
    TwitterClient *client = [[TwitterClient alloc] init];

    __block BOOL calledBack = NO;
    
//    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"public_time_line" ofType:@"json"];
//    NSData *jsonData = [NSData dataWithContentsOfFile:path];
//    NSError *error=nil;
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];    
//    STAssertNil(error, @"jsonの読み込みに失敗");
//    
//    [client __setMockResponse:json];
    
    Method originalURL = class_getInstanceMethod([NSURLRequest class], @selector(URL));
    Method mockURL = class_getInstanceMethod([NSURLRequest class], @selector(tweetForIndexPathURL));
    method_exchangeImplementations(originalURL, mockURL);

    [client requestPublicTimeline:^(TwitterClientResponseStatus status) {
        
        calledBack = YES;
    }];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while (calledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    Tweet *tweet = [client tweetForIndexPath:indexPath];
    
    STAssertNotNil(tweet, @"なんか帰ってきてほしい");
    
    [client release];
    
    method_exchangeImplementations(mockURL, originalURL);
}

- (void)testTweetForIndexPath_OverIndex
{
    TwitterClient *client = [[TwitterClient alloc] init];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    Tweet *tweet = [client tweetForIndexPath:indexPath];
    
    STAssertNil(tweet, @"何も返ってこないはず");
    
    [client release];
}

@end
