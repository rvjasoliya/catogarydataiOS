//
//  Extensions.swift
//  Sprig
//
//  Created by iMac on 30/12/21.
//

import UIKit
import Photos
import Foundation

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}

//MARK: UIViewController
extension UIViewController {
    
    func alertViewController(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "ok", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func add(_ child: UIViewController, frame: CGRect? = nil) {
        addChild(child)
        
        //        if let frame = frame {
        child.view.frame = child.view.bounds
        //        }
        
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
}

func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

//MARK: UIView
extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    //    @IBInspectable var dashBorder: Bool {
    //        get {
    //            return layer.shadowOpacity > 0.0
    //        }
    //        set {
    //            if newValue == true {
    //                self.setDashBorder()
    //            } else {
    //                layer.borderColor = UIColor.clear.cgColor
    //                layer.borderWidth = 0
    //            }
    //        }
    //    }
    
    func showBlurLoader() {
        let blurLoader = BlurLoader(frame: frame)
        self.addSubview(blurLoader)
    }
    
    func removeBluerLoader() {
        if let blurLoader = subviews.first(where: { $0 is BlurLoader }) {
            blurLoader.removeFromSuperview()
        }
    }
    
    func setBorder(width: CGFloat, color: UIColor){
        self.borderColor = color
        self.borderWidth = width
    }
    
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.5,
                   shadowRadius: CGFloat = 2.0) {
        //        layer.shadowColor = shadowColor
        //        layer.shadowOffset = shadowOffset
        //        layer.shadowOpacity = shadowOpacity
        //        layer.shadowRadius = shadowRadius
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 2.0
        //        self.translatesAutoresizingMaskIntoConstraints = false
        //        if cornerRadius != 0 {
        //            self.layer.masksToBounds = false
        //        } else{
        //            self.layer.masksToBounds = true
        //        }
    }
    
    func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.startPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.5, y: 0.0)
        self.layer.insertSublayer(gradient, at: 0)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 2.0
        self.clipsToBounds = true
        return gradient
    }
}

//MARK: UIImage
extension UIImage {
    func crop(toRect rect:CGRect) -> UIImage{
        let imageRef:CGImage = self.cgImage!.cropping(to: rect)!
        let cropped:UIImage = UIImage(cgImage:imageRef)
        return cropped
    }
    
    func resized(toWidth width: CGFloat) -> UIImage{
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func resized(toWidth width: CGFloat, toHeight height: CGFloat) -> UIImage{
        let canvasSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // MARK: - UIImage+Resize
    func compressTo(_ expectedSizeInMb:Int) -> UIImage? {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress:Bool = true
        var imgData:Data?
        var compressingValue:CGFloat = 0.5
        while (needCompress && compressingValue > 0.0) {
            if let data:Data = self.jpegData(compressionQuality: compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.1
                }
            }
        }
        
        if let data = imgData {
            if (data.count < sizeInBytes) {
                return UIImage(data: data)
            }
        }
        return nil
    }
    
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.4
        case high    = 0.75
        case highest = 1
    }
    
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
    
    convenience init?(withContentsOfUrl url: URL) throws {
        let imageData = try Data(contentsOf: url)
        
        self.init(data: imageData)
    }
    
}

//MARK: Array
extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}

//MARK: UIImage
extension UIImage {
    
    var getWidth: CGFloat {
        get {
            let width = self.size.width
            return width
        }
    }
    
    var getHeight: CGFloat {
        get {
            let height = self.size.height
            return height
        }
    }
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizedTo1MB() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
        let megaByte = 1000.0
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / megaByte // ! Or devide for 1024 if you need KB but not kB
        
        while imageSizeKB > megaByte { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resized(withPercentage: 0.5),
                  let imageData = resizedImage.pngData() else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / megaByte // ! Or devide for 1024 if you need KB but not kB
        }
        
        return resizingImage
    }
}

//MARK: UIColor
extension UIColor {
    
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
    
