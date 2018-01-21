# PhotoViewerController

[![CI Status](http://img.shields.io/travis/botirjon.nasridinov@gmail.com/PhotoViewerController.svg?style=flat)](https://travis-ci.org/botirjon.nasridinov@gmail.com/PhotoViewerController)
[![Version](https://img.shields.io/cocoapods/v/PhotoViewerController.svg?style=flat)](http://cocoapods.org/pods/PhotoViewerController)
[![License](https://img.shields.io/cocoapods/l/PhotoViewerController.svg?style=flat)](http://cocoapods.org/pods/PhotoViewerController)
[![Platform](https://img.shields.io/cocoapods/p/PhotoViewerController.svg?style=flat)](http://cocoapods.org/pods/PhotoViewerController)

## Example

To be able to use the library, you need to first install the pod. Then import the PhotoViewerController into your project:
```ruby
import PhotoViewerController
```
Then initliaze a PhotoViewerController object, set its delegate, initial item index. To get the desired behaviour set its modalPresentationStyle to .overFullScreen.

Example:

```ruby
let photoViewer = PhotoViewerController()
photoViewer?.delegate = self
photoViewer?.initialItemIndex = 3
photoViewer?.modalPresentationStyle = .overFullScreen
```

You should also implement its delegate functions:

Example:

```ruby
extension ViewController: PhotoViewerControllerDelegate{

    func photoViewer(imageView: UIImageView, at index: Int) {
        // configure the image view for item at the given index
    }

    func numberOfItems() -> Int {
        // return number of items to be displayed
    }

    func topBarLeftItems(forItemAt index: Int) -> [UIBarButtonItem] {
        // provide an array of left bar button item for top bar
    }

    func topBarRightItems(forItemAt index: Int) -> [UIBarButtonItem] {
        // provide an array of right bar button item for top bar
    }

    func numberOfActions(forItemAt index: Int) -> Int {
        // return number of actions you want apply on the item at the given index
    }

    func actionBar(button: UIButton, at position: Int) {
        // configure the button at the given position for the item at index
    }

    func title(forItemAt index: Int) -> String {
        // give title for the item at the given index
    }

    func caption(forItemAt index: Int) -> String {
        // return caption for the item at the given index
    }
}
```
After this you are all set to present the photoViewer:

```ruby
self.present(photoViewer!, animated: true, completion: nil)
```


## Requirements

## Installation

PhotoViewerController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PhotoViewerController'
```

## Author

botirjon.nasridinov@gmail.com, botirjon.nasridinov@gmail.com

## License

PhotoViewerController is available under the MIT license. See the LICENSE file for more info.
