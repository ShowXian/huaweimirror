import Foundation

class DeviceManager: ObservableObject {
    @Published var connectedDevices: [Device] = []
    private var timer: Timer? // 新增定时器属性

    struct Device: Identifiable {
        let id: String
        let name: String
        let connectionType: ConnectionType
    }

    enum ConnectionType {
        case usb
        case wireless
    }

    func startDeviceDiscovery() {
        print("开始通过adb devices发现设备...")
        let adbPath = "/opt/homebrew/bin/adb" // <-- update this line
        guard FileManager.default.fileExists(atPath: adbPath) else {
            print("错误: 未找到adb工具，请先安装Android SDK")
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: adbPath)
        process.arguments = ["devices"]

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                print("ADB设备列表：\n\(output)")
                let lines = output.components(separatedBy: "\n")
                var devices: [Device] = []
                for line in lines {
                    if line.contains("\tdevice") {
                        let parts = line.components(separatedBy: "\t")
                        if let id = parts.first {
                            let newDevice = Device(
                                id: id,
                                name: id,
                                connectionType: .usb
                            )
                            devices.append(newDevice)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.connectedDevices = devices
                }
            }
        } catch {
            print("adb devices 执行错误: \(error.localizedDescription)")
        }
    }

    func startAutoRefresh(interval: TimeInterval = 3.0) {
        // 启动定时器，每隔 interval 秒刷新一次设备列表
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.startDeviceDiscovery()
        }
        // 立即刷新一次
        startDeviceDiscovery()
    }

    func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
    }

    func connectToDevice(_ device: Device) {
        print("正在连接设备: \(device.name)")
        startMirroring(device)
    }

    private func startMirroring(_ device: Device) {
        print("准备启动scrcpy，设备ID: \(device.id)")
        let scrcpyPath = "/opt/homebrew/bin/scrcpy" // 修改为你的实际路径
        if !FileManager.default.fileExists(atPath: scrcpyPath) {
            print("scrcpy 未找到，请检查路径")
            return
        }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: scrcpyPath)
        process.arguments = ["--serial", device.id, "--no-audio"]
        do {
            try process.run()
            print("scrcpy 已启动")
        } catch {
            print("镜像错误: \(error.localizedDescription)")
        }
    }

    func addWirelessDevice(ip: String) {
        let id = ip.contains(":") ? ip : "\(ip):5555"
        // 自动执行 adb connect
        let adbPath = "/opt/homebrew/bin/adb"
        guard FileManager.default.fileExists(atPath: adbPath) else {
            print("错误: 未找到adb工具，请先安装Android SDK")
            return
        }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: adbPath)
        process.arguments = ["connect", id]
        let pipe = Pipe()
        process.standardOutput = pipe
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                print("adb connect 输出：\(output)")
                if output.contains("connected") || output.contains("already connected") {
                    let newDevice = Device(id: id, name: id, connectionType: .wireless)
                    DispatchQueue.main.async {
                        self.connectedDevices.append(newDevice)
                    }
                } else {
                    print("adb connect 失败，请检查IP和手机设置")
                }
            }
        } catch {
            print("adb connect 执行错误: \(error.localizedDescription)")
        }
    }
}