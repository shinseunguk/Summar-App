//
//  ServerRequest.swift
//  Summar
//
//  Created by mac on 2022/11/01.
//

import Foundation
import Alamofire


// MARK: - Summar 서버 URL
struct Server {
    static var url: String {
        let url = Bundle.main.url(forResource: "Network", withExtension: "plist")
        let dictionary = NSDictionary(contentsOf: url!)
        let LocalURL = dictionary!["ReleaseURL"] as? String
        
        return LocalURL!
    }
}

class ServerRequest: NSObject {
    static let shared = ServerRequest()
    
    var param : Dictionary<String, Any> = Dictionary<String, Any>()
    var requestParam : Dictionary<String, String> = Dictionary<String, String>()
    
    func requestGet(_ url: String) {
        let url = "http://13.209.114.45:8080/api/v1\(url)"
        AF.request(url,
                   method: .post,
                   parameters: nil,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/json", "Accept":"application/json"])
        .validate(statusCode: 200..<300)
        .responseJSON { (json) in
            //여기서 가져온 데이터를 자유롭게 활용하세요.
            print(json)
        }
    }
    
    func nicknameCheck(requestUrl : String!, completion: @escaping (Bool?, Error?) -> ()) {
        let url = Server.url + requestUrl
        AF.request(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "",
                   method: .get,
                   parameters: nil,
                   encoding: JSONEncoding.default,
                   headers: ["Content-Type":"application/json", "Accept":"application/json"])
        .validate(statusCode: 200..<300)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                print("nicknameCheck return value \(value)")
                guard let result = response.data else {return}
                                
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(NicknameCheck.self, from: response.data!)
                    completion(json.result?.result, nil)
                    
                } catch {
                    print("error! \(error)")
                    completion(nil, error)
                }
                
            case .failure(let error):
                print("🚫 Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
        }
    }
    
    // MARK: - 로그인, 회원가입 func => 서버의 loginStatus 값으로 회원인지, 회원이 아닌지 확인후 화면 이동
    func login(_ url: String,_ requestDic: Dictionary<String, Any>, completion : @escaping(Bool? ,Dictionary<String, Any>) -> ()) {
        let url = Server.url + url
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        // POST 로 보낼 정보
        var params = requestDic
        params["deviceToken"] = UserDefaults.standard.string(forKey: "deviceToken")
        
        print("/login params => \(params)")
        
        // httpBody 에 parameters 추가
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("http Body Error")
        }
        
