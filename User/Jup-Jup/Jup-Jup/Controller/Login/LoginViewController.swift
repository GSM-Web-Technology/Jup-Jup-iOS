//
//  LoginViewController.swift
//  Jup-Jup
//
//  Created by 조주혁 on 2021/01/11.
//

import UIKit
import Alamofire
import NVActivityIndicatorView

class LoginViewController: UIViewController {

    let indicator = NVActivityIndicatorView(frame: CGRect(x: 182, y: 423, width: 75, height: 75), type: .ballPulse, color: UIColor.init(named: "Primary Color"), padding: 0)
    
    @IBOutlet weak var logInEmail: UITextField! {
        didSet {
            logInEmail.delegate = self
            logInEmail.keyboardType = .emailAddress
        }
    }
    
    @IBOutlet weak var logInPassword: UITextField! {
        didSet {
            logInPassword.delegate = self
        }
    }
    
    @IBOutlet weak var logInBtn: UIButton! {
        didSet {
            logInBtn.layer.cornerRadius = 10
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicatorAutolayout()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.clipsToBounds = true
    }
    
    func indicatorAutolayout() {
        view.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
    }
    
    func goMainPage(){
        guard let goMain = self.storyboard?.instantiateViewController(identifier: "MainPage") else { return }
        goMain.modalPresentationStyle = .fullScreen
        self.present(goMain, animated: true)
    }
    
    func loginSucessAlert() {
        let alert = UIAlertController(title: "로그인 성공", message: "로그인 성공!!", preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "확인", style: UIAlertAction.Style.default) { (_) in
            self.goMainPage()
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func loginFailAlert(messages: String) {
        let alert = UIAlertController(title: "로그인 실패", message: messages, preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func checkTextField() -> Bool {
        if (logInEmail.text == "") || (logInPassword.text == "") {
            return false
        }
        return true
    }
    
    func signInApi(email: String,password: String) {
        let URL = "http://10.53.68.170:8081/v2/signin"
        let PARAM: Parameters = [
            "email": email,
            "password": password
        ]
        AF.request(URL, method: .post, parameters: PARAM, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let dic = value as? NSDictionary {
                    if let code = dic["code"] as? Int {
                        switch code {
                        case 0:
                            if let allToken = dic["data"] as? NSDictionary {
                                if let token = allToken["AccessToken"] as? String {
                                    print(token)
                                    KeychainManager.saveToken(token: token)
                                }
                            }
                            KeychainManager.saveEmail(email: self.logInEmail.text!)
                            KeychainManager.savePassword(password: self.logInPassword.text!)
                            self.indicator.stopAnimating()
                            self.loginSucessAlert()
                        case -1001:
                            self.indicator.stopAnimating()
                            self.loginFailAlert(messages: "계정이 존재하지 않거나 이메일 또는 비밀번호가 정확하지 않습니다.")
                        case -947:
                            self.indicator.stopAnimating()
                            self.loginFailAlert(messages: "이메일 인증을 해주세요!")
                        default:
                            return
                        }
                    }
                }
            case .failure(let e):
                self.indicator.stopAnimating()
                self.loginFailAlert(messages: "네트워크가 원활하지 않습니다.")
                print(e.localizedDescription)
            }
        }
    }
    
    @IBAction func logInButton(_ sender: UIButton) {
        if (checkTextField()) {
            indicator.startAnimating()
            signInApi(email: logInEmail.text!, password: logInPassword.text!)
        } else {
            loginFailAlert(messages: "빈칸을 모두 채워주세요.")
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        logInEmail.resignFirstResponder()
        logInPassword.resignFirstResponder()
        
        return true
    }
}
