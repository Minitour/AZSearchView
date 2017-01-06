//
//  AZSearchViewController.swift
//  AZSearchViewController
//
//  Created by Antonio Zaitoun on 04/01/2017.
//  Copyright © 2017 Antonio Zaitoun. All rights reserved.
//

import Foundation
import UIKit

struct AZSearchViewPref{
    
    static let nibName: String = "AZSearchView"
    
    static let reuseIdetentifer = "cell"
    
    static let backgroundColor: UIColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
    
    static let searchBarColor: UIColor = UIColor(colorLiteralRed: 0.86, green: 0.86, blue: 0.86, alpha: 1)
    
    static let searchBarPortraitHeight:CGFloat = 64
    
    static let searchBarLandscapeHeight:CGFloat = 32
    
    static let searchBarPortraitOffset:CGFloat = 10
    
    static let searchBarLandscapeOffset:CGFloat = 0
    
    static let animationDuration = 0.3

}

protocol AZSearchViewDelegate{
    ///didTextChange is called once the user types/deletes.
    /// - parameter text: Is the new text.
    /// - parameter textLength: Is the length of the new text.
    func didTextChange(toText text: String, textLength: Int)
    
    ///didSearch is called once the user clicks the `Search` button in the keyboard.
    /// - parameter text: Is the text that the user is searching for.
    func didSearch(forText text: String)
    
    ///didSelectResult is called once the user has selected one of the results in the table view.
    /// - parameter index: Is the index of the item that was selected.
    /// - parameter text: Is the text of the selected result. Note that this is fetched from the data source, so if the data source function `results()` has changed it's data set this will return the new data.
    func didSelectResult(at index: Int,text: String)
    
}

protocol AZSearchViewDataSource {
    ///results is called whenever the UITableView's data source functions `cellForRowAt` and `numberOfRowsInSection` and when calling `reloadData()` on an instance of `AZSearchViewController`.
    /// - returns: An array of strings which are displayed as a auto-complete suggestion.
    func results()->[String]
    
}

class AZSearchViewController: UIViewController{
        
    
    ///Auto complete tableview
    @IBOutlet fileprivate var tableView: UITableView!
    
    ///The navigation bar
    @IBOutlet var navigationBar: UINavigationBar!
    
    ///The navigation item
    @IBOutlet fileprivate var navItem: UINavigationItem!
    
    //The view under the status bar
    @IBOutlet fileprivate var statusBarUnderlayView: UIView!
    
    //The height constraint of the navigation bar
    @IBOutlet fileprivate var navigationBarHeightConstraint: NSLayoutConstraint!
    
    //The height constraint of the view that underlays the status bar
    @IBOutlet fileprivate var statusBarUnderlayHeightConstraint: NSLayoutConstraint!
    
    ///SearchView delegate
    open var delegate: AZSearchViewDelegate!
    
    ///SearchView data source
    open var dataSource: AZSearchViewDataSource!
    
    ///The search bar
    fileprivate var searchBar:UISearchBar!
    
    ///The bar height
    open var barHeight:CGFloat {
        get{
            return navigationBarHeightConstraint.constant
        }set{
            navigationBarHeightConstraint.constant = newValue
        }
    }
    
    ///The search bar offset
    internal var searchBarOffset: UIOffset{
        get{
            return self.searchBar.searchFieldBackgroundPositionAdjustment
        }set{
            self.searchBar.searchFieldBackgroundPositionAdjustment = newValue
        }
    }
    
    ///Computed variable to set the search bar background color
    open var searchBarBackgroundColor: UIColor = AZSearchViewPref.searchBarColor{
        didSet{
            if searchBar != nil, let searchField = searchBar.value(forKey: "searchField"){
                (searchField as! UITextField).backgroundColor = searchBarBackgroundColor
            }
        }
    }
    
    open var keyboardAppearnce: UIKeyboardAppearance = .default {
        didSet{
            self.searchBar.keyboardAppearance = keyboardAppearnce
        }
    }
    
    ///The navigation item which is an IBOutlet
    override var navigationItem: UINavigationItem{
        get{
            return self.navItem
        }
    }
    
    ///The search bar place holder text
    open var searchBarPlaceHolder: String = "Search"{
        didSet{
            if (self.searchBar != nil){
               self.searchBar.placeholder = searchBarPlaceHolder
            }
            
        }
    }
    
