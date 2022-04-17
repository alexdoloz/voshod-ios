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
    
    @IBAction func sendBigArray(_ sender: Any) {
        let plugin = vm?.plugins.first(where: { $0 is MyAwesomePlugin })!
        
        let currentTime = Double(clock()) / Double(CLOCKS_PER_SEC)
        let message: [String: LuaSendable] = [
            "array": array,
            "time": currentTime
        ]
        let sum = try! plugin?.send(
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
        let plugin = vm?.plugins.first(where: { $0 is MyAwesomePlugin })!
        
        let currentTime = Double(clock()) / Double(CLOCKS_PER_SEC)
        
        try! plugin?.send(
            message: [
                "string": string,
                "time": currentTime
            ],
            to: vm!
        )
    }
    
    let string = (0...10_000_000).map { String($0) }.joined(separator: "|")
    let array = Array(0...10_000_000) as [LuaSendable]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vm = try! VM(pluginTypes: [MyAwesomePlugin.self])
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
            receivedCount = receivedCount + 1
            --print("Received", message)
            local start = message.time
            local now = os.clock()
            print("Elapsed ", now - start)
            local array = message.array
            if not array then return end
            local sum = 0
            for i = 1, #array do
                sum = sum + array[i]
            end
            return {
                sum = sum,
                time = now
            }
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
    
    static var version: Version = Version(string: "1.1.0")
    
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
