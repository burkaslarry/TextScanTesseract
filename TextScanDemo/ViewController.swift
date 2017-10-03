//
//  ViewController.swift
//  TextScanDemo
//
//  Created by Larry Lo Wai Lun on 3/10/2017.
//  Copyright © 2017 Larry Lo Wai Lun. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UITextFieldDelegate , UIPickerViewDelegate  , UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
          return 1
    }
    

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var txtAmount: UITextField!    
    @IBOutlet weak var txtDesp: UITextField!
    
    @IBOutlet weak var btnScanRemarks: UIButton!
    
    @IBOutlet weak var btnScanAmount: UIButton!
    var pickerViewTuple: UIPickerView = UIPickerView()
    
    var amoun : Bool  = false
    
    var agent : Agent? = nil ;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        txtAmount.delegate = self
        txtDesp.delegate = self
        agent = Agent.sharedInstance
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewWillAppear(_ animated: Bool) {
        if agent?.scannedImage != nil {
            self.imgView.image = agent?.scannedImage
        }
        
        let count : Int = agent?.scannedItem.count ?? 0
        
        print("count\(count)")
        if count > 0 {
            let result = agent?.scannedItem.last?.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted)
            txtAmount.text = result
            
            //txtAmount.text = user?.scannedItem.last
            txtDesp.text = agent?.scannedItem.first
            //instaintiate picker tuple
            pickerViewTuple.dataSource = self
            pickerViewTuple.delegate = self
            pickerViewTuple.isHidden = true
            
            pickerViewTuple.frame = CGRect.init(x: 0, y: self.view.frame.size.height -  0.2 * self.view.frame.size.height, width: self.view.frame.size.width, height:  0.2 * self.view.frame.size.height)
            pickerViewTuple.backgroundColor = UIColor.white
            //other pickerView code like dataSource and delegate
            self.view.addSubview(pickerViewTuple)
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //self.view.endEditing(true)
        return textField.text!.characters.count > 0
    }
    
    @IBAction func createRecord(_ sender: Any) {
        
        if txtDesp.text!.isEmpty {  return }
        if txtAmount.text!.isEmpty  { return }
        
        agent?.setScannedlist(list: [])
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectText(_ sender: Any) {
        amoun = false
        pickerViewTuple.isHidden = false
    }
    @IBAction func selecAmount(_ sender: Any) {
        amoun = true
        pickerViewTuple.isHidden = false
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return agent?.scannedItem.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (agent?.scannedItem[row])!
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(amoun) {
            let result = agent?.scannedItem[row].trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted)
            txtAmount.text = result
        }else{
            txtDesp.text = agent?.scannedItem[row]
        }
        pickerViewTuple.isHidden = true
    }
    
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 20.0
    }
    
    @IBAction func showButtonPressed(_ sender: AnyObject) {
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"testCamera")
        viewController.modalTransitionStyle = .crossDissolve
        self.present(viewController, animated: true)
        
    }
    
    
}

