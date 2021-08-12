//
//  CameraVC.swift
//  Foodle
//
//  Created by Anton Vlezko on 10.08.2021.
//

import UIKit
import ARKit

class CameraVC: UIViewController {
    // MARK: - Properties
    
    let barTitle: String = "Camera"
    var vegetableName: String?
    var image: UIImage?
    var imagesDataStore: ImagesDataStore?
    
    lazy var recognitionRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: MLModel())
            let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                guard let self = self else { return }
                self.classificationProcess(for: request, error: error)
            }
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error.localizedDescription)")
        }
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()

    }
    
    // MARK: - Helper Functions
    
    func configureUI() {
        setupCamera()
        configureNavigationBar()
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = .systemBackground
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = UIColor.systemRed
        navigationItem.title = barTitle
    }
}

// MARK: - camera
extension CameraVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    private func setupCamera() {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let request = VNDetectFaceRectanglesRequest { req, err in
            if let err = err {
                debugPrint("error in \(#function) -->>>", err)
                return
            }
            
//            DispatchQueue.main.async {
//                if let results = req.results {
//                    self.numberOfFaces.text = "\(results.count) face(s)"
//                }
//            }
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            do {
                try handler.perform([request])
            } catch {
                debugPrint("failed to perform request in \(#function)")
            }
        }
    }
}
