华为手机鸿蒙系统，在mac上投屏
本地运行，打开USB调试模式
adb tcpip 5555
open /huaweimirror/Sources/HuaweiMirror.app

adb connect 手机IP:5555

查看列表
adb devices

