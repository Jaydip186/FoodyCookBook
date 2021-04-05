//
//  FavouriteVC.swift
//  Foody_book
//
//  Created by Jaydip on 04/04/21.
//

import UIKit

class FavouriteVC: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    
    @IBOutlet weak var lbl_nodata: UILabel!
    @IBOutlet weak var fav_tbl: UITableView!
    var arr_fav_food = [String]()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        fav_tbl.tableFooterView = UIView()
        if let saved_arr = UserDefaults.standard.array(forKey: "arr_fav_food") as? [String]
        {
            arr_fav_food = saved_arr
            reload_table_data()
        }
    }
    //MARK:- Button click method
    @IBAction func back_press(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK:- Tableview methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arr_fav_food.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Fav_cell")!
        cell.textLabel?.text = arr_fav_food[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete)
        {
            let alert = UIAlertController(title: "", message: "Are you sure you want to remove from favourite?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { [self]_ in
                arr_fav_food.remove(at: indexPath.row)
                UserDefaults.standard.setValue(arr_fav_food, forKey: "arr_fav_food")
                UserDefaults.standard.synchronize()
                self.reload_table_data()
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func reload_table_data()
    {
        fav_tbl.reloadData()
        if(arr_fav_food.count>0)
        {
            lbl_nodata.text = NO_DATA
        }
        else
        {
            lbl_nodata.text = ""
        }
    }
    

}