    convenience init(hexFromString:String, alpha:CGFloat = 1.0) {
        var cString:String = hexFromString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgbValue:UInt32 = 10066329 //color #999999 if string has wrong format
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) == 6) {
            Scanner(string: cString).scanHexInt32(&rgbValue)
        }
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

//MARK: UIImageView
extension UIImageView{
    func setImageFromURl(stringImageUrl url: String) -> UIImage?{
        var imagee: UIImage?
        if let url = NSURL(string: url) {
            if let data = NSData(contentsOf: url as URL) {
                imagee = UIImage(data: data as Data)
            }
        }
        return imagee
    }
}

//MARK: UITextField
extension UITextField {
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }
    
    @IBInspectable var paddingLeftCustom: CGFloat {
        get {
            return leftView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            leftView = paddingView
            leftViewMode = .always
        }
    }
    
    @IBInspectable var paddingRightCustom: CGFloat {
        get {
            return rightView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            rightView = paddingView
            rightViewMode = .always
        }
    }
}

//MARK: UITextView
extension UITextView :UITextViewDelegate {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder UILabel to this UITextView
     func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = self.text.count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
}

//MARK: UITableView
extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
    }
    
    func restore() {
        self.backgroundView = nil
    }
    
}

//MARK: UICollectionView
extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

//MARK: Date
extension Date {
    var formatted: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.string(from: self)
    }
    
    var MonthFormatted: String {
        let df = DateFormatter()
        df.dateFormat = "MMM yyyy"
        return df.string(from: self)
    }
    
    static var yesterday: Date { return Date().localDate().dayBefore }
    static var tomorrow:  Date { return Date().localDate().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    var day: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)!
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)!
        dateFormatter.dateFormat = "M"
        return dateFormatter.string(from: self)
    }
    var year: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)!
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
    }
    var hour: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)!
        dateFormatter.dateFormat = "hh"
        return dateFormatter.string(from: self)
    }
    var minute: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)!
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: self)
    }
    
    mutating func addDays(n: Int)
    {
        let cal = Calendar.current
        self = cal.date(byAdding: .day, value: n, to: self)!
    }
    
    func dayNameOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)!
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
    
    func getDayNameId() -> Int{
        let day = self.dayNameOfWeek()
        switch day {
        case "Sunday":
            return 1
        case "Monday":
            return 2
        case "Tuesday":
            return 3
        case "Wednesday":
            return 4
        case "Thursday":
            return 5
        case "Friday":
            return 6
        case "Saturday":
            return 7
        default:
            return 1
        }
    }
    
    func firstDayOfTheMonth() -> Date {
        return Calendar.current.date(from:
                                        Calendar.current.dateComponents([.year,.month], from: self))!
    }
    
    func getAllDays() -> [Date]
    {
        var days = [Date]()
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: self)!
        var day = firstDayOfTheMonth()
        for _ in 1...range.count
        {
            days.append(day)
            day.addDays(n: 1)
        }
        return days
    }
    
    func add(_ unit: Calendar.Component, value: Int) -> Date? {
        return Calendar.current.date(byAdding: unit, value: value, to: self)
    }
    
    func getFormattedDate2(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.calendar = Calendar.current
        dateformat.locale = Locale.current
        dateformat.timeZone = TimeZone(abbreviation: "UTC")
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
    
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
    
    func localDate() -> Date {
        //let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: self) else {return Date()}
        
        return localDate
    }
    
}

//MARK: Locale
extension Locale {
    static let currency: [String: (code: String?, symbol: String?, name: String?)] = isoRegionCodes.reduce(into: [:]) {
        let locale = Locale(identifier: identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: $1]))
        $0[$1] = (locale.currencyCode, locale.currencySymbol, locale.localizedString(forCurrencyCode: locale.currencyCode ?? ""))
    }
}

//MARK: UserDefaults
extension UserDefaults {
    func imageForKey(key: String) -> UIImage? {
        var image: UIImage?
        if let imageData = data(forKey: key) {
            image = NSKeyedUnarchiver.unarchiveObject(with: imageData) as? UIImage
        }
        return image
    }
    func setImage(image: UIImage?, forKey key: String) {
        var imageData: NSData?
        if let image = image {
            imageData = NSKeyedArchiver.archivedData(withRootObject: image) as NSData?
        }
        set(imageData, forKey: key)
    }
}

