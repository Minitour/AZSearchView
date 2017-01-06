# AZSearchView
A search controller with auto-complete suggestions written in Swift 3.

<img src="screenshots/gif1.gif"  height="400" /> <img src="screenshots/gif2.gif"  height="400" />

##Usage

Create a property of type ```AZSearchViewController``` and a String array to hold the data.
```swift
    var searchController: AZSearchViewController!
    var resultArray:[String] = []
```

Implement the delegate and data source protocols:
```swift
extension ViewController: AZSearchViewDelegate{
    
    func didSearch(forText text: String) {
        searchController.dismiss(animated: false, completion: nil)
    }
    
    func didTextChange(toText text: String, textLength: Int) {
        
        //update your resultArray here
        
        //finally reload the data
        self.searchController.reloadData()
    }
    
    func didSelectResult(at index: Int, text: String) {
        //dismiss the controller once user selects somethings
        self.searchController.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: AZSearchViewDataSource{
    
    func results() -> [String] {
        return self.resultArray
    }
}
```

Now initialize the controller object:
```swift
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchController = AZSearchViewController()
        self.searchController.delegate = self
        self.searchController.dataSource = self
    }
```

And finally present when needed:

```swift
self.present(searchController, animated: true, completion: nil)
```

##Customizations

Default Vs. Customized

<img src="screenshots/default.png"  height="400" />
<img src="screenshots/customized.png"  height="400" />

```swift
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
```

You can also configure with the following constants:

```swift
struct AZSearchViewPref{
    
    //The background color of the controller, default is black with 60% opacity
    static let backgroundColor: UIColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
   
    //The search bar background color, default is a light grey color
    static let searchBarColor: UIColor = UIColor(colorLiteralRed: 0.86, green: 0.86, blue: 0.86, alpha: 1)
    
    /*I recommended not to modify any of these values*/
    
    static let searchBarPortraitHeight:CGFloat = 64
    
    static let searchBarLandscapeHeight:CGFloat = 32
    
    static let searchBarPortraitOffset:CGFloat = 10
    
    static let searchBarLandscapeOffset:CGFloat = 0
    
    //The animation duration after rotating from portrait to landscape.
    static let animationDuration = 0.3

}

```

