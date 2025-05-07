import SwiftUI

struct MainView: View {
    @StateObject private var deviceManager = DeviceManager()
    @State private var showAlert = false
    @State private var showAddWireless = false // 新增：控制弹窗显示
    @State private var wirelessIP = ""         // 新增：输入框内容

    var body: some View {
        VStack {
            HStack {
                Button("测试") {
                    showAlert = true
                }
                Button("手动刷新") {
                    deviceManager.startDeviceDiscovery()
                }
                Button("添加无线设备") { // 新增按钮
                    showAddWireless = true
                }
            }
            .padding(.bottom, 10)
            if deviceManager.connectedDevices.isEmpty {
                Text("未检测到设备")
                    .font(.title)
                    .foregroundColor(.gray)
            } else {
                List(deviceManager.connectedDevices) { device in
                    Button(action: {
                        deviceManager.connectToDevice(device)
                    }) {
                        HStack {
                            Text(device.name)
                            Spacer()
                            Text(device.connectionType == .usb ? "USB" : "无线")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            deviceManager.startDeviceDiscovery()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("测试成功"), message: Text("按钮点击已响应"), dismissButton: .default(Text("确定")))
        }
        .sheet(isPresented: $showAddWireless) { // 新增弹窗
            VStack {
                Text("请输入无线投屏IP")
                TextField("如 192.168.1.100:5555", text: $wirelessIP)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("添加") {
                    deviceManager.addWirelessDevice(ip: wirelessIP)
                    showAddWireless = false
                    wirelessIP = ""
                }
                Button("取消") {
                    showAddWireless = false
                    wirelessIP = ""
                }
            }
            .padding()
        }
    }
}