import UIKit

class AppIconOptionsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView!
    var appIcons: [String]!
    var selectedIconIndex: Int!
    var backButton: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Change App Icon"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "YTSans-Bold", size: 22)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        
        self.selectedIconIndex = -1
        
        self.tableView = UITableView(frame: self.view.bounds, style: .plain)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(self.tableView)
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(back))
        if let backImage = UIImage(named: "yt_outline_chevron_left_ios_24pt", in: Bundle.main, compatibleWith: nil) {
            backButton.image = backImage
        } else {
            backButton.image = UIImage(systemName: "chevron.backward")
        }
        backButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "YTSans-Medium", size: 17)!], for: .normal)
        self.navigationItem.leftBarButtonItem = backButton
        
        let buttonColor = UIColor(red: 203.0/255.0, green: 22.0/255.0, blue: 51.0/255.0, alpha: 1.0)
        
        let resetButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetIcon))
        resetButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: buttonColor, NSAttributedString.Key.font: UIFont(name: "YTSans-Medium", size: 17)!], for: .normal)
        
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveIcon))
        saveButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: buttonColor, NSAttributedString.Key.font: UIFont(name: "YTSans-Medium", size: 17)!], for: .normal)
        
        self.navigationItem.rightBarButtonItems = [saveButton, resetButton]
        
        let bundle = Bundle(identifier: "com.example.uYouPlus")!
        if let iconsPath = bundle.path(forResource: "AppIcons", ofType: "png") {
            self.appIcons = try! FileManager.default.contentsOfDirectory(atPath: iconsPath)
        }
        
        if !UIApplication.shared.supportsAlternateIcons {
            print("Alternate icons are not supported on this device.")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appIcons.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        let iconPath = self.appIcons[indexPath.row]
        cell.textLabel?.text = (iconPath as NSString).lastPathComponent.deletingPathExtension
        
        if let iconImage = UIImage(contentsOfFile: iconPath) {
            cell.imageView?.image = iconImage
            cell.imageView?.layer.cornerRadius = 10.0
            cell.imageView?.clipsToBounds = true
            cell.imageView?.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
            cell.textLabel?.frame = CGRect(x: 60, y: 10, width: self.view.frame.size.width - 70, height: 40)
        }
        
        cell.accessoryType = indexPath.row == self.selectedIconIndex ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.selectedIconIndex = indexPath.row
        self.tableView.reloadData()
    }
    
    @objc func resetIcon() {
        UIApplication.shared.setAlternateIconName(nil) { error in
            if let error = error {
                print("Error resetting icon: \(error.localizedDescription)")
                showAlert(title: "Error", message: "Failed to reset icon")
            } else {
                print("Icon reset successfully")
                showAlert(title: "Success", message: "Icon reset successfully")
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func saveIcon() {
        let selectedIconPath = self.selectedIconIndex >= 0 ? self.appIcons[self.selectedIconIndex] : nil
        if let iconPath = selectedIconPath {
            let iconURL = URL(fileURLWithPath: iconPath)
            UIApplication.shared.setAlternateIconName(iconPath) { error in
                if let error = error {
                    print("Error setting alternate icon: \(error.localizedDescription)")
                    showAlert(title: "Error", message: "Failed to set alternate icon")
                } else {
                    print("Alternate icon set successfully")
                    showAlert(title: "Success", message: "Alternate icon set successfully")
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
}
