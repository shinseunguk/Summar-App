//
//  BannerTableViewCell.swift
//  Summar
//
//  Created by mac on 2022/12/22.
//

import UIKit

final class BannerTableViewCell: UITableViewCell {
    
    private let cellReuseIdentifier = "collectionCell"
    
    let viewWidth : CGFloat = {
        let width = UIScreen.main.bounds.width
        return width - 20
    }()
    
    lazy var viewHeight : CGFloat = {
        return self.viewWidth / 3
    }()
    
    // 이미지 슬라이더
    let view1 = UIView()
    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
       
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isScrollEnabled = false
        cv.layer.cornerRadius = 7
        return cv
    }()
    
    lazy var pageControl: UIPageControl = {
        // Create a UIPageControl.
        let pageControl = UIPageControl()
        // Set the number of pages to page control.
//        pageControl.numberOfPages = self.arrProductPhotos.count
        
        // Set the current page.
        pageControl.currentPage = 0
        
        // 페이지 표시 색상을 밝은 회색 설정
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        // 현재 페이지 표시 색상을 검정색으로 설정
        pageControl.currentPageIndicatorTintColor = UIColor.white
        
        pageControl.isUserInteractionEnabled = false
        
        return pageControl
    }()
    
    var arrProductPhotos = [
        UIImage(named: "TitleBanner")
    ]
    var timer : Timer?
    var currentCelIndex = 0

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        contentView.addSubview(collectionView)
        selectionStyle = .none
        backgroundColor = .Gray01
        
        contentView.addSubview(view1)
//        view1.layer.borderWidth = 1
        view1.backgroundColor = .white
        view1.snp.makeConstraints{(make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        self.view1.addSubview(collectionView)
//        collectionView.layer.borderWidth = 1
//        collectionView.layer.borderColor = UIColor.red.cgColor
        collectionView.snp.makeConstraints{(make) in
            make.top.equalTo(6)
            make.bottom.equalTo(-6)
            make.width.equalTo(viewWidth)
            make.height.equalTo(188)
            make.centerX.equalToSuperview()
        }
        imgSlider()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .clear
//        contentView.layer.borderWidth = 3
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
    }

}

extension BannerTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - 이미지 슬라이더
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrProductPhotos.count
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! HomeCollectionViewCell
        cell.imgProudctPhoto.image = arrProductPhotos[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func imgSlider(){
        collectionView.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        startTimer()
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(moveToNextIndex), userInfo: nil, repeats: true)
    }
        
    @objc func moveToNextIndex(){
        if (currentCelIndex == arrProductPhotos.count - 1){
            currentCelIndex = 0
        }else {
            currentCelIndex += 1
        }
        pageControl.currentPage = currentCelIndex
        collectionView.scrollToItem(at: IndexPath(item: currentCelIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
}
