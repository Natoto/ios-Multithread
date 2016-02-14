//
//  pthreadsViewController.m
//  多线程
//
//  Created by zeno on 16/2/14.
//  Copyright © 2016年 peng. All rights reserved.
//

#import "pthreadsViewController.h"
#import <pthread/pthread.h>
@interface pthreadsViewController ()

@end

@implementation pthreadsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    pthread_t thread;
    //创建一个线程并自动执行
    // 创建一个线程  (参1)pthread_t *restrict:创建线程的指针，(参2)const pthread_attr_t *restrict:线程属性  (参3)void *(*)(void *):线程执行的函数的指针，(参4)void *restrict:null
    pthread_create(&thread, NULL, run, NULL);
    
    // 何时回收线程不需要你考虑
    pthread_t thread2;
    pthread_create(&thread2, NULL, run, NULL);

}

void *start(void *data) {
    NSLog(@"%@", [NSThread currentThread]);
    return NULL;
}

void * run(void *param)
{
    for (NSInteger i = 0; i < 10; i++) {
        NSLog(@"---buttonclick---%zd---%@", i, [NSThread currentThread]);
    }
    
    return NULL;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
