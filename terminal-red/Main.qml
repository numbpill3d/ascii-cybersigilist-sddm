import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: container
    width: 1920
    height: 1080
    color: "#000000"

    property int sessionIndex: session.index

    // named roles (model.name, model.wayland) only resolve inside a Repeater
    // delegate context; this hidden store makes them available globally
    property var sessionNames: []
    property var sessionWaylands: []

    Item {
        id: sessionDataStore
        visible: false; width: 0; height: 0
        Repeater {
            model: sessionModel
            delegate: Item {
                width: 0; height: 0
                Component.onCompleted: {
                    var n = container.sessionNames.slice()
                    n[index] = model.name
                    container.sessionNames = n
                    var w = container.sessionWaylands.slice()
                    w[index] = model.wayland
                    container.sessionWaylands = w
                }
            }
        }
    }

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        onLoginSucceeded: {}
        onLoginFailed: {
            password.text = ""
            errorMessage.visible = true
            errorTimer.restart()
        }
    }

    Timer {
        id: errorTimer
        interval: 3000
        onTriggered: errorMessage.visible = false
    }

    // ── left marquee — scrolls down ───────────────────────────────────────────
    // poem: одиночество / loneliness in russian + japanese, one glyph per line
    Rectangle {
        id: leftMarqueeWrap
        x: 0; y: 0
        width: 16
        height: parent.height
        color: "#000000"
        clip: true
        z: 0

        property string poem:
            "я\nо\nд\nи\nн\nа\n·\nт\nи\nш\nи\nн\nа\n·\n" +
            "п\nу\nс\nт\nо\nт\nа\n·\nт\nе\nн\nь\n·\n" +
            "м\nо\nл\nч\nу\n·\nн\nо\n·\nо\nт\nв\nе\nт\n·\nн\nе\nт\n·\n" +
            "孤\n独\nの\n·\n夜\nに\n·\n声\nは\nな\nい\n·\n" +
            "暗\nく\nて\n·\n一\n人\n·\n忘\nれ\nた\n·\n" +
            "時\nの\n·\n静\nけ\nさ\n·\n虚\nし\nい\n·\n" +
            "│\n│\n·\n│\n│\n·\n"

        Text {
            id: leftText
            width: parent.width
            text: leftMarqueeWrap.poem + leftMarqueeWrap.poem
            color: "#620000"
            font.family: "Monospace"
            font.pixelSize: 13
            lineHeight: 1.15
            horizontalAlignment: Text.AlignHCenter

            SequentialAnimation {
                id: leftAnim
                running: false
                loops: Animation.Infinite
                NumberAnimation {
                    id: leftStep
                    target: leftText
                    property: "y"
                    to: 0
                    duration: 28000
                    easing.type: Easing.Linear
                }
                ScriptAction {
                    script: leftText.y = -(leftText.height / 2)
                }
            }

            Component.onCompleted: {
                leftText.y = -(leftText.height / 2)
                leftStep.from = -(leftText.height / 2)
                leftAnim.start()
            }
        }
    }

    // ── right marquee — scrolls up ────────────────────────────────────────────
    // poem: кричу в темноте / screaming in the dark — russian + japanese
    Rectangle {
        id: rightMarqueeWrap
        x: parent.width - 16; y: 0
        width: 16
        height: parent.height
        color: "#000000"
        clip: true
        z: 0

        property string poem:
            "к\nр\nи\nч\nу\n·\nв\n·\nт\nе\nм\nн\nо\nт\nе\n·\n" +
            "н\nо\n·\nм\nо\nл\nч\nа\nн\nи\nе\n·\nн\nе\nт\n·\n" +
            "с\nл\nо\nв\n·\nн\nе\nт\n·\nм\nе\nс\nт\nа\n·\n" +
            "誰\nも\nい\nな\nい\n·\n消\nえ\nた\n·\n" +
            "夢\nの\nよ\nう\nに\n·\n残\nる\nは\n·\n" +
            "影\nだ\nけ\n·\n何\nも\n·\n変\nわ\nら\nな\nい\n·\n" +
            "│\n│\n·\n│\n│\n·\n"

        Text {
            id: rightText
            width: parent.width
            text: rightMarqueeWrap.poem + rightMarqueeWrap.poem
            color: "#420000"
            font.family: "Monospace"
            font.pixelSize: 13
            lineHeight: 1.15
            horizontalAlignment: Text.AlignHCenter

            SequentialAnimation {
                id: rightAnim
                running: false
                loops: Animation.Infinite
                NumberAnimation {
                    id: rightStep
                    target: rightText
                    property: "y"
                    from: 0
                    to: 0
                    duration: 35000
                    easing.type: Easing.Linear
                }
                ScriptAction {
                    script: rightText.y = 0
                }
            }

            Component.onCompleted: {
                rightText.y = 0
                rightStep.to = -(rightText.height / 2)
                rightAnim.start()
            }
        }
    }

    // ── ASCII logo ────────────────────────────────────────────────────────────
    Text {
        id: asciiLogo
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.15

        text: "⠀⠀⢀⣤⡶⣾⠛⠛⠛⢻⡷⢶⣤⣀⠀⠀⠀⠀⠀⠀⣠⣾⠋⠁⣀⡼⠇⢰⡶⠾⠇⣀⠈⢙⣷⣄⠀⠀⠀\n⣴⠏⠉⣿⠂⠹⣆⠀⢸⡇⠀⣰⠏⠛⠞⠁⠹⣧⠀⣸⣏⣀⡘⠳⣤⣠⡾⣿⢻⡟⣿⢷⣄⣤⠾⢷⣀⣽⣇⣿⠉⢹⣇\n⣀⣠⣿⣛⣾⣿⣿⣷⣛⣿⣄⣀⣈⡉⠀⣿⣿⠀⣈⡉⠉⠙⣿⣭⢿⣿⣿⡿⣭⣿⠋⠉⢹⣇⣀⣿⢹⣟⠉⢷⡶⠛⠙⢷\n⣿⣼⣧⣿⡾⠋⠛⢦⡌⠉⣹⡏⠀⢻⣆⠀⣴⣤⣠⠟⠀⢸⡇⠀⠹⣆⠠⣿⣀⣰⡟⠀⠀⠀⠙⢿⣅⡀⠉⢰⡶⠾⠇\n⢰⡞⠉⢀⣠⡿⠋⠀⠀⠀⠀⠀⠀⠈⠛⠷⢾⣧⣤⣤⣤⡿⠾⠛⠁⠀⠀⠀⠀"

        color: "#8B0000"
        font.family: "Monospace"
        font.pixelSize: 14
        lineHeight: 0.85
        horizontalAlignment: Text.AlignHCenter
    }

    // ── login box ─────────────────────────────────────────────────────────────
    Rectangle {
        id: loginBox
        width: 420
        height: 320
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 80
        color: "#000000"
        border.color: "#333333"
        border.width: 2

        Column {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 18

            Rectangle {
                width: parent.width
                height: 35
                color: "#000000"
                border.color: "#333333"
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "[ SYSTEM LOGIN ]"
                    color: "#8B0000"
                    font.family: "Monospace"
                    font.pixelSize: 16
                    font.bold: true
                }
            }

            Column {
                width: parent.width
                spacing: 8
                Text {
                    text: "> USERNAME"
                    color: "#666666"
                    font.family: "Monospace"
                    font.pixelSize: 12
                }
                Rectangle {
                    width: parent.width
                    height: 40
                    color: "#000000"
                    border.color: username.activeFocus ? "#8B0000" : "#333333"
                    border.width: 2
                    TextInput {
                        id: username
                        anchors.fill: parent
                        anchors.margins: 10
                        text: userModel.lastUser
                        color: "#CCCCCC"
                        font.family: "Monospace"
                        font.pixelSize: 14
                        verticalAlignment: TextInput.AlignVCenter
                        focus: true
                        Keys.onReturnPressed: password.forceActiveFocus()
                        Keys.onEnterPressed: password.forceActiveFocus()
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: username.forceActiveFocus()
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 8
                Text {
                    text: "> PASSWORD"
                    color: "#666666"
                    font.family: "Monospace"
                    font.pixelSize: 12
                }
                Rectangle {
                    width: parent.width
                    height: 40
                    color: "#000000"
                    border.color: password.activeFocus ? "#8B0000" : "#333333"
                    border.width: 2
                    TextInput {
                        id: password
                        anchors.fill: parent
                        anchors.margins: 10
                        color: "#CCCCCC"
                        font.family: "Monospace"
                        font.pixelSize: 14
                        echoMode: TextInput.Password
                        verticalAlignment: TextInput.AlignVCenter
                        Keys.onReturnPressed: sddm.login(username.text, password.text, sessionIndex)
                        Keys.onEnterPressed: sddm.login(username.text, password.text, sessionIndex)
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: password.forceActiveFocus()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 45
                color: loginButtonArea.pressed ? "#8B0000" : "#000000"
                border.color: "#8B0000"
                border.width: 2
                Text {
                    anchors.centerIn: parent
                    text: "[ ENTER ]"
                    color: "#8B0000"
                    font.family: "Monospace"
                    font.pixelSize: 14
                    font.bold: true
                }
                MouseArea {
                    id: loginButtonArea
                    anchors.fill: parent
                    onClicked: sddm.login(username.text, password.text, sessionIndex)
                }
            }
        }
    }

    Text {
        id: errorMessage
        anchors.top: loginBox.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        text: "[ ! ] LOGIN FAILED [ ! ]"
        color: "#8B0000"
        font.family: "Monospace"
        font.pixelSize: 13
        visible: false
    }

    // ── dim overlay ───────────────────────────────────────────────────────────
    Rectangle {
        id: dimOverlay
        visible: sessionPopup.visible
        anchors.fill: parent
        color: "#000000"
        opacity: 0.88
        z: 10
        MouseArea {
            anchors.fill: parent
            onClicked: sessionPopup.visible = false
        }
    }

    // ── session picker popup ──────────────────────────────────────────────────
    Rectangle {
        id: sessionPopup
        visible: false
        anchors.centerIn: parent
        z: 11
        width: 560
        height: popupHeader.height + sessionModel.count * 86 + 2
        color: "#000000"
        border.color: "#8B0000"
        border.width: 2

        Keys.onEscapePressed: sessionPopup.visible = false

        Rectangle {
            id: popupHeader
            width: parent.width
            height: 52
            color: "#080000"

            Rectangle {
                anchors.left: parent.left
                width: 4
                height: parent.height
                color: "#8B0000"
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 22
                anchors.verticalCenter: parent.verticalCenter
                text: ">_  SELECT SESSION"
                color: "#CC2200"
                font.family: "Monospace"
                font.pixelSize: 14
                font.bold: true
                font.letterSpacing: 2
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                text: "ESC to dismiss"
                color: "#2A2A2A"
                font.family: "Monospace"
                font.pixelSize: 10
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#8B0000"
                opacity: 0.4
            }
        }

        Column {
            anchors.top: popupHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            Repeater {
                model: sessionModel
                delegate: Rectangle {
                    id: sessionCard
                    width: sessionPopup.width - 4
                    height: 86
                    color: rowArea.containsMouse
                        ? "#0D0000"
                        : (session.index === index ? "#0A0000" : "#000000")

                    Rectangle {
                        id: accentBar
                        anchors.left: parent.left
                        width: 4
                        height: parent.height
                        color: session.index === index
                            ? "#CC2200"
                            : (rowArea.containsMouse ? "#3A0000" : "#111111")
                    }

                    Text {
                        id: nameText
                        anchors.left: accentBar.right
                        anchors.leftMargin: 18
                        anchors.top: parent.top
                        anchors.topMargin: 18
                        text: model.name
                        color: session.index === index
                            ? "#FFFFFF"
                            : (rowArea.containsMouse ? "#AAAAAA" : "#555555")
                        font.family: "Monospace"
                        font.pixelSize: 14
                        font.bold: session.index === index
                    }

                    Text {
                        anchors.left: accentBar.right
                        anchors.leftMargin: 18
                        anchors.top: nameText.bottom
                        anchors.topMargin: 6
                        text: (model.comment && model.comment.length > 0) ? model.comment : "no description"
                        color: session.index === index ? "#4A4A4A" : "#2A2A2A"
                        font.family: "Monospace"
                        font.pixelSize: 11
                    }

                    Rectangle {
                        id: protoBadge
                        anchors.right: parent.right
                        anchors.rightMargin: 18
                        anchors.top: parent.top
                        anchors.topMargin: 16
                        width: protoLabel.width + 16
                        height: 20
                        color: "transparent"
                        border.width: 1
                        border.color: model.wayland ? "#4A0000" : "#2A2A2A"

                        Text {
                            id: protoLabel
                            anchors.centerIn: parent
                            text: model.wayland ? "WAYLAND" : "X11"
                            color: model.wayland ? "#8B0000" : "#444444"
                            font.family: "Monospace"
                            font.pixelSize: 9
                            font.letterSpacing: 1
                        }
                    }

                    Text {
                        visible: session.index === index
                        anchors.right: parent.right
                        anchors.rightMargin: 18
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 16
                        text: "[ ACTIVE ]"
                        color: "#8B0000"
                        font.family: "Monospace"
                        font.pixelSize: 10
                        font.bold: true
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: "#111111"
                    }

                    MouseArea {
                        id: rowArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            session.index = index
                            sessionPopup.visible = false
                        }
                    }
                }
            }
        }
    }

    // ── status bar ────────────────────────────────────────────────────────────
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 30
        color: "#000000"
        border.color: "#1A1A1A"
        border.width: 1

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 20

            // session picker button — width from inner Row so text never clips
            Rectangle {
                id: sessionPickerBtn
                width: sessionBtnRow.implicitWidth + 24
                height: 22
                color: sessionPickerArea.containsMouse ? "#0A0000" : "#000000"
                border.color: sessionPickerArea.containsMouse ? "#8B0000" : "#2A2A2A"
                border.width: 1

                Row {
                    id: sessionBtnRow
                    anchors.centerIn: parent
                    spacing: 6
                    Text {
                        text: "SESSION"
                        color: sessionPickerArea.containsMouse ? "#8B0000" : "#333333"
                        font.family: "Monospace"
                        font.pixelSize: 10
                        font.letterSpacing: 1
                    }
                    Text {
                        id: sessionPickerLabel
                        text: session.index >= 0 && session.index < container.sessionNames.length
                            ? (container.sessionNames[session.index] || "...")
                            : "NONE"
                        color: sessionPickerArea.containsMouse ? "#CCCCCC" : "#555555"
                        font.family: "Monospace"
                        font.pixelSize: 10
                    }
                    Text {
                        visible: session.index >= 0 && session.index < container.sessionWaylands.length
                        text: container.sessionWaylands[session.index] ? "[W]" : "[X]"
                        color: sessionPickerArea.containsMouse ? "#8B0000" : "#2A2A2A"
                        font.family: "Monospace"
                        font.pixelSize: 9
                    }
                    Text {
                        text: "v"
                        color: sessionPickerArea.containsMouse ? "#8B0000" : "#333333"
                        font.family: "Monospace"
                        font.pixelSize: 10
                    }
                }

                MouseArea {
                    id: sessionPickerArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: sessionPopup.visible = true
                }
            }

            Text {
                id: timeLabel
                color: "#333333"
                font.family: "Monospace"
                font.pixelSize: 11
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: timeLabel.text = Qt.formatDateTime(new Date(), "yyyy.MM.dd // hh:mm:ss")
                }
                Component.onCompleted: timeLabel.text = Qt.formatDateTime(new Date(), "yyyy.MM.dd // hh:mm:ss")
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Rectangle {
                width: 76
                height: 22
                color: rebootArea.containsMouse ? "#0A0000" : "#000000"
                border.color: rebootArea.containsMouse ? "#8B0000" : "#1A1A1A"
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "REBOOT"
                    color: rebootArea.containsMouse ? "#CC2200" : "#333333"
                    font.family: "Monospace"
                    font.pixelSize: 10
                }
                MouseArea {
                    id: rebootArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: sddm.reboot()
                }
            }

            Rectangle {
                width: 86
                height: 22
                color: shutdownArea.containsMouse ? "#0A0000" : "#000000"
                border.color: shutdownArea.containsMouse ? "#8B0000" : "#1A1A1A"
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    text: "SHUTDOWN"
                    color: shutdownArea.containsMouse ? "#CC2200" : "#333333"
                    font.family: "Monospace"
                    font.pixelSize: 10
                }
                MouseArea {
                    id: shutdownArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: sddm.powerOff()
                }
            }
        }
    }

    ComboBox {
        id: session
        visible: false
        model: sessionModel
        index: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    }

    Component.onCompleted: username.forceActiveFocus()
}
