//
//  InterfaceController.swift
//  watch tutorial WatchKit Extension
//
//  Created by Travis Elliott on 6/27/16.
//  Copyright © 2016 National Control Devices. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    let accessToken = "EnterAccessTokenHere"
    let deviceID = "EnterDeviceIDHere"
    
    var selectedTemperature: String = "70"
    
    var pickerItems: [WKPickerItem] = []

    @IBOutlet var currentTemperature: WKInterfaceLabel!
    
    @IBOutlet var Picker: WKInterfacePicker!
    @IBOutlet var SystemStateSwitch: WKInterfaceSwitch!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        //Populate temperatures in Set Temperature Picker
        
        for i in 50...90{
            let pickerItem = WKPickerItem()
            pickerItem.title = String(i)
            pickerItems.append(pickerItem)
        }
        Picker.setItems(pickerItems)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        //Get current set temp
        currentTemperature.setText("Loading")
        var scriptUrl = "https://api.particle.io/v1/devices/"+deviceID+"/setTemp"
        var urlWithParams = scriptUrl + "?access_token=\(accessToken)"
        var myUrl = NSURL(string: urlWithParams);
        var request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "GET"
        
        var task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            _ = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            do {
                if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    
                    // Print out dictionary
                    //                    print(convertedJsonIntoDict)
                    
                    // Get value by key
                    let resultValue = (convertedJsonIntoDict["result"] as! String)
                    
                    self.Picker.setSelectedItemIndex(Int(resultValue)!-50)
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        task.resume()
        
        
        //Get current Temperature
        particleVariableRead("data", labelOutput: self.currentTemperature, deviceID: deviceID, token: accessToken)
        
        //Get Set System State
        
        scriptUrl = "https://api.particle.io/v1/devices/"+deviceID+"/status"
        urlWithParams = scriptUrl + "?access_token=\(accessToken)"
        myUrl = NSURL(string: urlWithParams);
        request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "GET"
        
        task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            // Check for error
            if error != nil
            {
                self.currentTemperature.setText("error")
                print("error=\(error)")
                return
            }
            _ = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            do {
                if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    
                    // Print out dictionary
                    //                    print(convertedJsonIntoDict)
                    
                    // Get value by key
                    let resultValue = (convertedJsonIntoDict["result"] as! String)
                    if(resultValue == "on"){
                        self.SystemStateSwitch.setOn(true)
                    }else{
                        self.SystemStateSwitch.setOn(false)
                    }
                    
                }
            } catch let error as NSError {
                self.currentTemperature.setText("Error")
                print(error.localizedDescription)
            }
            
        }
        task.resume()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    @IBAction func PickerChanged(value: Int) {
        selectedTemperature = pickerItems[value].title!
    }
    @IBAction func setTemp() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.particle.io/v1/devices/"+deviceID+"/setTemp")!)
        request.HTTPMethod = "POST"
        let postString = "arg="+selectedTemperature+"&access_token="+accessToken
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            self.SystemStateSwitch.setOn(true)
        }
        task.resume()
    }
    @IBAction func SwitchChange(value: Bool) {
        var command = ""
        if(value){
            command = "on"
        }else{
            command = "off"
        }
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.particle.io/v1/devices/"+deviceID+"/setStatus")!)
        request.HTTPMethod = "POST"
        let postString = "arg="+command+"&access_token="+accessToken
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
        }
        task.resume()
    }
    
    func particleVariableRead(variable: String, labelOutput: WKInterfaceLabel, deviceID: String, token: String){
        let scriptUrl = "https://api.particle.io/v1/devices/"+deviceID+"/"+variable
        let urlWithParams = scriptUrl + "?access_token=\(token)"
        let myUrl = NSURL(string: urlWithParams);
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            // Check for error
            if error != nil
            {
                labelOutput.setText("error")
                print("error=\(error)")
                return
            }
            _ = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            do {
                if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    
                    var resultValue = (convertedJsonIntoDict["result"] as! String)
                    if(resultValue.characters.count > 3){
                        resultValue = resultValue.substringToIndex(resultValue.startIndex.advancedBy(4))
                    }
                    labelOutput.setText(resultValue)
                    
                }
            } catch let error as NSError {
                labelOutput.setText("Error")
                print(error.localizedDescription)
                labelOutput.setText("Error")
            }
            
        }
        task.resume()
    }
}
