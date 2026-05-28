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
    property var tempHistory: []
    property var flowHistory: []

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
                        var past = res.aarepast || [];
                        var temps = [], flows = [];
                        for (var i = 0; i < past.length; i++) {
                            temps.push(past[i].temperature !== null && past[i].temperature !== undefined ? past[i].temperature : null);
                            flows.push(past[i].flow);
                        }
                        root.tempHistory = temps;
                        root.flowHistory = flows;
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

    popoutWidth: 400
    popoutHeight: 460

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
                width: 360
            }

            StyledText {
                text: "Fluss: " + root.flowText
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
                width: 360
            }

            StyledText {
                text: "In 2h: " + root.forecast2h + " – " + root.forecast2hText
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
                width: 360
            }

            StyledText {
                text: "Wassertemperatur (48h)"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            Canvas {
                id: tempCanvas
                width: 360
                height: 70

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    var data = root.tempHistory;
                    if (!data || data.length < 2) return;
                    var minV = null, maxV = null;
                    for (var i = 0; i < data.length; i++) {
                        if (data[i] === null) continue;
                        if (minV === null || data[i] < minV) minV = data[i];
                        if (maxV === null || data[i] > maxV) maxV = data[i];
                    }
                    if (minV === null) return;
                    var range = (maxV - minV) || 1;
                    var margin = 38;
                    var plotW = width - margin;
                    var plotH = height - 4;
                    ctx.font = "10px sans-serif";
                    ctx.fillStyle = Theme.surfaceVariantText;
                    ctx.textAlign = "right";
                    ctx.textBaseline = "top";
                    ctx.fillText(maxV.toFixed(1) + "°", margin - 4, 2);
                    ctx.textBaseline = "bottom";
                    ctx.fillText(minV.toFixed(1) + "°", margin - 4, height - 2);
                    ctx.strokeStyle = Theme.surfaceVariantText;
                    ctx.lineWidth = 0.5;
                    ctx.beginPath();
                    ctx.moveTo(margin, 0);
                    ctx.lineTo(margin, height);
                    ctx.stroke();
                    ctx.strokeStyle = Theme.primary;
                    ctx.lineWidth = 1.5;
                    ctx.beginPath();
                    var needsMove = true;
                    for (var j = 0; j < data.length; j++) {
                        if (data[j] === null) { needsMove = true; continue; }
                        var x = margin + (j / (data.length - 1)) * plotW;
                        var y = height - 2 - ((data[j] - minV) / range) * plotH;
                        if (needsMove) { ctx.moveTo(x, y); needsMove = false; }
                        else ctx.lineTo(x, y);
                    }
                    ctx.stroke();
                }

                Connections {
                    target: root
                    function onTempHistoryChanged() { tempCanvas.requestPaint(); }
                }
            }

            StyledText {
                text: "Abfluss (48h)"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            Canvas {
                id: flowCanvas
                width: 360
                height: 70

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    var data = root.flowHistory;
                    if (!data || data.length < 2) return;
                    var minV = data[0], maxV = data[0];
                    for (var i = 1; i < data.length; i++) {
                        if (data[i] < minV) minV = data[i];
                        if (data[i] > maxV) maxV = data[i];
                    }
                    var range = (maxV - minV) || 1;
                    var margin = 38;
                    var plotW = width - margin;
                    var plotH = height - 4;
                    ctx.font = "10px sans-serif";
                    ctx.fillStyle = Theme.surfaceVariantText;
                    ctx.textAlign = "right";
                    ctx.textBaseline = "top";
                    ctx.fillText(maxV + " m³", margin - 4, 2);
                    ctx.textBaseline = "bottom";
                    ctx.fillText(minV + " m³", margin - 4, height - 2);
                    ctx.strokeStyle = Theme.surfaceVariantText;
                    ctx.lineWidth = 0.5;
                    ctx.beginPath();
                    ctx.moveTo(margin, 0);
                    ctx.lineTo(margin, height);
                    ctx.stroke();
                    ctx.strokeStyle = Theme.primary;
                    ctx.lineWidth = 1.5;
                    ctx.beginPath();
                    for (var j = 0; j < data.length; j++) {
                        var x = margin + (j / (data.length - 1)) * plotW;
                        var y = height - 2 - ((data[j] - minV) / range) * plotH;
                        if (j === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
                    }
                    ctx.stroke();
                }

                Connections {
                    target: root
                    function onFlowHistoryChanged() { flowCanvas.requestPaint(); }
                }
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
