//
//  XTableDataDelegate.m
//  DevelopFramework
//
//  Created by momo on 15/12/5.
//  Copyright © 2015年 teason. All rights reserved.
//

#import "XTableDataDelegate.h"
#import "UITableViewCell+Extension.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "BQViewModel.h"
#import "BQBaseViewModel.h"
#import "SVProgressHUD.h"
#import "MJRefresh.h"

@interface XTableDataDelegate ()

@property (nonatomic, strong) NSArray *cellIdentifierArray ;

@property (nonatomic, copy) DidSelectCellBlock          didSelectCellBlock ;
@property (nonatomic, strong) BQBaseViewModel *viewModel;


@end

@implementation XTableDataDelegate

- (NSArray *)cellIdentifierArray {
    if (_cellIdentifierArray == nil) {
        _cellIdentifierArray = [NSArray array];
    }
    return _cellIdentifierArray;
}

- (id)initWithViewModel:(BQBaseViewModel *)viewModel
    cellIdentifiersArray:(NSArray *)cellIdentifiersArray
    didSelectBlock:(DidSelectCellBlock)didselectBlock
{
    self = [super init] ;
    if (self) {
        self.viewModel = viewModel;
        self.cellIdentifierArray = cellIdentifiersArray ;
        self.didSelectCellBlock = didselectBlock ;
    }
    
    return self ;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.viewModel.dataArrayList[indexPath.row];
}

- (void)handleTableViewDatasourceAndDelegate:(UITableView *)table
{
    
    table.dataSource = self ;
    table.delegate   = self ;
    
    [UITableViewCell registerTable:table nibIdentifier:self.cellIdentifierArray[0]] ;
    table.tableFooterView = [UIView new];
    __weak typeof(self) weakSelf = self;
    __weak typeof(table) weakTable = table;
 
    [SVProgressHUD show];
    // 下拉刷新
    table.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        // 模拟延迟加载数据，因此2秒后才调用（真实开发中，可以移除这段gcd代码）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.viewModel getDataListSuccess:^{
                [SVProgressHUD dismiss];
                [weakTable reloadData];
            }];
        });
        // 结束刷新
        [weakTable.mj_header endRefreshing];
    }];

    [table.mj_header beginRefreshing];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    table.mj_header.automaticallyChangeAlpha = YES;

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self itemAtIndexPath:indexPath] ;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifierArray[0] forIndexPath:indexPath] ;
    
    [cell configure:cell customObj:item indexPath:indexPath];
    //  self.configureCellBlock(indexPath,item,cell) ;
    return cell ;
 
}

#pragma mark --c
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self itemAtIndexPath:indexPath] ;
    __weak typeof(self) weakSelf = self;
   
    return [tableView fd_heightForCellWithIdentifier:weakSelf.cellIdentifierArray[0] cacheByIndexPath:indexPath configuration:^(UITableViewCell *cell) {
        [cell configure:cell customObj:item indexPath:indexPath];
    }];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id item = [self itemAtIndexPath:indexPath] ;
    self.didSelectCellBlock(indexPath,item) ;
}

@end
