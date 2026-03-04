import UIKit

/// 统计视图 - 显示专注统计数据
class StatsView: UIView {
    
    // MARK: - Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "专注统计"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let focusedTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let distractedCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let focusRateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let averageDurationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let longestDurationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        addSubview(titleLabel)
        addSubview(focusedTimeLabel)
        addSubview(distractedCountLabel)
        addSubview(focusRateLabel)
        addSubview(averageDurationLabel)
        addSubview(longestDurationLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            focusedTimeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            focusedTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            focusedTimeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            distractedCountLabel.topAnchor.constraint(equalTo: focusedTimeLabel.bottomAnchor, constant: 8),
            distractedCountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            distractedCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            focusRateLabel.topAnchor.constraint(equalTo: distractedCountLabel.bottomAnchor, constant: 8),
            focusRateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            focusRateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            averageDurationLabel.topAnchor.constraint(equalTo: focusRateLabel.bottomAnchor, constant: 8),
            averageDurationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            averageDurationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            longestDurationLabel.topAnchor.constraint(equalTo: averageDurationLabel.bottomAnchor, constant: 8),
            longestDurationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            longestDurationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            longestDurationLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
        
        updateStats()
    }
    
    // MARK: - Public Methods
    
    /// 更新统计数据显示
    func updateStats(stats: FocusStats = FocusStats()) {
        focusedTimeLabel.text = "专注时长：\(formatTime(stats.totalFocusedTime))"
        distractedCountLabel.text = "离开次数：\(stats.distractionCount) 次"
        focusRateLabel.text = "专注率：\(String(format: "%.1f", stats.focusRate))%"
        averageDurationLabel.text = "平均专注：\(formatTime(stats.averageFocusDuration))"
        longestDurationLabel.text = "最长专注：\(formatTime(stats.longestFocusDuration))"
    }
    
    // MARK: - Private Methods
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d分%d秒", minutes, secs)
    }
}
