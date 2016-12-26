//
//  ViewController.swift
//  SwiftCoreDataDemo
//
//  Created by imwallet on 16/12/20.
//  Copyright © 2016年 imWallet. All rights reserved.
//

import UIKit
import CoreData

private let schoolTable      = "School"
private let studentTable     = "Student"
private let teacherTable     = "Teacher"

private let countryTable     = "Country"
private let nationalityTable = "Nationality"
private let cityTable        = "City"


class ViewController: UIViewController {
    
    fileprivate lazy var schoolContext: NSManagedObjectContext = {
        let schoolContext = NSManagedObjectContext.setupManagedObjectContext(schoolTable)
        return schoolContext
    }()
    
    fileprivate lazy var countryContext: NSManagedObjectContext = {
        let countryContext = NSManagedObjectContext.setupManagedObjectContext(countryTable)
        return countryContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func countryAddData(_ sender: UIButton) {
        addDataForSql()
    }
    
    @IBAction func countryRemoveData(_ sender: UIButton) {
        deleteDataForSql()
    }
    
    @IBAction func countrySearchData(_ sender: UIButton) {
        searchDataForSql()
    }
    
    @IBAction func countryChange(_ sender: UIButton) {
        updateDataForSql()
    }
    
    /************************************************************************************************/
    // MARK: - 分页查询&&模糊查询
    @IBAction func pageSearch(_ sender: UIButton) {
        pageSearchDataForSql()
    }
    
    @IBAction func fuzzySearch(_ sender: UIButton) {
        fuzzySearchDataForSql()
    }
    
    /************************************************************************************************/
    
    ///  加载模型文件中设置的FetchRequest请求模板，模板名为StudentAge，在School.xcdatamodeld中设置
    @IBAction func fetchRequest(_ sender: UIButton) {
        fetchRequestTemplate()
    }

    ///   对请求结果进行排序
    @IBAction func resultSort(_ sender: UIButton) {
        sortResultForSql()
    }
    
    ///  获取返回结果的Count值，通过设置NSFetchRequest的resultType属性
    @IBAction func getResultCountOne(_ sender: UIButton) {
        searchResultCountOne()
    }
    
    ///  获取返回结果的Count值，通过调用特定方法
    @IBAction func getResultCountTwo(_ sender: UIButton) {
        searchResultCountTwo()
    }
    
    /// 位运算
    @IBAction func bitwiseArithmetic(_ sender: UIButton) {
        resultBitwiseArithmetic()
    }
    
/*************************************************************************************/
    //MARK: - 批量操作&&Asynchronous Request
    @IBAction func batchUpdate(_ sender: UIButton) {
        batchUpdateSql()
    }
    
    @IBAction func batchDelete(_ sender: UIButton) {
        batchDeleteSql()
    }
    
    @IBAction func asyncRequest(_ sender: UIButton) {
        asyncRequestSql()
    }
    
/*************************************************************************************/
    
    //MARK: - 关联操作
    ///  设置了双向关联的托管对象执行添加操作(Country&&City)
    @IBAction func reverseRelationshipsAdd(_ sender: UIButton) {
        let cityOne = NSEntityDescription.insertNewObject(forEntityName: cityTable, into: countryContext) as! City
        cityOne.cityName = "北京"
        cityOne.isCapital = true
        
        let cityTwo = NSEntityDescription.insertNewObject(forEntityName: cityTable, into: countryContext) as! City
        cityTwo.cityName = "上海"
        cityTwo.isCapital = false
        
        let cityThree = NSEntityDescription.insertNewObject(forEntityName: cityTable, into: countryContext) as! City
        cityThree.cityName = "纽约"
        cityThree.isCapital = false
        
        let countryOne = NSEntityDescription.insertNewObject(forEntityName: nationalityTable, into: countryContext) as! Nationality
        countryOne.countryName = "中国"
        countryOne.area = 9_634_057.01
        
        countryOne.addToCitys([cityOne, cityTwo])//添加到citys中
        
        let countryTwo = NSEntityDescription.insertNewObject(forEntityName: nationalityTable, into: countryContext) as! Nationality
        countryTwo.countryName = "美国"
        countryTwo.area = 9_629_091.01
        
        countryTwo.addToCitys(cityThree)//添加到citys中
        
        contenxtSave(countryContext)
        
        print("cityOne.country is \(cityOne.country)")// 有值
        print("cityTwo.country is \(cityTwo.country)")// 有值
        
        print("countryOne.citys is \(countryOne.citys)")// 有值
        if let citys = countryOne.citys {
            for city in citys {
                print("city is \((city as! City).cityName) country is \(countryOne.countryName)")
            }
        }

        print("countryTwo.citys is \(countryTwo.citys)")// 有值
        if let citysTwo = countryTwo.citys {
            for city in citysTwo {
                print("city is \((city as! City).cityName) country is \(countryTwo.countryName)")
            }
        }
    }
    
    /// 删除Department托管对象，在删除Country托管对象后，其对应的City会将关联属性设置为空，City并不会被一起删除
    /// 在一个托管对象被删除时，其相关联的托管对象是否被删除，是由delete rule决定的
    @IBAction func reverseRelationshipsDelete(_ sender: UIButton) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: nationalityTable)
        let predicate = NSPredicate(format: "countryName = %@", "美国")
        request.predicate = predicate
        
