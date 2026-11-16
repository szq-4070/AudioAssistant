#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static NSString * const AAButtonTagKey = @"com.szq.audioassistant.button";
static BOOL AAInstalled = NO;

static UIViewController *AATopViewController(void) {
    UIApplication *app = UIApplication.sharedApplication;
    UIWindow *window = nil;

    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in app.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class]) continue;
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *candidate in windowScene.windows) {
                if (candidate.isKeyWindow) { window = candidate; break; }
            }
            if (window) break;
        }
    }
    if (!window) window = app.keyWindow;
    UIViewController *vc = window.rootViewController;
    while (vc) {
        if (vc.presentedViewController) vc = vc.presentedViewController;
        else if ([vc isKindOfClass:UINavigationController.class])
            vc = ((UINavigationController *)vc).visibleViewController;
        else if ([vc isKindOfClass:UITabBarController.class])
            vc = ((UITabBarController *)vc).selectedViewController;
        else break;
    }
    return vc;
}

@interface AAHomeController : UIViewController
@end

@implementation AAHomeController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"音频助手";

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.text = @"音频助手";
    title.font = [UIFont boldSystemFontOfSize:28];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:title];

    UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectZero];
    subtitle.text = @"本地音频管理与语音发送";
    subtitle.textColor = UIColor.secondaryLabelColor;
    subtitle.font = [UIFont systemFontOfSize:14];
    subtitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:subtitle];

    UIStackView *stack = [[UIStackView alloc] initWithFrame:CGRectZero];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 14;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];

    NSArray *items = @[
        @[@"folder", @"选择本地音频", @"第一版暂未接入文件选择器"],
        @[@"play.circle", @"试听音频", @"等待导入音频"],
        @[@"paperplane", @"发送语音", @"第一版暂未连接抖音发送接口"]
    ];
    for (NSArray *item in items) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.backgroundColor = [UIColor secondarySystemBackgroundColor];
        button.layer.cornerRadius = 13;
        button.tag = [items indexOfObject:item];
        [button setTitle:[NSString stringWithFormat:@"  %@    %@", item[0], item[1]]
                forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        button.contentEdgeInsets = UIEdgeInsetsMake(17, 14, 17, 14);
        [button addTarget:self action:@selector(showPlaceholder:) forControlEvents:UIControlEventTouchUpInside];
        [stack addArrangedSubview:button];
    }

    [NSLayoutConstraint activateConstraints:@[
        [title.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:32],
        [title.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24],
        [subtitle.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:8],
        [subtitle.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [stack.topAnchor constraintEqualToAnchor:subtitle.bottomAnchor constant:30],
        [stack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [stack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
}
- (void)showPlaceholder:(UIButton *)sender {
    NSArray *messages = @[
        @"文件选择功能将在下一阶段接入。",
        @"试听功能将在导入音频后接入。",
        @"发送功能需要先分析并复用抖音原生语音消息流程。"
    ];
    NSInteger index = MIN(sender.tag, (NSInteger)messages.count - 1);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"功能尚未接入"
        message:messages[index] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
@end

static void AAOpenPanel(void) {
    UIViewController *top = AATopViewController();
    if (!top || [top isKindOfClass:AAHomeController.class]) return;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[AAHomeController new]];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    [top presentViewController:nav animated:YES completion:nil];
}

static void AAInstallEntry(void) {
    if (AAInstalled) return;
    UIApplication *app = UIApplication.sharedApplication;
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in app.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class]) continue;
            for (UIWindow *candidate in ((UIWindowScene *)scene).windows) {
                if (candidate.isKeyWindow) { window = candidate; break; }
            }
            if (window) break;
        }
    }
    if (!window) window = app.keyWindow;
    if (!window) return;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(window.bounds.size.width - 112, window.safeAreaInsets.top + 90, 96, 38);
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    button.backgroundColor = [UIColor systemBlueColor];
    button.layer.cornerRadius = 19;
    [button setTitle:@"音频工具" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    [button addTarget:[AAActionTarget shared] action:@selector(open) forControlEvents:UIControlEventTouchUpInside];
    button.accessibilityIdentifier = AAButtonTagKey;
    [window addSubview:button];
    AAInstalled = YES;
}

@interface AAActionTarget : NSObject
+ (instancetype)shared;
- (void)open;
@end
@implementation AAActionTarget
+ (instancetype)shared { static AAActionTarget *t; static dispatch_once_t once; dispatch_once(&once, ^{ t=[self new]; }); return t; }
- (void)open { AAOpenPanel(); }
@end

%ctor {
    @autoreleasepool {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                object:nil queue:NSOperationQueue.mainQueue usingBlock:^(__unused NSNotification *note) {
                    AAInstallEntry();
                }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{ AAInstallEntry(); });
        });
    }
}
