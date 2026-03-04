import Foundation

/// 专注统计数据
struct FocusStats {
    /// 总专注时长 (秒)
    var totalFocusedTime: TimeInterval = 0
    /// 总离开时长 (秒)
    var totalDistractedTime: TimeInterval = 0
    /// 离开次数
    var distractionCount: Int = 0
    /// 专注率 (0-100)
    var focusRate: Double {
        let totalTime = totalFocusedTime + totalDistractedTime
        guard totalTime > 0 else { return 0 }
        return (totalFocusedTime / totalTime) * 100
    }
    /// 平均专注时长 (秒)
    var averageFocusDuration: TimeInterval {
        guard distractionCount > 0 else { return totalFocusedTime }
        return totalFocusedTime / Double(distractionCount)
    }
    /// 最长专注时长 (秒)
    var longestFocusDuration: TimeInterval = 0
    /// 当前专注时长 (秒)
    var currentFocusDuration: TimeInterval = 0
}

/// 统计数据管理器
class StatsManager {
    
    // MARK: - Properties
    
    /// 当前统计数据
    private(set) var stats = FocusStats()
    
    /// 当前专注开始时间
    private var currentFocusStart: Date?
    
    /// 当前离开开始时间
    private var currentDistractedStart: Date?
    
    /// 数据变化回调
    var onStatsUpdated: (() -> Void)?
    
    // MARK: - Public Methods
    
    /// 开始专注
    func startFocusing() {
        currentFocusStart = Date()
        currentDistractedStart = nil
    }
    
    /// 开始分心
    func startDistracting() {
        // 结束当前专注
        if let focusStart = currentFocusStart {
            let duration = Date().timeIntervalSince(focusStart)
            stats.totalFocusedTime += duration
            stats.currentFocusDuration = duration
            
            if duration > stats.longestFocusDuration {
                stats.longestFocusDuration = duration
            }
        }
        
        currentDistractedStart = Date()
        currentFocusStart = nil
        stats.distractionCount += 1
        
        onStatsUpdated?()
    }
    
    /// 专注状态结束 (人脸丢失)
    func focusLost() {
        // 结束当前专注
        if let focusStart = currentFocusStart {
            let duration = Date().timeIntervalSince(focusStart)
            stats.totalFocusedTime += duration
            stats.currentFocusDuration = duration
            
            if duration > stats.longestFocusDuration {
                stats.longestFocusDuration = duration
            }
        }
        
        currentFocusStart = nil
        currentDistractedStart = nil
        stats.currentFocusDuration = 0
        
        onStatsUpdated?()
    }
    
    /// 离开状态结束
    func distractionEnded() {
        // 结束当前离开
        if let distractedStart = currentDistractedStart {
            let duration = Date().timeIntervalSince(distractedStart)
            stats.totalDistractedTime += duration
        }
        
        currentDistractedStart = nil
        
        onStatsUpdated?()
    }
    
    /// 重置统计数据
    func reset() {
        stats = FocusStats()
        currentFocusStart = nil
        currentDistractedStart = nil
        onStatsUpdated?()
    }
    
    /// 获取格式化后的专注时长
    func formattedFocusedTime() -> String {
        return formatTime(stats.totalFocusedTime)
    }
    
    /// 获取格式化后的离开次数
    func formattedDistractionCount() -> String {
        return "\(stats.distractionCount) 次"
    }
    
    /// 获取格式化后的专注率
    func formattedFocusRate() -> String {
        return String(format: "%.1f%%", stats.focusRate)
    }
    
    /// 获取格式化后的平均专注时长
    func formattedAverageFocusDuration() -> String {
        return formatTime(stats.averageFocusDuration)
    }
    
    /// 获取格式化后的最长专注时长
    func formattedLongestFocusDuration() -> String {
        return formatTime(stats.longestFocusDuration)
    }
    
    // MARK: - Private Methods
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d分%d秒", minutes, secs)
    }
}
