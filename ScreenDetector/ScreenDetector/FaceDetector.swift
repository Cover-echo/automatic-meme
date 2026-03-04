import Vision
import UIKit
import AVFoundation

/// 人脸检测结果
struct FaceDetectionResult {
    /// 是否检测到人脸
    var hasFace: Bool = false
    /// 眼睛是否睁开 (0-1)
    var eyesOpen: Float = 0.0
    /// 视线方向 (0=看屏幕，1=视线偏离)
    var gazeAway: Float = 0.0
    /// 人脸边界框
    var faceBoundingBox: CGRect?
}

/// 人脸检测器 - 使用 Vision 框架进行人脸和眼睛检测
class FaceDetector {
    
    // MARK: - Properties
    
    /// 检测序列号，用于取消旧请求
    private var requestSequenceNumber = 0
    
    /// 最小人脸尺寸阈值 (0-1)，小于此尺寸的人脸会被忽略
    var minFaceSize: Float = 0.1
    
    /// 眼睛睁开阈值
    var eyesOpenThreshold: Float = 0.3
    
    /// 视线偏离阈值
    var gazeAwayThreshold: Float = 0.5
    
    // MARK: - Public Methods
    
    /// 处理视频帧并检测人脸
    func detectFace(in sampleBuffer: CMSampleBuffer, completion: @escaping (FaceDetectionResult) -> Void) {
        requestSequenceNumber += 1
        let currentSequence = requestSequenceNumber
        
        // 创建人脸矩形检测请求
        let faceRectRequest = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let self = self else { return }
            
            // 如果这是旧的请求，忽略结果
            guard currentSequence == self.requestSequenceNumber else { return }
            
            if let error = error {
                print("人脸检测错误：\(error.localizedDescription)")
                completion(FaceDetectionResult())
                return
            }
            
            guard let results = request.results as? [VNFaceObservation],
                  let face = results.first else {
                completion(FaceDetectionResult())
                return
            }
            
            // 检查人脸尺寸
            if face.boundingBox.width < self.minFaceSize || face.boundingBox.height < self.minFaceSize {
                completion(FaceDetectionResult(hasFace: false))
                return
            }
            
            // 创建人脸特征点检测请求
            let landmarksRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
                guard let self = self else { return }
                guard currentSequence == self.requestSequenceNumber else { return }
                
                if let error = error {
                    print("特征点检测错误：\(error.localizedDescription)")
                    completion(FaceDetectionResult(hasFace: true))
                    return
                }
                
                var result = FaceDetectionResult(
                    hasFace: true,
                    faceBoundingBox: self.convertFaceBoundingBox(face.boundingBox)
                )
                
                // 分析眼睛状态
                if let landmarks = request.results?.first?.landmarks {
                    result.eyesOpen = self.analyzeEyesOpen(landmarks)
                    result.gazeAway = self.analyzeGazeDirection(landmarks)
                }
                
                completion(result)
            }
            
            // 执行特征点检测
            let handler = VNImageRequestHandler(cvPixelBuffer: self.getPixelBuffer(from: sampleBuffer), orientation: .rightMirrored)
            do {
                try handler.perform([landmarksRequest])
            } catch {
                print("执行特征点检测失败：\(error.localizedDescription)")
                completion(FaceDetectionResult(hasFace: true))
            }
        }
        
        // 执行人脸矩形检测
        let handler = VNImageRequestHandler(cvPixelBuffer: getPixelBuffer(from: sampleBuffer), orientation: .rightMirrored)
        do {
            try handler.perform([faceRectRequest])
        } catch {
            print("执行人脸检测失败：\(error.localizedDescription)")
            completion(FaceDetectionResult())
        }
    }
    
    // MARK: - Private Methods
    
    /// 从 SampleBuffer 获取 PixelBuffer
    private func getPixelBuffer(from sampleBuffer: CMSampleBuffer) -> CVPixelBuffer {
        return CMSampleBufferGetImageBuffer(sampleBuffer)!
    }
    
    /// 转换人脸边界框坐标 (Vision 坐标系 -> UIKit 坐标系)
    private func convertFaceBoundingBox(_ rect: CGRect) -> CGRect {
        return CGRect(
            x: rect.origin.x,
            y: 1 - rect.origin.y - rect.height,
            width: rect.width,
            height: rect.height
        )
    }
    
    /// 分析眼睛睁开程度
    private func analyzeEyesOpen(_ landmarks: VNFaceLandmarks2D) -> Float {
        var eyesOpenScore: Float = 1.0
        
        // 检测左眼
        if let leftEye = landmarks.leftEye {
            eyesOpenScore = min(eyesOpenScore, calculateEyeOpenScore(from: leftEye))
        }
        
        // 检测右眼
        if let rightEye = landmarks.rightEye {
            eyesOpenScore = min(eyesOpenScore, calculateEyeOpenScore(from: rightEye))
        }
        
        return eyesOpenScore
    }
    
    /// 计算单只眼睛的睁开分数
    private func calculateEyeOpenScore(from eye: VNFaceLandmarkRegion2D) -> Float {
        let points = eye.normalizedPoints
        
        guard points.count >= 6 else { return 1.0 }
        
        // 计算眼睛的垂直高度 (上下眼睑距离)
        let topLid = points[1]  // 上眼睑中点
        let bottomLid = points[5]  // 下眼睑中点
        let eyeHeight = abs(topLid.y - bottomLid.y)
        
        // 计算眼睛的水平宽度
        let leftCorner = points[0]  // 左眼角
        let rightCorner = points[3]  // 右眼角
        let eyeWidth = abs(rightCorner.x - leftCorner.x)
        
        // 计算高宽比
        guard eyeWidth > 0 else { return 1.0 }
        let aspectRatio = eyeHeight / eyeWidth
        
        // 正常睁眼的宽高比约为 0.3-0.4，闭眼时接近 0
        // 归一化到 0-1 范围
        let normalizedScore = min(aspectRatio / 0.35, 1.0)
        
        return Float(normalizedScore)
    }
    
    /// 分析视线方向
    private func analyzeGazeDirection(_ landmarks: VNFaceLandmarks2D) -> Float {
        // 简化实现：通过人脸旋转角度估算视线方向
        // 更精确的实现需要瞳孔追踪
        
        guard let faceContour = landmarks.faceContour else { return 0.0 }
        
        let points = faceContour.normalizedPoints
        guard points.count >= 9 else { return 0.0 }
        
        // 获取人脸中心点
        let centerX = points.reduce(0) { $0 + $1.x } / Float(points.count)
        let centerY = points.reduce(0) { $0 + $1.y } / Float(points.count)
        
        // 获取鼻尖位置
        guard let nose = landmarks.nose, nose.normalizedPoints.count > 0 else { return 0.0 }
        let noseTip = nose.normalizedPoints[0]
        
        // 计算鼻尖相对于人脸中心的偏移
        let offsetX = noseTip.x - centerX
        
        // 偏移越大，视线偏离越明显
        let gazeScore = abs(offsetX) * 2.0  // 放大系数
        
        return min(Float(gazeScore), 1.0)
    }
}
