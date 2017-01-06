//
//  ViewController.swift
//  AZSearchViewController
//
//  Created by Antonio Zaitoun on 04/01/2017.
//  Copyright © 2017 Antonio Zaitoun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var resultArray:[String] = []
    
    var searchController:AZSearchViewController!
    
    @IBAction func click(_ sender: UIBarButtonItem) {
        self.present(searchController, animated: true, completion: nil)
    }
    
    
    func close(sender:AnyObject?){
        searchController.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchController = AZSearchViewController()
        self.searchController.delegate = self
        self.searchController.dataSource = self
        self.searchController.searchBarPlaceHolder = "Search Top Artists"
        self.searchController.navigationBar.barTintColor = #colorLiteral(red: 0.9019607843, green: 0.2235294118, blue: 0.4, alpha: 1)
        self.searchController.statusBarUnderlayOpacity = 0.10
        self.searchController.navigationBar.tintColor = UIColor.lightGray
        self.searchController.searchBarBackgroundColor = .white
        self.searchController.statusBarStyle = .lightContent
        self.searchController.keyboardAppearnce = .dark
        let item = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(ViewController.close(sender:)))
        item.tintColor = .white
        self.searchController.navigationItem.rightBarButtonItem = item
        

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pushWithTitle(text: String){
        let controller = UIViewController()
        controller.title = text
        controller.view.backgroundColor = UIColor.white
        self.navigationController?.pushViewController(controller, animated: true)
    }

}

extension ViewController: AZSearchViewDelegate{
    
    func didSearch(forText text: String) {
        searchController.dismiss(animated: false, completion: nil)
    }
    
    func didTextChange(toText text: String, textLength: Int) {
        self.resultArray.removeAll()
        
        if textLength > 3 {
            for i in 0..<arc4random_uniform(10)+1 {self.resultArray.append("\(text) \(i+1)")}
        }
        
        self.searchController.reloadData()
    }
    
    func didSelectResult(at index: Int, text: String) {
        self.searchController.dismiss(animated: true, completion: {
            self.pushWithTitle(text: text)
        })
        
        
        
    }
}

extension ViewController: AZSearchViewDataSource{
    
    func results() -> [String] {
        return self.resultArray
    }
    
}