        do {
            let countrys = try countryContext.fetch(request) as! [Nationality]
            for (index, country) in countrys.enumerated() {
                print("\(index) country delete \(country.countryName)")
                countryContext.delete(country)
            }
        } catch  {
            print("Delete Country Object Error : \(error)")
        }
        
        contenxtSave(countryContext)
    }
    
    
    ///  添加Student和Teacher托管对象，两者之间设置了关联关系但没有反向关联，也就是没有设置inverse。
    /// 下面Teacher将Student对象添加到自己的集合属性后，在数据库中Teacher有一个指向Student的外键，而Student则不知道Teacher，也就是Student的外键没有指向Teacher。
    /// 在下面打印结果也可以看出，Teacher打印关联属性是有值的，而Student的关联属性没值。如果设置inverse结果则不同，这就是inverse设置与否的区别。
    @IBAction func relationshipsAdd(_ sender: UIButton) {
        let studentOne = NSEntityDescription.insertNewObject(forEntityName: studentTable, into: schoolContext) as! Student
        studentOne.name = "Google"
        studentOne.age = 18
        
        let studentTwo = NSEntityDescription.insertNewObject(forEntityName: studentTable, into: schoolContext) as! Student
        studentTwo.name = "Baidu"
        studentTwo.age = 19
        
        let teacherOne = NSEntityDescription.insertNewObject(forEntityName: teacherTable, into: schoolContext) as! Teacher
        teacherOne.name = "America"
        teacherOne.subject = "Internet"
        teacherOne.addToStudents(studentOne)//添加到teacher
        
        let teacherTwo = NSEntityDescription.insertNewObject(forEntityName: teacherTable, into: schoolContext) as! Teacher
        teacherTwo.name = "China"
        teacherTwo.subject = "Family bucket"
        teacherTwo.addToStudents(studentTwo)//添加到teacher
        
        contenxtSave(schoolContext)
        
        print("studentOne.teacher is \(studentOne.teacher)")
        print("studentTwo.teacher is \(studentTwo.teacher)")
        
        print("TeacherOne.students is \(teacherOne.students)")
        if let students = teacherOne.students {
            for student in students {
                print("student.name is \((student as! Student).name) teacher is \(teacherOne.name)")
            }
        }
        
        print("TeacherTwo.students is \(teacherTwo.students)")
        if let studentsTwo = teacherTwo.students {
            for student in studentsTwo {
                print("student.name is \((student as! Student).name) teacher is \(teacherTwo.name)")
            }
        }
    }
    
    
    ///  删除Teacher对象并不会对其关联属性关联的对象造成影响，这主要还是Delete rule设置的结果
    @IBAction func relationshipsDelete(_ sender: UIButton) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: teacherTable)
        let predicate = NSPredicate(format: "subject = %@", "Family bucket")
        request.predicate = predicate
        
        do {
            let teachers = try schoolContext.fetch(request) as! [Teacher]
            for (index, teacher) in teachers.enumerated() {
                print("\(index) teacher name is \(teacher.name)")
                
                schoolContext.delete(teacher)
            }
        } catch  {
            print("Delete Teacher Object Error \(error.localizedDescription)")
        }
    }
    
    
    //MARK: - NSFetchedResultsController
    @IBAction func fetchRequestController(_ sender: UIButton) {
        self.present(FetchResultViewController(), animated: true) {}
    }
    
    
    @IBAction func persistentContainerController(_ sender: UIButton) {
        self.present(PersistentContainerViewController(), animated: true, completion: nil)
    }
    
}


