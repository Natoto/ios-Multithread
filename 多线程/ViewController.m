//
//  ViewController.m
//  多线程
//
//  Created by zeno on 16/2/14.
//  Copyright © 2016年 peng. All rights reserved.
//

#import "ViewController.h"
#import "pthreadsViewController.h"
#import "nsthreadViewController.h"
#import "gcdViewController.h"
#import "nsoprationViewController.h"
#import "gcdfunViewController.h"

@interface ViewController ()
AS_CELL_STRUCT_COMMON(pthread)
AS_CELL_STRUCT_COMMON(nsthread)
AS_CELL_STRUCT_COMMON(gcd)
AS_CELL_STRUCT_COMMON(gcdfun)
AS_CELL_STRUCT_COMMON(nsoperation)
@end


@implementation ViewController
GET_CELL_STRUCT_WITH(pthread, pthread)
GET_CELL_STRUCT_WITH(nsthread, NSThread)
GET_CELL_STRUCT_WITH(gcd, GCD(四种类型))
GET_CELL_STRUCT_WITH(gcdfun, GCD(常用函数))
GET_CELL_STRUCT_WITH(nsoperation,NSOperation)

GET_CELL_SELECT_ACTION(cellstruct)
{
    HBBaseViewController * ctr;
    if(cellstruct == self.cell_struct_pthread)
    {
        ctr = [pthreadsViewController new];
    }
    else if (cellstruct == self.cell_struct_gcd)
    {
        ctr = [gcdViewController new];
    }
    else if (cellstruct == self.cell_struct_gcdfun)
    {
        ctr = [gcdfunViewController new];
    }
    else if (cellstruct == self.cell_struct_nsthread)
    {
        ctr = [nsthreadViewController new];
    }
    else if (cellstruct == self.cell_struct_nsoperation)
    {
        ctr = [nsoprationViewController new];
    }
    
    [self.navigationController pushViewController:ctr animated:YES];    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    int rowindex = 0,sectionIndex = 0;
    [self.dataDictionary setObject:self.cell_struct_pthread forKey:KEY_INDEXPATH(sectionIndex, rowindex++)];
    [self.dataDictionary setObject:self.cell_struct_nsthread forKey:KEY_INDEXPATH(sectionIndex, rowindex++)];
    [self.dataDictionary setObject:self.cell_struct_gcd forKey:KEY_INDEXPATH(sectionIndex, rowindex++)];
    [self.dataDictionary setObject:self.cell_struct_gcdfun forKey:KEY_INDEXPATH(sectionIndex, rowindex++)];
    [self.dataDictionary setObject:self.cell_struct_nsoperation forKey:KEY_INDEXPATH(sectionIndex, rowindex++)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
