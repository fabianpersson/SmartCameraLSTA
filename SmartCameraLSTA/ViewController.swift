//
//  ViewController.swift
//  SmartCameraLSTA
//
//  Created by Fabian Persson on 2018-04-18.
//  Copyright © 2018 mealmatch. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //here is where we start up the camera
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        
       
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoqueue"))
        captureSession.addOutput(dataOutput)
       
        //VNImageRequestHandler(cgImage: CGImage, options: [:]).perform(requests: [VNRequest])
        
    }
    
    //called every time the camera cathces a frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        print("camera was able to capture a frame", Date())
        
        guard let pixelBuffer: CVPixelBuffer =
            CMSampleBufferGetImageBuffer(sampleBuffer) else {
                return
        }
      
        
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else { return }
        
       
        
        
        let request = VNCoreMLRequest(model: model)
        { (finishedReq,err) in
            //print("hallå")
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
        
            guard let firstObservation = results.first else { return }
            print(firstObservation.identifier, firstObservation.confidence)
        
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                              options: [:]).perform([request])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