    ///A var to change the status bar appearnce
    open var statusBarStyle: UIStatusBarStyle = .default{
        didSet{
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    ///A var to change the opacity under the status bar
    open var statusBarUnderlayOpacity: CGFloat = 0 {
        didSet{
            if statusBarUnderlayView != nil {
                let alpha =  statusBarUnderlayOpacity > 0.10 ? 0.10 : max(0, statusBarUnderlayOpacity)
                self.statusBarUnderlayView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: Float(alpha))
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return self.statusBarStyle
    }
    
    ///Private var to assist viewDidAppear
    fileprivate var didAppear = false
    
    //MARK: - Init
    convenience init(){
        let bundle = Bundle(for: AZSearchViewController.self)
        self.init(nibName: AZSearchViewPref.nibName, bundle: bundle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    deinit {
        //remove keyboard oberservers
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - UIViewController
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        self.searchBar.resignFirstResponder()
        super.dismiss(animated: flag, completion: completion)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //update status bar underlayig view
        self.statusBarUnderlayView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: Float(self.statusBarUnderlayOpacity))
        
        //update view background
        self.view.backgroundColor = AZSearchViewPref.backgroundColor
        
        //setup tableview
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: AZSearchViewPref.reuseIdetentifer)
        self.tableView.tableFooterView = UIView()
        self.tableView.isHidden = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        var orientation = 0
        if UIDevice.current.orientation.isLandscape {orientation = 1} else {orientation = 0}
        
        let height = orientation == 0 ? AZSearchViewPref.searchBarPortraitHeight : AZSearchViewPref.searchBarLandscapeHeight
        
        self.tableView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: height, left: 0, bottom: 0, right: 0)
        
        //setup search bar
        self.searchBar.placeholder = self.searchBarPlaceHolder
        
        if let searchField = searchBar.value(forKey: "searchField"){(searchField as! UITextField).backgroundColor = self.searchBarBackgroundColor}
        
        let offset = orientation == 0 ? AZSearchViewPref.searchBarPortraitOffset : AZSearchViewPref.searchBarLandscapeOffset
        
        self.searchBar.searchFieldBackgroundPositionAdjustment = UIOffset(horizontal: 0, vertical: offset)
        
        self.navItem.titleView = self.searchBar
        
        self.searchBar.delegate = self
        
        //setup background tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(AZSearchViewController.didTapBackground(sender:)))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        //add observers to listen to keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(AZSearchViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AZSearchViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //open keyboard
        self.searchBar.becomeFirstResponder()
        
        //fix bar height
        var orientation = 0
        if UIDevice.current.orientation.isLandscape {orientation = 1} else {orientation = 0}
        
        if orientation == 0 {
            self.barHeight = AZSearchViewPref.searchBarPortraitHeight
            self.statusBarUnderlayHeightConstraint.constant = 20
        }else{
            self.barHeight = AZSearchViewPref.searchBarLandscapeHeight
            self.statusBarUnderlayHeightConstraint.constant = 0
        }
        
        let animations: ()-> Void = {
            if orientation == 0 {
                self.searchBarOffset = UIOffset(horizontal: 0, vertical: AZSearchViewPref.searchBarPortraitOffset)
            }else{
                self.searchBarOffset = UIOffset(horizontal: 0, vertical: AZSearchViewPref.searchBarLandscapeOffset)
            }
            
            self.tableView.contentInset = UIEdgeInsets(top: self.barHeight, left: 0, bottom: self.tableView.contentInset.bottom, right: 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: self.barHeight, left: 0, bottom: self.tableView.scrollIndicatorInsets.bottom, right: 0)
        }
        
        if  !self.didAppear {
            animations()
            self.didAppear = true
        }else{
            UIView.animate(withDuration: AZSearchViewPref.animationDuration, animations: {
                animations()
                self.view.layoutIfNeeded()
            })
        }
        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        var orientation = 0
        if UIDevice.current.orientation.isLandscape {
            orientation = 1
        } else {
            orientation = 0
        }
        coordinator.animate(alongsideTransition: { (context) in
            
            }) { (context) in
                if orientation == 0 {
                    self.barHeight = AZSearchViewPref.searchBarPortraitHeight
                    self.statusBarUnderlayHeightConstraint.constant = 20
                }else{
                    self.barHeight = AZSearchViewPref.searchBarLandscapeHeight
                    self.statusBarUnderlayHeightConstraint.constant = 0
                }
                
                UIView.animate(withDuration: AZSearchViewPref.animationDuration, animations: {
                    if orientation == 0 {
                        self.searchBarOffset = UIOffset(horizontal: 0, vertical: AZSearchViewPref.searchBarPortraitOffset)
                    }else{
                        self.searchBarOffset = UIOffset(horizontal: 0, vertical: AZSearchViewPref.searchBarLandscapeOffset)
                    }
                    
                    self.tableView.contentInset = UIEdgeInsets(top: self.barHeight, left: 0, bottom: self.tableView.contentInset.bottom, right: 0)
                    self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: self.barHeight, left: 0, bottom: self.tableView.scrollIndicatorInsets.bottom, right: 0)
                    
                    self.view.layoutIfNeeded()
                })
                
        }
        
    }
    
    fileprivate func setup(){
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationCapturesStatusBarAppearance = true
        self.searchBar = UISearchBar()
        if ((self.view) != nil){}
    }
    
    ///reloadData - refreshes the UITableView. If the data source function `results()` contains 0 index, the table view will be hidden.
    open func reloadData(){
        if self.dataSource.results().count > 0 {
            tableView.isHidden = false
        }else{
            tableView.isHidden = true
        }
        self.tableView.reloadData()
    }
    
    //MARK: - Selectors
    
    func didTapBackground(sender: AnyObject?){
        self.dismiss(animated: true, completion: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        guard let kbSizeValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        guard let kbDurationNumber = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        animateToKeyboardHeight(kbHeight: kbSizeValue.cgRectValue.height, duration: kbDurationNumber.doubleValue)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        guard let kbDurationNumber = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        animateToKeyboardHeight(kbHeight: 0, duration: kbDurationNumber.doubleValue)
    }
    
    func animateToKeyboardHeight(kbHeight: CGFloat, duration: Double) {
        tableView.contentInset = UIEdgeInsets(top: tableView.contentInset.top, left: 0, bottom: kbHeight, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: tableView.contentInset.top, left: 0, bottom: kbHeight, right: 0)
    }
    
}

//MARK: - UIGestureRecognizerDelegate

extension AZSearchViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: self.tableView))!{
            return false
        }
        return true
    }
}

//MARK: - UITableViewDelegate

extension AZSearchViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.didSelectResult(at: indexPath.row, text: dataSource.results()[indexPath.row])
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UITableViewDataSource

extension AZSearchViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.results().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = self.dataSource.results()[indexPath.row]
        return cell!
    }
}

//MARK: - UISearchBarDelegate

extension AZSearchViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.delegate.didTextChange(toText: searchBar.text!, textLength: searchBar.text!.characters.count)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.delegate.didSearch(forText: searchBar.text!)
    }
}

