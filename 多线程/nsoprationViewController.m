//
//  nsoprationViewController.m
//  多线程
//
//  Created by zeno on 16/2/14.
//  Copyright © 2016年 peng. All rights reserved.
//

#import "nsoprationViewController.h"

@interface nsoprationViewController ()
@property(nonatomic,strong) UIImageView * imageView;
@end

@implementation nsoprationViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self testNSOperationQueue];
//    [self testblockopration];
    [self demo_combinenetworkimage];
}

-(void)testblockopration
{
    //1.创建NSBlockOperation对象
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@", [NSThread currentThread]);
    }];
    //2.开始任务
#warning NOTE：addExecutionBlock 方法必须在 start() 方法之前执行，否则就会报错：
//    [operation start];
    
    //1.创建NSBlockOperation对象
    NSBlockOperation *operation2 = operation; //[NSBlockOperation blockOperationWithBlock:^{\
        NSLog(@"%@", [NSThread currentThread]);\
    }];
    //添加多个Block
    for (NSInteger i = 0; i < 5; i++) {
        [operation2 addExecutionBlock:^{
            NSLog(@"第%ld次：%@", i, [NSThread currentThread]);
        }];
    }
    //2.开始任务
    [operation2 start];
}

-(void)testNSOperationQueue
{
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 4;//最大并行执行从操作为1时 其实就是串行 一个一个执行的
    NSBlockOperation *block1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"download1 -------------- %@", [NSThread currentThread]);
    }];
    
    NSBlockOperation *block2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"download2 -------------- %@", [NSThread currentThread]);
    }];
    
    NSBlockOperation *block3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"download3 -------------- %@", [NSThread currentThread]);
    }];
    
    NSBlockOperation *block4 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"download4 -------------- %@", [NSThread currentThread]);
    }];
    // 添加依赖: block1 和 block2执行完后 再执行 block3  block3依赖于block1和block2
    
    // 给block3添加依赖 让block3在block1和block2之后执行
    [block3 addDependency:block1];
    [block3 addDependency:block2];
    
    [queue addOperation:block1];
    [queue addOperation:block2];
    [queue addOperation:block3];
    [queue addOperation:block4];
}

-(void)demo_combinenetworkimage
{
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    
    __block UIImage * image1;
    NSBlockOperation * block1 = [NSBlockOperation blockOperationWithBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://img1.gtimg.com/15/1513/151394/15139471_980x1200_0.jpg"]];
        image1 = [UIImage imageWithData:data];
        NSLog(@"下载图片1%@", [NSThread currentThread]);
    }];
    
    __block UIImage * image2;
    NSBlockOperation * block2 = [NSBlockOperation blockOperationWithBlock:^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://img1.gtimg.com/15/1513/151311/15131165_980x1200_0.png"]];
        image2 = [UIImage imageWithData:data];
        NSLog(@"下载图片2%@", [NSThread currentThread]);
    }];
    
    
    NSBlockOperation * block3 = [NSBlockOperation blockOperationWithBlock:^{
       
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
        [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"合成图片 %@", [NSThread currentThread]);
            self.imageView.image = image;
        }]];
    }];
    
    
    //4.设置依赖
    [block3 addDependency:block1];
    [block3 addDependency:block2];
    
    [queue addOperation:block1];
    [queue addOperation:block2];
    [queue addOperation:block3];
    
}
/*
 以上就是一些主要方法, 下面还有一些常用方法需要大家注意：
 
 NSOperation
 BOOL executing; //判断任务是否正在执行
 BOOL finished; //判断任务是否完成
 void (^completionBlock)(void); //用来设置完成后需要执行的操作
 - (void)cancel; //取消任务
 - (void)waitUntilFinished; //阻塞当前线程直到此任务执行完毕
 NSOperationQueue 
 
 NSUInteger operationCount; //获取队列的任务数
 - (void)cancelAllOperations; //取消队列中所有的任务
 - (void)waitUntilAllOperationsAreFinished; //阻塞当前线程直到此队列中的所有任务执行完毕
 [queue setSuspended:YES]; // 暂停queue
 [queue setSuspended:NO]; // 继续queue
 
 
 @synchronized
 {
 }
 */


@end