// MARK: - 增 删 改 查
extension ViewController{
    
    fileprivate func addDataForSql() {
        
        for index in 0...15 {
            let student = NSEntityDescription.insertNewObject(forEntityName: studentTable, into: schoolContext) as! Student
            student.name = "HAHA" + String(index)
            student.age = index + 10
        }
        contenxtSave(schoolContext)
    }
    
    fileprivate func deleteDataForSql() {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: studentTable)
        let predicate = NSPredicate(format: "age = %d", 13)
        request.predicate = predicate
        do {
            let students = try schoolContext.fetch(request) as! [Student]
            if students.isEmpty {
                print("CoreData search age = 20 is not exit")
                return
            }
            for (index, student) in students.enumerated() {
                schoolContext.delete(student)// 删除
                print("deleteDataForSql \(index) student name is \(student.name!) is delete")
                print("deleteDataForSql \(index) student age is \(student.age) is delete")
            }
        } catch {
            print("CoreData remove Data Error : \(error.localizedDescription)")
        }
        
        contenxtSave(schoolContext)
    }
    
    fileprivate func updateDataForSql() {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: studentTable)
        let predicate = NSPredicate(format: "age = %d", 15)
        request.predicate = predicate
        do {
            let students = try schoolContext.fetch(request) as! [Student]
            if students.isEmpty {
                print("CoreData change HAHA is not exit")
                return
            }
            
            for (index, student) in students.enumerated() {
                student.name = "HeiHei"
                student.age = 18
                print("updateDataForSql \(index) student name is \(student.name!)")
                print("updateDataForSql \(index) student age is \(student.age)")
            }
        } catch {
            print("CoreData remove Data Error : \(error.localizedDescription)")
        }
        
        contenxtSave(schoolContext)
    }
    
    fileprivate func searchDataForSql() {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: studentTable)
        /* NSFetchRequestResultType
         managedObjectResultType   返回值是NSManagedObject的子类，也就是托管对象，这是默认选项
         managedObjectIDResultType 返回NSManagedObjectID类型的对象，也就是NSManagedObject的ID，对内存占用比较小.MOC可以通过NSManagedObjectID对象获取对应的托管对象，并且可以通过缓存NSManagedObjectID参数来节省内存消耗
         dictionaryResultType      返回字典类型对象
         countResultType           返回请求结果的count值，这个操作是发生在数据库层级的，并不需要将数据加载到内存中
         */
        request.resultType = .managedObjectResultType
        let predicate = NSPredicate(format: "age = %d", 22)
        request.predicate = predicate
        
        do {
            let students = try schoolContext.fetch(request) as! [Student]
            if students.isEmpty {
                print("CoreData search HAHA is not exit")
                return
            }
            
            for (index, student) in students.enumerated() {
                print("searchDataForSql \(index) student name is \(student.name!)")
                print("searchDataForSql \(index) student age is \(student.age)")
            }
        } catch {
            print("CoreData search Data Error : \(error.localizedDescription)")
        }
    }
}


extension ViewController{
    
    /// 分页查询
    fileprivate func pageSearchDataForSql() {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: studentTable)
        
        // 设置分页，每次请求获取六个托管对象
        request.fetchLimit = 6
        // 设置查找起始点，这里是从搜索结果的第2个开始获取
        request.fetchOffset = 2
        //        // 从数据库里每次加载20条数据来筛选数据
        //        request.fetchBatchSize = 20
        
        // 设置排序规则，这里设置年龄升序排序
        let sortDesc = NSSortDescriptor(key: "age", ascending: true)
        request.sortDescriptors = [sortDesc]
        
