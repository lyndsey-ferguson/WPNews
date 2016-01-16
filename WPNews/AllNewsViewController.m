//
//  AllNewsViewController.m
//  WPNews
//
//  Created by Lyndsey on 1/16/16.
//  Copyright © 2016 Lyndsey Ferguson Software. All rights reserved.
//

#import "AllNewsViewController.h"


static NSString* kWashingtonPostURLString = @"http://www.washingtonpost.com/wp-srv/simulation/simulation_test.json";

@interface AllNewsViewController ()
@property (strong, nonatomic) NSArray* newsArticles;
@end

@implementation AllNewsViewController

- (void)setNewsArticles:(NSArray *)newsArticles {
    if (_newsArticles != newsArticles) {
        _newsArticles = newsArticles;
        // todo: add table reload datacall
    }
}

- (void)updateNewsArticlesFromData:(NSData *)downloadedNewsArticlesData {
    self.newsArticles = [NSJSONSerialization JSONObjectWithData:downloadedNewsArticlesData
                                                     options:kNilOptions
                                                       error:nil];
}

- (void)updateNewsFromNetData:(NSData *)data {
    self.newsArticles = [NSJSONSerialization JSONObjectWithData:data
                                                        options:kNilOptions
                                                          error:nil];
}

- (BOOL)isTesting {
    return YES;
    
#if 0
    static dispatch_once_t tag;
    dispatch_once(&tag, ^{
        NSArray* launchArguments = [NSProcessInfo processInfo].arguments;
        [launchArguments enumerateObjectsUsingBlock:^(NSString*  _Nonnull argument, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([@"TESTING" isEqualToString:argument]) {
                _testing = YES;
                *stop = YES;
            }
        }];
    });
    return _testing;
#endif
}

- (void)loadTestingData {
    NSString* mockedJsonFilepath = [[NSBundle mainBundle] pathForResource:@"mocked_response"
                                                                   ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:mockedJsonFilepath];
    [self updateNewsFromNetData:data];
}

- (void)loadData {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kWashingtonPostURLString]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self updateNewsFromNetData:data];
    }] resume];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isTesting) {
        [self loadTestingData];
    }
    else {
        [self loadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
