import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property string temp: "--"
    property string flow: "--"

    function fetchAareData() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://aareguru.existenz.ch/v2018/current?city=bern");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var res = JSON.parse(xhr.responseText);
                        var t = res.aare && res.aare.temperature;
                        var f = res.aare && res.aare.flow;
                        root.temp = (t != null) ? t.toFixed(1) + "°C" : "Err";
                        root.flow = (f != null) ? f.toFixed(1) + " m³/s" : "Err";
                    } catch (e) {
                        root.temp = "Err";
                        root.flow = "Err";
                    }
                } else {
                    root.temp = "Err";
                    root.flow = "Err";
                }
            }
        };
        xhr.send();
    }

    Timer {
        interval: 300000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.fetchAareData()
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            DankIcon {
                name: "pool"
                size: root.iconSize
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.temp
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Bold
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: "(" + root.flow + ")"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            DankIcon {
                name: "pool"
                size: root.iconSize
                color: Theme.primary
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.temp
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Bold
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
