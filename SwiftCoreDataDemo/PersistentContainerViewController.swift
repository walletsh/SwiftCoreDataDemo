//
//  PersistentContainerViewController.swift
//  SwiftCoreDataDemo
//
//  Created by imwallet on 16/12/26.
//  Copyright © 2016年 imWallet. All rights reserved.
//

import UIKit
import CoreData

class PersistentContainerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        toucheOne()
//        toucheTwo()
    }

}

extension PersistentContainerViewController{
    fileprivate func toucheOne() {
        
        /// 创建一个新线程管理上下文
        let context = IMCoreDataManager.manager.persistentContainer.newBackgroundContext()
        
        for index in 0...15 {
            let contact = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context) as! Contact
            contact.name = "HAHA" + "-" + String(index)
            contact.tel = String(20000 + index)
        }
        
        /// 开启异步多线程保存到数据库
        IMCoreDataManager.manager.persistentContainer.performBackgroundTask { (objContext) in
            
            //这里不能使用上面创建的context，而必须要使用block参数中的context（因为NSPersistentContainer对多线程做了优化处理）
            do{
                try objContext.save()
                print("performBackgroundTask save success")
            }catch{
                print("performBackgroundTask error \(error.localizedDescription)")
            }
        }
    }
    
    fileprivate func toucheTwo() {
        for index in 0...15 {
            let contact = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: IMCoreDataManager.manager.persistentContainer.viewContext) as! Contact
            contact.name = "HAHA" + "-" + String(index)
            contact.tel = String(10000 + index)
        }
        
        /// 保存到数据库
        IMCoreDataManager.manager.saveDataForSql()

    }
}

