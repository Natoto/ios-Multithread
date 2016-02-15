//
//  gcdfunViewController.m
//  多线程
//
//  Created by zeno on 16/2/14.
//  Copyright © 2016年 peng. All rights reserved.
//

//--------------单例模式--------------------

#if __has_feature(objc_instancetype)
#undef	AS_SINGLETON
#define AS_SINGLETON( ... ) \
- (instancetype)sharedInstance; \
+ (instancetype)sharedInstance;

#undef	DEF_SINGLETON
#define DEF_SINGLETON \
- (instancetype)sharedInstance \
{ \
return [[self class] sharedInstance]; \
} \
+ (instancetype)sharedInstance \
{ \
static dispatch_once_t once; \
static id __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } ); \
return __singleton__; \
}
#undef	DEF_SINGLETON
#define DEF_SINGLETON( ... ) \
- (instancetype)sharedInstance \
{ \
return [[self class] sharedInstance]; \
} \
+ (instancetype)sharedInstance \
{ \
static dispatch_once_t once; \
static id __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } ); \
return __singleton__; \
}

#else	// #if __has_feature(objc_instancetype)
#undef	AS_SINGLETON
#define AS_SINGLETON( __class ) \
- (__class *)sharedInstance; \
+ (__class *)sharedInstance;

#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
- (__class *)sharedInstance \
{ \
return [__class sharedInstance]; \
} \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[[self class] alloc] init]; } ); \
return __singleton__; \
}

#endif	// #if __has_feature(objc_instancetype)

#import "gcdfunViewController.h"

#pragma mark - 单例模式👆 👇
@interface Person:NSObject
//+ (instancetype)shareInstance;
AS_SINGLETON(Person)
@end

@implementation Person
DEF_SINGLETON(Person)

/*
+ (instancetype)shareInstance
{
    static id _person;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _person = [[super alloc] init];
    });
    return _person;
}
*/
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static id _person;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _person = [super allocWithZone:zone];
    });
    return _person;
}

- (id)copy
{
    return [Person sharedInstance];
}

@end

@interface gcdfunViewController ()
{
//    dispatch_source_t _timer;
}
@property(nonatomic,strong) UIImageView * imageView;
@end

@implementation gcdfunViewController

-(UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.frame = CGRectMake(0, 0, 300, 300);
        _imageView.center = self.view.center;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_imageView];
    }
    return _imageView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * button = [self.view viewWithTag:2222];
    if (!button) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(50, 100, 100, 30);
        button.center = CGPointMake(self.view.center.x, 100);
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        button.tag = 2222;
        [self.view addSubview:button];
        [button setTitle:@"点击倒计时" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self testdispatch_after];
//    [self testbarrier];
//    [self testdispatch_apply];
    [self demo_combineimage];
}

#pragma mark - dispatch_apply
//示例小程序：将一个文件夹中的图片剪切到另一个文件夹
-(void)testdispatch_apply
{
    // 将图片剪切到另一个文件夹里
    NSString *from = @"/Users/Ammar/Pictures/壁纸";
    NSString *to = @"/Users/Ammar/Pictures/to";
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *subPaths = [manager subpathsAtPath:from];
    
    // 快速迭代
    dispatch_apply(subPaths.count, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index) {
        NSLog(@"%@ - %zd", [NSThread currentThread], index);
        NSString *subPath = subPaths[index];
        NSString *fromPath = [from stringByAppendingPathComponent:subPath];
        NSString *toPath = [to stringByAppendingPathComponent:subPath];
        
        // 剪切
        [manager moveItemAtPath:fromPath toPath:toPath error:nil];
        NSLog(@"%@---%zd", [NSThread currentThread], index);
    });

    //作用是把指定次数指定的block添加到queue中, 第一个参数是迭代次数，第二个是所在的队列，第三个是当前索引，dispatch_apply可以利用多核的优势，所以输出的index顺序不是一定的
    //重复执行block，需要注意的是这个方法是同步返回，也就是说等到所有block执行完毕才返回，如需异步返回则嵌套在dispatch_async中来使用。多个block的运行是否并发或串行执行也依赖queue的是否并发或串行。
    dispatch_apply(10, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index) {
        NSLog(@"dispatch_apply %zd",index);
    });
    /*输出结果 无序的
     2016-02-15 10:15:21.229 多线程[4346:48391] dispatch_apply 0
     2016-02-15 10:15:21.229 多线程[4346:48784] dispatch_apply 1
     2016-02-15 10:15:21.230 多线程[4346:48830] dispatch_apply 2
     2016-02-15 10:15:21.230 多线程[4346:48391] dispatch_apply 4
     2016-02-15 10:15:21.230 多线程[4346:48829] dispatch_apply 3
     2016-02-15 10:15:21.231 多线程[4346:48391] dispatch_apply 6
     2016-02-15 10:15:21.231 多线程[4346:48391] dispatch_apply 9
     2016-02-15 10:15:21.230 多线程[4346:48784] dispatch_apply 5
     2016-02-15 10:15:21.231 多线程[4346:48829] dispatch_apply 8
     2016-02-15 10:15:21.231 多线程[4346:48830] dispatch_apply 7
     */
}


