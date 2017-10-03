// 
//

import AVFoundation
import UIKit
import Vision
import TesseractOCR

class CameraViewController: UIViewController , AVCapturePhotoCaptureDelegate {
    
    
    private var cameraView: AVCaptureVideoPreviewLayer!
    private var camera: AVCaptureDevice!
    private var cameraInput: AVCaptureDeviceInput!
    private var cameraOutput: AVCapturePhotoOutput! = AVCapturePhotoOutput()
    private var photoSampleBuffer: CMSampleBuffer?
    private var previewPhotoSampleBuffer: CMSampleBuffer?
    private var photoData: Data? = nil
    
    private let cameraSession = AVCaptureSession()
    
    var capturedImage : UIImage? = nil
    
    var agent : Agent? = nil
    var scannerdText : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        agent = Agent.sharedInstance
        // Do any additional setup after loading the view, typically from a nib.
        tesseract?.pageSegmentationMode = .sparseText
        tesseract?.charWhitelist = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890()-+*!/?.,@#$%&"
        if isAuthorized() {
            configureTextDetection()
            configureCamera()
        }
    }
    
    
    @IBAction func capturePhoto(_ sender: Any) {
        
        cameraSession.stopRunning()
        cameraSession.beginConfiguration()
        cameraSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        
        let device : AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: device)
            
            
            if cameraSession.canAddInput(captureDeviceInput) {
                cameraSession.addInput(captureDeviceInput)
            }
            
            
        }
        catch {
            print("Error occured \(error)")
            return
        }
        
        
        if(device.isFocusModeSupported(.continuousAutoFocus)) {
            try! device.lockForConfiguration()
            device.focusMode = .continuousAutoFocus
            device.unlockForConfiguration()
        }
        
        
        cameraSession.addOutput(cameraOutput)
        cameraSession.commitConfiguration()
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .on
        photoSettings.isHighResolutionPhotoEnabled = true
        
        if photoSettings.__availablePreviewPhotoPixelFormatTypes.count > 0 {
            photoSettings.previewPhotoFormat = [ kCVPixelBufferPixelFormatTypeKey as String : photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
            
        }
        
        cameraSession.startRunning()
        print("go this")
        cameraOutput.isHighResolutionCaptureEnabled = true
        cameraOutput.capturePhoto(with: photoSettings, delegate: self)
        print("go that")
    }
    
    
    
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        print("go threee ")
        
        if let error = error {
            print("error occure : \(error.localizedDescription)")
        }
        
        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            
            // print(UIImage(data: dataImage)?.size as Any)
            
            
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
            
            capturedImage = image
            
            
            agent?.setScannedlist(list: self.scannerdText)
            agent?.capImage(captured :  capturedImage!  )
            self.dismiss(animated: false, completion: nil)
            
        } else {
            print("some error here")
        }
    }
    
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    //
    //    func ciimageFromSampleBuffer(sampleBuffer : CMSampleBuffer) -> CIImage
    //    {
    //        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
    //        let cameraImage = CIImage(cvImageBuffer: imageBuffer!  )
    //        return cameraImage
    //    }
    //
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureTextDetection() {
        textDetectionRequest = VNDetectTextRectanglesRequest(completionHandler: handleDetection)
        textDetectionRequest!.reportCharacterBoxes = true
    }
    
    
    func configureCamera() {
        
        preview.session = session
        
        let cameraDevices =  AVCaptureDevice.DiscoverySession.init(deviceTypes:  [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo  , position: .back)
        
        var cameraDevice: AVCaptureDevice?
        
        for device in (cameraDevices?.devices)! {
            if device.position == .back {
                cameraDevice = device
                break
            }
        }
        
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: cameraDevice!)
            if session.canAddInput(captureDeviceInput) {
                session.addInput(captureDeviceInput)
            }
        }
        catch {
            print("Error occured \(error)")
            return
        }
        
        session.sessionPreset = AVCaptureSessionPresetHigh
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue(label: "Buffer Queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil))
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        preview.videoPreviewLayer.videoGravity = AVLayerVideoGravityResize
        
        session.startRunning()
    }
    
    private func handleDetection(request: VNRequest, error: Error?) {
        
        guard let detectionResults = request.results else {
            print("No detection results")
            return
        }
        let textResults = detectionResults.map() {
            return $0 as? VNTextObservation
        }
        if textResults.isEmpty {
            return
        }
        textObservations = textResults as! [VNTextObservation]
        DispatchQueue.main.async {
            
            //            guard let sublayers = self.view.layer.sublayers else {
            guard let sublayers = self.preview.layer.sublayers else {
                return
            }
            for layer in sublayers[1...] {
                if (layer as? CATextLayer) == nil {
                    layer.removeFromSuperlayer()
                }
            }
            
            //let viewWidth = self.view.frame.size.width
            //let viewHeight = self.view.frame.size.height
            
            let viewWidth = self.preview.frame.size.width
            let viewHeight = self.preview.frame.size.height
            
            
            for result in textResults {
                
                if let textResult = result {
                    
                    let layer = CALayer()
                    var rect = textResult.boundingBox
                    rect.origin.x *= viewWidth
                    rect.size.height *= viewHeight
                    rect.origin.y = ((1 - rect.origin.y) * viewHeight) - rect.size.height
                    rect.size.width *= viewWidth
                    
                    layer.frame = rect
                    layer.borderWidth = 2
                    layer.borderColor = UIColor.red.cgColor
                    self.preview.layer.addSublayer(layer)
                }
            }
        }
    }
    
    @IBOutlet weak var preview: PreviewView!
    
    //    private var preview: PreviewView {
    //        return view as! PreviewView
    //    }
    
    //     var preview: PreviewView = PreviewView ()
    
    
    private func isAuthorized() -> Bool {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo,
                                          completionHandler: { (granted:Bool) -> Void in
                                            if granted {
                                                DispatchQueue.main.async {
                                                    self.configureTextDetection()
                                                    self.configureCamera()
                                                }
                                            }
            })
            return true
        case .authorized:
            return true
        case .denied, .restricted: return false
        }
    }
    var textDetectionRequest: VNDetectTextRectanglesRequest?
    let session = AVCaptureSession()
    var textObservations = [VNTextObservation]()
    var tesseract = G8Tesseract(language: "eng", engineMode: .tesseractOnly)
    //    tesseract.delegate = self;
    
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: - Camera Delegate and Setup
    public func captureOutput(_ output: AVCaptureOutput, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var imageRequestOptions = [VNImageOption: Any]()
        if let cameraData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            imageRequestOptions[.cameraIntrinsics] = cameraData
        }
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: imageRequestOptions)
        do {
            try imageRequestHandler.perform([textDetectionRequest!])
        }
        catch {
            print("Error occured \(error)")
        }
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        capturedImage = convert(cmage : ciImage)
        
        
        let transform = ciImage.orientationTransform(for: CGImagePropertyOrientation(rawValue: 6)!)
        ciImage = ciImage.applying(transform)
        let size = ciImage.extent.size
        var recognizedTextPositionTuples = [(rect: CGRect, text: String)]()
        scannerdText = []
        
        for textObservation in textObservations {
            guard let rects = textObservation.characterBoxes else {
                continue
            }
            var xMin = CGFloat.greatestFiniteMagnitude
            var xMax: CGFloat = 0
            var yMin = CGFloat.greatestFiniteMagnitude
            var yMax: CGFloat = 0
            for rect in rects {
                
                xMin = min(xMin, rect.bottomLeft.x)
                xMax = max(xMax, rect.bottomRight.x)
                yMin = min(yMin, rect.bottomRight.y)
                yMax = max(yMax, rect.topRight.y)
            }
            let imageRect = CGRect(x: xMin * size.width, y: yMin * size.height, width: (xMax - xMin) * size.width, height: (yMax - yMin) * size.height)
            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(ciImage, from: imageRect) else {
                continue
            }
            let uiImage = UIImage(cgImage: cgImage)
            tesseract?.image = uiImage
            tesseract?.recognize()
            guard var text = tesseract?.recognizedText else {
                continue
            }
            text = text.trimmingCharacters(in: CharacterSet.newlines)
            if !text.isEmpty {
                let x = xMin
                let y = 1 - yMax
                let width = xMax - xMin
                let height = yMax - yMin
                recognizedTextPositionTuples.append((rect: CGRect(x: x, y: y, width: width, height: height), text: text))
            }
        }
        textObservations.removeAll()
        DispatchQueue.main.async {
            let viewWidth = self.preview.frame.size.width
            let viewHeight = self.preview.frame.size.height
            guard let sublayers = self.preview.layer.sublayers else {
                return
            }
            
            for layer in sublayers[1...] {
                
                if let _ = layer as? CATextLayer {
                    layer.removeFromSuperlayer()
                }
            }
            
            for tuple in recognizedTextPositionTuples {
                let textLayer = CATextLayer()
                textLayer.backgroundColor = UIColor.clear.cgColor
                var rect = tuple.rect
                
                rect.origin.x *= viewWidth
                rect.size.width *= viewWidth
                rect.origin.y *= viewHeight
                rect.size.height *= viewHeight
                
                textLayer.frame = rect
                textLayer.string = tuple.text
                print("tuple.text \(tuple.text)")
                
                self.scannerdText.append(tuple.text)
                // textLayer.foregroundColor = UIColor.green.cgColor
                //self.view.layer.addSublayer(textLayer)
                //self.preview.layer.addSublayer(textLayer)
            }
        }
    }
}

