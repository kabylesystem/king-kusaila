//@ pragma UseQApplication
import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: app

    readonly property string thumbDir: Quickshell.env("HOME") + "/.cache/naly-clipboard/thumbs"
    property bool thumbsDone: false
    property var dates: ({})
    property string bigId: ""
    property string bigPath: ""

    readonly property string mono: "JetBrainsMono Nerd Font"
    readonly property string sans: "Adwaita Sans"
    readonly property color surface: "#070c15"
    readonly property color raise: "#0d1522"
    readonly property color line: "#16283a"
    readonly property color dim: "#5f7186"
    readonly property color soft: "#9db4c9"
    readonly property color bright: "#eaf4ff"
    readonly property color accent: "#a3e635"
    readonly property color alert: "#ff2e88"
    readonly property color lime: "#9dff3c"

    property var entries: []
    property string filter: ""
    property int sel: 0
    property bool entered: false
    property bool leaving: false
    property bool armed: false

    function dayKey(ts) {
        var d = new Date(ts * 1000);
        return d.getFullYear() + "-" + d.getMonth() + "-" + d.getDate();
    }

    function dayName(ts) {
        var d = new Date(ts * 1000);
        var now = new Date();
        var today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        var that = new Date(d.getFullYear(), d.getMonth(), d.getDate());
        var diff = Math.round((today - that) / 86400000);
        if (diff === 0)
            return "TODAY";
        if (diff === 1)
            return "YESTERDAY";
        var days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
        if (diff < 7)
            return days[d.getDay()] + " " + d.getDate() + " " + months[d.getMonth()];
        return d.getDate() + " " + months[d.getMonth()] + (d.getFullYear() !== now.getFullYear() ? " " + d.getFullYear() : "");
    }

    readonly property var shown: {
        var base = [];
        if (app.filter.length === 0) {
            base = app.entries;
        } else {
            var f = app.filter.toLowerCase();
            for (var i = 0; i < app.entries.length; i++) {
                if (app.entries[i].text.toLowerCase().indexOf(f) >= 0)
                    base.push(app.entries[i]);
            }
        }
        var out = [];
        var prev = "";
        for (var j = 0; j < base.length; j++) {
            var e = base[j];
            var ts = app.dates[e.id];
            var key = ts ? app.dayKey(ts) : "older";
            var label = "";
            if (key !== prev) {
                label = ts ? app.dayName(ts) : "OLDER";
                prev = key;
            }
            out.push({
                id: e.id,
                text: e.text,
                image: e.image,
                dims: e.dims,
                thumb: e.thumb,
                day: label
            });
        }
        return out;
    }

    function showBig(id) {
        app.bigId = id;
        app.bigPath = "";
        bigDecoder.command = ["sh", "-c", "cliphist decode " + id + " > /tmp/naly-clip-big.png"];
        bigDecoder.running = true;
    }

    function hideBig() {
        app.bigId = "";
        app.bigPath = "";
        Quickshell.execDetached(["rm", "-f", "/tmp/naly-clip-big.png"]);
    }

    function closeNow() {
        Quickshell.execDetached(["kill", "-TERM", String(Quickshell.processId)]);
    }

    function dismiss() {
        if (app.leaving)
            return;
        app.leaving = true;
        dismissTimer.start();
    }

    function copy(id) {
        Quickshell.execDetached(["sh", "-c", "cliphist decode " + id + " | wl-copy"]);
        app.dismiss();
    }

    function remove(id) {
        Quickshell.execDetached(["sh", "-c", "cliphist decode " + id + " | cliphist delete"]);
        reloadTimer.restart();
    }

    Timer {
        id: dismissTimer
        interval: 170
        onTriggered: app.closeNow()
    }

    Timer {
        id: reloadTimer
        interval: 220
        onTriggered: lister.running = true
    }

    Timer {
        interval: 16
        running: true
        onTriggered: {
            app.entered = true;
            lister.running = true;
        }
    }

    Timer {
        interval: 420
        running: true
        onTriggered: app.armed = true
    }

    Process {
        id: dateReader
        command: ["sh", "-c", "cat \"${XDG_CACHE_HOME:-$HOME/.cache}/naly-clipboard/dates.tsv\" 2>/dev/null || true"]
        stdout: StdioCollector {
            onStreamFinished: {
                var m = {};
                var lines = text.split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split("\t");
                    if (parts.length >= 2)
                        m[parts[0]] = parseInt(parts[1], 10);
                }
                app.dates = m;
            }
        }
    }

    Process {
        id: bigDecoder
        command: ["sh", "-c", "true"]
        onExited: function (code) {
            if (code === 0)
                app.bigPath = "file:///tmp/naly-clip-big.png?" + Date.now();
        }
    }

    Process {
        id: thumbMaker
        command: [Quickshell.env("HOME") + "/.local/bin/naly-clip-thumbs", "150"]
        onExited: lister.running = true
    }

    Process {
        id: lister
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = [];
                var lines = text.split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var l = lines[i];
                    if (l.length === 0)
                        continue;
                    var t = l.indexOf("\t");
                    if (t < 0)
                        continue;
                    var id = l.substring(0, t);
                    var body = l.substring(t + 1);
                    var img = body.indexOf("[[ binary data") === 0;
                    var dim = "";
                    if (img) {
                        var m = body.match(/(\d+)x(\d+)/);
                        if (m)
                            dim = m[1] + " x " + m[2];
                    }
                    out.push({
                        id: id,
                        text: body,
                        image: img,
                        dims: dim,
                        thumb: img ? "file://" + app.thumbDir + "/" + id + ".png" : ""
                    });
                }
                app.entries = out;
                app.sel = 0;
                dateReader.running = true;
                if (!app.thumbsDone) {
                    app.thumbsDone = true;
                    thumbMaker.running = true;
                }
            }
        }
    }

    component Glyph: Item {
        id: g
        property real size: 15
        property color stroke: "#ffffffff"
        property string kind: ""

        readonly property var paths: ({
            "clip": "M9 3h6a1 1 0 0 1 1 1v1H8V4a1 1 0 0 1 1-1Z M8 5H6a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-2",
            "img": "M4 5h16v14H4z M8.5 10.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3Z M20 15l-5-5L6 19",
            "text": "M4 6h16 M4 12h16 M4 18h10",
            "search": "M11 3a8 8 0 1 0 0 16 8 8 0 0 0 0-16Z M21 21l-4.35-4.35",
            "x": "M18 6 6 18 M6 6l12 12"
        })

        width: size
        height: size

        Shape {
            anchors.centerIn: parent
            width: 24
            height: 24
            scale: g.size / 24
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: g.stroke
                strokeWidth: 1.7
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                PathSvg {
                    path: g.paths[g.kind] !== undefined ? g.paths[g.kind] : ""
                }
            }
        }
    }

    component Glass: Item {
        id: gl
        property real cut: 14
        property color fill: "#00000000"
        property color line: "#00000000"
        property real lineWidth: 1

        Rectangle {
            anchors.fill: parent
            radius: gl.cut
            antialiasing: true
            color: gl.fill
            border.width: gl.lineWidth
            border.color: gl.line
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: gl.lineWidth
            radius: Math.max(0, gl.cut - gl.lineWidth)
            antialiasing: true
            visible: gl.fill.a > 0.25
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "#16ffffff"
                }
                GradientStop {
                    position: 0.45
                    color: "#03ffffff"
                }
                GradientStop {
                    position: 1.0
                    color: "#00ffffff"
                }
            }
        }
    }

    PanelWindow {
        id: win

        WlrLayershell.namespace: "naly-clipboard"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: "#04060b"
            opacity: app.entered && !app.leaving ? 0.42 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 190
                }
            }
        }

        // Clic dans le vide : ca ferme, comme les autres panneaux
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (app.armed)
                    app.dismiss();
            }
        }

        Item {
            id: panel
            anchors.centerIn: parent
            width: 560
            height: Math.min(560, win.height - 140)

            opacity: app.entered && !app.leaving ? 1 : 0
            scale: app.entered && !app.leaving ? 1 : 0.96

            Behavior on opacity {
                NumberAnimation {
                    duration: 190
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: 320
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.1
                }
            }

            Glass {
                anchors.fill: parent
                cut: 22
                fill: Qt.rgba(app.surface.r, app.surface.g, app.surface.b, 0.95)
                line: Qt.rgba(app.accent.r, app.accent.g, app.accent.b, 0.32)
                lineWidth: 1.2
            }

            MouseArea {
                anchors.fill: parent
            }

            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 12

                Item {
                    width: parent.width
                    height: 34

                    Glass {
                        anchors.fill: parent
                        cut: 12
                        fill: app.raise
                        line: app.filter.length > 0 ? Qt.rgba(app.accent.r, app.accent.g, app.accent.b, 0.55) : app.line
                        Behavior on line {
                            ColorAnimation {
                                duration: 170
                            }
                        }
                    }

                    Glyph {
                        id: si
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        kind: "search"
                        size: 13
                        stroke: app.filter.length > 0 ? app.accent : app.dim
                    }

                    Text {
                        anchors.left: si.right
                        anchors.leftMargin: 10
                        anchors.right: cnt.left
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: app.filter.length > 0 ? app.filter : "TYPE TO SEARCH"
                        elide: Text.ElideRight
                        font.family: app.mono
                        font.pixelSize: app.filter.length > 0 ? 12 : 10
                        font.letterSpacing: app.filter.length > 0 ? 0 : 1.4
                        color: app.filter.length > 0 ? app.bright : app.dim
                    }

                    Text {
                        id: cnt
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: app.shown.length + " ITEMS"
                        font.family: app.mono
                        font.pixelSize: 9
                        font.letterSpacing: 1.2
                        color: app.dim
                    }
                }

                ListView {
                    id: list
                    width: parent.width
                    height: parent.height - 46
                    clip: true
                    spacing: 3
                    model: app.shown
                    currentIndex: app.sel
                    boundsBehavior: Flickable.StopAtBounds

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        onWheel: function (w) {
                            var step = w.angleDelta.y > 0 ? -62 : 62;
                            var maxY = Math.max(0, list.contentHeight - list.height);
                            list.contentY = Math.max(0, Math.min(maxY, list.contentY + step));
                            w.accepted = true;
                        }
                    }


                    delegate: Item {
                        id: row
                        required property int index
                        required property var modelData
                        property bool hovered: false
                        readonly property bool on: app.sel === index
                        readonly property int headH: modelData.day.length > 0 ? 24 : 0
                        width: list.width
                        height: headH + (modelData.image ? 62 : 42)

                        Item {
                            id: dayHead
                            visible: row.headH > 0
                            width: parent.width - 4
                            height: row.headH
                            anchors.top: parent.top

                            Text {
                                id: dayText
                                anchors.left: parent.left
                                anchors.leftMargin: 13
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.day
                                font.family: app.mono
                                font.pixelSize: 9
                                font.letterSpacing: 2
                                font.weight: Font.Bold
                                color: app.dim
                            }

                            Rectangle {
                                anchors.left: dayText.right
                                anchors.leftMargin: 10
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: dayText.verticalCenter
                                height: 1
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop {
                                        position: 0
                                        color: Qt.rgba(app.dim.r, app.dim.g, app.dim.b, 0.45)
                                    }
                                    GradientStop {
                                        position: 1
                                        color: "transparent"
                                    }
                                }
                            }
                        }

                        Item {
                            id: body
                            anchors.top: parent.top
                            anchors.topMargin: row.headH
                            width: parent.width
                            height: parent.height - row.headH

                        Glass {
                            anchors.fill: parent
                            anchors.rightMargin: 4
                            cut: 11
                            fill: row.on ? Qt.rgba(app.accent.r, app.accent.g, app.accent.b, 0.16) : (row.hovered ? "#12ffffff" : "#00000000")
                            line: row.on ? Qt.rgba(app.accent.r, app.accent.g, app.accent.b, 0.5) : (row.hovered ? "#24ffffff" : "#00000000")
                            Behavior on fill {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                            Behavior on line {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                        }

                        Rectangle {
                            visible: row.on
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: 3
                            height: parent.height - 18
                            radius: 1.5
                            color: app.alert
                        }

                        Glyph {
                            id: ri
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            kind: modelData.image ? "img" : "text"
                            size: 14
                            stroke: row.on ? app.accent : app.dim
                            visible: !modelData.image
                        }

                        Item {
                            id: thumb
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            width: 46
                            height: 38
                            visible: modelData.image

                            Glass {
                                anchors.fill: parent
                                cut: 9
                                fill: Qt.rgba(app.accent.r, app.accent.g, app.accent.b, 0.16)
                                line: Qt.rgba(app.accent.r, app.accent.g, app.accent.b, 0.45)
                                visible: preview.status !== Image.Ready
                            }

                            Image {
                                id: preview
                                anchors.fill: parent
                                anchors.margins: 1
                                source: modelData.thumb
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: false
                                retainWhileLoading: true
                                smooth: true
                                mipmap: true
                                sourceSize.width: 160
                                sourceSize.height: 160
                                visible: false
                            }

                            OpacityMask {
                                anchors.fill: preview
                                source: preview
                                maskSource: thumbMask
                                visible: preview.status === Image.Ready
                            }

                            Rectangle {
                                id: thumbMask
                                width: preview.width
                                height: preview.height
                                radius: 7
                                visible: false
                                layer.enabled: true
                            }

                            Rectangle {
                                anchors.fill: preview
                                color: "transparent"
                                radius: 7
                                border.width: 1
                                border.color: Qt.rgba(app.accent.r, app.accent.g, app.accent.b, row.on ? 0.6 : 0.22)
                                visible: preview.status === Image.Ready
                            }

                            Glyph {
                                anchors.centerIn: parent
                                kind: "img"
                                size: 16
                                stroke: app.accent
                                visible: preview.status !== Image.Ready
                            }
                        }

                        Column {
                            anchors.left: modelData.image ? thumb.right : ri.right
                            anchors.leftMargin: 12
                            anchors.right: delBtn.left
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                width: parent.width
                                text: modelData.image ? "IMAGE" : modelData.text
                                elide: Text.ElideRight
                                font.family: modelData.image ? app.mono : app.sans
                                font.pixelSize: modelData.image ? 10 : 12
                                font.letterSpacing: modelData.image ? 1.4 : 0
                                font.weight: modelData.image ? Font.Bold : Font.Normal
                                color: modelData.image ? app.accent : (row.on ? app.bright : app.soft)
                            }

                            Text {
                                visible: modelData.image && modelData.dims.length > 0
                                text: modelData.dims
                                font.family: app.mono
                                font.pixelSize: 9
                                color: app.dim
                            }
                        }

                        Item {
                            id: delBtn
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            width: 24
                            height: 24
                            opacity: row.hovered ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 150
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 8
                                color: delArea.containsMouse ? Qt.rgba(app.alert.r, app.alert.g, app.alert.b, 0.24) : "#00000000"
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 140
                                    }
                                }
                            }

                            Glyph {
                                anchors.centerIn: parent
                                kind: "x"
                                size: 12
                                stroke: delArea.containsMouse ? app.alert : app.dim
                            }

                            MouseArea {
                                id: delArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: app.remove(modelData.id)
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.rightMargin: 38
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onEntered: row.hovered = true
                            onExited: row.hovered = false
                            onClicked: function (mouse) {
                                app.sel = row.index;
                                if (mouse.button === Qt.RightButton) {
                                    if (modelData.image)
                                        app.showBig(modelData.id);
                                    return;
                                }
                                app.copy(modelData.id);
                            }
                        }
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: app.shown.length === 0
                    text: app.filter.length > 0 ? "NOTHING MATCHES" : "CLIPBOARD IS EMPTY"
                    font.family: app.mono
                    font.pixelSize: 10
                    font.letterSpacing: 2
                    color: app.dim
                }
            }
        }

        Rectangle {
            id: bigLayer
            anchors.fill: parent
            color: Qt.rgba(0.02, 0.03, 0.06, 0.96)
            visible: app.bigId.length > 0
            opacity: visible ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 130
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: app.hideBig()
            }

            Image {
                id: bigImage
                anchors.centerIn: parent
                width: Math.min(sourceSize.width, parent.width - 80)
                height: Math.min(sourceSize.height, parent.height - 110)
                source: app.bigPath
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: false
                smooth: true
                visible: status === Image.Ready
            }

            Rectangle {
                anchors.fill: bigImage
                anchors.margins: -1
                color: "transparent"
                radius: 4
                border.width: 1
                border.color: Qt.rgba(app.accent.r, app.accent.g, app.accent.b, 0.5)
                visible: bigImage.status === Image.Ready
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 18
                text: bigImage.status === Image.Ready ? bigImage.sourceSize.width + " x " + bigImage.sourceSize.height : "LOADING"
                font.family: app.mono
                font.pixelSize: 10
                font.letterSpacing: 2
                color: app.accent
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 18
                text: "CLICK OR ESC TO CLOSE   ·   ENTER TO COPY"
                font.family: app.mono
                font.pixelSize: 9
                font.letterSpacing: 2
                color: app.dim
            }
        }

        Item {
            anchors.fill: parent
            focus: true
            Component.onCompleted: forceActiveFocus()

            Keys.onPressed: function (event) {
                if (app.bigId.length > 0) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        var bid = app.bigId;
                        app.hideBig();
                        app.copy(bid);
                    } else {
                        app.hideBig();
                    }
                    event.accepted = true;
                    return;
                }
                if (event.key === Qt.Key_Escape) {
                    if (app.filter.length > 0)
                        app.filter = "";
                    else
                        app.dismiss();
                } else if (event.key === Qt.Key_Backspace) {
                    app.filter = app.filter.substring(0, app.filter.length - 1);
                } else if (event.key === Qt.Key_Down) {
                    app.sel = Math.min(app.shown.length - 1, app.sel + 1);
                    list.positionViewAtIndex(app.sel, ListView.Contain);
                } else if (event.key === Qt.Key_Up) {
                    app.sel = Math.max(0, app.sel - 1);
                    list.positionViewAtIndex(app.sel, ListView.Contain);
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (app.shown.length > 0)
                        app.copy(app.shown[app.sel].id);
                } else if (event.key === Qt.Key_Delete) {
                    if (app.shown.length > 0)
                        app.remove(app.shown[app.sel].id);
                } else if (event.text.length === 1 && event.text >= " ") {
                    app.filter += event.text;
                    app.sel = 0;
                }
                event.accepted = true;
            }
        }
    }
}
