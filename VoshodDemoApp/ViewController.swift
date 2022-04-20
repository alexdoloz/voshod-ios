//
//  ViewController.swift
//  VoshodDemoApp
//
//  Created by Alexander Doloz on 12.04.2022.
//

import UIKit
import Voshod

class ViewController: UIViewController {
    var vm: VM?
    
    var plugin: Plugin {
        vm!.plugins.first(where: { $0 is MyAwesomePlugin })!
    }
    
    @IBAction func sendNestedValues(_ sender: Any) {
        let message: [String: LuaSendable] = [
            "a": "b",
            "c": 100,
            "d": LuaNil.nil,
            "e": ["a", "b", "c", 100],
            "f": ["a" : "b", "c" : "d"]
        ]
        let response = try! plugin.send(message: message, to: vm!)
        let dict = response as! [String: String]
        print(dict)
    }
    
    
    @IBAction func sendBigArray(_ sender: Any) {
        
        
        let currentTime = Double(clock()) / Double(CLOCKS_PER_SEC)
        let message: [String: LuaSendable] = [
            "array": array,
            "time": currentTime
        ]
        let sum = try! plugin.send(
            message: message,
            to: vm!
        )
        let sumDict = sum as! [String: Int]
        let timeFromScript = Double(sumDict["time"]!)
        let sumValue = Double(sumDict["sum"]!)
        
        let currentTime2 = Double(clock()) / Double(CLOCKS_PER_SEC)
        print("Got sum \(sumValue); elapsed time from script \(currentTime2 - timeFromScript)")
    }
    
    @IBAction func sendBigString(_ sender: Any) {
        let currentTime = Double(clock()) / Double(CLOCKS_PER_SEC)
        
        try! plugin.send(
            message: [
                "string": string,
                "time": currentTime
            ],
            to: vm!
        )
    }
    
    @IBAction func startTimer(_ sender: Any) {
        try! vm!.run(script: """
        import "Timer 0.1.0"
        local timer = Timer()
        timer:start(3.0, function ()
            print("Tick")
        end)
        """)
    }
    
    let string = (0...100).map { String($0) }.joined(separator: "|")
    let array = Array(0...100) as [LuaSendable]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vm = try! VM(pluginTypes: [MyAwesomePlugin.self, TimerPlugin.self])
        print(vm)
        self.vm = vm
        try! vm.run(script: """
        print("From demo app!")
        import "MyAwesomePlugin 1.1"
        print("rc", MyAwesome.getReceivedCount())
        MyAwesome.sendString("Hello from Lua!")
        """)
        
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
//        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc
    func tapped() {
        
    }
}

class MyAwesomePlugin: Voshod.Plugin {
    init(vm: VM) {
        self.vm = vm
    }
    
    var installerScript: String {
        """
        local plugin, environment = ...
        local receivedCount = 0
        
        function plugin:receive(message)
            if message.a then
                for k, v in pairs(message) do
                    print(k, v)
                end
            end
            return { x = "qwerty" }
        end
        
        local MyAwesome = {}
        
        function MyAwesome.getReceivedCount()
            return receivedCount
        end
        
        function MyAwesome.sendString(str)
            plugin:send(str)
        end
        
        environment.MyAwesome = MyAwesome
        """
    }
    
    var dependencies: [String] { [] }
    
    unowned var vm: VM
    
    static var dependencies: [Dependency] = []
    
    static var version: Version = Version("1.1.0")!
    
    static var name: String = "MyAwesomePlugin"
    
    static func provideInstance(for vm: VM, resolvedDependencies: [String : Plugin]) -> Plugin {
        return MyAwesomePlugin(vm: vm)
    }
    
    func receive(message: LuaReceivable, from vm: VM) -> LuaSendable {
        switch message {
        case let string as String:
            print("Received string from lua \(string)")
        default:
            print("Received message \(message)")
        }
        return LuaNil.nil
    }
}

final class TimerPlugin: Plugin {
    var installerScript: String {
        """
        local plugin, environment = ...
        
        function plugin:receive(message)
            if currentTimer then
                currentTimer.callback()
            end
        end
        
        currentTimer = nil
        
        function Timer()
            if currentTimer then return currentTimer end
        
            local timer = {}
            local timerMT = {
                __newindex = function () end,
                __gc = function (self)
                    self:stop()
                end
            }
            timerMT.__index = timerMT
        
            function timerMT:start(timeInterval, callback)
                timerMT.callback = callback
                timerMT.timeInterval = timeInterval
                plugin:send(timeInterval)
            end
            
            function timerMT:stop()
                plugin:send("stop")
                currentTimer = nil
            end
            
            setmetatable(timer, timerMT)
            currentTimer = timer
            return timer
        end
        
        environment.Timer = Timer
        """
    }
    
    var dependencies: [String] = []
    
    unowned var vm: VM
    
    static var dependencies: [Dependency] = []
    
    static var version: Version = Version("0.1.0")!
    
    static var name: String { "Timer" }
    
    init(vm: VM) {
        self.vm = vm
    }
    
    static func provideInstance(for vm: VM, resolvedDependencies: [String : Plugin]) -> Plugin {
        return TimerPlugin(vm: vm)
    }
    
    func receive(message: LuaReceivable, from vm: VM) -> LuaSendable {
        switch message {
        case let string as String where string == "stop":
            stopTimer()
        case let double as Double:
            startTimer(interval: double)
        case let int as Int:
            startTimer(interval: Double(int))
        default:
            break
        }
        return LuaNil.nil
    }
    
    private var timer: Timer?
    
    private func startTimer(interval: TimeInterval) {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [unowned self] _ in
            try! self.send(message: "tick", to: self.vm)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