#pragma mark - dispatch_after
-(void)testdispatch_after
{
//    dispatch_after 延迟执行
    // 延迟执行
    // 方法1
    [self performSelector:@selector(run:) withObject:@"参数" afterDelay:2.0];
    
    // 方法2
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (NSInteger i = 0; i < 100; i++) {
            NSLog(@"%@", [NSThread currentThread]);
        }
    });
    
    // 方法3
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(run:) userInfo:nil repeats:NO];
 
}

#pragma mark - 执行run方法
- (void)run:(NSString *)param
{
    // 当前线程是否是主线程
    for (NSInteger i = 0; i < 10; i++) {
        NSLog(@"---%@---%zd---%d", [NSThread currentThread], i,  [NSThread isMainThread]);
    }
    
}

#pragma mark - 定时器
//做定时器或倒计时
//遗留问题： 返回上一个页面 线程并没有被销毁
//
//-(void)dealloc
//{
//    if (_timer) {
//        dispatch_source_cancel(_timer);
//        _timer = nil;
//    }
//}

-(IBAction)buttonTap:(id)sender
{
    UIButton * button = (UIButton *)sender;
    button.enabled = NO;
    
    // 1.创建一个定时器源
    
    // 参1:类型定时器
    // 参2:句柄
    // 参3:mask传0
    // 参4:队列  (注意:dispatch_source_t本质是OC对象，表示源)
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    // 严谨起见，时间间隔需要用单位int64_t，做乘法以后单位就变了
    // 下面这句代码表示回调函数时间间隔是多少
    int64_t interval = (int64_t)(1.0 * NSEC_PER_SEC);
    
    // 如何设置开始时间 CGD给我们了一个设置时间的方法
    // 参1:dispatch_time_t when 传一个时间， delta是增量
    
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)); // 从现在起0秒后开始
    
    // 参1:timer
    // 参2:开始时间
    // 参3:时间间隔
    // 参4:传0 不需要   DISPATCH_TIME_NOW 表示现在 GCD 时间用 NS 表示
    dispatch_source_set_timer(timer, start, interval, 0);
    
    __block int count = 60;
    
    // 3.设置回调(即每次间隔要做什么事情)
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"----------------%@", [NSThread currentThread]);
        // 如果希望做5次就停掉
        count -- ;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (count == 0) {
                dispatch_source_cancel(timer);
//                timer = nil;
                [button setTitle:@"点击倒计时" forState:UIControlStateNormal];
                button.enabled = YES;
            }
            else
            {
                [button setTitle:[NSString stringWithFormat:@"%d",count] forState:UIControlStateNormal];
                [button setTitle:[NSString stringWithFormat:@"%d",count] forState:UIControlStateDisabled];
            }
        });
    });
    // 4.启动定时器  (恢复)
    dispatch_resume(timer);
}

/*
 
 dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
 dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
 __block int count = 60;
 
 // 3.设置回调(即每次间隔要做什么事情)
 dispatch_source_set_event_handler(timer, ^{
 NSLog(@"----------------%@", [NSThread currentThread]);
 // 如果希望做5次就停掉
 count -- ;
 dispatch_async(dispatch_get_main_queue(), ^{
 if (count == 0) {
 dispatch_source_cancel(timer);
 [button setTitle:@"点击倒计时" forState:UIControlStateNormal];
 button.enabled = YES;
 }
 else
 {
 [button setTitle:[NSString stringWithFormat:@"%d",count] forState:UIControlStateNormal];
 [button setTitle:[NSString stringWithFormat:@"%d",count] forState:UIControlStateDisabled];
 }
 });
 });
 
 dispatch_resume(timer);
 */
