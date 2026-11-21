import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui as Ui

Ui.BarWidget {
    id: root

    moduleName: "nivagator.clipboard-mpv"

    property bool mpvRunning: false

    readonly property string helperPath: decodeURIComponent(
        Qt.resolvedUrl("clipboard-mpv.sh").toString().replace(/^file:\/\//, "")
    )

    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    function runAction(action) {
        Quickshell.execDetached(["bash", root.helperPath, action])
    }

    Process {
        id: statusProcess

        command: ["bash", root.helperPath, "status"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.mpvRunning = this.text.trim() === "running"
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true

        onTriggered: {
            if (!statusProcess.running)
                statusProcess.running = true
        }
    }

    Ui.WidgetButton {
        id: button

        anchors.fill: parent
        bar: root.bar

        text: "\uf16a"
        foreground: root.mpvRunning ? "#ff0000" : "#ffffff"

        tooltipText: "Clipboard MPV\n"
            + "Left: play video (up to 1080p)\n"
            + "Middle: play audio only\n"
            + "Right: stop all your mpv players"

        onPressed: function(buttonCode) {
            if (buttonCode === Qt.LeftButton)
                root.runAction("video")
            else if (buttonCode === Qt.MiddleButton)
                root.runAction("audio")
            else if (buttonCode === Qt.RightButton)
                root.runAction("stop")
        }
    }
}
