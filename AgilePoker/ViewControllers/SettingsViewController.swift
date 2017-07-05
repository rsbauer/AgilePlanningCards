//
//  SettingsViewController.swift
//  AgilePoker
//
//  Created by Astro on 6/25/17.
//  Copyright © 2017 Rock Solid Bits. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet var settingsView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var deckPicker: UIPickerView!
    @IBOutlet weak var backgroundCollectionView: UICollectionView!

    static let deckIndexSetting = "deckIndex"
    static let backgroundImageIndexSetting = "backgroundImageIndex"
    
    var decks: Array<String> = []
    var images: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screen = UIScreen.main.bounds
        
        var frame = self.settingsView.frame
        frame.size.width = screen.size.width
        self.settingsView.frame = frame
        
        self.scrollView.addSubview(self.settingsView)
        self.scrollView.contentSize = CGSize(width: screen.size.width, height: self.settingsView.frame.height)
        
        setupBackgroundImageCollectionView()
        
        setupDeckPicker()

        self.deckPicker.dataSource = self
        self.deckPicker.delegate = self
        
        let deckIndex = UserDefaults.standard.integer(forKey: SettingsViewController.deckIndexSetting)
        self.deckPicker.selectRow(deckIndex, inComponent: 0, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let backgroundImageIndex = UserDefaults.standard.integer(forKey: SettingsViewController.backgroundImageIndexSetting)
        let indexPath = IndexPath(item: backgroundImageIndex, section: 0)
        self.backgroundCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // save settings
        let deckIndex = self.deckPicker.selectedRow(inComponent: 0)
        let selectedItems = self.backgroundCollectionView.indexPathsForSelectedItems
        if selectedItems != nil && selectedItems!.count > 0 {
            let selectedItem = selectedItems![0]
            let selectedImageIndex = selectedItem.row
            UserDefaults.standard.set(selectedImageIndex, forKey: SettingsViewController.backgroundImageIndexSetting)
            MessageBroker.sharedMessageBroker.publish(SettingsMessage.backgroundImageIndex(selectedImageIndex))
        }
        UserDefaults.standard.set(deckIndex, forKey: SettingsViewController.deckIndexSetting)
        MessageBroker.sharedMessageBroker.publish(SettingsMessage.deckIndex(deckIndex))
        
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Settings
    
    func setupBackgroundImageCollectionView() {
        images = []
        let imageCollection = SettingsViewController.loadImagesPlist()
        for item in imageCollection {
            if let imageName = item["image"] as? String {
                images.append(imageName)
            }
        }
        
        let nib = UINib(nibName: "BackgroundImageSettingCollectionViewCell", bundle: nil)
        self.backgroundCollectionView.register(nib, forCellWithReuseIdentifier: "BackgroundImageSettingCollectionViewCell")

        self.backgroundCollectionView.delegate = self
        self.backgroundCollectionView.dataSource = self
    }
    
    func setupDeckPicker() {
        decks = []
        let array = SettingsViewController.loadDecksPlist()
        for item in array {
            if let display = item["display"] as? String {
                self.decks.append(display)
            }
        }
    }
    
    // MARK: Misc

    static func loadImagesPlist() -> Array<Dictionary<String, AnyObject>> {
        return loadPlist(named: "AppBackgroundImages")
        
    }
    
    static func loadDecksPlist() -> Array<Dictionary<String, AnyObject>> {
        return loadPlist(named: "Decks")
    }
    
    static func loadPlist(named: String) -> Array<Dictionary<String, AnyObject>> {
        if let path = Bundle.main.path(forResource: named, ofType: "plist") {
            if let array = NSArray(contentsOfFile: path) as? Array<Dictionary<String, AnyObject>> {
                return array
            }
        }
        
        let empty: Array<Dictionary<String, AnyObject>> = []
        return empty
    }
}

extension SettingsViewController: UIPickerViewDelegate {
    //MARK: UIPickerViewDelegate

}

extension SettingsViewController: UIPickerViewDataSource {
    //MARK: UIPickerViewDataSource
    
    @available(iOS 2.0, *)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return decks.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return decks[row]
    }
}


extension SettingsViewController: UICollectionViewDataSource {
    //MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BackgroundImageSettingCollectionViewCell", for: indexPath) as! BackgroundImageSettingCollectionViewCell
        
        let image = images[indexPath.item]
        cell.configureCell(imageName: image)
 
        cell.wasDeselected()
        let selectedItems = self.backgroundCollectionView.indexPathsForSelectedItems
        if selectedItems != nil && selectedItems!.count > 0 {
            let selectedItem = selectedItems![0]
            if selectedItem.row == indexPath.row {
                cell.wasSelected()
            }
        }
        return cell
    }
}

extension SettingsViewController: UICollectionViewDelegate {
    //MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! BackgroundImageSettingCollectionViewCell
        cell.wasSelected()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? BackgroundImageSettingCollectionViewCell
        cell?.wasDeselected()
    }
}

extension SettingsViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150.0, height: 150.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout colletionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    
}
