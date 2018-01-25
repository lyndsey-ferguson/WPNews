//
//  AllNewsViewController.m
//  WPNews
//
//  Created by Lyndsey on 1/16/16.
//  Copyright © 2016 Lyndsey Ferguson Software. All rights reserved.
//

#import "AllNewsViewController.h"
#import "NSAttributedString+HTML.h"
#import "NewsArticleViewController.h"

static NSString* kWashingtonPostURLString = @"http://www.washingtonpost.com/wp-srv/simulation/simulation_test.json";

typedef NS_ENUM(NSInteger, AllNewsViewSortStyle) {
    AllNewsViewSortStyleDate,
    AllNewsViewSortStyleHeadline,
};

@interface AllNewsViewController ()
@property (strong, nonatomic) NSArray* newsArticles;
@property (weak, nonatomic) IBOutlet UITableView *newsArticlesTableView;
@property (weak, nonatomic) IBOutlet UIButton *sortByHeadlineButton;
@property (weak, nonatomic) IBOutlet UIButton *sortByDateButton;
@property (assign, nonatomic, getter=isTesting) BOOL testing;
@property (assign, nonatomic) AllNewsViewSortStyle sortStyle;
@end

@implementation AllNewsViewController

- (void)sortNewsArticles {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-dd-MM H:mm:ss"]; //2014-02-12 20:29:36
    
    NSArray* sortedNewsArticles = [_newsArticles sortedArrayUsingComparator:^NSComparisonResult(NSDictionary*  _Nonnull article1, NSDictionary*  _Nonnull article2) {
        
        switch (self.sortStyle) {
            case AllNewsViewSortStyleHeadline:
                return [article1[@"title"] compare:article2[@"title"] options:NSCaseInsensitiveSearch];
                break;
            case AllNewsViewSortStyleDate: {
                NSDate *date1 = [dateFormat dateFromString:article1[@"date"]];
                NSDate *date2 = [dateFormat dateFromString:article2[@"date"]];
                return [date2 compare:date1];
                break;
            }
            default:
                break;
        }
        
    }];
    _newsArticles = sortedNewsArticles;
}

- (void)setNewsArticles:(NSArray *)newsArticles {
    if (_newsArticles != newsArticles) {
        _newsArticles = newsArticles;
        
        [self sortNewsArticles];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.newsArticlesTableView reloadData];
        });
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
                                                          error:nil][@"posts"];
}

- (BOOL)isTesting {
    static dispatch_once_t tag;
    dispatch_once(&tag, ^{
        NSArray* launchArguments = [NSProcessInfo processInfo].arguments;
        [launchArguments enumerateObjectsUsingBlock:^(NSString* _Nonnull argument, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([@"TESTING" isEqualToString:argument]) {
                _testing = YES;
                *stop = YES;
            }
        }];
    });
    return _testing;
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
        if (data) {
            [self updateNewsFromNetData:data];
        }
        else {
            // TODO: Add code to display the error and disallow selection and view of non-existent details
        }
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
    self.newsArticlesTableView.dataSource = self;
    self.newsArticlesTableView.accessibilityIdentifier = @"news-article-table";
    [self updateSortButtonEnableState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateSortButtonEnableState {
    self.sortByDateButton.enabled = (self.sortStyle != AllNewsViewSortStyleDate);
    self.sortByHeadlineButton.enabled = (self.sortStyle != AllNewsViewSortStyleHeadline);
}

- (void)sortButtonTapped {
    [self sortNewsArticles];
    [self updateSortButtonEnableState];
    [self.newsArticlesTableView reloadData];
}

- (IBAction)sortByDateButtonTapped:(id)sender {
    self.sortStyle = AllNewsViewSortStyleDate;
    self.sortByDateButton.enabled = NO;
    [self sortButtonTapped];
}

- (IBAction)sortByHeadlineButtonTapped:(id)sender {
    self.sortStyle = AllNewsViewSortStyleHeadline;
    [self sortButtonTapped];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"show-news-article"]) {
        NewsArticleViewController* viewController = [segue destinationViewController];
        
        NSIndexPath* path = [self.newsArticlesTableView indexPathForSelectedRow];
        NSString* content = self.newsArticles[path.row][@"content"];
        viewController.htmlContent = content;
    }
}

+ (NSAttributedString*)cleanUpTitleString:(NSAttributedString*)titleString {
    NSMutableAttributedString* cleanedUpString = [titleString mutableCopy];
    [cleanedUpString beginEditing];
    __block BOOL found = NO;
    
    UIFont* systemFont = [UIFont systemFontOfSize:14];
    [cleanedUpString enumerateAttribute:NSFontAttributeName
                                inRange:NSMakeRange(0, cleanedUpString.length)
                                options:0
                             usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value) {
            [cleanedUpString removeAttribute:NSFontAttributeName range:range];
            [cleanedUpString addAttribute:NSFontAttributeName value:systemFont range:range];
            found = YES;
        }
    }];
    [cleanedUpString endEditing];
    return cleanedUpString;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.newsArticles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"newsArticleTableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"newsArticleTableViewCell"];
    }
    
    NSDictionary* newsArticle = self.newsArticles[indexPath.row];
    NSAttributedString* title = [NSAttributedString attributedStringFromHTMLString:newsArticle[@"title"]];
    cell.textLabel.attributedText = [AllNewsViewController cleanUpTitleString:title];
    cell.textLabel.accessibilityIdentifier = @"headline";
    cell.detailTextLabel.text = newsArticle[@"date"];
    cell.detailTextLabel.accessibilityIdentifier = @"date";
    cell.detailTextLabel.isAccessibilityElement = YES;
    return cell;
}


@end
