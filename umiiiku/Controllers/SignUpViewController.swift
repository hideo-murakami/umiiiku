//
//  SignUpViewController.swift
//  umiiiku
//
//  Created by 村上英夫 on 2020/07/12.
//  Copyright © 2020 村上英夫. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import PKHUD

class SignUpViewController: UIViewController {
    
    var alertController: UIAlertController!
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    @IBOutlet weak var signUpBGimage: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupViews() {
        
    profileImageButton.layer.cornerRadius = 85
    profileImageButton.layer.borderWidth = 1
    profileImageButton.layer.borderColor = UIColor.rgb(red: 60, green: 60, blue: 60).cgColor
    
    registerButton.layer.cornerRadius = 12
    
    profileImageButton.addTarget(self, action: #selector(tappedProfileImageButton), for: .touchUpInside)
    registerButton.addTarget(self, action: #selector(tappedRegisterButton), for: .touchUpInside)
    alreadyHaveAccountButton.addTarget(self, action: #selector(tappedAlreadyHaveAccountButton), for: .touchUpInside)
    
    emailTextField.delegate = self
    passwordTextField.delegate = self
    usernameTextField.delegate = self
    
    registerButton.isEnabled = false
    registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        
    if (UITraitCollection.current.userInterfaceStyle == .dark) {
        /* ダークモード時の処理 */
        signUpBGimage.image = UIImage(named:"BG_dark")
    } else {
        /* ライトモード時の処理 */
        signUpBGimage.image = UIImage(named:"BG_light")
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
        
    @objc private func tappedAlreadyHaveAccountButton(){
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(identifier: "LoginViewController")
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @objc private func tappedProfileImageButton(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true,
                     completion:nil)
    }
    
    @objc private func tappedRegisterButton(){
        
        let image = profileImageButton.imageView?.image ?? UIImage(named: "profile_default_image")
        guard let uploadImage = image?.jpegData(compressionQuality: 0.3) else { return }
        
        HUD.show(.progress)
        
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        
        storageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Firestoregaeへの情報の保存に失敗しました。\(err)")
                HUD.hide()
                return
            }
            
            print("Firestoregaeへの情報の保存に成功しました。")
            storageRef.downloadURL { (url, err) in
                if let err = err {
                    print("Firestoreからのダウンロードに失敗しました。\(err)")
                    HUD.hide()
                    return
                }
                guard let urlString = url?.absoluteString else { return }
                self.createUserToFirebase(profileImageUrl: urlString)
            }
        }
    }
    
    private func createUserToFirebase(profileImageUrl: String){
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("Auth情報の保存に失敗しました。\(err)")
                HUD.hide()
                self.alert(
                    title: "情報が正しくありません",
                    message: "既に登録されているメースアドレスまたは、メールアドレス、パスワード（６文字以上）が正しくありません、再度正しい情報を入力してください"
                )
                return
            }
            print("認証情報の保存に成功しました。")
            
            guard let uid = res?.user.uid else { return }
            guard let username = self.usernameTextField.text else { return }
            let docData = [
                "email": email,
                "username": username,
                "createAt": Timestamp(),
                "profileImageUrl":profileImageUrl
                ] as [String : Any]
            
            Firestore.firestore().collection("users").document(uid).setData(docData) {
                (err) in
                if let err = err {
                    print("データベースの情報の保存に失敗しました。\(err)")
                    HUD.hide()
                    return
                }
                
                print("データベースへの情報の保存が成功しました")
                HUD.hide()
                self.dismiss(animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        let usernameIsEmpty = usernameTextField.text?.isEmpty ?? false
        let profileImageIsEmpty = profileImageButton.imageView?.image
        if !emailIsEmpty && !passwordIsEmpty && !usernameIsEmpty && (profileImageIsEmpty != nil) {
            registerButton.isEnabled = true
            registerButton.backgroundColor = .rgb(red: 0, green: 185, blue: 227)
        } else {
            registerButton.isEnabled = false
            registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        }
    }

}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
    }
        profileImageButton.setTitle("", for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment = .fill
        profileImageButton.clipsToBounds = true
        
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        let usernameIsEmpty = usernameTextField.text?.isEmpty ?? false
        let profileImageIsEmpty = profileImageButton.imageView?.image
        if !emailIsEmpty && !passwordIsEmpty && !usernameIsEmpty && (profileImageIsEmpty != nil) {
            registerButton.isEnabled = true
            registerButton.backgroundColor = .rgb(red: 0, green: 185, blue: 227)
        } else {
            registerButton.isEnabled = false
            registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        }
        
       dismiss(animated: true, completion: nil)
        
    }
    
}
