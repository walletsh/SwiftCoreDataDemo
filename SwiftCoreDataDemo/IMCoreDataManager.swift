//
//  IMCoreDataManager.swift
//  SwiftCoreDataDemo
//
//  Created by imwallet on 16/12/20.
//  Copyright © 2016年 imWallet. All rights reserved.
//

import Foundation
import CoreData


//MARK: - NSManagedObjectContext管理CoreData
/**
 模型文件操作
 1.1 创建模型文件，后缀名为.xcdatamodeld。创建模型文件之后，可以在其内部进行添加实体等操作(用于表示数据库文件的数据结构)
 1.2 添加实体(表示数据库文件中的表结构)，添加实体后需要通过实体，来创建托管对象类文件。
 1.3 添加属性并设置类型，可以在属性的右侧面板中设置默认值等选项。(每种数据类型设置选项是不同的)
 1.4 创建获取请求模板、设置配置模板等。
 1.5 根据指定实体，创建托管对象类文件(基于NSManagedObject的类文件)
 
 
 实例化上下文对象
 2.1 创建托管对象上下文(NSManagedObjectContext)
 2.2 创建托管对象模型(NSManagedObjectModel)
 2.3 根据托管对象模型，创建持久化存储协调器(NSPersistentStoreCoordinator)
 2.4 关联并创建本地数据库文件，并返回持久化存储对象(NSPersistentStore)
 2.5 将持久化存储协调器赋值给托管对象上下文，完成基本创建。
 */

extension NSManagedObjectContext{
    
    class func setupManagedObjectContext(_ sqlName: String) -> NSManagedObjectContext {
        
        /* NSManagedObjectContextConcurrencyType:
         confinementConcurrencyType  并发类型，被弃用
         privateQueueConcurrencyType 私有并发队列类型，操作都是在子线程中完成的。
         mainQueueConcurrencyType    主并发队列类型，如果涉及到UI相关的操作，应该考虑使用这个参数初始化上下文。
         */
        
        //  1 创建托管对象上下文(NSManagedObjectContext)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        //  2 创建托管对象模型(NSManagedObjectModel)
        let sqlUrl = Bundle.main.url(forResource: sqlName, withExtension: "momd")
        let sqlModel = NSManagedObjectModel(contentsOf: sqlUrl!)
        
        //  3 根据托管对象模型，创建持久化存储协调器(NSPersistentStoreCoordinator)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: sqlModel!)
        
        var sqlPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        
        sqlPath?.append("/\(sqlName).sqlite")
        
        print("\(sqlName) SQL path is : \(sqlPath!)")
        do {
            // 4 关联并创建本地数据库文件，并返回持久化存储对象(NSPersistentStore)
            /*
             NSSQLiteStoreType : SQLite数据库
             NSXMLStoreType : XML文件
             NSBinaryStoreType : 二进制文件
             NSInMemoryStoreType : 直接存储在内存中
             */
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: URL(fileURLWithPath: sqlPath!), options: nil)
            
        } catch {
            print("addPersistentStore \(error.localizedDescription)")
        }
        
        //  5 将持久化存储协调器赋值给托管对象上下文，完成基本创建。
        context.persistentStoreCoordinator = coordinator
        
        return context
    }
}

//MARK: -NSPersistentContainer管理CoreData

@available(iOS 10.0, *)
class IMCoreDataManager {
    
    static let manager = IMCoreDataManager()
    private init(){}

    lazy var persistentContainer: NSPersistentContainer = {
        
        let url = Bundle.main.url(forResource: "User", withExtension: "momd")
        let objModel = NSManagedObjectModel(contentsOf: url!)
        let persistentContainer = NSPersistentContainer(name: "user.sql", managedObjectModel: objModel!)
        
        ///   合并Bundle所有.momd文件,budles: 指定为nil,自动从mainBundle里找所有.momd文件
//        let objModel = NSManagedObjectModel.mergedModel(from: nil)
//        let persistentContainer = NSPersistentContainer(name: "sql.db", managedObjectModel: objModel!)
        
        /// 加载存储器，此方法必须要调用，否则无法存储数据
        /// block中NSPersistentStoreDescription用于描述生成的存储器信息，如：数据库文件路径、存储类型等  NSError用于描述加载存储器是否成功或失败信息
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            print("loadPersistentStores storeDescription : \(storeDescription)")
            
            if let error = error{
                fatalError("loadPersistentStores error : \(error)")
            }
        })
        
        return persistentContainer
    }()
}

extension IMCoreDataManager{
    
    func saveDataForSql() {
        
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
                print("saveDataForSql success!!!")
            } catch  {
                print("saveDataForSql error : \(error.localizedDescription) ")
            }
        }
    }
    
}




