//
//  nsthreadViewController.m
//  多线程
//
//  Created by zeno on 16/2/14.
//  Copyright © 2016年 peng. All rights reserved.
//

#import "nsthreadViewController.h"

@interface nsthreadViewController ()
@property(nonatomic,strong) UIImageView * imageView;
@end

@implementation nsthreadViewController

-(UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.frame = CGRectMake(0, 0, 300, 300);
        _imageView.center = self.view.center;
        [self.view addSubview:_imageView];
    }
    return _imageView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //监听线程结束的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handle_threadexit:) name:NSThreadWillExitNotification object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //第一种方式：先创建再启动线程
    // 创建线程
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(run:) object:@"booob"];
    
    // 线程启动了，事情做完了才会死， 一个NSThread对象就代表一条线程
    [thread start];
    
    //第二种：直接创建并启动线程
    // 直接创建并启动线程
    [NSThread detachNewThreadSelector:@selector(run:) toTarget:self withObject:@"wang"];
    
    
    //第三种：
    // 直接创建并启动线程
    [self performSelectorInBackground:@selector(run:) withObject:@"wang000"];
    // 使线程进入阻塞状态
    [NSThread sleepForTimeInterval:2.0];
    
    
    //例子
    // 获取图片的url
    NSURL *url = [NSURL URLWithString:@"https://pages.github.com/images/slideshow/yeoman.png"];
    // 另开1条线程 object用于数据的传递
    NSThread *thread3 = [[NSThread alloc] initWithTarget:self selector:@selector(downLoadWithURL:) object:url];
    thread3.name = @"downloadimage...";
    // 由于下面下载图片的耗时太长，应开启线程来完成
    [thread3 start];

}
#pragma mark - 执行run方法
- (void)run:(NSString *)param
{
    // 当前线程是否是主线程
    for (NSInteger i = 0; i < 10; i++) {
        NSLog(@"---%@---%zd---%d", [NSThread currentThread], i,  [NSThread isMainThread]);
    }
    
}

//线程直接的交互
// 下载图片
- (void)downLoadWithURL:(NSURL *)url
{
    NSLog(@"%s ,%s %@",__FILE__,__FUNCTION__, [NSThread currentThread]);
    // 下载图片
    NSData *data = [NSData dataWithContentsOfURL:url];
    // 生成图片
    UIImage *image = [UIImage imageWithData:data];
    // 返回主线程显示图片
    [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
}

//处理线程结束事件
-(void)handle_threadexit:(NSNotification *)notify
{
    NSThread  * thread = (NSThread *)notify.object;
    NSLog(@"+++++++++++++++ 线程 %@ 结束 ++++++++++++",thread.name);
}

@end