//MARK: UIFont
extension UIFont {
    
    func withTraits(traits:UIFontDescriptor.SymbolicTraits, size:CGFloat) -> UIFont? {
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return nil //size 0 means keep the size as it is
    }
    
    func bold(size:CGFloat) -> UIFont? {
        return withTraits(traits: .traitBold, size: size)
    }
    
    func italic(size:CGFloat) -> UIFont? {
        return withTraits(traits: .traitItalic, size: size)
    }
    
    func boldItalics(size:CGFloat) -> UIFont? {
        return withTraits(traits: [.traitBold, .traitItalic ], size: size)
    }
}

//MARK: UITextField
extension UITextField{
    
    //    @IBInspectable var doneAccessory: Bool{
    //        get{
    //            return self.doneAccessory
    //        }
    //        set (hasDone) {
    //            if hasDone{
    //                addDoneButtonOnKeyboard()
    //            }
    //        }
    //    }
    //
    //    func addDoneButtonOnKeyboard()
    //    {
    //        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    //        doneToolbar.barStyle = .default
    //
    //        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    //        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
    //
    //        let items = [flexSpace, done]
    //        doneToolbar.items = items
    //        doneToolbar.sizeToFit()
    //
    //        self.inputAccessoryView = doneToolbar
    //    }
    //
    //    @objc func doneButtonAction()
    //    {
    //        self.resignFirstResponder()
    //    }
}

//MARK: String
extension String {
    
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
    
    func encodeBase64() -> String {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return ""
    }
    
