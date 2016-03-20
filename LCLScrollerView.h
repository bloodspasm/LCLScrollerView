//
//  LCLScrollerView.h
//  
//
//  Created by 覗文君 on 2015-06-06
//
//  2015-06-06 08:04:50 覗文君改 添加自动轮播功能感谢原作者(Ethan)
//  2015-06-07 22:33:38 修复拖拽时图片自动轮播问题
//  2015-06-24 14:55:30 增加不可轮播不可拖
//  2015-06-26 14:47:23 修复无法点击bug
//  2015-07-16 15:43:30 修复动画白边
//  2015-09-02 23:42:12 修复内存ARC
//  2016-03-20 23:44:01 修复SWD的https支持
#import <UIKit/UIKit.h>

@protocol LCLScrollerViewDelegate <NSObject>
@optional
-(void)ScrollerViewDidClicked:(NSUInteger)index;
@end

@interface LCLScrollerView : UIView<UIScrollViewDelegate> {
	CGRect viewSize;
	UIScrollView *scrollView;
    UIView  *limitView;
    NSTimer *timer;
	NSArray *imageArray;
    NSArray *titleArray;
    UIPageControl *pageControl;
    id<LCLScrollerViewDelegate> delegate;
    int currentPageIndex;
    UILabel *noteTitle;
    BOOL Drag;
}
@property(nonatomic,strong)id<LCLScrollerViewDelegate> delegate;
@property(nonatomic,assign)BOOL move;
-(id)initWithFrameRect:(CGRect)rect ImageArray:(NSArray *)imgArr TitleArray:(NSArray *)titArr;
- (void)removeTimer;
- (void)addTimer;
@end
