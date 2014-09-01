import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1

Window {
    title: window.title + " - Version Lookup"
    visible: false
    onVisibleChanged: if (visible) {
                          x = window.x + (window.width - width) / 2
                          y = window.y + (window.height - height) / 2
                      }
    height: 140
    width: 430
    ColumnLayout {
        height: parent.height
        width: parent.width
        RowLayout {
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Row {
                spacing: 1
                SpinBox {
                    id: major
                    prefix: "10."
                    value: 3
                    maximumValue: 255
                    onEditingFinished: relookup.clicked()
                }
                SpinBox {
                    id: minor
                    value: 0
                    maximumValue: 255
                    onEditingFinished: relookup.clicked()
                }
                SpinBox {
                    id: build
                    value: 1052
                    maximumValue: 9999
                    stepSize: 3
                    onEditingFinished: relookup.clicked()
                }
            }
            Button {
                id: relookup
                text: "Lookup"
                enabled: !p.scanning
                onClicked: p.reverseLookup(country.value, carrier.value, device.selectedItem, variant.selectedItem, 0/*server.selectedItem*/, "10." + major.value + "." + minor.value + "." + build.value);
            }
            Button {
                property bool looking: false
                text: looking ? "Stop Scan" : "Autoscan"
                enabled: !p.scanning || looking
                onClicked: { looking = !looking; if (looking) { build.value += 3; relookup.clicked(); } }
                Timer {
                    id: autoLookup
                    interval: 10;
                    running: parent.looking && !p.scanning
                    onTriggered: {
                        if (p.scanning > 0)
                            return;
                        if (downloadPotential.visible) {
                            parent.looking = false;
                        } else if (p.softwareRelease == "SR not in system") {
                            if (build.value >= 9998) {
                                minor.value++;
                                build.value = (build.value+3) % 10000;
                            } else
                                build.value += 3;
                            relookup.clicked();
                        }
                    }
                }
            }
        }
        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            Text {
                Layout.alignment: Qt.AlignLeft
                text: "Software Release: " + p.softwareRelease
                font.pointSize: 12
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                property string osVersion: ""
                visible: p.softwareRelease.charAt(0) == "1" || p.softwareRelease.charAt(0) == "2"
                onVisibleChanged: if (visible) osVersion = "10." + major.value + "." + minor.value + "." + build.value
                Button {
                    id: downloadPotential
                    enabled: true // Exists?
                    text: "Test"
                    onClicked: p.downloadPotentialLink(p.softwareRelease, parent.osVersion)
                }
                Button {
                    enabled: true // Exists?
                    text: isMobile ? "Copy Links" : "Grab Links"
                    onClicked: p.grabPotentialLinks(p.softwareRelease, parent.osVersion)
                }
            }
        }
        Button {
            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
            text: "Hide"
            onClicked: close();
        }
    }
}
