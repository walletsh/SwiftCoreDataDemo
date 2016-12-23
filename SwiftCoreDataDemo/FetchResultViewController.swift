//
//  FetchResultViewController.swift
//  SwiftCoreDataDemo
//
//  Created by imwallet on 16/12/22.
//  Copyright © 2016年 imWallet. All rights reserved.
//

import UIKit
import CoreData

private let userTabel = "User"
private let contactTable = "Contact"

class FetchResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    fileprivate lazy var backBtn: UIButton = {[unowned self] in
        let backBtn = UIButton(frame: CGRect(x: 20, y: 20, width: 60, height: 30))
        backBtn.backgroundColor = UIColor.orange
        backBtn.setTitle("返回", for: .normal)
        backBtn.setTitleColor(UIColor.red, for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnAction(_:)), for: .touchUpInside)
        return backBtn
    }()
    
    fileprivate lazy var tableView: UITableView = {[unowned self] in
        let tableView = UITableView(frame: CGRect(x: 0, y: 50, width: self.view.frame.size.width, height: self.view.frame.size.height - 50 - 30), style: .plain)
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    fileprivate lazy var refreshBtn: UIButton = {[unowned self] in
        let refreshBtn = UIButton(frame: CGRect(x: self.view.frame.size.width * 0.5, y: self.view.frame.size.height - 30, width: self.view.frame.size.width * 0.5, height: 30))
        refreshBtn.backgroundColor = UIColor.purple
        refreshBtn.setTitle("刷新数据", for: .normal)
        refreshBtn.addTarget(self, action: #selector(refreshBtnAction(_:)), for: .touchUpInside)
        return refreshBtn
    }()
    
    fileprivate lazy var creatBtn: UIButton = {[unowned self] in
        let creatBtn = UIButton(frame: CGRect(x: 0, y: self.view.frame.size.height - 30, width: self.view.frame.size.width * 0.5, height: 30))
        creatBtn.backgroundColor = UIColor.yellow
        creatBtn.setTitle("测试数据", for: .normal)
        creatBtn.setTitleColor(UIColor.black, for: .normal)
        creatBtn.addTarget(self, action: #selector(creatBtnAction(_:)), for: .touchUpInside)
        return creatBtn
    }()
    
    var fetchResultVC: NSFetchedResultsController<NSFetchRequestResult>?
    
    fileprivate lazy var userContext: NSManagedObjectContext = {
        let userCon = NSManagedObjectContext.setupManagedObjectContext(userTabel)
        return userCon
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = UIColor.white
        
        view.addSubview(backBtn)
        
        view.addSubview(tableView)
        
        view.addSubview(refreshBtn)
        
        view.addSubview(creatBtn)
    }
    
}

// MARK: - UITableViewDataSource && UITableViewDelegate
extension FetchResultViewController{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        guard (fetchResultVC != nil) else {return 0 }
        
        if let sections = fetchResultVC!.sections {
            return sections.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultVC!.sections![section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellID")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "cellID")
        }
        let contact = fetchResultVC?.object(at: indexPath) as! Contact
        
        cell?.textLabel?.text = contact.name
        cell?.detailTextLabel?.text = contact.tel
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchResultVC?.sections?[section].indexTitle
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 这里是简单模拟UI删除cell后，本地持久化区数据和UI同步的操作。在调用下面MOC保存上下文方法后，FRC会回调代理方法并更新UI
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let contact = fetchResultVC?.object(at: indexPath) as! Contact
            userContext.delete(contact)
            contenxtSave(userContext)
            break
        case .insert:break
        case .none: break
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension FetchResultViewController: NSFetchedResultsControllerDelegate{
    @objc fileprivate func backBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func refreshBtnAction(_ sender: UIButton) {
        
        if fetchResultVC == nil  {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: contactTable)
            let nameSort = NSSortDescriptor(key: "tel", ascending: true)
            request.sortDescriptors = [nameSort]
            
            fetchResultVC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: userContext, sectionNameKeyPath: "birthday", cacheName: nil)
            
            fetchResultVC?.delegate = self
        }

        do {
            /// 执行获取请求，执行后fetchResultVC会从持久化存储区加载数据，其他地方可以通过fetchResultVC获取数据
            try fetchResultVC?.performFetch()
        } catch  {
            print(" performFetch error : \(error.localizedDescription)")
        }
        
        tableView.reloadData()
    }
    
    @objc fileprivate func creatBtnAction(_ sender: UIButton) {
        
        for index in 0...20 {
            let contact = NSEntityDescription.insertNewObject(forEntityName: contactTable, into: userContext) as! Contact
            contact.name = "HOHO" + "-" + String(index)
            contact.tel = String(1000 + index)
            contact.birthday = String(index % 5)
        }
        
        contenxtSave(userContext)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension FetchResultViewController{
    /// 本地数据源发生改变，将要开始回调NSFetchedResultsControllerDelegate。
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    /// 本地数据源发生改变，NSFetchedResultsControllerDelegate回调完成。
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    /// 返回section的title，可以在这里对title做进一步处理。这里修改title后，对应section的indexTitle属性会被更新。
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        print("sectionIndexTitleForSectionName \(sectionName)")
        return sectionName
    }
    
    /// Cell数据源发生改变会回调此方法，例如添加新的托管对象等
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("indexPath is \(indexPath) \n type is \(type) \n newIndexPath is \(newIndexPath)")
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
            break
        case .update:
            let contact = fetchResultVC?.object(at: indexPath!) as! Contact
            let cell = tableView.cellForRow(at: indexPath!)
            cell?.textLabel?.text = contact.name
            cell?.detailTextLabel?.text = contact.tel
            tableView.reloadRows(at: [indexPath!], with: .automatic)
            break
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            break
        }
    }
    
    /// Section数据源发生改变回调此方法，例如修改section title等
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        print("sectionInfo is \(sectionInfo) \n atSectionIndex is \(sectionIndex) \n type is \(type)")
        
        switch type {
        case .insert:
            let indexSet = IndexSet.init(integer: sectionIndex)
            tableView.insertSections(indexSet, with: .automatic)
            break
        case .update:
            break
        case .move:
            break
        case .delete:
            tableView.deleteSections(IndexSet.init(integer: sectionIndex), with: .automatic)
            break
        }
    }
}


// MARK: - 数据库更新
extension FetchResultViewController{
    
    fileprivate func contenxtSave(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                print("CoreData save Data success")
            } catch let error {
                print("CoreData remove Data Error : \(error.localizedDescription)")
            }
        }
    }
}

