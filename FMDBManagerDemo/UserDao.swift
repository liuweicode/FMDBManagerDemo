//
//  UserDao.swift
//  Exercise
//
//  Created by 楼顶 on 15/7/29.
//  Copyright (c) 2015年 楼顶. All rights reserved.
//

import UIKit

class UserDao: BaseDao {
   
    /**
    创建用户表
    
    :param: db 数据库
    
    :returns: 是否创建成功
    */
    override class func createTable(db: FMDatabase) -> Bool {
        var createTableSql = "CREATE TABLE TB_User ( " +
            " accountId INTEGER PRIMARY KEY ," +       //帐号id
            " username VARCHAR(200) ," +               //用户名
            " password VARCHAR(200) ," +               //密码
            " mobile VARCHAR(20) "  +                  //手机
        " ) "
        
        if !db.executeUpdate(createTableSql, withArgumentsInArray: []) {
            println("创建用户表失败 failure: \(db.lastError())")
            return false
        }else{
            println("创建用户表成功")
            return true
        }
    }
    
    
    class func saveOrUpdate(username:String,password:String,mobile:String?) -> Bool {
        
        var sql = "replace INTO TB_User (username, password, mobile) VALUES ( ? , ? , ? ) "
        
        var args : [AnyObject] = [username , password , filterNilValueToNull(mobile)]
        
        //var args : [AnyObject] = [username , password , mobile == nil ? NSNull() : mobile!]
        
        return DBManager.shareInstance().executeUpdate(sql, withArgumentsInArray: args)
    }
    
    class func findAllUser() -> [User]?
    {
        var userList : [User]?
        
        var sql = "SELECT accountId, username, password, mobile FROM TB_User"
        
        var args : [AnyObject] = []
        
        var (resultDictArray,error) : ([[NSObject:AnyObject]]?,error:NSError?) = DBManager.shareInstance().executeQuery(sql, args: args)
        
        if resultDictArray != nil
        {
            userList = [User]()
            
            for item in resultDictArray!
            {
                var user = User()
                user.accountId = item["accountId"] as? Int
                user.username = item["username"] as? String
                user.password = item["password"] as? String
                user.mobile = item["mobile"] as? String
                userList!.append(user)
            }
        }
        
        return userList
    }
    
}
