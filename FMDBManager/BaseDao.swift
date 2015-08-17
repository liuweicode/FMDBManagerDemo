//
//  BaseDao.swift
//  isflyer
//
//  Created by 楼顶 on 15/5/11.
//  Copyright (c) 2015年 楼顶. All rights reserved.
//

import UIKit


protocol IBaseDao
{
    static func createTable(db:FMDatabase) -> Bool
}

class BaseDao: NSObject, IBaseDao {
   
    /**
        子类必须实现该方法
    
        :param: db 数据库
    
        :returns: 创建数据库表是否成功
    */
    class func createTable(db: FMDatabase) -> Bool {
        fatalError("\(object_getClassName(self))[ createTable(db: FMDatabase) -> Bool ] has not been override")
    }
    
    /**
        因为FMDB参数不能有nil值，所以需要过滤nil的值，转换为NSNull
    
        :param: oValue 是个可选值
    
        :returns: 解包后的值或者NSNull
    */
    class func filterNilValueToNull(oValue:AnyObject?) -> AnyObject!
    {
        return oValue ?? NSNull()
    }
    
}
