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

    class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
        @IBOutlet var cameraImageView: UIImageView!
        
        //let japaneseOptions = JapaneseTextRecognizerOptions()
        let japaneseTextRecognizer = TextRecognizer.textRecognizer(options: JapaneseTextRecognizerOptions())
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
        }
        let image = VisionImage(image: UIImage(named: "sample")!)
        image.orientation = imageOrientation(deviceOrientation: UIDevice.current.orientation, cameraPosition: .back)
        func imageOrientation(deviceOrientaton: UIDeviceOrientation, cameraPosition: AVCaptureDevice.Position) -> UIImage.Orientation{
            switch deviceOrientaton {
            case .portrait:
                return cameraPosition == .front ? .leftMirrored : .right
            case .landscapeLeft:
                <#code#>
            case .portraitUpsideDown:
                <#code#>
            case .landscapeRight:
                <#code#>
            case .faceDown, .faceUp:
                <#code#>
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
    //カメラ、カメラロールを使った時に選択した画像をアプリ内に表示するためのメソッド
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else{
            print("Image not found.")
            return
        }
        cameraImageView.image = image
    }
        
}

