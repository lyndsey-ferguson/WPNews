//
//  NewsArticleViewController.m
//  WPNews
//
//  Created by Lyndsey on 1/16/16.
//  Copyright © 2016 Lyndsey Ferguson Software. All rights reserved.
//

#import "NewsArticleViewController.h"
#import "NSAttributedString+HTML.h"

@interface NewsArticleViewController ()
@property (weak, nonatomic) IBOutlet UITextView *newsArticleTextView;

@end

@implementation NewsArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.newsArticleTextView.attributedText = [NSAttributedString attributedStringFromHTMLString:self.htmlContent];
    self.newsArticleTextView.accessibilityIdentifier = @"body-text";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