        do {
            let students = try schoolContext.fetch(request) as! [Student]
            if students.isEmpty {
                print("CoreData pageSearch is not exit")
                return
            }
            
            for (index, student) in students.enumerated() {
                print("pageSearchDataForSql \(index) student name is \(student.name!)")
                print("pageSearchDataForSql \(index) student age is \(student.age)")
            }
        } catch {
            print("CoreData search Data Error : \(error.localizedDescription)")
        }
    }
    
    /// 模糊查询
    fileprivate func fuzzySearchDataForSql() {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: studentTable)
        /*
         let predicate = NSPredicate(format: "name BEGINSWITH %@", "HAHA") // 以HAHA开头
         let predicate = NSPredicate(format: "name ENDSWITH %@", "HAHA") // 以HAHA结尾
         let predicate = NSPredicate(format: "name contains %@", "HAHA") // 其中包含HAHA
         */
        // 创建模糊查询条件。这里设置的带通配符的查询，查询条件是结果包含HAHA
        let predicate = NSPredicate(format: "name LIKE %@", "*HAHA*")
        request.predicate = predicate
        
        do {
            let students = try schoolContext.fetch(request) as! [Student]
            if students.isEmpty {
                print("CoreData fuzzySearch HAHA is not exit")
                return
            }
            
            for (index, student) in students.enumerated() {
                print("fuzzySearchDataForSql \(index) student name is \(student.name!)")
                print("fuzzySearchDataForSql \(index) student age is \(student.age)")
            }
        } catch {
            print("CoreData search Data Error : \(error.localizedDescription)")
        }
    }
}

extension ViewController{
    
    /// 通过模板请求
    fileprivate func fetchRequestTemplate() {
        let model = schoolContext.persistentStoreCoordinator?.managedObjectModel
        let request = model?.fetchRequestTemplate(forName: "StudentAge") // 请求模板
        guard (request != nil) else { return }
        do {
            let students = try schoolContext.fetch(request!) as! [Student]
            if students.isEmpty {
                print("CoreData fuzzySearch HAHA is not exit")
                return
            }
            
            for (index, student) in students.enumerated() {
                print("fetchRequestTemplate \(index) student name is \(student.name!)")
                print("fetchRequestTemplate \(index) student age is \(student.age)")
            }
        } catch {
            print("CoreData search Data Error : \(error.localizedDescription)")
        }
    }
    
    /// 排序
    fileprivate func sortResultForSql() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: studentTable)
        // 设置请求结果排序方式，可以设置一个或一组排序方式，最后将所有的排序方式添加到排序数组中
        let sortDesc = NSSortDescriptor(key: "age", ascending: true)
        // NSSortDescriptor的操作都是在SQLite层级完成的，不会将对象加载到内存中，所以对内存的消耗是非常小的
        request.sortDescriptors = [sortDesc]
        
        do {
            let students = try schoolContext.fetch(request) as! [Student]
            if students.isEmpty {
                print("CoreData Search resultSort is not exit")
                return
            }
            
            for (index, student) in students.enumerated() {
                print("sortResultForSql \(index) student name is \(student.name!)")
                print("sortResultForSql \(index) student age is \(student.age)")
            }
        } catch {
            print("CoreData resultSort Data Error : \(error.localizedDescription)")
        }
    }
    
    /// 搜索结果的数量1
    fileprivate func searchResultCountOne() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: studentTable)
        let predicate = NSPredicate(format: "age > 20 AND age < 22")
        request.predicate = predicate
        request.resultType = .countResultType
        do {
            // 返回结果存在数组的第一个元素中，是一个NSNumber的对象，通过这个对象即可获得Count值
            let students = try schoolContext.fetch(request) as! [NSNumber]
            let count = students.first?.intValue
            print("fetch request result count is \(count!)")
            
        } catch  {
            print("CoreData getResultCountOne Error : \(error.localizedDescription)")
        }
    }
    
    /// 搜索结果的数量2
    fileprivate func searchResultCountTwo() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: studentTable)
        let predicate = NSPredicate(format: "age > 20 AND age < 22")
        request.predicate = predicate
        //        request.resultType = .countResultType
        
        do {
            // 通过调用countForFetchRequest方法，获取请求结果count值
            let count = try schoolContext.count(for: request)
            print("fetch request result count is \(count)")
            
        } catch  {
            print("CoreData getResultCountTwo Error : \(error.localizedDescription)")
        }
    }
}

/**
 对返回的结果进行按位运算，这个运算是发生在SQLite数据库层的，所以执行效率很快，对内存的消耗也很小
 如果需要对托管对象的某个属性进行运算，比较推荐这种效率高的方法
 */
extension ViewController{
    
    /// 位运算
    fileprivate func resultBitwiseArithmetic() {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: studentTable)
        
        // 设置返回值为字典类型，这是为了结果可以通过设置的name名取出，这一步是必须的
        request.resultType = .dictionaryResultType
        
