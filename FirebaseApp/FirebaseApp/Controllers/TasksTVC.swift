//
//  TasksTVC.swift
//  FirebaseApp
//
//  Created by Apple on 9.11.23.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class TasksTVC: UITableViewController {

    // MARK: - Properties
    private var user: User!
    private var  tasks = [Task]()
    var ref: DatabaseReference!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ///достаем текущего юзера
        guard let  currentUser = Auth.auth().currentUser else { return }
        user = User(user: currentUser)
        ref = Database.database().reference(withPath: "user").child(user.uid).child("tasks")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ref.observe(.value) { [ weak self ] snapshot in
            var tasks = [Task]()
            for item in snapshot.children {
                guard let snapshot = item as? DataSnapshot,
                      let task = Task(snapshot: snapshot) else { return }
                tasks.append(task)
            }
            self?.tasks = tasks
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    @IBAction func SignOut(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch  {
            print(error.localizedDescription)
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func addNewTaskBtn(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New task", message: "Add new task", preferredStyle: .alert)
        alertController.addTextField()
        // 1 - save
        let save = UIAlertAction(title: "Save", style: .default) { [ weak self ] _ in
            guard let self = self,
                  let textField = alertController.textFields?.first,
                  let text = textField.text else { return }
            let uid = self.user.uid
            ///cоздем таск
            let task = Task(title: text, userId: uid)
            ///создаем референс на новую таску
            let taskRef = self.ref.child(task.title.lowercased())
            /// отправляем на сервер
            taskRef.setValue(task.convertToDictinary())
        }
        // 2 - cansel
        let cansel = UIAlertAction(title: "Cansel", style: .cancel)
        
        alertController.addAction(save)
        alertController.addAction(cansel)
        present(alertController, animated: true)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let currentTask = tasks[indexPath.row]
        cell.textLabel?.text = currentTask.title
        toggleColection(cell: cell, iscompleted: currentTask.completed)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//
//        }
//    }
    
    // MARK: - Private func
    private func toggleColection(cell: UITableViewCell, iscompleted: Bool){
        cell.accessoryType = iscompleted ? .checkmark : .none
    }
}
