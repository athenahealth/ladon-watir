# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Added
- `Ladon::Watir::BrowserAutomation` to represent an automation that uses a
  browser.
  - Supports both local and remote (Selenium grid) browsers.
  - `#screenshot` method to record a screenshot in the result.
- `Ladon::Watir::Browser` to represent the browser itself.
  - Using `watir` 6.0+.
- `Ladon::Watir::PageObjectState` to represent a page in a web application.
  - Using `page-object` 2.0+.
  - Supports accessors defined at both the class and "instance" (singleton
    class) level
- `Ladon::Watir::WebAppFiniteStateMachine` to represent the web application.
