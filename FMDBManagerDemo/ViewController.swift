//
//  ViewController.swift
//  FMDBManagerDemo
//
//  Created by 楼顶 on 15/8/17.
//  Copyright (c) 2015年 Liuwei Code. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var userList = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        
        //启动需要创建的表
        var tables :[BaseDao.Type] = [
            UserDao.self        //用户表
        ]
        
        //在应用程序启动的时候，初始化数据库表, 只初始化一次
        DBManager.shareInstance().initDatabase(tables)
        
        dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
            //插入
            for var i = 0 ; i < 10 ; i++
            {
                UserDao.saveOrUpdate("ThreadFirst\(i)", password: "密码\(i)", mobile: i % 2 == 0 ? nil : "手机\(i)")
            }
            //查询
            if let ulist = UserDao.findAllUser()
            {
                self.userList += ulist
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        })
        
        
        dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in
            //插入
            for var i = 0 ; i < 10 ; i++
            {
                UserDao.saveOrUpdate("ThreadSecond\(i)", password: "密码\(i)", mobile: i % 2 == 0 ? nil : "手机\(i)")
            }
            //查询
            if let ulist = UserDao.findAllUser()
            {
                self.userList += ulist
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        })
        
    }
    
    // MARK : - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        
        var user = self.userList[indexPath.row]
        
        if let mobile = user.mobile
        {
            cell.textLabel?.text =  "\(user.accountId!), \(user.username!), \(user.password!), \(mobile)"
        }else{
            cell.textLabel?.text =  "\(user.accountId!), \(user.username!), \(user.password!)"
        }
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

