//
//  ViewControllerImage.swift
//  Queue2
//
//  Created by Ваня Науменко on 21.11.22.
//

import UIKit

class ViewControllerImage: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var timer: Timer?
    private let imageURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/d/dd/Big_%26_Small_Pumkins.JPG")

    override func viewDidLoad() {
        super.viewDidLoad()
       fetchImage()
    }
    
    private var image: UIImage? {
        get {
            imageView.image
        }
        set {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = true
            imageView.image = newValue
            imageView.sizeToFit()
        }
    }
    
    private func fetchImage() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
       
        let queue = DispatchQueue.global(qos: .utility)
        queue.async {
            guard let url = self.imageURL, let imageData = try? Data(contentsOf: url) else { return }
            DispatchQueue.main.async { [weak self] in
                self?.image = UIImage(data: imageData)
                self?.delay(3) {
                    self?.loginAlert()
                }
            }
        }
    }
    
    private func delay (_ delay: Int, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) {
            closure()
        }
    }
    private func loginAlert() {
        let alertController = UIAlertController(title: "Узнай на кого ты похож в эмоджи", message: "Введите ваше имя и фамилию", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {_ in
            guard let name = alertController.textFields?[0].text,
                  let surname = alertController.textFields?[1].text else { return }
            self.title = "\(name) \(surname)"
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        })
        let cancelActiv = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelActiv)
        alertController.addTextField { userNameTF in
            userNameTF.placeholder = "Введите имя"
        }
        alertController.addTextField { userSurnameTF in
            userSurnameTF.placeholder = "Введите фамилию"
            // userSurnameTF.isSecureTextEntry = true - скрывает текст , чисто дял поролей )
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func update() {
        self.imageView.image = self.randomEmoji().image()
    }
    // MARK: нашел )))
    private func randomEmoji() -> String {
        let range = 0x1F300 ... 0x1F3F0
        let index = Int(arc4random_uniform(UInt32(range.count)))
        let ord = range.lowerBound + index
        guard let scalar = UnicodeScalar(ord) else { return "❓" }
        return String(scalar)
    }
}

extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 400, height: 400)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 360)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
