[![Build Status](https://travis-ci.org/Coiney/Plastic.svg?branch=master)](https://travis-ci.com/Coiney/Plastic)

_VISA, MasterCard, JCB, American Express, Diners Club, Discover and their logos are trademarks or registered trademarks of their respective owners._

# Plastic

A collection of credit card-related widgets for iOS apps.

![Example](.readme_images/sample.png "Sample")

## Overview

The Plastic framework contains the following UI components.

### CYCardBrandListView

`CYCardBrandListView` shows a list of card brands, useful for indicating which brands are accepted.  It can display any combination of Visa, MasterCard, JCB, American Express, Diners Club, and Discover logos.

### CYCardEntryView

`CYCardEntryView` facilitates entering a credit card number, expiration, and card verification code.

The card number is Luhn-checked, and the expiration is checked against the current date.  If either check fails, text is shown in red to indicate the error.

The CVC field accepts four digits for American Express, and three for other brands.

Once the user has entered their card number, expiration, and CVC, the embedding app is notified by a `CYCardEntryViewDelegate` method, at which point the credit card information can be obtained from the `CYCardEntryView` and sent over to a payment processor.

### CYKeypad

`CYKeypad` is a numeric keypad widget that can be used with `CYCardEntryView`.

## Usage

See the sample app in `Plastic.xcodeproj` for an example of how to add Plastic to your project.  The sample app demonstrates the functionality of all three widgets.

## Requirements

* Xcode 8
* iOS 8.0 and above