        // 创建描述对象的name字符串
        let descriptionName = "sumOperatin"
        
        // 创建描述对象
        let expressionDesc = NSExpressionDescription()
        
        // 设置描述对象的name，最后结果需要用这个name当做key来取出结果
        expressionDesc.name = descriptionName
        
        // 设置返回值类型，根据运算结果设置类型
        expressionDesc.expressionResultType = .integer16AttributeType
        
        // 创建具体描述对象，用来描述对哪个属性进行什么运算(可执行的运算类型很多，这里描述的是对age属性，做sum运算)
        let expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "age")])
        
        // 只能对应一个具体描述对象
        expressionDesc.expression = expression
        
        // 给请求对象设置描述对象，这里是一个数组类型，也就是可以设置多个描述对象
        request.propertiesToFetch = [expressionDesc]
        
        do {
            let results = try schoolContext.fetch(request) as! [NSDictionary]
            // 通过上面设置的name值，当做请求结果的key取出计算结果
            let sumResults = results.first?[descriptionName]
            
            print("fetch request result is \(sumResults)")
        } catch  {
            print("fetch request result error : \(error.localizedDescription)");
        }
    }
}


/**
 注意：无论是批量更新还是批量删除，这个批量操作都是发生在SQLite层的。然而在SQLite发生了批量操作后，并不会主动更新上层上下文中缓存的托管对象，所以在进行批量操作后，需要对相关的MOC进行更新操作。
     虽然在客户端很少遇到大量数据处理的情况，但是如果遇到这样的需求，推荐使用批量处理API。
     调用批量处理API，要注意版本适配
 */
extension ViewController{
    
    /// 批量更新
    fileprivate func batchUpdateSql() {
        let updateRequest = NSBatchUpdateRequest(entityName: studentTable)
        
        // 设置返回值类型，默认是什么都不返回(statusOnlyResultType)，这里设置返回发生改变的对象Count值
        updateRequest.resultType = .updatedObjectsCountResultType
        
        // 设置发生改变字段的字典
        updateRequest.propertiesToUpdate = ["age" : 23]
        do {
            let result =  try schoolContext.execute(updateRequest) as! NSBatchUpdateResult
            let updateResult = result.result as! Int
            print("batchUpdate count is \(updateResult)")
            
            // 更新context中的托管对象，使context和本地持久化区数据同步
            schoolContext.refreshAllObjects()
        } catch  {
            print("batch update request result error :\(error.localizedDescription)")
        }
    }
    
    /// 批量删除
    fileprivate func batchDeleteSql() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: studentTable)
        let predicate = NSPredicate(format: "age > 20")
        request.predicate = predicate
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeCount
        do {
            let result = try schoolContext.execute(deleteRequest) as!NSBatchDeleteResult
            let deleteResult = result.result as! Int
            print("batch delete request result count is \(deleteResult)")
            
            schoolContext.refreshAllObjects()
        } catch  {
            print("batch delete request error \(error.localizedDescription)")
        }
    }
}


/*
 如果有多个请求同时发起，不需要担心线程安全的问题，系统会将所有的异步请求添加到一个操作队列中，在前一个任务访问数据库时，CoreData会将数据库加锁，等前面的执行完成才会继续执行后面的操作。
 需要做版本兼容
 */
extension ViewController{
    fileprivate func asyncRequestSql() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: studentTable)
        let asycRequest = NSAsynchronousFetchRequest(fetchRequest: request) { (asycResult:NSAsynchronousFetchResult) in
            // 通过返回结果的finalResult属性，获取结果数组
            if let result = asycResult.finalResult {
                let students = result as! [Student]
                for (index, student) in students.enumerated(){
                    print("asyncRequestSql \(index) student name is \(student.name)")
                    print("asyncRequestSql \(index) student age is \(student.age)")
                }
            }else{
                print("core data is not exit")
            }
        }
        
        do {
            // 执行异步请求，和批量处理执行同一个请求方法
            try schoolContext.execute(asycRequest)
        } catch  {
            print("asyncRequest errer is \(error.localizedDescription)")
        }
    }
}


// MARK: - 数据库更新
extension ViewController{
    
     fileprivate func contenxtSave(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                print("CoreData save Data success")
            } catch  {
                print("CoreData remove Data Error : \(error.localizedDescription)")
            }
        }
    }
}

/**********************************************************/
