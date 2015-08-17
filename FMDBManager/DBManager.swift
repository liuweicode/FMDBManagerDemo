   //
//  DBManager.swift
//  JuMiHang
//
//  Created by 刘伟 on 3/27/15.
//  Copyright (c) 2015 Louding. All rights reserved.
//

import UIKit

let DBNAME = "myfmdb.db"
   
//单利类 操作数据库是线程安全的
class DBManager {
    
    var queue: FMDatabaseQueue!
    
    var writeQueue: NSOperationQueue!
    
    var writeQueueLock: NSRecursiveLock!
    
    private var documentsDirectory: NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.endIndex-1] as! NSURL
    }
    
    class func shareInstance()->DBManager{
        struct DBManagerSingleton{
            static var predicate:dispatch_once_t = 0
            static var instance:DBManager? = nil
        }
        dispatch_once(&DBManagerSingleton.predicate,{
                DBManagerSingleton.instance = DBManager()
                DBManagerSingleton.instance!.setup()
            }
        )
        return DBManagerSingleton.instance!
    }
    
    private func setup()
    {
        self.queue = FMDatabaseQueue(path: databasePath())
        self.writeQueue = NSOperationQueue()
        self.writeQueue.maxConcurrentOperationCount = 1
        self.writeQueueLock = NSRecursiveLock()
    }
    
    //数据库路径
    func databasePath()->String
    {
        return documentsDirectory.URLByAppendingPathComponent(DBNAME).absoluteString!
    }
    
    /**
    初始化数据库，创建表
    
    需要创建数据库表，则需要创建类继承BaseDao，并复写createTable方法，然后在该initDB方法里面的tables变量中，添加需要创建表的类
    */
    func initDatabase(tables :[BaseDao.Type])
    {
        if(isDatabaseInitialized()){
            println("数据库已经初始化: \(databasePath())")
            return
        }
        
        writeQueueLock.lock()
        
        queue.inTransaction { (db, rollback) -> Void in
            
            println("数据库初始化开始")
            
            for tb in tables
            {
                //创建表
                if !tb.createTable(db)
                {
                    rollback.initialize(true)
                    println("数据库初始化失败:\(self.databasePath())")
                    return
                }
            }
            //如果所有数据库表创建成功，则标记数据库初始化成功
            self.setDatabaseInitialized(true)
            println("数据库初始化成功:\(self.databasePath())")
        }
        writeQueueLock.unlock()
    }
    
    /**
        数据库是否已经初始化
    */
    private func isDatabaseInitialized() -> Bool
    {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var isDatabaseInitialized = userDefaults.boolForKey("kIsDatabaseInitialized")
        return isDatabaseInitialized
    }
    
    /**
        设置数据库是否已经初始化
    */
    private func setDatabaseInitialized(isDatabaseInitialized:Bool)
    {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(isDatabaseInitialized, forKey: "kIsDatabaseInitialized")
        userDefaults.synchronize()
    }
    
    /**
    
    操作数据库，执行单条语句
    
    :param: sql :插入，更新，删除等操作
    :param: args :后面附带的参数
    
    :returns: 成功或失败
    
    */
    func executeUpdate(sql:String, withArgumentsInArray args:[AnyObject]) -> Bool
    {
        var excuteResult = false
        
        writeQueueLock.lock()
        
        queue.inDatabase { (db) -> Void in

            excuteResult = db.executeUpdate(sql, withArgumentsInArray: args)
            
            if !excuteResult
            {
                println("执行SQL:\(sql) 参数:\(args) 报错信息:\(db.lastErrorMessage()) \(db.lastError().description)")
            }
            
        }
        writeQueueLock.unlock()
        
        return excuteResult
    }
    
    /**
    
    操作数据库，执行单条语句
    
    :param: sql :插入，更新，删除等操作
    :param: args :后面附带的参数
    
    :returns: 成功或失败
    */
    func executeUpdate(sql:String, withParameterDictionary args:[NSObject : AnyObject]) -> Bool
    {
        var excuteResult = false
        
        writeQueueLock.lock()
        
        queue.inDatabase { (db) -> Void in
            
            excuteResult = db.executeUpdate(sql, withParameterDictionary: args)
            
            if !excuteResult
            {
                println("执行SQL:\(sql) 参数:\(args) 报错信息:\(db.lastErrorMessage()) \(db.lastError().description)")
            }
        }
        writeQueueLock.unlock()
        
        return excuteResult
    }
    
    
    /**

    可在同一个事务中执行多条语句
    
    :param: inTransaction 数据库
    
    :returns: 成功或失败
    */
    func executeUpdate(inTransaction :(db:FMDatabase) -> Bool) -> Bool
    {
        var executeSuccess = false
        
        writeQueueLock.lock()
        queue.inTransaction { (db, rollback) -> Void in
            
            executeSuccess = inTransaction(db: db)
            
            if !executeSuccess
            {
                rollback.initialize(true)
            }
        }
        writeQueueLock.unlock()
        
        return executeSuccess
    }
    
    /**
    查询数据库
    
    :param: sql  查询SQL
    :param: args 查询SQL的条件值
    
    :returns: （查询结果,错误）
    */
    func executeQuery(sql:String!, args:NSArray!) -> ([[NSObject:AnyObject]]?,error:NSError?)
    {
        var resultDictArray : [[NSObject:AnyObject]]?
        var error : NSError?
        
        writeQueueLock.lock()
        
        var resultArray = [[NSObject : AnyObject]]()
        
        queue.inDatabase { (db) -> Void in
            
            var resultSet = db.executeQuery(sql, withArgumentsInArray: args as [AnyObject])
            if resultSet == nil
            {
                println("执行SQL:\(sql) 参数:\(args) 报错信息:\(db.lastErrorMessage())")
                error = db.lastError()
            }else{
                
                resultDictArray = [[NSObject:AnyObject]]()
                
                while resultSet.next()
                {
                    resultDictArray!.append(resultSet.resultDictionary())
                }
            }
            resultSet.close()
        }
        writeQueueLock.unlock()
        
        return (resultDictArray,error)
    }
    
}