        AF.request(request)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
            switch response.result {
            case .success(let value):
                print(value)
                
                var json = value as! Dictionary<String, Any>
                
//                print(json["accessToken"])
                print(json["loginStatus"])
//                print(json["refreshToken"])
                json["userEmail"] = params["userEmail"]
                json["socialType"] = params["socialType"]
                
                params["loginStatus"] = json["loginStatus"]
                
                let loginStatus = json["loginStatus"] as! String
                
                
                if loginStatus == "로그인"{
                    //UserDefault에 회원정보 저장
                    print(#line ,type(of: params["userEmail"]))
                    
                    UserDefaults.standard.set(json, forKey: "UserInfo")
                    UserDefaults.standard.set(json["accessToken"], forKey: "accessToken")
                    UserDefaults.standard.set(json["refreshToken"], forKey: "refreshToken")
                    
                    
                    completion(true, params)
                } else if loginStatus == "회원가입"{
                    completion(false, params)
                } else if loginStatus == "회원가입완료"{
                    print(#line ,type(of: params["userEmail"]))
                    
                    params["follower"] = 0
                    params["following"] = 0
                    
                    UserDefaults.standard.set(params, forKey: "UserInfo")
                    UserDefaults.standard.set(json["accessToken"], forKey: "accessToken")
                    UserDefaults.standard.set(json["refreshToken"], forKey: "refreshToken")
                    
                    completion(true, params)
                }
                
            case .failure(let error):
                print("🚫 Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
            }
        }
    }
    
    // MARK: - 마이 써머리 https://github.com/arifinfrds/iOS-MVVM-Alamofire
    func requestMyInfo(_ url: String, completion: @escaping (UserInfo?, Error?, Int?) -> ()) {
        let url = Server.url + url
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            print("url => \(url)")
            print(token)
            AF.request(url,
                       method: .get,
                       parameters: nil,
                       encoding: URLEncoding.default,
                       headers: ["Content-Type":"application/json", "Accept":"application/json",
                                 "Authorization":"Bearer \(token)"])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    guard let result = response.data else {return}
                                    
                    do {
                        let decoder = JSONDecoder()
                        let json = try decoder.decode(UserInfo.self, from: response.data!)
                        
                        completion(json, nil, nil)
                        
                    } catch {
                        print("error! \(error)")
                        completion(nil, error, nil)
                    }
                case .failure(let error):
                    print("🚫 @@Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                    
                    var statusCode = response.response?.statusCode
                    completion(nil, error, statusCode)
                }
            }
        }
    }
    
    // MARK: - UITabBar 닉네임 검색
    func searchNickname(_ url: String, completion: @escaping (SearchUserList?, Error?, Int?) -> ()) {
        let url = Server.url + url
        if let token = UserDefaults.standard.string(forKey: "accessToken") {
            print("url => \(url)")
            print(token)
            AF.request(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "",
                       method: .get,
                       parameters: nil,
                       encoding: URLEncoding.default,
                       headers: ["Content-Type":"application/json; charset=utf-8", "Accept":"application/json",
                                 "Authorization":"Bearer \(token)"])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    guard let result = response.data else {return}
                    
                    print("value => \(value)")
                                    
                    do {
                        let decoder = JSONDecoder()
                        let json = try decoder.decode(SearchUserList.self, from: response.data!)

                        completion(json, nil, nil)

                    } catch {
                        print("error! \(error)")
                        completion(nil, error, nil)
                    }
                case .failure(let error):
                    print("🚫 @@Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                    
                    var statusCode = response.response?.statusCode
                    completion(nil, error, statusCode)
                }
            }
        }
    }
    
    // MARK: - AccessToken 재발급
    func requestAccessToken(_ url: String, completion: @escaping (AccessToken?, Error?) -> ()) {
        let url = Server.url + url
        print("url => \(url)")
        
        if let value = UserDefaults.standard.dictionary(forKey: "UserInfo") {
            param = value
        }
        
        requestParam["userEmail"] = param["userEmail"] as! String
        
        print("requestAccessToken requestParam => \(requestParam)")
        
            AF.request(url,
                       method: .post,
                       parameters: requestParam,
                       encoding: JSONEncoding.default,
                       headers: ["Content-Type":"application/json", "Accept":"application/json"])
            .validate(statusCode: 200..<300)
            .responseJSON{ response in
                switch response.result {
                case .success(let value):
                    guard let result = response.data else {return}
                                    
                    do {
                        let decoder = JSONDecoder()
                        let json = try decoder.decode(AccessToken.self, from: response.data!)
                        completion(json, nil)
                        
                    } catch {
                        print("error! \(error)")
                    }
                case .failure(let error):
                    print("🚫 !!Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")

                    completion(nil, error)
                    var statusCode = response.response?.statusCode
                    print("requestAccessToken statusCode => \(statusCode)")
                }
            }
    }
    
    // MARK: - RefreshToken, AccessToken 재발급
    func requestRefreshToken(_ url: String, completion: @escaping (Token?, Error?) -> ()) {
        let url = Server.url + url
        print("url => \(url)")

        if let value = UserDefaults.standard.dictionary(forKey: "UserInfo") {
            param = value
        }

        print(param)

        requestParam["userEmail"] = param["userEmail"] as! String

            AF.request(url,
                       method: .post,
                       parameters: requestParam,
                       encoding: JSONEncoding.default,
                       headers: ["Content-Type":"application/json", "Accept":"application/json"])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("value ==> \(value)")
                    guard let result = response.data else {return}

                    do {
                        let decoder = JSONDecoder()
                        let json = try decoder.decode(Token.self, from: response.data!)
                        print("json => \(json)")

                        completion(json, nil)

                    } catch {
                        print("error! \(error)")
                        completion(nil, error)
                    }
                case .failure(let error):
                    print("🚫 ##Alamofire Request Error\nCode:\(error._code), Message: \(error.errorDescription!)")
                    completion(nil, error)
                }
            }
    }
    
    // MARK: - AccessToken 혹은 RefreshToken 재요청
    func reloadToken(_ statusCode: Int?){
        if let statusCode = statusCode {
            if statusCode == 500{
                // 토큰 재요청
                print("AccessToken 토큰 재요청 -> UserDefault Change -> 서버요청")
                
                self.requestAccessToken("/user/give-access-token", completion: {(accessToken, error) in
                    
                    if let error = error {
                        print("error \(error)")
                        
                        print("AccessToken AND RefreshToken 재요청 -> UserDefault Change -> 서버요청")
                        
                        self.requestRefreshToken("/user/give-both-token", completion: {(bothToken, error) in
                            if let error = error {
                                print("error \(error)")
                            }
                            if let bothToken = bothToken {
                                print("bothToken \(bothToken)")
                                let accessToken = bothToken.results.accessToken
                                
                                UserDefaults.standard.set(accessToken, forKey: "accessToken")
                            }
                        })
                    }
                    
                    if let accessToken = accessToken {
                        let accessToken = accessToken.accessToken
                        
                        UserDefaults.standard.set(accessToken, forKey: "accessToken")
                    }
                })
                
            }
        }
    }
}
