//
//  MyPageViewController.swift
//  Jup-Jup
//
//  Created by 조주혁 on 2021/01/07.
//

import UIKit
import Alamofire

class MyPageViewController: UIViewController {
    
    var model: LogOutModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.shadowImage = UIImage()
        self.tabBarController?.tabBar.backgroundImage = UIImage()
        self.tabBarController?.tabBar.clipsToBounds = true
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.clipsToBounds = true
        
    }
    
    func apiCall() {
        let URL = "http://10.53.68.170:8081/v2/logout"
        let token = KeychainManager.getToken()
        AF.request(URL, method: .post, headers: ["Authorization": token]).responseData(completionHandler: { data in
            guard let data = data.data else { return }
            self.model = try? JSONDecoder().decode(LogOutModel.self, from: data)
            if (self.model?.success)! == true {
                KeychainManager.removeToken()
                KeychainManager.removeEmail()
                KeychainManager.removePassword()
                self.goLoginPage()
            } else {
                self.logOutFailAlert()
            }
        })
    }
    
    func logOutAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let ok = UIAlertAction(title: "로그아웃", style: .destructive) { (_) in
            self.apiCall()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
    }
    
    func logOutFailAlert() {
        let alert = UIAlertController(title: "로그아웃 실패!", message: "네트워크가 원활하지 않습니다.", preferredStyle: UIAlertController.Style.alert)
        let ok = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func goLoginPage(){
        guard let goMain = self.storyboard?.instantiateViewController(identifier: "LoginViewController") else { return }
        goMain.modalPresentationStyle = .fullScreen
        self.present(goMain, animated: true)
    }
    
    @IBAction func signOutButton(_ sender: Any) {
        logOutAlert()
    }
}

