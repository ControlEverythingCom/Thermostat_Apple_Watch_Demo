//
//  GlanceController.swift
//  watch tutorial WatchKit Extension
//
//  Created by Travis Elliott on 6/27/16.
//  Copyright © 2016 National Control Devices. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {
    let accessToken = "EnterAccessTokenHere"
    let devID = "EnterDeviceIDHere"

    @IBOutlet var label: WKInterfaceLabel!
    
    @IBOutlet var SetTempLabel: WKInterfaceLabel!
    @IBOutlet var SystemState: WKInterfaceLabel!
    override init(){
        
        print("init")
        super.init()
    }
    
    override func awakeWithContext(context: AnyObject?) {
        print("awakeWithContext")
        super.awakeWithContext(context)
    }

    override func willActivate() {
        
        
        super.willActivate()
        self.label.setText("Loading")
        self.SetTempLabel.setText("...")
        self.SystemState.setText("...")
        
        //Get current temperature
        particleVariableRead("data", labelOutput: self.label, deviceID: devID, token: accessToken)
        
        //Get Set temperature
        particleVariableRead("setTemp", labelOutput: self.SetTempLabel, deviceID: devID, token: accessToken)
        
        //Get current system status
        particleVariableRead("cStatus", labelOutput: self.SystemState, deviceID: devID, token: accessToken)

    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        print("didDeactivate")
        super.didDeactivate()
    }

    override func didAppear() {
        print("did appear")
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
