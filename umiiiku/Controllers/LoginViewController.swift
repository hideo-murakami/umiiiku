//
//  LoginViewController.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/07/19.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import UIKit
import Firebase
import PKHUD

class LoginViewController: UIViewController {
    
    var alertController: UIAlertController!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    @IBOutlet weak var loginBGimage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 8
        dontHaveAccountButton.addTarget(self, action: #selector(tappedDontHaveAccountButton), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(tappedLoginButton), for: .touchUpInside)
        
        if (UITraitCollection.current.userInterfaceStyle == .dark) {
            /* ダークモード時の処理 */
            loginBGimage.image = UIImage(named:"BG_dark")
        } else {
            /* ライトモード時の処理 */
            loginBGimage.image = UIImage(named:"BG_light")
        }
    }
    
    private func alert(title:String, message:String) {
        alertController = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK",
                                       style: .default,
                                       handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func tappedDontHaveAccountButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func tappedLoginButton() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        HUD.show(.progress)
        
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
        if let err = err {
            print("ログインに失敗しました。\(err)")
            HUD.hide()
            self.alert(
                title: "情報が正しくありません",
                message: "メールアドレス、パスワード（６文字以上）が正しくありません、再度正しい情報を入力してください"
            )
            return
        }
        print("ログインに成功しました")
            
            HUD.hide()
            
           self.dismiss(animated: true, completion: nil)
            
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
