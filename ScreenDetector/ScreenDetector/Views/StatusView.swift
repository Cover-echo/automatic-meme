import UIKit

/// 状态指示视图 - 显示当前专注状态
class StatusView: UIView {
    
    // MARK: - Properties
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusIndicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 50
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        backgroundColor = .clear
        
        addSubview(statusIndicator)
        addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            statusIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            statusIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            statusIndicator.widthAnchor.constraint(equalToConstant: 100),
            statusIndicator.heightAnchor.constraint(equalToConstant: 100),
            
            statusLabel.topAnchor.constraint(equalTo: statusIndicator.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        // 初始状态
        updateState(.noFace)
    }
    
    // MARK: - Public Methods
    
    /// 更新状态显示
    func updateState(_ state: FocusState) {
        switch state {
        case .focused:
            statusIndicator.backgroundColor = UIColor.systemGreen
            statusIndicator.layer.shadowColor = UIColor.systemGreen.cgColor
            statusIndicator.layer.shadowOffset = CGSize(width: 0, height: 0)
            statusIndicator.layer.shadowOpacity = 0.6
            statusIndicator.layer.shadowRadius = 10
            statusLabel.text = "专注中"
            
        case .distracted:
            statusIndicator.backgroundColor = UIColor.systemRed
            statusIndicator.layer.shadowColor = UIColor.systemRed.cgColor
            statusIndicator.layer.shadowOffset = CGSize(width: 0, height: 0)
            statusIndicator.layer.shadowOpacity = 0.6
            statusIndicator.layer.shadowRadius = 10
            statusLabel.text = "视线离开"
            
        case .noFace:
            statusIndicator.backgroundColor = UIColor.systemGray
            statusIndicator.layer.shadowColor = UIColor.clear.cgColor
            statusIndicator.layer.shadowOffset = .zero
            statusIndicator.layer.shadowOpacity = 0
            statusIndicator.layer.shadowRadius = 0
            statusLabel.text = "未检测到人脸"
        }
        
        // 添加脉冲动画
        addPulseAnimation()
    }
    
    // MARK: - Animation
    
    private func addPulseAnimation() {
        statusIndicator.layer.removeAnimation(forKey: "pulse")
        
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1.0
        animation.toValue = 1.1
        animation.duration = 1.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        statusIndicator.layer.add(animation, forKey: "pulse")
    }
}
