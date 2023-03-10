//
//  SignUpController.swift
//  Summar
//
//  Created by ukBook on 2022/10/23.
//

import Foundation
import UIKit
import SnapKit

final class SignUpController : UIViewController, SignUp1Delegate, SignUp2Delegate{
    func nextBtn(_ nickName: String) {
        print("nickName => \(nickName)")
        requestDic["userNickname"] = nickName
        print("\(#line) requestDic => ", requestDic)
        
        progressBarAnimate(0.6)
        animation(viewAnimation1: signUp1View, viewAnimation2: signUp2View)
    }
    
    func memberYN(_ TF: Bool, _ requestDic: Dictionary<String, Any>) {
        progressBarAnimate(1.0)
        animation(viewAnimation1: signUp2View, viewAnimation2: signUp3View)
        
        self.arrowBackWard.removeFromSuperview()
    }
    
    let helper : Helper = Helper()
    let request = ServerRequest.shared
    
    var requestDic: Dictionary<String, Any> = Dictionary<String, Any>()
    
    let progressBar : UIProgressView = {
        let progressBar = UIProgressView()
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.trackTintColor = .lightGray
        progressBar.progressTintColor = UIColor.summarColor2
        progressBar.progress = 0.3
        return progressBar
    }()
    
    let arrowBackWard : UIButton = {
        let arrowBackWard = UIButton()
        arrowBackWard.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        arrowBackWard.addTarget(self, action: #selector(forwardAction), for: .touchUpInside)
        return arrowBackWard
    }()
    
    
    let signUp1View = SignUp1View()
    let signUp2View = SignUp2View()
    let signUp3View = SignUp3View()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.addSubview(signUp1View)
//        view.addSubview(progressBar)
        self.view.backgroundColor = .white
        
        signUp1View.delegate = self
        signUp2View.delegate = self
//
//        layoutInit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(#file , #function)
        view.addSubview(signUp1View)
        view.addSubview(progressBar)
        view.addSubview(arrowBackWard)
        
        helper.showAlertAction(vc: self, title: "??????", message: "??????????????? ??????\n???????????? ???????????? ???????????????.")
        
        layoutInit()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print(#file , #function)
        self.signUp1View.removeFromSuperview()
        self.signUp2View.removeFromSuperview()
        self.signUp3View.removeFromSuperview()
        
        self.progressBar.progress = 0.3
    }
    
    // MARK: - ???????????? init
    func layoutInit() {
        progressBar.snp.makeConstraints{(make) in
            make.topMargin.equalTo(20)
            make.leftMargin.equalTo(10)
            make.rightMargin.equalTo(-10)
            make.height.equalTo(5)
        }
        
        arrowBackWard.snp.makeConstraints{(make) in
            make.topMargin.equalTo(progressBar.snp.bottom).offset(30)
            make.leftMargin.equalTo(10)
//            make.rightMargin.equalTo(-10)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
        
        // layout
        signUp1View.snp.makeConstraints{(make) in
            make.top.equalTo(arrowBackWard.snp.bottom).offset(10)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        }
    }
    
    // MARK: - ?????? ????????????
    func majorInput(major1: String, major2: String) {
        requestDic["major1"] = major1
        requestDic["major2"] = major2
        
        print("\(#line) requestDic => ", requestDic)
        
        //????????????
        self.request.login("/user/login", self.requestDic, completion: { (login, param) in
            guard let login = login else {return}
            self.memberYN(login, param)
        })
        // ???????????? ??????
    }
    
    private func animation(viewAnimation1: UIView, viewAnimation2: UIView) {
        UIView.animate(withDuration: 0.5, animations: {
            viewAnimation1.frame.origin.x = -viewAnimation1.frame.width
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewAnimation1.removeFromSuperview()
//            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.anima(viewAnimation2)
            }
            
        })
    }
    
    func anima(_ view: UIView){
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.view.addSubview(view)
         
            
            // arrowBackWard Remove??? ?????? ????????????
            if view == self.signUp3View {
                view.snp.makeConstraints{(make) in
                    make.top.equalTo(30)
                    make.left.equalTo(0)
                    make.right.equalTo(0)
                    make.bottom.equalTo(0)
                }
            }else {
                // layout
                view.snp.makeConstraints{(make) in
                    make.top.equalTo(self.arrowBackWard.snp.bottom).offset(10)
                    make.left.equalTo(0)
                    make.right.equalTo(0)
                    make.bottom.equalTo(0)
                }
            }
            
        }, completion: nil)
    }
    
    func progressBarAnimate(_ f: Float){
        UIView.animate(withDuration: 1) {
            self.progressBar.setProgress(f, animated: true)
        }
    }
    
    // MARK : - arrowBackWard Action progressBar.progress??? ???????????? view??? ????????????
    @objc func forwardAction() {
        print("progressBar.progress => ", progressBar.progress)
        
        if progressBar.progress == 0.3{
            self.navigationController?.popViewController(animated: true)
        } else if progressBar.progress == 0.6{
            progressBarAnimate(0.3)
            animation(viewAnimation1: signUp2View, viewAnimation2: signUp1View)
        }
    }
 }