    func decodeBase64() -> String {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8) ?? ""
        }
        return ""
    }
    
    func contains(_ string: String, options: CompareOptions) -> Bool {
        return range(of: string, options: options) != nil
    }
    
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "%20")
    }
    
    func addSpace() -> String {
        return self.replace(string: "%20", replacement: " ")
    }
    
    func relativeDateFormatter() -> String {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .short
        relativeDateFormatter.dateStyle = .short
        relativeDateFormatter.locale = Locale(identifier: "en_GB")
        relativeDateFormatter.doesRelativeDateFormatting = true
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = inputFormatter.date(from: self) {
            return relativeDateFormatter.string(from: date)
        }
        return ""
    }
    
    
    var url:URL?{
        return URL(string: self)
    }
    
    var thumbnailImage:String {
        return "http://img.youtube.com/vi/\(self)/0.jpg"
    }
    
    var youtubeVideo: String {
        return "http://www.youtube.com/embed/\(self)"
    }
    
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
    
    func isValidPassword() -> Bool {
        // least one uppercase,
        // least one digit
        // least one lowercase
        // least one symbol
        //  min 8 characters total
        let password = self.trimmingCharacters(in: CharacterSet.whitespaces)
        let passwordRegx = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&<>*~:`-]).{8,}$"
        let passwordCheck = NSPredicate(format: "SELF MATCHES %@",passwordRegx)
        return passwordCheck.evaluate(with: password)
        
    }
    
    var getIDfromLink:String? {
        var result:String? = nil
        
        if let theURL = self.url {
            if theURL.host == "youtu.be" {
                result = theURL.pathComponents[1]
            } else if theURL.absoluteString.contains("www.youtube.com/embed") {
                result = theURL.pathComponents[2]
            } else if theURL.host == "youtube.googleapis.com" ||
                        theURL.pathComponents.first == "www.youtube.com" {
                result = theURL.pathComponents[2]
            }
            else {
                if ((theURL.query?.contains("v=")) == true) {
                    result = theURL.query?.replacingOccurrences(of: "v=", with: "")
                } else{
                    let urlComponents = URLComponents(url: theURL, resolvingAgainstBaseURL: false)
                    if ((urlComponents?.path.contains("/v/")) == true) {
                        result = urlComponents?.path.replacingOccurrences(of: "/v/", with: "")
                    }
                }
                //let _res = theURL.dictionaryForQueryString("v")
                //result = _res["v"] as? String
            }
        }
        return result
    }
    
    var isValidURL:Bool {
        if let _url = self.url {
            return _url.scheme != ""
        }
        return false
    }
    
    func addBaseURL(_ theURL:String) -> String {
        if self.isValidURL { return self }
        
        // No check for now, just prepending the base url as passed
        return theURL + self
    }
    
    var stringByDecodingURL:String {
        let result = self
            .replacingOccurrences(of: "+", with: " ")
            .removingPercentEncoding
        return result!
    }
    
    func toFormatedDate(from: String, to:String) -> String?{
        let dateFormatter = DateFormatter()
        //        dateFormatter.calendar = Calendar.current
        //        dateFormatter.locale = Locale.current
        //        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)!
        dateFormatter.dateFormat = from
        let date = dateFormatter.date(from: self)
        return date?.getFormattedDate2(format: to)
    }
    
    func toDate(withFormat format: String = "d/MM/yyyy")-> Date?{
        
        let dateFormatter = DateFormatter()
        //        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)!
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.locale = Locale.current
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date
        
    }
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
    
    func convertToTimeInterval() -> TimeInterval {
        guard self != "" else {
            return 0
        }
        var interval:Double = 0
        let parts = self.components(separatedBy: ":")
        for (index, part) in parts.reversed().enumerated() {
            interval += (Double(part) ?? 0) * pow(Double(60), Double(index))
        }
        return interval
    }
    
}

//MARK: BlurLoader
class BlurLoader: UIView {
    
    var blurEffectView: UIVisualEffectView?
    
    override init(frame: CGRect) {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView = blurEffectView
        super.init(frame: frame)
        addSubview(blurEffectView)
        addLoader()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addLoader() {
        guard let blurEffectView = blurEffectView else { return }
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        blurEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.center = blurEffectView.contentView.center
        activityIndicator.startAnimating()
    }
}

//MARK: DashedBorderView
class DashedBorderView: UIView {
    let borderLayer = CAShapeLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        //custom initialization
        applyDashBorder()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        applyDashBorder()
    }
    
    func applyDashBorder() {
        borderLayer.strokeColor = #colorLiteral(red: 0.5293717384, green: 0.5293846726, blue: 0.5293776989, alpha: 1)
        borderLayer.lineDashPattern = [2,2]
        borderLayer.frame = bounds
        borderLayer.fillColor = nil
        borderLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 5, height: 5)).cgPath
        layer.addSublayer(borderLayer)
    }
}

//MARK: UISwitch
extension UISwitch {
    
    static let standardHeight: CGFloat = 31
    static let standardWidth: CGFloat = 51
    
    @IBInspectable var width: CGFloat {
        set {
            set(width: newValue, height: height)
        }
        get {
            frame.width
        }
    }
    
    @IBInspectable var height: CGFloat {
        set {
            set(width: width, height: newValue)
        }
        get {
            frame.height
        }
    }
    
    func set(width: CGFloat, height: CGFloat) {
        
        let heightRatio = height / UISwitch.standardHeight
        let widthRatio = width / UISwitch.standardWidth
        
        transform = CGAffineTransform(scaleX: widthRatio, y: heightRatio)
    }
}

//MARK: UIDevice
extension UIDevice {
    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom > 0
        }
        return false
    }
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String {
#if os(iOS)
            switch identifier {
            case "iPhone1,1" : return "iPhone"
            case "iPhone1,2" : return "iPhone 3G"
            case "iPhone2,1" : return "iPhone 3GS"
            case "iPhone3,1" : return "iPhone 4"
            case "iPhone3,2" : return "iPhone 4 GSM Rev A"
            case "iPhone3,3" : return "iPhone 4 CDMA"
            case "iPhone4,1" : return "iPhone 4S"
            case "iPhone5,1" : return "iPhone 5 (GSM)"
            case "iPhone5,2" : return "iPhone 5 (GSM+CDMA)"
            case "iPhone5,3" : return "iPhone 5C (GSM)"
            case "iPhone5,4" : return "iPhone 5C (Global)"
            case "iPhone6,1" : return "iPhone 5S (GSM)"
            case "iPhone6,2" : return "iPhone 5S (Global)"
            case "iPhone7,1" : return "iPhone 6 Plus"
            case "iPhone7,2" : return "iPhone 6"
            case "iPhone8,1" : return "iPhone 6s"
            case "iPhone8,2" : return "iPhone 6s Plus"
            case "iPhone8,4" : return "iPhone SE (GSM)"
            case "iPhone9,1" : return "iPhone 7"
            case "iPhone9,2" : return "iPhone 7 Plus"
            case "iPhone9,3" : return "iPhone 7"
            case "iPhone9,4" : return "iPhone 7 Plus"
            case "iPhone10,1" : return "iPhone 8"
            case "iPhone10,2" : return "iPhone 8 Plus"
            case "iPhone10,3" : return "iPhone X Global"
            case "iPhone10,4" : return "iPhone 8"
            case "iPhone10,5" : return "iPhone 8 Plus"
            case "iPhone10,6" : return "iPhone X GSM"
            case "iPhone11,2" : return "iPhone XS"
            case "iPhone11,4" : return "iPhone XS Max"
            case "iPhone11,6" : return "iPhone XS Max Global"
            case "iPhone11,8" : return "iPhone XR"
            case "iPhone12,1" : return "iPhone 11"
            case "iPhone12,3" : return "iPhone 11 Pro"
            case "iPhone12,5" : return "iPhone 11 Pro Max"
            case "iPhone12,8" : return "iPhone SE 2nd Gen"
            case "iPhone13,1" : return "iPhone 12 Mini"
            case "iPhone13,2" : return "iPhone 12"
            case "iPhone13,3" : return "iPhone 12 Pro"
            case "iPhone13,4" : return "iPhone 12 Pro Max"
            case "iPhone14,2" : return "iPhone 13 Pro"
            case "iPhone14,3" : return "iPhone 13 Pro Max"
            case "iPhone14,4" : return "iPhone 13 Mini"
            case "iPhone14,5" : return "iPhone 13"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
#endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
}

//MARK: Array
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

//MARK: UITableViewCell
extension UITableViewCell {
    func selectedBackgroundView() {
        let view = UIView()
        view.backgroundColor = .clear
        self.selectedBackgroundView = view
    }
}

//MARK: UIButton
extension UIButton {
    @IBInspectable var letterSpacing: CGFloat {
        set {
            let attributedString: NSMutableAttributedString
            if let currentAttrString = attributedTitle(for: .normal) {
                attributedString = NSMutableAttributedString(attributedString: currentAttrString)
            }
            else {
                attributedString = NSMutableAttributedString(string: self.title(for: .normal) ?? "")
                setTitle(.none, for: .normal)
            }
            attributedString.addAttribute(NSAttributedString.Key.kern, value: newValue, range: NSRange(location: 0, length: attributedString.length))
            setAttributedTitle(attributedString, for: .normal)
        }
        get {
            if let currentLetterSpace = attributedTitle(for: .normal)?.attribute(NSAttributedString.Key.kern, at: 0, effectiveRange: .none) as? CGFloat {
                return currentLetterSpace
            }
            else {
                return 0
            }
        }
    }
}

//MARK: Double
extension Double {
    func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
        formatter.unitsStyle = style
        return formatter.string(from: self) ?? ""
    }
}

func randomKeyGenerates(length: Int) -> String {
    var result = ""
    let base36chars = [Character]("0123456789abcdefghijklmnopqrstuvwxyz")
    let maxBase : UInt32 = 48
    let minBase : UInt16 = 16
    
    for _ in 0..<length {
        let random = Int(arc4random_uniform(UInt32(min(minBase, UInt16(maxBase)))))
        result.append(base36chars[random])
    }
    return result
}
