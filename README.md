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

    func numberOfItems(in photoViewer: PhotoViewerController) -> Int {
        // provide the number of items to display.
    }

    func numberOfActions(in photoViewer: PhotoViewerController, forItemAt index: Int) -> Int {
        // provide the number of actions for an item diplayed at index in photoViewer.
    }

    func photoViewer(_ photoViewer: PhotoViewerController, imageView: UIImageView, at index: Int) {
        // customize the imageView provided for an item to display at index in photoViewer.
    }

    func photoViewer(_ photoViewer: PhotoViewerController, topBarLeftItemsAt index: Int) -> [UIBarButtonItem] {
        // provide an array of left top bar items for the the item to display at index.
    }

    func photoViewer(_ photoViewer: PhotoViewerController, topBarRightItemsAt index: Int) -> [UIBarButtonItem] {
        // provide an array of right top bar items for the the item to display at index.
    }

    func photoViewer(_ photoViewer: PhotoViewerController, actionBarButton button: UIButton, at position: Int, forItemAt index: Int) {
        // customize the provided action button at position for an item to display at index in photoViewer.
    }

    func photoViewer(_ photoViewer: PhotoViewerController, titleForItemAt index: Int) -> String {
        // provide a title for an item to display at index in photoViewer.
    }

    func photoViewer(_ photoViewer: PhotoViewerController, captionForItemAt index: Int) -> String {
        // provide a caption text for an item to display at index in photoViewer.
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

Botirjon Nasridinov, botirjon.nasridinov@gmail.com

## License

PhotoViewerController is available under the MIT license. See the LICENSE file for more info.
