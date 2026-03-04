import AVFoundation
import UIKit

/// 摄像头管理器 - 负责摄像头的初始化和视频帧捕获
class CameraManager: NSObject {
    
    // MARK: - Properties
    
    static let shared = CameraManager()
    
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    /// 视频帧回调闭包
    var frameHandler: ((CMSampleBuffer) -> Void)?
    
    /// 摄像头权限状态
    var isAuthorized = false
    
    // MARK: - Public Methods
    
    /// 请求摄像头权限
    func requestPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            completion(true)
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    completion(granted)
                }
            }
            
        case .denied, .restricted:
            isAuthorized = false
            completion(false)
            
        @unknown default:
            isAuthorized = false
            completion(false)
        }
    }
    
    /// 设置摄像头预览层
    func setupPreviewLayer(on view: UIView) -> AVCaptureVideoPreviewLayer? {
        guard let session = captureSession else { return nil }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        
        view.layer.addSublayer(previewLayer!)
        
        return previewLayer
    }
    
    /// 更新预览层 frame
    func updatePreviewLayerBounds(for view: UIView) {
        previewLayer?.frame = view.bounds
    }
    
    /// 启动摄像头
    func startCamera() -> Bool {
        guard isAuthorized else { return false }
        
        // 如果已经在运行，先停止
        stopCamera()
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high
        
        // 获取前置摄像头
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("无法获取前置摄像头")
            return false
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            
            if captureSession?.canAddInput(input) == true {
                captureSession?.addInput(input)
            } else {
                print("无法添加摄像头输入")
                return false
            }
            
            // 设置视频输出
            videoOutput = AVCaptureVideoDataOutput()
            videoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue", qos: .userInteractive))
            videoOutput?.alwaysDiscardsLateVideoFrames = true
            
            if captureSession?.canAddOutput(videoOutput!) == true {
                captureSession?.addOutput(videoOutput!)
            } else {
                print("无法添加视频输出")
                return false
            }
            
            // 设置视频方向
            if let connection = videoOutput?.connection(with: .video) {
                if frontCamera.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
            }
            
            captureSession?.startRunning()
            return true
            
        } catch {
            print("摄像头启动错误：\(error.localizedDescription)")
            return false
        }
    }
    
    /// 停止摄像头
    func stopCamera() {
        captureSession?.stopRunning()
        captureSession = nil
        videoOutput = nil
    }
    
    /// 检查摄像头是否可用
    func isCameraAvailable() -> Bool {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) != nil
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        frameHandler?(sampleBuffer)
    }
}
