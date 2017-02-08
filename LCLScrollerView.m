//
//  LCLScrollerView.m
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
#import "LCLScrollerView.h"
#import "UIImageView+WebCache.h"
@implementation LCLScrollerView
@synthesize delegate;
@synthesize move;

-(id)initWithFrameRect:(CGRect)rect ImageArray:(NSArray *)imgArr TitleArray:(NSArray *)titArr
{
    
	if ((self=[super initWithFrame:rect])) {
        
        Drag = NO;
        self.userInteractionEnabled=YES;
        titleArray= [NSMutableArray arrayWithArray:titArr];//[titArr retain]
        NSMutableArray *tempArray=[NSMutableArray arrayWithArray:imgArr];
        [tempArray insertObject:[imgArr objectAtIndex:([imgArr count]-1)] atIndex:0];
        [tempArray addObject:[imgArr objectAtIndex:0]];
		imageArray=[NSArray arrayWithArray:tempArray];
		viewSize=rect;
        NSUInteger pageCount=[imageArray count];
        scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, viewSize.size.width, viewSize.size.height)];
        limitView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, viewSize.size.width, viewSize.size.height)];
        [limitView setHidden:YES];
        scrollView.pagingEnabled = YES;
        scrollView.contentSize = CGSizeMake(viewSize.size.width * pageCount, viewSize.size.height);
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.scrollsToTop = NO;
        scrollView.delegate = self;
        for (int i=0; i<pageCount; i++) {
            NSString *imgURL=[imageArray objectAtIndex:i];
            UIImageView *imgView=[[UIImageView alloc] init] ;
            if ([imgURL hasPrefix:@"http"]) {
                //网络图片 请使用ego异步图片库
                [[SDWebImageManager sharedManager].imageDownloader setValue: nil forHTTPHeaderField:@"Accept"];
                [imgView sd_setImageWithURL:[NSURL URLWithString:imgURL]];
            }
            else
            {
                
                UIImage *img=[UIImage imageNamed:[imageArray objectAtIndex:i]];
                [imgView setImage:img];
            }
            
            [imgView setFrame:CGRectMake(viewSize.size.width*i, 0,viewSize.size.width, viewSize.size.height)];
            imgView.tag=i;
            UITapGestureRecognizer *Tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagePressed:)];
            [Tap setNumberOfTapsRequired:1];
            [Tap setNumberOfTouchesRequired:1];
            imgView.userInteractionEnabled=YES;
            [imgView addGestureRecognizer:Tap];
            [scrollView addSubview:imgView];
        }
        //其实是31231 结构 开始在1
        [scrollView setContentOffset:CGPointMake(viewSize.size.width, 0)];
        [self addSubview:scrollView];
        [self addSubview:limitView];
        
        
        //说明文字层
        UIView *noteView=[[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-33,self.bounds.size.width,33)];
        [noteView setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5]];
        float pageControlWidth=(pageCount-2)*10.0f+40.f;
        float pagecontrolHeight=20.0f;
        pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0, 6, self.bounds.size.width, pagecontrolHeight)];
        pageControl.currentPage=0;
        pageControl.numberOfPages=(pageCount-2);
        pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
        [noteView addSubview:pageControl];
        
        noteTitle=[[UILabel alloc] initWithFrame:CGRectMake(5, 12, self.frame.size.width, 20)];
        [noteTitle setText:[titleArray objectAtIndex:0]];
        [noteTitle setBackgroundColor:[UIColor clearColor]];
        [noteTitle setFont:[UIFont systemFontOfSize:13]];
        [noteTitle setTextAlignment:NSTextAlignmentCenter];
        //[noteView addSubview:noteTitle];
        [self addSubview:noteView];
	}
	return self;
}





- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    currentPageIndex=page;
       
    pageControl.currentPage=(page-1);
    int titleIndex=page-1;
    if (titleIndex==[titleArray count]) {
        titleIndex=0;
    }
    if (titleIndex<0) {
        titleIndex=[titleArray count]-1;
    }
    [noteTitle setText:[titleArray objectAtIndex:titleIndex]];
}
#pragma mark - 还原
- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView
{
    //NSLog(@"currentPageIndex = %d",currentPageIndex);
    if (currentPageIndex==0) {
      
        [_scrollView setContentOffset:CGPointMake(([imageArray count]-2)*viewSize.size.width, 0)];
    }
    if (currentPageIndex==([imageArray count]-1)) {
       
        [_scrollView setContentOffset:CGPointMake(viewSize.size.width, 0)];
        
    }

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)_scrollView{
   // NSLog(@"currentPageIndex = %d",currentPageIndex);
    if (currentPageIndex==0) {
        
        [_scrollView setContentOffset:CGPointMake(([imageArray count]-2)*viewSize.size.width, 0)];
    }
    if (currentPageIndex==([imageArray count]-1)) {
        
        [_scrollView setContentOffset:CGPointMake(viewSize.size.width, 0)];
        
    }
}
#pragma mark - 拖拽
// 开始拖拽的时候调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //    开启定时器
    if (Drag) {
        [self addTimer];
    }
    
}

/**
 *  开启定时器
 */
- (void)addTimer{
    Drag = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

#pragma mark - 逻辑
- (void)nextImage
{
   
    currentPageIndex++;
    [UIView animateWithDuration:0.1 animations:^{
        [limitView setHidden:NO];
        [limitView setAlpha:1.0];
    } completion:^(BOOL finished) {
        [limitView setAlpha:0.0];
        [limitView setHidden:YES];
    }];

    
    CGFloat x = (currentPageIndex) * scrollView.frame.size.width;
    [scrollView scrollRectToVisible:CGRectMake( x, 0, scrollView.frame.size.width, scrollView.frame.size.height) animated:YES];
}

/**
 *  关闭定时器
 */
- (void)removeTimer
{
    [timer invalidate];
}

/**
 *  优化体验
 */
- (void)imagePressed:(UITapGestureRecognizer *)sender
{

    if ([delegate respondsToSelector:@selector(ScrollerViewDidClicked:)]) {
        [delegate ScrollerViewDidClicked:sender.view.tag];
    }
}


@end
