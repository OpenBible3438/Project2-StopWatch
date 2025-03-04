//
//  ViewController.swift
//  StopwatchOfClock
//
//  Created by 최우태 on 2023/04/21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var lapTimeLabel: UILabel!       // 작은 글씨 시간 Label
    @IBOutlet weak var totalTimeLabel: UILabel!     // 큰 글씨 시간 Label
    
    @IBOutlet weak var leftButton: UIButton!        // Lap <-> Reset Button
    @IBOutlet weak var rightButton: UIButton!       // Start <-> Stop Button
    
    @IBOutlet weak var lapTableView: UITableView!
    
    var leftButtonState: ButtonState!
    var rightButtonState: ButtonState!
    
    var timer = Timer()
    var lapTimer = Timer()
    var lapMilliseconds = 0
    var milliseconds = 0
    
    var count = 0                                   // Timer 카운트
    var startTime: TimeInterval = 0                 // Timer 시작 시간
    var pauseTime: TimeInterval = 0                 // Timer 일시정지 시간
    var isTimerRunning = false                      // 타이머 동작 여부
    
    var lapArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lapTableView.dataSource = self
        
        setButton()
    }
    
    func setButton() {
        // 앱 실행 시 버튼 상태 설정
        rightButtonState = .start
        leftButtonState = .lap
        
        leftButton.setTitle("Lap", for: .normal)
        rightButton.setTitle("Start", for: .normal)
        rightButton.setTitleColor(.systemGreen, for: .normal)
        
        // Lap 버튼 비활성화
        leftButton.isEnabled = false
    }
    
    // 왼쪽 버튼 이벤트
    @IBAction func leftButtonTapped(_ sender: UIButton) {
        if leftButtonState == .reset {
            // 초기화
            milliseconds = 0
            lapMilliseconds = 0
            count = 0
            startTime = 0
            pauseTime = 0
            lapArray.removeAll()
            
            lapTimeLabel.text = "00:00.00"
            totalTimeLabel.text = "00:00.00"
            
            // Reset -> Lap
            leftButton.setTitle("Lap", for: .normal)
            leftButtonState = .lap
            leftButton.isEnabled = false
            
            lapTableView.reloadData()
            
        } else { // Lap
            // 기록 추가
            lapArray.append(lapTimeLabel.text!)
            
            // Lap 초기화
            lapMilliseconds = 0
            lapTimeLabel.text = "00:00.00"
            
            lapTableView.reloadData()
        }
    }
    
    // 오른쪽 버튼 이벤트
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        if rightButtonState == .start {
            // 상태 변경
            rightButtonState = .stop
            
            // 버튼 글자 변경
            rightButton.setTitle("Stop", for: .normal)
            rightButton.setTitleColor(.red, for: .normal)
            
            // Timer Start
            if isTimerRunning == false {
                startTime = Date.timeIntervalSinceReferenceDate - TimeInterval(count)
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTotalTimeLabel), userInfo: nil, repeats: true)
                lapTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateLapTimeLabel), userInfo: nil, repeats: true)
                isTimerRunning = true
                
                // leftButton Reset -> Lap 변경
                if leftButtonState == .reset {
                    leftButton.setTitle("Lap", for: .normal)
                    leftButtonState = .lap
                }
            }
            
            leftButton.isEnabled = true
            
        } else {
            // 상태 변경
            rightButtonState = .start
            
            // 버튼 글자 변경
            rightButton.setTitle("Start", for: .normal)
            rightButton.setTitleColor(.systemGreen, for: .normal)
            
            // Timer 일시정지
            if isTimerRunning == true {
                pauseTime = Date.timeIntervalSinceReferenceDate
                timer.invalidate()
                lapTimer.invalidate()
                isTimerRunning = false
                count = Int(pauseTime - startTime)
                
                // leftButton Lap -> Reset 변경
                leftButton.setTitle("Reset", for: .normal)
                leftButtonState = .reset
                
            }

        }
    }
    
    @objc func updateTotalTimeLabel() {
        milliseconds += 1
        let seconds = Double(milliseconds) / 100.0
        let minutes = Int(seconds / 60)
        totalTimeLabel.text = String(format: "%02d:%05.2f", minutes, seconds)
    }
    
    @objc func updateLapTimeLabel() {
        lapMilliseconds += 1
        let seconds = Double(lapMilliseconds) / 100.0
        let minutes = Int(seconds / 60)
        lapTimeLabel.text = String(format: "%02d:%05.2f", minutes, seconds)
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lapArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lapCell = lapTableView.dequeueReusableCell(withIdentifier: "LapTableViewCell", for: indexPath) as! LapTableViewCell
        lapCell.cellLapNumberLabel.text = "Lap \(lapArray.count - indexPath.row)"
        lapCell.cellLapTimeLabel.text = lapArray[lapArray.count - 1 - indexPath.row]
        return lapCell
    }
    
}

class LapTableViewCell: UITableViewCell {
    @IBOutlet weak var cellLapNumberLabel: UILabel!
    @IBOutlet weak var cellLapTimeLabel: UILabel!
}

enum ButtonState {
    case lap
    case reset
    case start
    case stop
}

