//
//  WriteFeed.swift
//  Summar
//
//  Created by mac on 2022/12/22.
//

import Foundation
import UIKit
import BSImagePicker
import Photos
import YPImagePicker

class WriteFeedController : UIViewController, ImagePickerDelegate{
    static let shared = WriteFeedController()
    
    let wfView = WriteFeedView.shared
    
    var imageArr = [UIImage]()
    
    let titleLabel : UILabel = {
        let title = UILabel()
        title.text = "피드 작성"
        title.font = .boldSystemFont(ofSize: 20)
        title.textColor = UIColor.summarColor1
        title.sizeToFit()
        return title
    }()
    
    override func viewDidLoad() {
        wfView.delegate = self
        self.view.addSubview(wfView)
        
        self.navigationItem.titleView = titleLabel
        self.navigationItem.rightBarButtonItem = self.navigationItem.makeSFSymbolButton(self, action: #selector(closeAction), uiImage: UIImage(systemName: "xmark")!, tintColor: .black)
        
        // MARK: - Feed Body
        wfView.snp.makeConstraints{(make) in

            make.top.equalTo(0)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
    
    @objc func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showImageFullScreen(_ imageArr: [UIImage]) {
        print("self.navigationController \(self.navigationController)")
        print("imageArr => \(imageArr)")
        let VC = FullScreenImageController.shared
        VC.imageArr = imageArr
        self.navigationController?.pushViewController(FullScreenImageController.shared, animated: true)
    }
    
    // MARK: - ImagePicker func
    func openPhoto(completion: @escaping([UIImage]?) -> ()) {
        var config = YPImagePickerConfiguration()
        config.library.maxNumberOfItems = 10 // 최대 선택 가능한 사진 개수 제한
        config.library.minNumberOfItems = 1
        config.library.mediaType = .photo // 미디어타입(사진, 사진/동영상, 동영상)
        config.usesFrontCamera = false
        config.showsPhotoFilters = false
        config.showsVideoTrimmer = false
        config.screens = [.library]
        config.library.onlySquare = false
//        config.library.skipSelectionsGallery = false
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            if cancelled {
                picker.dismiss(animated: true, completion: nil)
                return
            }
            
            for item in items {
                switch item {
                case .photo(let photo):
                    print("photo \(photo.image)")
                    print("photo \(photo.originalImage)")
                    print("photo \(photo.modifiedImage)")
                    
                    print(type(of: photo.image))
                    print(type(of: self.imageArr))
                    self.imageArr.append(photo.image)
                case .video(let video): // Disable
                    print(video)
                }
            }
                print("imageArr => \(self.imageArr)")
                completion(self.imageArr)
                self.imageArr.removeAll()
                    
                picker.dismiss(animated: true, completion: nil)
         }
          present(picker, animated: true, completion: nil)
    }
    
    func authorization(){
        DispatchQueue.main.async {
            
            // [앨범의 사진에 대한 접근 권한 확인 실시]
            PHPhotoLibrary.requestAuthorization( { status in
                switch status{
                case .authorized:
                    print("")
                    print("====================================")
                    //                print("[\(self.ACTIVITY_NAME) >> testMain() :: 앨범의 사진에 대한 접근 권한 확인 실시]")
                    print("상태 :: 앨범 권한 허용")
                    print("====================================")
                    print("")
                    
                    // [앨범 열기 수행 실시]
//                    self.openPhoto()
                    break
                    
                case .denied:
                    print("")
                    print("====================================")
                    //                print("[\(self.ACTIVITY_NAME) >> testMain() :: 앨범의 사진에 대한 접근 권한 확인 실시]")
                    print("상태 :: 앨범 권한 거부")
                    print("====================================")
                    print("")
                    break
                    
                case .notDetermined:
                    print("")
                    print("====================================")
                    //                print("[\(self.ACTIVITY_NAME) >> testMain() :: 앨범의 사진에 대한 접근 권한 확인 실시]")
                    print("상태 :: 앨범 권한 선택하지 않음")
                    print("====================================")
                    print("")
                    break
                    
                case .restricted:
                    print("")
                    print("====================================")
                    //                print("[\(self.ACTIVITY_NAME) >> testMain() :: 앨범의 사진에 대한 접근 권한 확인 실시]")
                    print("상태 :: 앨범 접근 불가능, 권한 변경이 불가능")
                    print("====================================")
                    print("")
                    break
                    
                default:
                    print("")
                    print("====================================")
                    //                print("[\(self.ACTIVITY_NAME) >> testMain() :: 앨범의 사진에 대한 접근 권한 확인 실시]")
                    print("상태 :: default")
                    print("====================================")
                    print("")
                    break
                }
            })
            
            
        }
    }
}
