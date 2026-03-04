import Foundation

/// 专注状态
enum FocusState {
    case focused      // 正在看屏幕
    case distracted   // 视线离开
    case noFace       // 未检测到人脸
}

/// 专注状态变化回调
typealias FocusStateHandler = (FocusState) -> Void

/// 专注追踪器 - 追踪用户专注状态
class FocusTracker {
    
    // MARK: - Properties
    
    /// 当前专注状态
    private(set) var currentState: FocusState = .noFace
    
    /// 视线离开持续时间 (秒)
    private var distractedDuration: TimeInterval = 0.0
    
    /// 专注开始时间
    private var focusStartTime: Date?
    
    /// 专注状态变化回调
    var onStateChanged: FocusStateHandler?
    
    /// 视线离开提醒阈值 (秒)
    var distractionThreshold: TimeInterval = 3.0
    
    /// 提醒回调
    var onDistractionAlert: (() -> Void)?
    
    /// 最小人脸置信度
    var minFaceConfidence: Float = 0.5
    
    // MARK: - Public Methods
    
    /// 更新检测结果
    func update(with result: FaceDetectionResult) {
        let newState: FocusState
        
        if !result.hasFace {
            newState = .noFace
        } else if result.eyesOpen < 0.3 || result.gazeAway > 0.5 {
            newState = .distracted
        } else {
            newState = .focused
        }
        
        // 状态变化处理
        if newState != currentState {
            let oldState = currentState
            currentState = newState
            
            // 处理状态转换
            handleStateTransition(from: oldState, to: newState)
            
            // 通知状态变化
            onStateChanged?(newState)
        } else {
            // 状态未变化，更新持续时间
            if newState == .distracted {
                distractedDuration += 0.1  // 假设每 0.1 秒更新一次
                
                // 检查是否超过提醒阈值
                if distractedDuration >= distractionThreshold {
                    onDistractionAlert?()
                    // 重置计时器，避免连续提醒
                    distractedDuration = 0
                }
            } else if newState == .focused {
                distractedDuration = 0
            }
        }
    }
    
    /// 重置追踪器
    func reset() {
        currentState = .noFace
        distractedDuration = 0
        focusStartTime = nil
    }
    
    /// 获取专注时长 (秒)
    func getFocusedDuration() -> TimeInterval {
        guard let startTime = focusStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    // MARK: - Private Methods
    
    private func handleStateTransition(from oldState: FocusState, to newState: FocusState) {
        switch (oldState, newState) {
        case (_, .focused):
            // 开始专注
            if focusStartTime == nil {
                focusStartTime = Date()
            }
            distractedDuration = 0
            
        case (_, .distracted):
            // 开始分心
            distractedDuration = 0
            
        case (_, .noFace):
            // 人脸丢失
            if oldState == .focused {
                focusStartTime = nil
            }
            distractedDuration = 0
            
        default:
            break
        }
    }
}
