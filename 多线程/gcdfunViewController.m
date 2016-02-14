//
//  gcdfunViewController.m
//  多线程
//
//  Created by zeno on 16/2/14.
//  Copyright © 2016年 peng. All rights reserved.
//

#import "gcdfunViewController.h"

@interface gcdfunViewController ()

@end

@implementation gcdfunViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self testdispatch_after];
//    [self testbarrier];
}

-(void)testdispatch_after
{
//    dispatch_after 延迟执行
    // 延迟执行
    // 方法1
    [self performSelector:@selector(run:) withObject:@"参数" afterDelay:2.0];
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t  queue = dispatch_queue_create("boob", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group,queue, ^{
        dispatch_after(6*NSEC_PER_SEC, queue, ^{
            [self run:nil];
        });
    });
    
}

#pragma mark - 执行run方法
- (void)run:(NSString *)param
{
    // 当前线程是否是主线程
    for (NSInteger i = 0; i < 10; i++) {
        NSLog(@"---%@---%zd---%d", [NSThread currentThread], i,  [NSThread isMainThread]);
    }
    
}

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




@end
