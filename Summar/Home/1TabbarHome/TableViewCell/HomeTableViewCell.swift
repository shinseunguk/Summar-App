//
//  HomeTableViewCell.swift
//  Summar
//
//  Created by mac on 2022/12/21.
//

import UIKit
//import Toast_Swift makeToast("asd", duration: 2.0, position: .center)

final class HomeTableViewCell: UITableViewCell, UIScrollViewDelegate, ViewAttributes {
    weak var delegate : HomeViewDelegate?
    let viewModel = HomeViewModel(nil, nil)
    let helper = Helper()
    let fontManger = FontManager()
    
    var feedInfo: FeedInfo?
    var userSeq: Int?
    var feedSeq: Int?
    var likeCountInt: Int = 0
    var imageArr = [String]()
    var feedImages : [FeedImages]? {
        didSet {
            guard let image = feedImages else {return}
            
            for i in 0 ..< image.count {
                imageArr.append(image[i].imageUrl!)
            }
            
            initImageArr(imageArr) { finish in
                if finish {
                    self.imageArr = []
                }
            }
        }
    }
    
    let imageViewWidth : CGFloat = {
        let width = UIScreen.main.bounds.width
        return width - 40
    }()
    
    lazy var profileImg : UIImageView = {
        let view = UIImageView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.followShadowColor.cgColor
        view.layer.cornerRadius = 20
        view.image = UIImage(named: "NonProfile")
        view.tintColor = UIColor.grayColor205
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.tag = 1

        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(didSelect(_:))
        )
        view.addGestureRecognizer(recognizer)
        
        return view
    }()
    lazy var nickName : UILabel = {
        let label = UILabel()
        label.font = FontManager.getFont(Font.Bold.rawValue).medium15Font
        label.textColor = .black
        label.sizeToFit()
        label.isUserInteractionEnabled = true
        label.tag = 1
        
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(didSelect(_:))
        )
        label.addGestureRecognizer(recognizer)
        return label
    }()
    lazy var major : UILabel = {
        let label = UILabel()
        label.font = FontManager.getFont(Font.Regular.rawValue).smallFont
        label.textColor = UIColor.init(r: 115, g: 120, b: 127)
        label.sizeToFit()
        label.isUserInteractionEnabled = true
        label.tag = 1
        
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(didSelect(_:))
        )
        label.addGestureRecognizer(recognizer)
        return label
    }()
    lazy var pageControl: UIPageControl = {
        // Create a UIPageControl.
        let pageControl = UIPageControl()
        // Set the number of pages to page control.
//        pageControl.numberOfPages = self.arrProductPhotos.count
        
        // Set the current page.
        pageControl.currentPage = 0
        
        // ????????? ?????? ????????? ?????? ?????? ??????
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        // ?????? ????????? ?????? ????????? ??????????????? ??????
        pageControl.currentPageIndicatorTintColor = UIColor.white
        
        pageControl.isUserInteractionEnabled = false
        
        return pageControl
    }()
    
    lazy var scrollView: UIScrollView = {
        // Create a UIScrollView.
        let scrollView = UIScrollView()
        // Hide the vertical and horizontal indicators.
        
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.showsVerticalScrollIndicator = false
        
        // Allow paging.
        scrollView.isPagingEnabled = true
        
        // Set delegate of ScrollView.
        scrollView.delegate = self
        
        scrollView.isScrollEnabled = true
        
        scrollView.layer.cornerRadius = 6
        scrollView.isUserInteractionEnabled = true

        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(didSelectImg(_:))
        )
        scrollView.addGestureRecognizer(recognizer)
        
        // Specify the screen size of the scroll.