#pragma mark - dispatch_barrier_async
-(void)testdispatch_barrier_async
{
    // 1.barrier : 在barrier前面的先执行，然后再执行barrier，然后再执行barrier后面的 barrier的queue不能是全局的并发队列
    dispatch_queue_t queue = dispatch_queue_create("11", DISPATCH_QUEUE_CONCURRENT);
 
    dispatch_async(queue, ^{
        for (int i = 0;  i < 2; i++) {
            NSLog(@"%@--1", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0;  i < 3; i++) {
            NSLog(@"%@--2", [NSThread currentThread]);
        }
    });
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"------- barrier ----------- ");
        for (int i = 0;  i < 4; i++) {
            NSLog(@"%@--3", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0;  i < 5; i++) {
            NSLog(@"%@--4", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0;  i < 6; i++) {
            NSLog(@"%@--5", [NSThread currentThread]);
        }
    });

}


#pragma mark - 队列组 dispatch_group_notify

-(void)demo_combineimage
{
    
    UIActivityIndicatorView * loadingview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:loadingview];
    loadingview.center = self.view.center;
    [loadingview startAnimating];
    // 创建队列
    dispatch_queue_t queue = dispatch_queue_create("download", DISPATCH_QUEUE_CONCURRENT); //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 创建组
    dispatch_group_t group = dispatch_group_create();
    __block UIImage * image1;
    // 用组队列下载图片1
    dispatch_group_async(group, queue, ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://img1.gtimg.com/15/1513/151394/15139471_980x1200_0.jpg"]];
        image1 = [UIImage imageWithData:data];
        NSLog(@"下载图片1%@", [NSThread currentThread]);
    });
    
    // 用组队列下载图片2
    __block UIImage * image2;
    dispatch_group_async(group, queue, ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://img1.gtimg.com/15/1513/151311/15131165_980x1200_0.png"]];
        image2 = [UIImage imageWithData:data];
        NSLog(@"下载图片2%@", [NSThread currentThread]);
    });
    
    // 将图片1和图片2合成一张图片
    dispatch_group_notify(group, queue, ^{
        CGFloat imageW = self.imageView.bounds.size.width;
        CGFloat imageH = self.imageView.bounds.size.height;
        
        // 开启位图上下文
        UIGraphicsBeginImageContext(self.imageView.bounds.size);
        
        // 画图
        [image1 drawInRect:CGRectMake(0, 0, imageW * 0.5, imageH)];
        [image2 drawInRect:CGRectMake(imageW * 0.5, 0, imageW * 0.5, imageH)];
        
        // 将图片取出
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        // 关闭图形上下文
        UIGraphicsEndImageContext();
        
        // 在主线程上显示图片
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"合成图片 %@", [NSThread currentThread]);
            self.imageView.image = image;
            [loadingview stopAnimating];
        });
    });
}

/*
 dispatch队列还实现其它一些常用函数，包括：
 
 void dispatch_apply(size_t iterations, dispatch_queue_t queue, void (^block)(size_t)); //重复执行block，需要注意的是这个方法是同步返回，也就是说等到所有block执行完毕才返回，如需异步返回则嵌套在dispatch_async中来使用。多个block的运行是否并发或串行执行也依赖queue的是否并发或串行。
 
 void dispatch_barrier_async(dispatch_queue_t queue, dispatch_block_t block); //这个函数可以设置同步执行的block，它会等到在它加入队列之前的block执行完毕后，才开始执行。在它之后加入队列的block，则等到这个block执行完毕后才开始执行。
 
 void dispatch_barrier_sync(dispatch_queue_t queue, dispatch_block_t block); //同上，除了它是同步返回函数
 
 void dispatch_after(dispatch_time_t when, dispatch_queue_t queue, dispatch_block_t block); //延迟执行block
 
 最后再来看看dispatch队列的一个很有特色的函数：
 
 void dispatch_set_target_queue(dispatch_object_t object, dispatch_queue_t queue);
 
 它会把需要执行的任务对象指定到不同的队列中去处理，这个任务对象可以是dispatch队列，也可以是dispatch源（以后博文会介绍）。而且这个过程可以是动态的，可以实现队列的动态调度管理等等。比如说有两个队列dispatchA和dispatchB，这时把dispatchA指派到dispatchB：
 
 dispatch_set_target_queue(dispatchA, dispatchB);
 
 那么dispatchA上还未运行的block会在dispatchB上运行。这时如果暂停dispatchA运行：
 
 dispatch_suspend(dispatchA);
 
 则只会暂停dispatchA上原来的block的执行，dispatchB的block则不受影响。而如果暂停dispatchB的运行，则会暂停dispatchA的运行。
 
 这里只简单举个例子，说明dispatch队列运行的灵活性，在实际应用中你会逐步发掘出它的潜力。
 
 dispatch队列不支持cancel（取消），没有实现dispatch_cancel()函数，不像NSOperationQueue，不得不说这是个小小的缺憾。
 */

@end
