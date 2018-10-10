//
//  ViewController.swift
//  DocPicker
//
//  Created by AFFIXUS IMAC1 on 8/21/18.
//  Copyright © 2018 AFFIXUS IMAC1. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import PhotosUI
import Alamofire

class ViewController: UIViewController, UIDocumentMenuDelegate,UIDocumentPickerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var imageSelected: UIImage?
     @IBOutlet weak var myImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
//        let myURL = url as URL
//        print("import result : \(myURL)")
//
//        do {
//
//            let filename = url.lastPathComponent
//            let fileData = try Data(contentsOf: url, options: Data.ReadingOptions.init(rawValue: String.Encoding.utf8.rawValue))
//           uploadImage(fileData: fileData)
//        } catch  {
//
//        }
//
//    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let fileURL = url as URL
        print("The Url is : \(fileURL)")
        let fileNameWithoutExtension = fileURL.lastPathComponent
        print("fileNameWithoutExtension: \(fileNameWithoutExtension)")
        
            
            do {
                let data = try Data(contentsOf: fileURL, options: Data.ReadingOptions.init(rawValue: String.Encoding.utf8.rawValue))
                print("data=\(data)")
                
//                let image : UIImage = UIImage(data: data)!
//                myImageView.image = image
//                imageSelected = UIImage(data: data)!
//                let imgData = UIImagePNGRepresentation(image) as Data?
                
                //TODO: call upload API
                let headers: HTTPHeaders = [
                    "Content-Type": "multipart/form-data",
                    "uid": "admin",
                    "auth": "MJAXODMWMTBZV1J0YVC0PQ"
                ]
                
                Alamofire.upload(multipartFormData: { multipartFormData in
                    multipartFormData.append(data, withName: "fileData",fileName: fileNameWithoutExtension, mimeType: "image/jpeg")
                    multipartFormData.append("13".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: "inst_id")    //userId parameters
                    multipartFormData.append("application/pdf".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: "contentType")   //dpchange parameters (true)
                    
                },
                                 
                                 to: "http://www.oxloopdemo.com/samweb/rest/file/binary/upload" ,method:.post,
                                 headers:headers)
                    
                { (result) in
                    
                    switch result {
                    case .success(let upload, _, _):
                        
                        upload.uploadProgress(closure: { (progress) in
                            print("Upload Progress: \(progress.fractionCompleted)")
                        })
                        
                        
                        upload.responseJSON { response in
                            print(response.result.value!)
                            
                            do {
                                let responseDict = try JSONSerialization.jsonObject(with: response.data!) as! [String:Any]
                                
                            } catch {
                                
                            }
                            
                        }
                        
                    case .failure(let encodingError):
                        print(encodingError)
                        
                    }
                }
        }
        
            catch {print("uploaderror")/* error handling here */}
        
        
        
    }
    
    
    public func documentMenu(_ documentMenu:UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
        //Gallery
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            myImageView.image = image
            
        }
        else
        {
            //Error message
        }
        self.dismiss(animated: true, completion: nil)
        
        if let imageURL = info[UIImagePickerControllerReferenceURL] as? NSURL {
            let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL as URL], options: nil)
            let filename = result.firstObject?.value(forKey: "filename") as? String ?? "Unknown"
            print("Image Name is \(filename)")
        }
  
        
        
        
        //Camera
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            myImageView.contentMode = .scaleToFill
            myImageView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btDocPicker(_ sender: Any) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: self.fromCamera))
        alertController.addAction(UIAlertAction(title: "Gallery", style: .default, handler: self.fromGallery))
        alertController.addAction(UIAlertAction(title: "Browse", style: .default, handler: self.browseCloud))
         alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion:  nil)
    
    }
    
    func browseCloud(alert: UIAlertAction){
        let options = [kUTTypePDF as String, kUTTypeZipArchive  as String, kUTTypePNG as String, kUTTypeJPEG as String, kUTTypeText  as String, kUTTypePlainText as String]
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: options, in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func fromGallery(alert: UIAlertAction){
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        image.allowsEditing = false
        
        self.present(image, animated: true)
        {
            //After it is complete
        }
    }
    
    func fromCamera(alert: UIAlertAction){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func openCloudd(_ sender: UIButton) {
       
        
    }
    
    func uploadImage(){
        
        let image: UIImage = imageSelected!
        let data = UIImagePNGRepresentation(image) as Data?
        
        let headers: HTTPHeaders = [
            "uid": "admin",
            "auth": "MJAXODI4MTJZV1J0YVC0PQ"
        ]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data!, withName: "fileData",fileName: "cloud", mimeType: "image/jpg")
            multipartFormData.append("13".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: "inst_id")    //userId parameters
            multipartFormData.append("application/pdf".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: "contentType")   //dpchange parameters (true)
            
        },
                         
                         to: "http://www.oxloopdemo.com/samweb/rest/file/binary/upload" ,method:.post,
                         headers:headers)
            
        { (result) in
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                
                upload.responseJSON { response in
                    print(response.result.value!)
                    
                    do {
                        let responseDict = try JSONSerialization.jsonObject(with: response.data!) as! [String:Any]
                        
                    } catch {
                        
                    }
                    
                }
                
            case .failure(let encodingError):
                print(encodingError)
                
            }
        }
    }
    
}
