//
//  MagnifierViewController.h
//  MegaTunes Player
//
//  Created by Lori Hill on 10/10/12.
//
//
@class TextMagnifierViewController;
//@class ScrollLabel;

@protocol TextMagnifierViewControllerDelegate <NSObject>

- (void)textMagnifierViewControllerDidCancel: (TextMagnifierViewController *)controller;

@end

@interface TextMagnifierViewController : UIViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) id <TextMagnifierViewControllerDelegate> delegate;

@property (strong, nonatomic) NSString *textToMagnify;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *magnifiedLabel;

- (IBAction)tapDetected:(UITapGestureRecognizer *)sender;
- (IBAction)swipeDetected:(UIPanGestureRecognizer *)sender;


@end