//
//  ViewController.swift
//  RepairSystem_2
//
//  Created by 李翌臣 on 2020/4/16.
//  Copyright © 2020 gentlemans. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class ViewController: UIViewController,UISearchBarDelegate,CLLocationManagerDelegate,MKMapViewDelegate{
    
    
    // 取得螢幕的尺寸
    let fullScreenSize = UIScreen.main.bounds.size
    
    let City = ["台北市","新北市"]
    let DistT = ["中正區","大同區","中山區","松山區","大安區","萬華區","信義區","士林區","北投區","內湖區","南港區","文山區"]
    let DistN = ["萬里區","金山區","板橋區","汐止區","深坑區","石碇區","瑞芳區","平溪區","雙溪區","貢寮區","新店區","坪林區","烏來區","永和區","中和區","土城區","三峽區","樹林區","鶯歌區","三重區","新莊區","泰山區","林口區","蘆洲區","五股區","八里區","淡水區","三芝區","石門區"]
    var CAddressCity = ""
    var CAddressDist = ""
    var travelpay: String?
    var checkOrder :String = ""
    // 建立 UIPickerView 設置位置及尺寸
    @IBOutlet var btnSignOut: UIBarButtonItem!
    @IBOutlet weak var searchBarMap: UISearchBar!
    @IBOutlet var MKMapView: MKMapView!
    @IBOutlet var travalexpress: UILabel!
    @IBOutlet var btnNext: UIBarButtonItem!
    @IBAction func btnNext(_ sender: Any) {
        
        let controller = UIAlertController(title: "確認地址\n(請詳細標出樓層號碼)", message: "\(searchBarMap.text!)", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "是", style: .default) { (_) in
           print("check address")
            self.performSegue(withIdentifier: "segue_RepairPage", sender: self)
        }
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
        print("to RepairPageVC")
    }
    
    
    
    
    var locationManger = CLLocationManager()
    
    let myPickerView = UIPickerView()
    let myPickerView2 = UIPickerView()
    var myTextField1 = UITextField()
    var myTextField2 = UITextField()
    var annotationCO = CLLocation()
    var annotationCU = MKPointAnnotation()
    var annotationNOW = MKPointAnnotation()
    var check = 0
    var locationscan :String = ""
    var phoneNumber:String?
    var documentName :String?
    var checkstatus :String?
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumber = Auth.auth().currentUser?.phoneNumber!
  
        self.title="叫修地點確認"
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        searchBarMap.delegate = self
        locationManger.delegate = self
        MKMapView.delegate = self //地圖元件
        
        
        locationManger.desiredAccuracy=kCLLocationAccuracyBest
        locationManger.requestAlwaysAuthorization()
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
        
        annotationCU.title = "叫修位置"
        
        annotationCO = CLLocation(latitude:25.04166, longitude: 121.536253) //公司位置
        myTextField1 = UITextField(frame: CGRect(
          x: 0, y: 0,
            width: fullScreenSize.width/2.25, height: 40))
        
        myTextField2 = UITextField(frame: CGRect(
        x: 0, y: 0,
        width: fullScreenSize.width/2.25, height: 40))
        myTextField2.clearsOnBeginEditing = true

        // 建立一個 UITextField

        myTextField1.text = City[0]
        myTextField2.text = DistT[0]
        
        myTextField1.tag = 100
        myTextField2.tag = 200
        myPickerView.tag = 1
        myPickerView2.tag = 2
        


        // 增加一個觸控事件 點空白鍵盤消失
        let tap = UITapGestureRecognizer(
          target: self,
          action:
            #selector(ViewController.hideKeyboard(tapG:)))

        tap.cancelsTouchesInView = false

        // 加在最基底的 self.view 上
        self.view.addGestureRecognizer(tap)
        
        
        checkorder()
        
        
        // Do any additional setup after loading the view.
    }
    func checkorder(){
        //查詢最新筆訂單
        self.showLoading()
        let db = Firestore.firestore()
        db.collection("users").document(self.phoneNumber!).getDocument(source: .cache) { (document, error) in
            
           if let document = document{
            var status :String?
            status = document.get("status") as? String
            
            
            if status == "1"{
                self.checkstatus = "1"
                print(self.checkstatus!)
            }else{
                print("status not 1")
            }
          }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.removeLoading()
            if self.checkstatus == "1"{
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "OrderVC")
                self.navigationController?.pushViewController(vc, animated: true)
                //self.performSegue(withIdentifier: "segue_VCtoOrderVC", sender:nil)
                print("go")
                }
            }
             
            
        }
            
    }
    @objc func hideKeyboard(tapG:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    //按下搜尋動作
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getAdderss()
        self.view.endEditing(true)
        print(self.searchBarMap.text!)
        
    }
    func getAdderss(){
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(searchBarMap.text!){
            (placemarks,error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location
                
            else {
                    print("無法找到此地點")
                self.check = 0
       	             return
            }
            self.annotationCU.coordinate = location.coordinate
            self.MKMapView.showAnnotations([self.annotationCU], animated: true)
            self.MKMapView.selectAnnotation(self.annotationCU, animated: true)
            print("經度:",location.coordinate.latitude)
            print("緯度:",location.coordinate.longitude)
            let userlocation = CLLocation(latitude: location.coordinate.latitude,longitude: location.coordinate.longitude)
            
            var distance = userlocation.distance(from: self.annotationCO)
            print(self.annotationCO.coordinate.latitude)
            print(self.annotationCO.coordinate.longitude)
            
            distance=ceil(distance/1000)
            if (distance < 5){
                self.travalexpress.text = ("距離約\(distance)公里 車馬費估計200元")
                self.travelpay = "200"
                print(distance)
            }else{
                self.travalexpress.text = ("距離約\(distance)公里 車馬費估計300元")
                self.travelpay = "300"
                print(distance)
            }
        }
        print("success get address")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations)
        
        let locationMe = locations[locations.count - 1]
        if locationMe.horizontalAccuracy > 0 {
            //this line will check if the location is available
        // 由於定位功能十分耗電，我們既然已經取得了位置，就該速速把它關掉
            locationManger.stopUpdatingLocation()
            print("latitude: \(locationMe.coordinate.latitude), longtitude: \(locationMe.coordinate.longitude)")
            let geo = CLGeocoder()
            geo.reverseGeocodeLocation(locationMe, completionHandler: {(placemarks, error) in
                if(error != nil){
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as[CLPlacemark]
                
                if pm.count > 0 {
                let pm = placemarks![0]
                //print(pm.country)
                //print(pm.administrativeArea)
                //print(pm.subAdministrativeArea)//城市
                //print(pm.subLocality)
                //print(pm.locality )//區
                //print(pm.name)//號

                    if(pm.subAdministrativeArea != nil ){
                        if(!self.locationscan.contains(pm.subAdministrativeArea!)){
                            self.locationscan = self.locationscan + pm.subAdministrativeArea!
                        }
                    }
                    if(pm.locality != nil){
                        if(!self.locationscan.contains(pm.locality!)){
                            self.locationscan = self.locationscan + pm.locality!
                        }
                        
                    }
                    if(pm.thoroughfare != nil){
                        if(!self.locationscan.contains(pm.thoroughfare!)){
                            self.locationscan = self.locationscan + pm.thoroughfare!
                        }
                        
                    }
                    if(pm.subThoroughfare != nil){
                        if(!self.locationscan.contains(pm.subThoroughfare!)){
                            self.locationscan = self.locationscan + pm.subThoroughfare!
                        }
                        
                    }
                
                }
                self.searchBarMap.text = "\(self.locationscan)號"
                self.annotationNOW.coordinate = locationMe.coordinate
                self.MKMapView.showAnnotations([self.annotationNOW], animated: true)
                self.MKMapView.selectAnnotation(self.annotationNOW, animated: true)
                var distance = locationMe.distance(from: self.annotationCO)
                print(self.annotationCO.coordinate.latitude)
                print(self.annotationCO.coordinate.longitude)
                
                distance=ceil(distance/1000)
                
                if (distance < 5){
                    self.travalexpress.text = ("距離約\(distance)公里 車馬費估計200元")
                    self.travelpay = "200"
                    print(distance)
                }else{
                    self.travalexpress.text = ("距離約\(distance)公里 車馬費估計300元")
                    self.travelpay = "300"
                    print(distance)
                }
            })
        }
        
    }
    
    @IBAction func btnSignOut_tapped(_ sender: Any) {
        do {
          try Auth.auth().signOut()
            let alertController = UIAlertController(title: "登出成功!",message: nil, preferredStyle: .alert)
            self.present(alertController, animated: true, completion: nil)
            let back = self.storyboard?.instantiateViewController(withIdentifier: "StartVC")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                
                self.navigationController?.pushViewController(back!, animated: true)
            }
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_RepairPage" {
            let vc = segue.destination as! RepairPageVC
            vc.lastAddress = self.searchBarMap.text!
            vc.distance = travelpay
        }
    }
    

}

