//
//  PhotoViewController.swift
//  gallery
//
//  Created by Admin on 14.04.17.
//  Copyright © 2017 justsayozz. All rights reserved.
//

import UIKit
import MessageUI

class PhotoViewController: UIViewController, UIScrollViewDelegate, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var shareActionButton: UIBarButtonItem!
    @IBOutlet weak var errorLabel: UILabel!
    
    var photo: Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setErrorState() {
        shareActionButton.isEnabled = false
        errorLabel.isHidden = false
        activityIndicator.stopAnimating()
    }
    
    func setPhoto(photo: Photo?) {
        guard let photo = photo else {
            setErrorState()
            return
        }
        self.photo = photo
        self.navigationItem.title = photo.title ?? "Photo"
        
        photo.getLargeImage(downloadComplete: { (image) in
            DispatchQueue.main.async {
                self.imageView.image = image
                self.activityIndicator.stopAnimating()
            }
        }, downloadError: {
            DispatchQueue.main.async {
                self.setErrorState()
            }
        })
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func shareButtonTouched(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mailController = MFMailComposeViewController()
            mailController.mailComposeDelegate = self
            mailController.setSubject(photo?.title ?? "Photo")
            mailController.setMessageBody("Look at this photo!", isHTML: false)
            if let image = imageView.image {
                if let imageData = UIImagePNGRepresentation(image) {
                    mailController.addAttachmentData(
                        imageData,
                        mimeType: "image/png",
                        fileName: photo?.title ?? "photo")
                }
            }
            self.present(mailController, animated: true, completion: nil)
        } else {
            showAlert(
                title: "Error",
                message: "You've got no email accounts enabled. Please check your settings and try again")
        }
    }
    
    //MFMailComposeViewController delegates
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        switch result {
        case .sent:
            showAlert(title: "Succeed", message: "Message has been sent")
            break
        case .failed:
            showAlert(title: "Error", message: "Failed to send message. Please try again")
            break
        default:
            break
        }
    }
    
    //UIScrollView delegates
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    //
}
