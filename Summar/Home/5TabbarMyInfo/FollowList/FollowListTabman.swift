//
//  FollowListTabman.swift
//  Summar
//
//  Created by ukBook on 2023/02/06.
//

import Foundation
import Tabman
import Pageboy

class FollowListTabman: TabmanViewController, ViewAttributes {
    var userSeq: Int?
    let VC1 = FollowerListViewController()
    let VC2 = FollowingListViewController()
    
    lazy var viewControllers = [VC1, VC2]
    
    var followerList: SearchUserList? {
        didSet {
            smLog("\(followerList)")
            self.dataSource = self
        }
    }
    
    var followingList: SearchUserList? {
        didSet {
            smLog("\(followingList)")
            self.dataSource = self
        }
    }
    
    let bar: TMBar.ButtonBar = {
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .snap // Customize
        bar.indicator.tintColor = .black
        bar.indicator.overscrollBehavior = .compress
        bar.indicator.weight = .custom(value: 2)
        bar.layout.contentMode = .fit
        bar.backgroundView.style = .clear
        return bar
    }()
    let line : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.Gray02
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VC1.userSeq = userSeq
        VC2.userSeq = userSeq
        
        setUI()
        setAttributes()
        setTabManTitle()
    }
    
    func setUI() {
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = self.navigationItem.makeSFSymbolButton(self, action: #selector(topBtnAction(_:)), uiImage: UIImage(systemName: "arrow.backward")!, tintColor: .black)
        
        // Add to view
        addBar(bar, dataSource: self, at: .top)
        self.view.addSubview(line)
    }
    
    func setAttributes() {
        bar.buttons.customize {
            
            $0.tintColor = .black
            $0.selectedTintColor = .black
            $0.selectedFont = FontManager.getFont(Font.Bold.rawValue).mediumFont
            $0.font = FontManager.getFont(Font.Regular.rawValue).mediumFont
        }
        bar.snp.makeConstraints {
            
            $0.height.equalTo(44)
            $0.left.right.top.equalTo(self.view.safeAreaLayoutGuide)
        }
        line.snp.makeConstraints {
            
            $0.top.equalTo(bar.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(2)
        }
    }
    
    func setTabManTitle() {
        guard let userSeq = userSeq else {return}
        let viewModel = FollowListViewModel(0, 100000)
        
        //?????????
        viewModel.getFollowerList(userSeq)
        viewModel.didFinishFollowerListFetch = {
            self.followerList = viewModel.followerList
        }
        
        //?????????
        viewModel.getFollowingList(userSeq)
        viewModel.didFinishFollowingListFetch = {
            self.followingList = viewModel.followingList
        }
    }
    
    @objc func topBtnAction(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
    }
}

extension FollowListTabman: PageboyViewControllerDataSource, TMBarDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        guard let followerList = followerList?.totalRecordCount, let followingList = followingList?.totalRecordCount else {return TMBarItem(title: "")}
        
        if index == 0 {
            return TMBarItem(title: "\(followerList) ?????????")
        }else {
            return TMBarItem(title: "\(followingList) ?????????")
        }
    }
}