//        scrollView.contentSize = CGSize(width: CGFloat(pageSize) * self.view.frame.maxX, height: 0)
        
        return scrollView
    }()
    lazy var heartImage : UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "heart") // ?????? ?????? heart.fill
        view.tintColor = .black
        view.isUserInteractionEnabled = true
        view.tag = 2
        
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(didSelect(_:))
        )
        view.addGestureRecognizer(recognizer)
        
        return view
    }()
    lazy var likeCount : UILabel = {
        let label = UILabel()
        label.font = FontManager.getFont(Font.Regular.rawValue).smallFont
        label.sizeToFit()
        label.isUserInteractionEnabled = true
        label.tag = 2
        
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(didSelect(_:))
        )
        label.addGestureRecognizer(recognizer)
        
        return label
    }()
    lazy var bubbleImage : UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "bubble.left")
        view.tintColor = .black
        return view
    }()
    lazy var commentCount : UILabel = {
        let label = UILabel()
        label.font = FontManager.getFont(Font.Regular.rawValue).smallFont
        label.sizeToFit()
        label.isUserInteractionEnabled = true
        return label
    }()
    lazy var bookmark : UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "bookmark") // ?????? ????????? heart.fill
        view.tintColor = .black
        view.isUserInteractionEnabled = true
        view.tag = 3
        
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(didSelect(_:))
        )
        view.addGestureRecognizer(recognizer)
        return view
    }()
    let contentsLabel : UILabel = {
        let UILabel = UILabel()
        UILabel.font = FontManager.getFont(Font.Regular.rawValue).medium15Font
        UILabel.textColor = UIColor.homeContentsColor
        UILabel.textAlignment = .left
        UILabel.numberOfLines = 3
        UILabel.lineBreakMode = .byTruncatingTail
        UILabel.sizeToFit()
        return UILabel
    }()
    
    let line: UIView = {
        let view = UIView()
        view.backgroundColor = .Gray01
        return view
    }()
    
    @objc func didSelect(_ sender: UITapGestureRecognizer) {
        guard let feedSeq = feedInfo?.feedSeq else {return}
        let tag = sender.view?.tag as? Int
        let param : Dictionary<String, Int> = ["feedSeq": feedSeq, "userSeq": getMyUserSeq()]
        
        switch tag {
        case 1: // ????????? ??????
            guard let userSeq = userSeq else {return}
            self.delegate?.pushScreen(ProfileViewController(), userSeq)
            
        case 2: // ????????? ??????
            viewModel.feedLikeScarp("like", feedSeq, param)
            viewModel.didFinishLikeScrapFetch = {
                UIDevice.vibrate()
                let img = self.heartImage.image
                
                if img!.isEqual(UIImage(systemName: "heart")) {
                    smLog("1")
                    self.heartImage.image = UIImage(systemName: "heart.fill")
                    self.likeCountInt += 1
                    self.likeCount.text = String(self.likeCountInt.commaRepresentation)
                }else {
                    smLog("2")
                    self.heartImage.image = UIImage(systemName: "heart")
                    self.likeCountInt -= 1
                    self.likeCount.text = String(self.likeCountInt.commaRepresentation)
                }
            }
            
        case 3: // ????????? ??????
            viewModel.feedLikeScarp("scrap", feedSeq, param)
            viewModel.didFinishLikeScrapFetch = {
                UIDevice.vibrate()
                let img = self.bookmark.image
                
                if img!.isEqual(UIImage(systemName: "bookmark")) {
                    smLog("1")
                    self.bookmark.image = UIImage(systemName: "bookmark.fill")
                    self.bookmark.tintColor = UIColor.magnifyingGlassColor
                }else {
                    smLog("2")
                    self.bookmark.image = UIImage(systemName: "bookmark")
                    self.bookmark.tintColor = UIColor.black
                }
            }
            
        default:
            print("default")
        }
    }
    
    @objc func didSelectImg(_ sender: UITapGestureRecognizer) {
        guard let feedInfo = feedInfo else {return}
        self.delegate?.pushScreen(FeedDetailViewController(), feedInfo)
    }
    
    func setUpCell(_ feedInfo: FeedInfo){
        print("setUpCell \(feedInfo)")
        guard let user = feedInfo.user, let major2 = user.major2, let likeYn = feedInfo.likeYn, let commentYn = feedInfo.commentYn, let totalLikeCount = feedInfo.totalLikeCount, let totalCommentCount = feedInfo.totalCommentCount, let scrapYn = feedInfo.scrapYn else { return }
        self.feedInfo = feedInfo
        userSeq = user.userSeq
        
        // ?????????
        setProfileImage(profileImg, user.profileImageUrl)
        nickName.text = user.userNickname
        major.text = "\(major2) / \(compareDate(feedInfo.createdDate))"
        
        // ?????? ?????????
        feedImages = feedInfo.feedImages
        
        // ?????????
        guard let image = likeYn ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart") else {return}
        heartImage.image = image
        
        // ????????? ?????????
        likeCountInt = totalLikeCount
        likeCount.text = String(likeCountInt.commaRepresentation)
        
        if commentYn {
            // ?????? ?????????
            commentCount.text = String(totalCommentCount.commaRepresentation)
            bubbleImage.alpha = 1.0
            commentCount.alpha = 1.0
        }else {
            bubbleImage.alpha = 0.0
            commentCount.alpha = 0.0
        }
        
        
        // ?????????
        guard let image = scrapYn ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark") else {return}
        
        bookmark.image = image
        if scrapYn {
            bookmark.tintColor = UIColor.magnifyingGlassColor
        }else {
            bookmark.tintColor = .black
        }
        
        
        
        // ?????? ??????
        contentsLabel.text = feedInfo.contents
        
        
        
        helper.lineSpacing(contentsLabel, 5)
    }
    
    func setProfileImage(_ imageView: UIImageView,_ urlString: String?) {
        guard let urlString = urlString else {
            imageView.image = UIImage(named: "NonProfile")
            return
        }
        let url = URL(string: urlString)
        //DispatchQueue??? ?????? ?????? -> ???????????? ??? ?????? ???????????? ???????????? ?????? ?????? ????????? ????????? ????????? ??????. (?????? : ?????? ???????????? ?????????????????????)
        //DispatchQueue??? ?????? ?????? ???????????? ???????????? ??????????????? ????????? ????????? ?????????.
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                imageView.kf.indicatorType = .activity
                imageView.kf.setImage(
                  with: url,
                  placeholder: nil,
                  options: [.transition(.fade(1.2))],
                  completionHandler: nil
                )
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .Gray01
        
        setUI()
        setAttributes()
    }
    
    func setUI() {
        contentView.addSubview(profileImg)
        contentView.addSubview(nickName)
        contentView.addSubview(major)
        
        contentView.addSubview(scrollView)
        contentView.addSubview(pageControl)
        
        contentView.addSubview(heartImage)
        contentView.addSubview(likeCount)
        
        contentView.addSubview(bubbleImage)
        contentView.addSubview(commentCount)
        contentView.addSubview(bookmark)
        
        contentView.addSubview(contentsLabel)
        
        contentView.addSubview(line)
    }
    
    func setAttributes() {
        profileImg.snp.makeConstraints { (make) in
            
            make.top.equalTo(20)
            make.left.equalTo(20)
            make.width.height.equalTo(40)
        }
        nickName.snp.makeConstraints { (make) in
            
            make.bottom.equalTo(profileImg.snp.centerY).offset(-1)
            make.left.equalTo(profileImg.snp.right).offset(12)
        }
        major.snp.makeConstraints { (make) in
            
            make.top.equalTo(profileImg.snp.centerY).offset(2)
            make.left.equalTo(profileImg.snp.right).offset(12)
        }
        
        scrollView.snp.makeConstraints { (make) in
            
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImg.snp.bottom).offset(20)
            make.width.equalTo(imageViewWidth)
            make.height.equalTo(imageViewWidth)
        }
        pageControl.snp.makeConstraints { (make) in
            
            make.top.equalTo(scrollView.snp.bottom).offset(-36)
            make.left.right.equalToSuperview()
        }
        heartImage.snp.makeConstraints {
            
            $0.top.equalTo(scrollView.snp.bottom).offset(13)
            $0.left.equalTo(20)
            $0.width.height.equalTo(20)
        }
        likeCount.snp.makeConstraints {
            
            $0.centerY.equalTo(heartImage.snp.centerY)
            $0.left.equalTo(heartImage.snp.right).offset(5)
        }
        bubbleImage.snp.makeConstraints {
            
            $0.centerY.equalTo(heartImage.snp.centerY)
            $0.left.equalTo(likeCount.snp.right).offset(20)
            $0.width.height.equalTo(20)
        }
        commentCount.snp.makeConstraints {
            
            $0.centerY.equalTo(bubbleImage.snp.centerY)
            $0.left.equalTo(bubbleImage.snp.right).offset(5)
        }
        bookmark.snp.makeConstraints {
            
            $0.centerY.equalTo(heartImage.snp.centerY)
            $0.right.equalTo(-20)
            $0.width.equalTo(20)
            $0.height.equalTo(20)
        }
        contentsLabel.snp.makeConstraints { (make) in
            
            make.top.equalTo(heartImage.snp.bottom).offset(15)
            make.left.equalTo(20)
            make.width.equalTo(imageViewWidth)
        }
        
        line.snp.makeConstraints { (make) in
            make.top.equalTo(contentsLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(16)
            make.bottom.equalTo(0)
        }
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 4
        label.lineBreakMode = .byCharWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        print(label.frame.height)
        contentsLabel.snp.updateConstraints {
            $0.height.equalTo(label.frame.height)
        }
        return label.frame.height
    }

    
    func initImageArr(_ imageArr : [String], completion : @escaping(Bool) -> ()){
            pageControl.numberOfPages = imageArr.count
            
            for i in 0..<imageArr.count{
                let url = URL(string: imageArr[i])
                //DispatchQueue??? ?????? ?????? -> ???????????? ??? ?????? ???????????? ???????????? ?????? ?????? ????????? ????????? ????????? ??????. (?????? : ?????? ???????????? ?????????????????????)
                //DispatchQueue??? ?????? ?????? ???????????? ???????????? ??????????????? ????????? ????????? ?????????.
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        let imageview = UIImageView()
                        imageview.contentMode = .scaleAspectFit
                        imageview.backgroundColor = .white
                        imageview.clipsToBounds = true
                        
                        imageview.kf.indicatorType = .activity
                        imageview.kf.setImage(
                            with: url,
                            placeholder: nil,
                            options: [.transition(.fade(1.2))],
                            completionHandler: nil
                        )
                        
                        let xPosition = self.imageViewWidth * CGFloat(i)
                        
                        imageview.frame = CGRect(x: xPosition, y: 0, width: self.imageViewWidth, height: self.imageViewWidth)
                        self.scrollView.contentSize.width = self.imageViewWidth * CGFloat(1+i)
                        
                        self.scrollView.addSubview(imageview)
                    }
                }
            }
            completion(true)
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let currentPage = round(scrollView.contentOffset.x / imageViewWidth)
            pageControl.currentPage = Int(CGFloat(currentPage))
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            contentView.backgroundColor = .white
            // table view margin
//              contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
        }

    }
