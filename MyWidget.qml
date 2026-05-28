import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property string city: pluginData.city ?? "bern"
    onCityChanged: fetchAareData()

    property string temp: "--"
    property string flow: "--"
    property string location: "Aare"
    property string tempText: "--"
    property string tempTextShort: "--"
    property string flowText: "--"
    property string forecast2h: "--"
    property string forecast2hText: "--"

    function fetchAareData() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://aareguru.existenz.ch/v2018/current?city=" + root.city);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var res = JSON.parse(xhr.responseText);
                        var a = res.aare;
                        root.location      = (a && a.location)            || "Aare";
                        root.temp          = (a && a.temperature != null) ? a.temperature.toFixed(1) + "°C" : "Err";
                        root.flow          = (a && a.flow != null)        ? String(a.flow) + " m³/s"       : "Err";
                        root.tempText      = (a && a.temperature_text)      || "–";
                        root.tempTextShort = (a && a.temperature_text_short) || "–";
                        root.flowText      = (a && a.flow_text)             || "–";
                        root.forecast2h    = (a && a.forecast2h != null)    ? a.forecast2h.toFixed(1) + "°C" : "–";
                        root.forecast2hText = (a && a.forecast2h_text)      || "–";
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

    popoutWidth: 360
    popoutHeight: 210

    popoutContent: Component {
        Column {
            spacing: Theme.spacingS
            padding: Theme.spacingM

            StyledText {
                text: "Aare " + root.location
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Bold
                color: Theme.surfaceText
            }

            StyledText {
                text: root.temp + "  ·  " + root.flow
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            StyledText {
                text: root.tempText + " (" + root.tempTextShort + ")"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
                width: 320
            }

            StyledText {
                text: "Fluss: " + root.flowText
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
                width: 320
            }

            StyledText {
                text: "In 2h: " + root.forecast2h + " – " + root.forecast2hText
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
                width: 320
            }
        }
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
