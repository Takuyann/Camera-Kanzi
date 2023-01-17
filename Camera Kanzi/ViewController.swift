//
//  ViewController.swift
//  Camera Kanzi
//
//  Created by clark on 2022/06/29.
//

import UIKit
import MLKit
import MLKitTextRecognitionJapanese
import MLKitTextRecognitionCommon
import AVFoundation
import CropViewController

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate{
        @IBOutlet var cameraImageView: UIImageView!
        @IBOutlet var honyakukekka: UILabel!
        
        let japaneseOptions = JapaneseTextRecognizerOptions()
        let japaneseTextRecognizer = TextRecognizer.textRecognizer(options: JapaneseTextRecognizerOptions())
        var kanzihonyaku: String = ""
       // let image = VisionImage(image: UIImage(named: "159905")!)
        override func viewDidLoad() {
            honyakukekka.adjustsFontSizeToFitWidth = true
            super.viewDidLoad()
//            japaneseTextRecognizer.process(image) { result, error in
//                guard error == nil, let result = result else { return }
//                print("resultText: \(result.text)")
//            }
            // Do any additional setup after loading the view.
        }
       // func scan(sampleBuffer: CMSampleBuffer){
    //カメラで撮ったのをひらがなにする{
        @IBAction func botan(){
            let image = VisionImage(image: cameraImageView.image!)
            japaneseTextRecognizer.process(image) { result, error in
                guard error == nil, let result = result else { return }
                self.kanzihonyaku = result.text
                print("resultText: \(result.text)")
            }
            var request = URLRequest(url: URL(string: "https://labs.goo.ne.jp/api/hiragana")!)
                    request.httpMethod = "POST"
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    //POSTするデータをURLRequestに持たせる
                    let postData = PostData(app_id: "6937c927439be919b9c5add398fcd7a18307788779ce23b4181eb3a9c5435b6f", request_id: "record003", sentence: kanzihonyaku, output_type: "hiragana")
                    guard let uploadData = try? JSONEncoder().encode(postData) else {
                        print("json生成に失敗しました")
                        return
                    }
                    request.httpBody = uploadData
                    //APIへPOSTしてresponseを受け取る
                    let task = URLSession.shared.uploadTask(with: request, from: uploadData) {
                        data, response, error in
                        if let error = error {
                            print ("error: \(error)")
                            return
                        }
                        guard let response = response as? HTTPURLResponse,
                            (200...299).contains(response.statusCode) else {
                                print ("server error")
                                return
                        }
                        if response.statusCode == 200 {
                            guard let data = data, let jsonData = try? JSONDecoder().decode(Rubi.self, from: data) else {
                                print("json変換に失敗しました")
                                return
                            }
                            print(jsonData.converted)
                            DispatchQueue.main.async {
                                self.honyakukekka.text = jsonData.converted
                            }
                        } else {
                            print("サーバエラー ステータスコード: \(response.statusCode)\n")
                        }
                    }
                    task.resume()
                }
        //   }
        //画像のテキストを認識する
        func imageOrientation(deviceOrientaton: UIDeviceOrientation, cameraPosition: AVCaptureDevice.Position) -> UIImage.Orientation{
            switch deviceOrientaton {
            case .portrait:
                return cameraPosition == .front ? .leftMirrored : .right
            case .landscapeLeft:
                return cameraPosition == .front ? .downMirrored : .up
            case .portraitUpsideDown:
                return cameraPosition == .front ? .rightMirrored : .left
            case .landscapeRight:
                return cameraPosition == .front ? .upMirrored : .down
            case .faceDown, .faceUp, .unknown:
                return .up
            }
        }
        
        @IBAction func selectPicture(_ sender: UIButton) {
            //カメラロールが利用可能か？
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                //写真を選ぶビュー
                let pickerView = UIImagePickerController()
                //写真の選択元をカメラロールにする
                //「.camera」にすればカメラを起動できる
                pickerView.sourceType = .photoLibrary
                //デリゲート
                pickerView.delegate = self
                //ビューに表示
                self.present(pickerView,animated: true)
            }
        }
    @IBAction func takePhoto(){
        //カメラが使えるかの確認
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            //カメラを起動
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            self.present(imagePicker,animated: true,completion: nil)
        } else {
            //カメラを使えない時はエラーがコンソールに出ます
            print("Camera not available")
        }
    }
        func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
                updateImageViewWithImage(image, fromCropViewController: cropViewController)
            }
                
            func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
                cameraImageView.image = image
                cropViewController.dismiss(animated: true, completion: nil)
            }
    //カメラ、カメラロールを使った時に選択した画像をアプリ内に表示するためのメソッド
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else{
            print("Image not found.")
            return
        }
        //cameraImageView.image = image
        let cropController = CropViewController(croppingStyle: .default, image: image)
                cropController.delegate = self
                cropController.customAspectRatio = CGSize(width: 100, height: 100)
                
                //今回は使わないボタン等を非表示にする。
                cropController.aspectRatioPickerButtonHidden = true
                cropController.resetAspectRatioEnabled = true
                cropController.rotateButtonsHidden = true
                
                //cropBoxのサイズを固定する。
                cropController.cropView.cropBoxResizeEnabled = true
                //pickerを閉じたら、cropControllerを表示する。
                picker.dismiss(animated: true) {
                    self.present(cropController, animated: true, completion: nil)
                }
    }
//        func japaneseTextRecognizer.process(image); {result, error in
//            guard error == nil, let result = result else { return }
//            print("resultText: \(result.text)")
//        }
}
struct Rubi:Codable {
    var request_id: String
    var output_type: String
    var converted: String
}
struct PostData: Codable {
    var app_id:String
    var request_id: String
    var sentence: String
    var output_type: String
}

