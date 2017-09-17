//
//  ViewController.swift
//  Donate
//
//  Created by Ziad on 8/7/17.
//  Copyright © 2017 IntensifyStudio. All rights reserved.
//

import UIKit
import BraintreeDropIn
import Braintree

class ViewController: UIViewController {

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var donateButton: UIButton! {
        didSet {
            donateButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -42, bottom: 0, right: 0)
            donateButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
            donateButton.layer.cornerRadius = donateButton.bounds.midY
            donateButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var currencyLabel: UILabel! {
        didSet {
            currencyLabel.layer.cornerRadius = currencyLabel.bounds.midY
            currencyLabel.layer.masksToBounds = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        amountTextField.becomeFirstResponder()
    }
    
    let toKinizationKey = "sandbox_tgg4p67v_6vxjwdzh2zj4q267"

    @IBAction func pay(_ sender: Any) {
        // Test Values
        // Card Number: 4111111111111111
        // Expiration: 08/2018
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: toKinizationKey, request: request)
        { [unowned self] (controller, result, error) in
            
            if let error = error {
                self.show(message: error.localizedDescription)
                
            } else if (result?.isCancelled == true) {
                self.show(message: "Transaction Cancelled")
                
            } else if let nonce = result?.paymentMethod?.nonce, let amount = self.amountTextField.text {
                self.sendRequestPaymentToServer(nonce: nonce, amount: amount)
            }
            controller.dismiss(animated: true, completion: nil)
        }
        
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    func sendRequestPaymentToServer(nonce: String, amount: String) {
        activityIndicator.startAnimating()
        
        let paymentURL = URL(string: "http://localhost/donate/pay.php")!
        var request = URLRequest(url: paymentURL)
        request.httpBody = "payment_method_nonce=\(nonce)&amount=\(amount)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let data = data else {
                self?.show(message: error!.localizedDescription)
                return
            }
            	
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let success = result?["success"] as? Bool, success == true else {
                self?.show(message: "Transaction failed. Please try again.")
                return
            }
            
            self?.show(message: "Successfully charged. Thanks So Much :)")
            }.resume()
    }

    func show(message: String) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            
            let alertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

