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
    @IBOutlet weak var backgroundCollectionView: UICollectionView!
    @IBOutlet weak var deckTableView: UITableView!

    static let deckIndexSetting = "deckIndex"
    static let backgroundImageIndexSetting = "backgroundImageIndex"
    
    var decks: Array<Dictionary<String, AnyObject>> = []
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

        self.deckTableView.dataSource = self
        self.deckTableView.delegate = self
        self.deckTableView.register(DeckTableViewCell.self, forCellReuseIdentifier: "DeckCell")

        let deckIndex = UserDefaults.standard.integer(forKey: SettingsViewController.deckIndexSetting)
        let indexPath = IndexPath(row: deckIndex, section: 0)
        self.deckTableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
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
        if let deckIndex = self.deckTableView.indexPathForSelectedRow?.row {
            UserDefaults.standard.set(deckIndex, forKey: SettingsViewController.deckIndexSetting)
            MessageBroker.sharedMessageBroker.publish(SettingsMessage.deckIndex(deckIndex))
        }
        
        let selectedItems = self.backgroundCollectionView.indexPathsForSelectedItems
        if selectedItems != nil && selectedItems!.count > 0 {
            let selectedItem = selectedItems![0]
            let selectedImageIndex = selectedItem.row
            UserDefaults.standard.set(selectedImageIndex, forKey: SettingsViewController.backgroundImageIndexSetting)
            MessageBroker.sharedMessageBroker.publish(SettingsMessage.backgroundImageIndex(selectedImageIndex))
        }
        
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
        decks = SettingsViewController.loadDecksPlist()
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

/*
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
*/

extension SettingsViewController: UITableViewDelegate {
    //MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
    }
     */
}

extension SettingsViewController: UITableViewDataSource {
    //MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks.count
    }
    
    func tableView(_ cellForRowAttableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cellForRowAttableView.dequeueReusableCell(withIdentifier: "DeckCell", for: indexPath) as! DeckTableViewCell
        
        let deck = decks[indexPath.row]
        
        cell.textLabel?.text = deck["name"] as? String ?? ""
        cell.detailTextLabel?.text = deck["description"] as? String ?? ""
        return cell
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

class DeckTableViewCell : UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "DeckCell")
        self.backgroundColor = UIColor(hexColor: 0x0971B2)
        
        let selectionColor = UIView()
        selectionColor.backgroundColor = UIColor(hexColor: 0xFFFC19) // 0x1485CC)
        self.selectedBackgroundView = selectionColor;

        self.layer.cornerRadius = 7;
        self.layer.masksToBounds = true;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
