//
//  gcdViewController.m
//  多线程
//
//  Created by zeno on 16/2/14.
//  Copyright © 2016年 peng. All rights reserved.
//

#import "gcdViewController.h"

@interface gcdViewController ()
{
    dispatch_queue_t queueSerial;
    dispatch_queue_t queueConcurrent;
}
@property(nonatomic,strong) UIImageView * imageView;
@end

@implementation gcdViewController

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
//      dispatch_queue_t queue = dispatch_get_main_queue();
    // 创建串行队列  serial 串行  concurrent并发
    queueSerial = dispatch_queue_create("searial.whenbar.com", DISPATCH_QUEUE_SERIAL);
    
    //创建并行队列
    // 参1:const char *label 队列名称
    // 参2:dispatch_queue_attr_t attr 队列类型
    queueConcurrent = dispatch_queue_create("concurrent.whenbar.com", DISPATCH_QUEUE_CONCURRENT);

}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
//    [self runqueueSerial];
//    [self runqueueConcurrent];
    [self rungroup];
    [self demo_downloadimage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//1 获得主队列
-(void)runqueueMain
{
    // 获取主队列  在主队列中的任务都会在主线程中执行。
    dispatch_queue_t queueMain = dispatch_get_main_queue();
    
}

//2. 创建串行队列
-(void)runqueueSerial
{
  
    // GCD同步函数串行队列(立即执行，当前线程)
    // 参1: dispatch_queue_t queue 队列
    // 参2: 任务
    dispatch_sync(queueSerial, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"~~~%ld %@",i, [NSThread currentThread]);
        }
    });
    
    
    // 异步函数串行队列 (另开线程，多个任务按顺序执行)
    dispatch_async(queueSerial, ^{
        dispatch_async(queueSerial, ^{
            for (NSInteger i = 0; i < 10; i++) {
                NSLog(@"~~~%ld %@",i, [NSThread currentThread]);
            }
        });
        dispatch_async(queueSerial, ^{
            for (NSInteger i = 0; i < 10; i++) {
                NSLog(@"~~~%ld %@",i, [NSThread currentThread]);
            }
        });
        dispatch_async(queueSerial, ^{
            for (NSInteger i = 0; i < 10; i++) {
                NSLog(@"~~~%ld %@",i, [NSThread currentThread]);
            }
        });
    });

}



//3. 创建并发队列
-(void)runqueueConcurrent
{
    
    // 同步函数并行队列(立即执行，当前线程)
    dispatch_sync(queueConcurrent, ^{
        for (NSInteger i = 0; i < 10; i++) {
            NSLog(@"~~~%ld %@",i, [NSThread currentThread]);
        }
    });

    // 异步函数并行队列 (另开线程，多个任务一起执行)
    dispatch_async(queueConcurrent, ^{
        dispatch_async(queueConcurrent, ^{
            for (NSInteger i = 0; i < 5; i++) {
                NSLog(@"~~~%ld %@",i, [NSThread currentThread]);
            }
        });
        dispatch_async(queueConcurrent, ^{
            for (NSInteger i = 0; i < 6; i++) {
                NSLog(@"~~~%ld %@",i, [NSThread currentThread]);
            }
        });
        dispatch_async(queueConcurrent, ^{
            for (NSInteger i = 0; i < 7; i++) {
                NSLog(@"~~~%ld %@",i, [NSThread currentThread]);
            }
        });
    });
}

//4. 创建全局队列
-(void)runqueueGlobal
{
    // 获取全局队列 全局队列是并发队列
    // 参1:队列的优先级
    // 参2:0(以后可能用到的参数)
    //#define DISPATCH_QUEUE_PRIORITY_HIGH 2 // 高\
    #define DISPATCH_QUEUE_PRIORITY_DEFAULT 0 // 默认（中）\
    #define DISPATCH_QUEUE_PRIORITY_LOW (-2) // 低\
    #define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN // 后台
    dispatch_queue_t queueGlobal = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
}

//----------------- 队列组 -----------------------------
//队列组可以将很多队列添加到一个组里，这样做的好处是，当这个组里所有的任务都执行完了，队列组会通过一个方法通知我们。下面是使用方法，这是一个很实用的功能。
-(void)rungroup
{
    //1.创建队列组
    dispatch_group_t group=dispatch_group_create();
    //2.创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    //3.多次使用队列组的方法执行任务, 只有异步方法
    //3.1.执行3次循环
    dispatch_group_async(group,queue,^{
        for (NSInteger i = 0; i< 3; i++){
            NSLog(@"group-01 - %@", [NSThread currentThread]);
        }
    });
    //3.2.主队列执行8次循环
    dispatch_group_async(group, dispatch_get_main_queue(), ^{
        for (NSInteger i=0;i<8;i++) {
            NSLog(@"group-02 - %@", [NSThread currentThread]);
        }
    });
    //3.3.执行5次循环
    dispatch_group_async(group, queue, ^{
        for(NSInteger i=0;i<5;i++) {
            NSLog(@"group-03 - %@", [NSThread currentThread]);
        }
    });
    //4.都完成后会自动通知
    dispatch_group_notify(group,dispatch_get_main_queue(),^{
        NSLog(@"完成 - %@", [NSThread currentThread]);
    });
}



-(void)demo_downloadimage
{
    UIActivityIndicatorView * loadingview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:loadingview];
    loadingview.center = self.view.center;
    [loadingview startAnimating];
    // 获取图片的url
    NSURL *url = [NSURL URLWithString:@"http://d.hiphotos.baidu.com/baike/c0%3Dbaike92%2C5%2C5%2C92%2C30/sign=484a03b6014f78f0940692a118586130/d439b6003af33a875af79df8c45c10385243b5be.jpg"];
    
    // 开启线程下载图片
    dispatch_queue_t queue = dispatch_queue_create("111", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        
        // 下载完成后返回主线程显示图片
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
            [loadingview stopAnimating];
        });
    });
}

@end
