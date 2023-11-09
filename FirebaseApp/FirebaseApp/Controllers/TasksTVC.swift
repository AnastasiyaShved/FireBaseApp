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

    private var user: User!
    private var  tasks = [Task]()
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
///достаем текущего юзеар
        guard let  currentUser = Auth.auth().currentUser else { return }
        user = User(user: currentUser)
        ref = Database.database().reference(withPath: "user").child(user.uid).child("tasks")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ///можем навесить абрервепа
        ref.observe(.value) { [ weak self ] snapshot in
            var tasks = [Task]()
            for item in snapshot.children {
                guard let snapshot = item as? DataSnapshot,
                        let task = Task(snapshot: snapshot) else { return }
                tasks.append(task)
            }
            self?.tasks = tasks
            self?
        }

    }
    
    
    
    
    @IBAction func SignOut(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch  {
            print(error.localizedDescription)
        }
        /// ПРОЕРИТЬ!!!!
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
            ///cоздет таск
            let task = Task(title: text, userId: uid)
            //создаем референс на новую таску
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
    
    private func toglComplition(cll: UITableViewCell, iscompleted: Bool){
     
        //accessoryType ?????
        cell.accessoryType = iscompleted ? .checkmark : .none
    }
    
    
    // MARK: - Table view data source

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let currentTask = tasks[indexPath.row]
        cell.textLabel?.text = currentTask.title


        return cell
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
