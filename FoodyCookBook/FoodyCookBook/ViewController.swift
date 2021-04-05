//
//  ViewController.swift
//  Foody_book
//
//  Created by Jaydip on 04/04/21.
//

import UIKit
import Alamofire
import JGProgressHUD

class ViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var search_textfield: UITextField!
    @IBOutlet weak var btn_fav: UIButton!
    var arr_fav = [String]()
    let meal_data_dict = [String:Any]()
    var is_food_display = false
    var food_name = String()
    let hud = JGProgressHUD()
    
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_source: UILabel!
    @IBOutlet weak var lbl_category: UILabel!
    @IBOutlet weak var lbl_instruction: UILabel!
    @IBOutlet weak var lbl_tag: UILabel!
    @IBOutlet weak var lbl_youtube: UILabel!
    @IBOutlet weak var lbl_Area: UILabel!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let arr = UserDefaults.standard.array(forKey: "arr_fav_food") as? [String]
        {
            arr_fav = arr
            print(arr)
        }
        if Connectivity.isConnectedToInternet
        {
            get_random_food()
        }
        else
        {
            self.show_alert(msg: NETWORK_ALERT)
        }
        
    }
    override func viewWillAppear(_ animated: Bool)
    {
        if let arr = UserDefaults.standard.array(forKey: "arr_fav_food") as? [String]
        {
            arr_fav = arr
            if(self.arr_fav.contains(food_name))
            {
                self.btn_fav.setBackgroundImage(UIImage(named: "heart"), for: .normal)
            }
            else
            {
                self.btn_fav.setBackgroundImage(UIImage(named: "like"), for: .normal)
            }
        }
        
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        search_textfield.text = ""
    }
    //MARK:- Button click method
    @IBAction func btn_search_press(_ sender: UIButton)
    {
        if search_textfield.text?.isEmpty ?? true
        {
            self.show_alert(msg: "Please enter text")
        }
        else
        {
            if Connectivity.isConnectedToInternet
            {
                get_search_food()
            }
            else
            {
                self.show_alert(msg: NETWORK_ALERT)
            }
            
        }
    }
    @IBAction func btn_list_press(_ sender: UIButton)
    {
        let fav_page = self.storyboard?.instantiateViewController(withIdentifier: "FavouriteVC") as! FavouriteVC
        self.navigationController?.pushViewController(fav_page, animated: true)
    }
    @IBAction func btn_fav_press(_ sender: UIButton)
    {
        if(is_food_display)
        {
            if(sender.tag==0)
            {
                sender.tag = 1
                sender.setBackgroundImage(UIImage(named: "heart"), for: .normal)
                arr_fav.append(food_name)
                UserDefaults.standard.setValue(arr_fav, forKey: "arr_fav_food")
                UserDefaults.standard.synchronize()
            }
            else
            {
                sender.tag = 0
                sender.setBackgroundImage(UIImage(named: "like"), for: .normal)
                self.arr_fav.remove(at: arr_fav.index(of: food_name)!)
            }
        }
    }
    //MARK:- API call method
    func get_random_food()
    {
        hud.show(in: self.view)
        AF.request(BASEURL+RANDOM_API, method: .get, parameters: nil)
            .responseJSON { [self] (response) in
                
                hud.dismiss()
                switch response.result {
                
                
                case .success:
                    print("success")
                    if let result_dict = response.value as? [String:Any]
                    {
                        if let meal_arr = result_dict["meals"] as? [[String:Any]]
                        {
                            if let info_dict = meal_arr[0] as? [String:Any]
                            {
                                let jsonData = try? JSONSerialization.data(withJSONObject: info_dict, options: [])
                                let decoder = JSONDecoder()
                                do {
                                    is_food_display = true
                                    let meal_data = try decoder.decode(Meal_obj.self, from: jsonData!)
                                    self.food_name = meal_data.strMeal
                                    self.set_ui(meal_Info: meal_data)
                                } catch {
                                    print(error)
                                }
                                
                                
        
                            }
                        }
                    }
                case .failure(let error):
                    // error handling
                    self.show_alert(msg: SOMETHING_WRONG)
                    search_textfield.text = ""
                    break
                }
        }
    }
    func get_search_food()
    {
        hud.show(in: self.view)
        AF.request(BASEURL+SEARCH_API+"?s=\(search_textfield.text!)", method: .get, parameters: nil)
            .responseJSON { [self] (response) in
                hud.dismiss()
                switch response.result {
                case .success:
                    if let result_dict = response.value as? [String:Any]
                    {
                        if let meal_arr = result_dict["meals"] as? [[String:Any]]
                        {
                            if let info_dict = meal_arr[0] as? [String:Any]
                            {
                                let jsonData = try? JSONSerialization.data(withJSONObject: info_dict, options: [])
                                let decoder = JSONDecoder()
                                do {
                                    let meal_data = try decoder.decode(Meal_obj.self, from: jsonData!)
                                    self.food_name = meal_data.strMeal
                                    self.set_ui(meal_Info: meal_data)
                                    is_food_display = true
                                    if(self.arr_fav.contains(food_name))
                                    {
                                        self.btn_fav.setBackgroundImage(UIImage(named: "heart"), for: .normal)
                                    }
                                    else
                                    {
                                        self.btn_fav.setBackgroundImage(UIImage(named: "like"), for: .normal)
                                    }
                                } catch {
                                    print(error)
                                }
                                
                                
                                
    
                            }
                        }
                    }
                case .failure(let error):
                    self.show_alert(msg: SOMETHING_WRONG)
                    break
                }
        }
    }
    func set_ui(meal_Info:Meal_obj)
    {
        lbl_name.text = "Name : " + meal_Info.strMeal
        lbl_tag.text = "Tags : " + meal_Info.strTags
        lbl_Area.text = "Area : " + meal_Info.strArea
        lbl_source.text = "Source : " + meal_Info.strImageSource
        lbl_category.text = "Category : " + meal_Info.strCategory
        lbl_youtube.text = "Youtube : " + meal_Info.strYoutube
        lbl_instruction.text = "Instruction : " + meal_Info.strInstructions
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }

}

struct Connectivity {
  static let sharedInstance = NetworkReachabilityManager()!
  static var isConnectedToInternet:Bool {
      return self.sharedInstance.isReachable
    }
}


extension UIViewController
{
    func show_alert(msg:String)
    {
        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
