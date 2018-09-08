# ShiftViewController

![](https://img.shields.io/badge/version-1.0.0-blue.svg)

<!--
[![CI Status](https://img.shields.io/travis/daviwiki/ShiftViewController.svg?style=flat)](https://travis-ci.org/daviwiki/ShiftViewController)
[![Version](https://img.shields.io/cocoapods/v/ShiftViewController.svg?style=flat)](https://cocoapods.org/pods/ShiftViewController)
[![License](https://img.shields.io/cocoapods/l/ShiftViewController.svg?style=flat)](https://cocoapods.org/pods/ShiftViewController)
[![Platform](https://img.shields.io/cocoapods/p/ShiftViewController.svg?style=flat)](https://cocoapods.org/pods/ShiftViewController)
-->

### What you will see ...
<img src ="./readme/example.gif" width="300">

## Installation

ShiftViewController is available through my private repository at github so, if you want to install in this way you must include this into your Podfile

```ruby
source 'https://github.com/daviwiki/daviwiki-podspecs'
``` 

Once included you could import the Pod into your desired spec.

```ruby
pod 'ShiftViewController'
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation and Usage of the code example include

Once you have installed the Pod (or cloning the code o whatever you need :) ... **how could i use this tool?**. Lets see this point by point:

##### 1. Create the cell (or cells) that we want to display

For our example we used *nib* for creating and inflating the cells so we create two files:

 - [BeautifulPlacesShiftCell.swift](./Example/ShiftViewController/Cells/BeautifulPlacesShiftCell.swift)
 - [BeautifulPlacesShiftCell.xib](./Example/ShiftViewController/Cells/BeautifulPlacesShiftCell.xib)
 
```swift
class BeautifulPlacesShiftCell: ShiftCardViewCell {
    // Here all the code you need for your cell
}
```

Feel free to customize the *UI* your cell as you want. 

**Note:** I need to study the problems if you install another PanGesture that could crash with the local installed.

##### 2. Instantiate and include the *ShiftViewController*

Once your cell is created you need to create the ShiftViewController (that present the cells) and add it to your view tree.

For the next code, we assume that the ShiftViewController will be included inside another [UIViewController](./Example/ShiftViewController/Presentation/ViewController.swift).

```swift
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.view.viewDidLoad()
    }
    
    private func mountShiftViewController() {
        // We perform a little margin beetwen the card stack and my controller
        let width = view.bounds.width * 0.8
        let height = view.bounds.height * 0.8
        let x = (view.bounds.width - width) / 2
        let y = (view.bounds.height - height) / 2
        let frame = CGRect(x: x, y: y, width: width, height: height)
    
        // Create and include the ShiftViewController
        let shiftVC = ShiftCardViewController()
        addChildViewController(shiftVC)
        shiftVC.view.frame = frame
        shiftVC.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(shiftVC.view)
        didMove(toParentViewController: shiftVC)
    
        // Provide a datasource for the ShiftViewController
        shiftVC.dataSource = self
    }
}
```

##### 3. Load and inflate the items we want

But ... damn it! the code not compile, I need to implement ShiftCardViewDataSource

```swift
extension ViewController: ShiftCardViewDataSource {
    
    func noMoreCardsView(shiftController: ShiftCardViewController) -> UIView? {
        return nil
    }
    
    func numberOfCards(shiftController: ShiftCardViewController) -> Int {
        return places.count
    }
    
    func card(shiftController: ShiftCardViewController, forItemAtIndex index: Int) -> ShiftCardViewCell {
        let nib = UINib(nibName: "BeautifulPlacesShiftCell", bundle: Bundle.main)
        let cell = nib.instantiate(withOwner: nil, options: nil).first as! BeautifulPlacesShiftCell
        cell.show(location: places[index])
        return cell
    }
}
```

Note that **places** variable is feed by the presenter and represent a set of fake locations composed by a {name, country, and url} fields

##### 4. \[Optional\] Include a empty view

Oh! I haven't got any card or all the cards have been presented ... Could you present a default view? Yes, here's the way:

At first create your custom view as you want:
```swift
class EmptyView: UIView {

    weak var viewController: ViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTap(gesture:)))
        self.addGestureRecognizer(gesture)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func onTap(gesture: UITapGestureRecognizer) {
        viewController?.reloadData()
    }
}
```

and now modify the data source to provide it:

```swift
extension ViewController: ShiftCardViewDataSource {
    
    func noMoreCardsView(shiftController: ShiftCardViewController) -> UIView? {
        let emtpyView = EmptyView(frame: .zero)
        emtpyView.viewController = self
        return emtpyView
    }
    
    ...
}
```

##### 5. \[Optional\] I want to customize my cell during scrolling!

Damn that was pretty cool (it will?) but i want to customize the cell when the user is dragging. 🤔 ok, lets try this:

Come back to your cell and override the following methods: 

```swift
    override func cellPanShift(with percent: CGFloat, andDirection direction: ShiftCardDirection?) {
        // This method is called each time user drag it finger accros the screen. 
        // percent -> represents the percent of distance from initial point in range [0, 1]
        // direction -> represents the direction of the drag. Note: When nil we cant assume a valid direction (user touches multiple timer, gesture is cancelled for any reason).  
    }

    override func cellReset(animationDuration: Double) {
        // This method is called when the cell wants to recover it initial state. You could restore your cell here
    }
```

## Author

daviwiki, daviddvd19@gmail.com

## Thanks

Specially thanks to Phill Farrugia's [article](https://medium.com/@phillfarrugia/building-a-tinder-esque-card-interface-5afa63c6d3db) that allow me to build this piece

## License

ShiftViewController is available under the MIT license. See the LICENSE file for more info.
