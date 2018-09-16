//
//  ViewController.swift
//  CameraAppTest
//
//  Created by Binayak Tiwari on 6/13/18.
//  Copyright © 2018 bintiw. All rights reserved.
//

import UIKit
import Vision
import TesseractOCR
import AudioToolbox


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, G8TesseractDelegate , UITextFieldDelegate{
    
    @IBOutlet weak var BlurBackground: UIVisualEffectView!
    
    @IBAction func UserInputChange(_ sender: UITextField) {
        UserDefaults.standard.set(ScanType, forKey: "ScanTypeData")
        var items = UserInput.text?.components(separatedBy: [" ", ",", "."])
        items = items?.filter{$0 != ""}
        print(items)
    }
    @IBOutlet weak var Loading: UIActivityIndicatorView!
    @IBOutlet weak var SearchBtn: UIButton!
    @IBOutlet weak var UserInput: UITextField!
    @IBOutlet weak var Photos: UIButton!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var Camera: UIButton!
    @IBOutlet weak var TextView: UITextView!
    
    var imageToCheck: UIImage!
    var imageToDetect: UIImage!
    var RecogText: String?
    var activityIndicator:UIActivityIndicatorView=UIActivityIndicatorView()
    
    var ScanType:[String:[String]] = ["Vegan":["chicken","pork","beef","mutton","egg","milk","cheese","fish","salmon"],
                                      "Vegeterian":["chicken","pork","beef","mutton","egg","fish","salmon"],
                                      "Lactose":["milk","yoghurt","cream","butter","ice cream","cheese"]]
    
    override func viewDidAppear(_ animated: Bool) {
        if let x = UserDefaults.standard.object(forKey: "ScanTypeData") as? [String:[String]] {
            ScanType = x
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UserInput.delegate = self
        UIApplication.shared.isIdleTimerDisabled = false
        Loading.isHidden = true
        TextView.isHidden = true
        BlurBackground.isHidden = true
         GoBack.isHidden = true
       
    }

    @IBOutlet weak var GoBack: UIButton!
    @IBAction func GoBackAction(_ sender: UIButton) {
        self.TextView.isHidden = true
        self.BlurBackground.isHidden = true
        self.GoBack.isHidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func CameraAction(_ sender: UIButton) {
        
       if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
       {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
        }
        
        
        
    }
    
    @IBAction func PhotoAction(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func progressImageRecognition(for tesseract: G8Tesseract!) {
        //print("Recognition Progress \(tesseract.progress) %")
        let progress = tesseract.progress
        print (progress)
    }
    
    
    func RecogWork(){
        
        var items = UserInput.text?.components(separatedBy: [" ", ",", "."])
        items = items?.filter{$0 != ""}
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                
                self.UserInput.resignFirstResponder()
                self.ImageView.image = self.imageToCheck
            }
            if(self.imageToDetect != self.imageToCheck){
                DispatchQueue.main.async {
                    self.Loading.startAnimating()}
                if let tesseract = G8Tesseract(language: "eng"){
                    tesseract.delegate = self
                    tesseract.image = (self.imageToCheck)?.g8_blackAndWhite()
                    tesseract.recognize()
                    self.RecogText = tesseract.recognizedText
                }
                DispatchQueue.main.async {
                    self.Loading.stopAnimating()
                }
                self.imageToDetect = self.imageToCheck
            }
            DispatchQueue.main.async {
                var UserText = self.UserInput.text
                var itemContains = [String]()
                var itemsDoesnotContains = [String]()
                
                for itemsToCheck in items!{
                    UserText = itemsToCheck
                if self.RecogText!.lowercased().range(of: UserText!.lowercased()) != nil{
                   // self.TextView.text = "This Item Contain \(UserText!)"
                   // self.TextView.textColor = UIColor.green
                    itemContains.append(UserText!)
                   // self.TextView.isHidden = false
                }
                else
                {
                    //self.TextView.text = "This Item Doesn't Contain \(UserText!)"
                    //self.TextView.textColor = UIColor.red
                    itemsDoesnotContains.append(UserText!)
                    //self.TextView.isHidden = false
                }
                
            }
            AudioServicesPlaySystemSound(SystemSoundID(1007))
                var conString : String?
                var doesnotConString: String?
                
                conString = "This Item Contain: \n"
                for i in itemContains{
                    conString = conString! + i + "\n"
                }
                
                
                doesnotConString =  "\n\n\nThis Item Doesn't Contain: \n"
                for i in itemsDoesnotContains{
                   doesnotConString = doesnotConString! + i + "\n"
                }
                
                let attrs1 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedStringKey.foregroundColor : UIColor.green]
                
                let attrs2 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedStringKey.foregroundColor : UIColor.red]
                
                let attributedString1 = NSMutableAttributedString(string:conString!, attributes:attrs1)
                
                let attributedString2 = NSMutableAttributedString(string:doesnotConString!, attributes:attrs2)
                
                
                attributedString1.append(attributedString2)
                self.TextView.attributedText = attributedString1
                
                
                self.TextView.isHidden = false
                self.BlurBackground.isHidden = false
                self.GoBack.isHidden = false
                
                print (itemContains)
                print (itemsDoesnotContains)
        }
        }
    }
    
    @IBAction func Button(_ sender: UIButton) {
        RecogWork()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedimage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            ImageView.contentMode = .scaleAspectFit
            ImageView.image = pickedimage
            imageToCheck = pickedimage
        }
picker.dismiss(animated: true, completion: nil)
    }
}

