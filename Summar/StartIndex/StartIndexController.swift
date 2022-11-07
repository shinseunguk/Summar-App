//
//  StartIndexController.swift
//  Summar
//
//  Created by mac on 2022/10/18.
//

import Foundation
import UIKit
import SnapKit

class StartIndexController : UIViewController {
    
    var indexArr = [String]()
    
    var tableV : UITableView = {
        var tableV = UITableView()
        tableV.translatesAutoresizingMaskIntoConstraints = false
        return tableV
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indexAdd()
    }
    
    func indexAdd(){
        indexArr.append("시작화면")
        indexArr.append("소셜로그인")
        indexArr.append("회원가입")
        
        
        tableInit()
    }
    
    func tableInit() {
        view.addSubview(tableV)
        tableV.delegate = self
        tableV.dataSource = self

        tableV.snp.makeConstraints{(make) in
            make.topMargin.equalTo(0)
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
            make.bottomMargin.equalTo(0)
        }
    }
}

extension StartIndexController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return indexArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = indexArr[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            moveScreen(StartController())
        case 1:
            moveScreen(SocialLoginController())
        case 2:
            moveScreen(SignUpController())
        default:
            print("default")
        }
    }
    
    func moveScreen(_ viewC: UIViewController) {
        self.navigationController?.pushViewController(viewC, animated: true)
    }
}
