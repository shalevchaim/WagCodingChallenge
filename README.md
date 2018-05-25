# WagCodingChallenge

[Original Code Challenge](https://github.com/melvinmt/ios-challenge)

## Notes:

The ViewController is the main file that does all the heavy lifting

The Item class is the object that holds the info for each item in the array returned from the JSON response.

CustomTableViewCell is a reusable cell used in the table view.

Core Data was used to save the images offline. Used two attributes: profile_img is the binary data which is converted to a UIImage, and profile_src which is the url that points to the image. profile_src is used as a key to indicate whether the image has been saved or not.
