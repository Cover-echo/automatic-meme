import UIKit
import AVFoundation

/// 主视图控制器
class ViewController: UIViewController {
    
    // MARK: - Properties
    
    private let cameraManager = CameraManager.shared
    private let faceDetector = FaceDetector()
    private let focusTracker = FocusTracker()
    private let statsManager = StatsManager()
    
    private var previewView: UIView!
    private var statusView: StatusView!
    private var statsView: StatsView!
    private var controlView: UIView!
    private var startButton: UIButton!
    private var stopButton: UIButton!
    private var settingsButton: UIButton!
    private var resetButton: UIButton!
    
    private var isRunning = false
    private var detectionTimer: Timer?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCallbacks()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopDetection()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // 预览视图
        previewView = UIView()
        previewView.backgroundColor = .black
        previewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewView)
        
        // 状态视图
        statusView = StatusView()
        statusView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusView)
        
        // 统计视图
        statsView = StatsView()
        statsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statsView)
        
        // 控制视图
        controlView = UIView()
        controlView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlView)
        
        // 开始按钮
        startButton = createButton(title: "开始检测", backgroundColor: .systemGreen)
        startButton.addTarget(self, action: #selector(startDetectionTapped), for: .touchUpInside)
        controlView.addSubview(startButton)
        
        // 停止按钮
        stopButton = createButton(title: "停止检测", backgroundColor: .systemRed)
        stopButton.addTarget(self, action: #selector(stopDetectionTapped), for: .touchUpInside)
        stopButton.isEnabled = false
        controlView.addSubview(stopButton)
        
        // 设置按钮
        settingsButton = createButton(title: "设置", backgroundColor: .systemBlue)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        controlView.addSubview(settingsButton)
        
        // 重置按钮
        resetButton = createButton(title: "重置统计", backgroundColor: .systemGray)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        controlView.addSubview(resetButton)
        
        // 布局约束
        NSLayoutConstraint.activate([
            // 预览视图
            previewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            // 状态视图
            statusView.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: 20),
            statusView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            statusView.heightAnchor.constraint(equalToConstant: 180),
            
            // 统计视图
            statsView.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 20),
            statsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statsView.heightAnchor.constraint(equalToConstant: 160),
            
            // 控制视图
            controlView.topAnchor.constraint(equalTo: statsView.bottomAnchor, constant: 20),
            controlView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            controlView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            controlView.heightAnchor.constraint(equalToConstant: 60),
            controlView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // 按钮布局
        let buttonWidth: CGFloat = (view.bounds.width - 60) / 2 - 5
        NSLayoutConstraint.activate([
            startButton.leadingAnchor.constraint(equalTo: controlView.leadingAnchor),
            startButton.centerYAnchor.constraint(equalTo: controlView.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            startButton.heightAnchor.constraint(equalToConstant: 44),
            
            stopButton.trailingAnchor.constraint(equalTo: controlView.trailingAnchor),
            stopButton.centerYAnchor.constraint(equalTo: controlView.centerYAnchor),
            stopButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            stopButton.heightAnchor.constraint(equalToConstant: 44),
            
            settingsButton.leadingAnchor.constraint(equalTo: controlView.leadingAnchor),
            settingsButton.topAnchor.constraint(equalTo: controlView.bottomAnchor, constant: 10),
            settingsButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            settingsButton.heightAnchor.constraint(equalToConstant: 44),
            
            resetButton.trailingAnchor.constraint(equalTo: controlView.trailingAnchor),
            resetButton.topAnchor.constraint(equalTo: controlView.bottomAnchor, constant: 10),
            resetButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            resetButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func createButton(title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func setupCallbacks() {
        // 摄像头帧处理
        cameraManager.frameHandler = { [weak self] sampleBuffer in
            self?.processFrame(sampleBuffer)
        }
        
        // 专注状态变化
        focusTracker.onStateChanged = { [weak self] state in
            DispatchQueue.main.async {
                self?.statusView.updateState(state)
            }
        }
        
        // 分心提醒
        focusTracker.onDistractionAlert = { [weak self] in
            DispatchQueue.main.async {
                self?.showDistractionAlert()
            }
        }
        
        // 统计数据更新
        statsManager.onStatsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.statsView.updateStats(stats: self?.statsManager.stats ?? FocusStats())
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func startDetectionTapped() {
        // 请求摄像头权限
        cameraManager.requestPermission { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                // 启动摄像头
                if self.cameraManager.startCamera() {
                    // 设置预览层
                    self.cameraManager.setupPreviewLayer(on: self.previewView)
                    
                    // 开始检测
                    self.isRunning = true
                    self.startButton.isEnabled = false
                    self.stopButton.isEnabled = true
                    
                    // 启动定时器进行检测
                    self.detectionTimer = Timer.scheduledTimer(
                        timeInterval: 0.1,
                        target: self,
                        selector: #selector(self.performDetection),
                        userInfo: nil,
                        repeats: true
                    )
                    
                } else {
                    self.showAlert(title: "错误", message: "无法启动摄像头")
                }
            } else {
                self.showPermissionAlert()
            }
        }
    }
    
    @objc private func stopDetectionTapped() {
        stopDetection()
    }
    
    @objc private func settingsTapped() {
        showSettingsAlert()
    }
    
    @objc private func resetTapped() {
        let alert = UIAlertController(
            title: "重置统计",
            message: "确定要重置所有统计数据吗？",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "重置", style: .destructive) { [weak self] _ in
            self?.statsManager.reset()
            self?.focusTracker.reset()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func performDetection() {
        // 检测由 CameraManager 的 frameHandler 自动触发
    }
    
    // MARK: - Detection
    
    private func processFrame(_ sampleBuffer: CMSampleBuffer) {
        faceDetector.detectFace(in: sampleBuffer) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // 更新专注追踪器
                self.focusTracker.update(with: result)
                
                // 更新统计数据
                switch self.focusTracker.currentState {
                case .focused:
                    if self.statsManager.stats.currentFocusDuration == 0 {
                        self.statsManager.startFocusing()
                    }
                    
                case .distracted:
                    if self.statsManager.stats.currentFocusDuration > 0 {
                        self.statsManager.startDistracting()
                    }
                    
                case .noFace:
                    self.statsManager.focusLost()
                }
            }
        }
    }
    
    private func stopDetection() {
        detectionTimer?.invalidate()
        detectionTimer = nil
        
        cameraManager.stopCamera()
        
        // 移除预览层
        previewView.layer.sublayers?.removeAll()
        
        isRunning = false
        startButton.isEnabled = true
        stopButton.isEnabled = false
        
        statusView.updateState(.noFace)
    }
    
    // MARK: - Alerts
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "摄像头权限被拒绝",
            message: "请在设置中允许此应用访问摄像头，以便进行视线检测。",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "打开设置", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        present(alert, animated: true)
    }
    
    private func showDistractionAlert() {
        // 轻微震动提醒
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // 显示提示
        let alert = UIAlertController(
            title: "注意",
            message: "您已离开屏幕超过 3 秒，请保持专注！",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "好的", style: .default))
        
        present(alert, animated: true)
    }
    
    private func showSettingsAlert() {
        let alert = UIAlertController(
            title: "检测设置",
            message: "当前设置:\n\n视线离开提醒阈值：\(Int(focusTracker.distractionThreshold)) 秒\n最小人脸尺寸：\(Int(faceDetector.minFaceSize * 100))%",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "提醒阈值 (秒)"
            textField.keyboardType = .numberPad
            textField.text = String(Int(self.focusTracker.distractionThreshold))
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "保存", style: .default) { [weak self] _ in
            guard let self = self,
                  let text = alert.textFields?.first?.text,
                  let value = Int(text), value > 0 else { return }
            
            self.focusTracker.distractionThreshold = TimeInterval(value)
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .default))
        present(alert, animated: true)
    }
}
