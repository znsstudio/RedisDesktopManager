import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Dialogs 1.2
import "."
import "./QChart.js" as Charts
import "./editors/formatters/formatters.js" as Formatters

Rectangle {
    id: approot
    objectName: "rdm_qml_root"
    color: "transparent"
    property var currentValueFormatter

    TabView {
        id: tabs
        objectName: "rdm_qml_tabs"
        anchors.fill: parent
        anchors.margins: 2
        currentIndex: 0

        onCurrentIndexChanged: {

            var index = currentIndex

            if (tabs.getTab(0).not_mapped)
                index -= 1

            console.log(index)

            viewModel.setCurrentTab(index)
        }

        Tab {
            id: jsTab
            title: "js console"

            property var outModel: ListModel {
                id: outputModel
            }

            function jsCall(exp) {
                //var data = Util.call(exp);
                // insert the result at the beginning of the list
                outputModel.insert(0, {'result': eval(exp)})
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 9



                QChart {
                  id: chart_line;
                  width: 300;
                  height: 300;
                  chartAnimated: true;
                  chartAnimationEasing: Easing.InOutElastic;
                  chartAnimationDuration: 2000;
                  chartType: Charts.ChartType.LINE;

                  Component.onCompleted: {
                     chartData = {
                            labels: ["January","February","March","April","May","June","July"],
                          datasets: [{
                                     fillColor: "rgba(220,220,220,0.5)",
                                   strokeColor: "rgba(220,220,220,1)",
                                    pointColor: "rgba(220,220,220,1)",
                              pointStrokeColor: "#ffffff",
                                          data: [65,59,90,81,56,55,40]
                          }, {
                                     fillColor: "rgba(151,187,205,0.5)",
                                   strokeColor: "rgba(151,187,205,1)",
                                    pointColor: "rgba(151,187,205,1)",
                              pointStrokeColor: "#ffffff",
                                          data: [28,48,40,19,96,27,100]
                          }]
                      }
                  }
                }

                RowLayout {
                    Layout.fillWidth: true
                    TextField {
                        id: input
                        Layout.fillWidth: true
                        focus: true
                        onAccepted: {
                            // call our evaluation function on root
                            jsTab.jsCall(input.text)
                        }
                    }
                    Button {
                        text: qsTr("Send")
                        onClicked: {
                            // call our evaluation function on root
                            jsTab.jsCall(input.text)
                            console.log(appVersion)
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Rectangle {
                        anchors.fill: parent
                        color: '#333'
                        border.color: Qt.darker(color)
                        opacity: 0.2
                        radius: 2
                    }

                    ScrollView {
                        id: scrollView
                        anchors.fill: parent
                        anchors.margins: 9
                        ListView {
                            id: resultView
                            model: jsTab.outModel
                            delegate: ColumnLayout {
                                width: ListView.view.width
                                Label {
                                    Layout.fillWidth: true
                                    color: 'green'
                                    text: "> " + model.expression
                                }
                                Label {
                                    Layout.fillWidth: true
                                    color: 'blue'
                                    text: "" + model.result
                                }
                                Rectangle {
                                    height: 1
                                    Layout.fillWidth: true
                                    color: '#333'
                                    opacity: 0.2
                                }
                            }
                        }
                    }
                }
            }
        }

        WelcomeTab {
            objectName: "rdm_qml_welcome_tab"
            property bool not_mapped: true

            function close(index) {
                tabs.removeTab(index)
            }
        }

        ValueTabs {
            objectName: "rdm_qml_value_tabs"
            model: viewModel
        }

        style: TabViewStyle {
            tab: Rectangle {
                color: "#cccccc"
                implicitWidth: layout.implicitWidth + 3
                implicitHeight: 28
                radius: 2

                Rectangle {
                    id: content
                    color: styleData.selected ? "white" :"#cccccc"
                    anchors.fill: parent
                    anchors.topMargin: styleData.selected
                    anchors.rightMargin: styleData.selected
                    anchors.leftMargin: styleData.selected

                    RowLayout {
                        id: layout
                        anchors.fill: parent
                        anchors.rightMargin: 8

                        Item { Layout.preferredWidth: 3 }

                        Text {
                            Layout.fillWidth: true
                            Layout.minimumWidth: implicitWidth
                            color: "red"
                            text: styleData.title
                        }
                        Item {
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18

                            Image {
                                anchors.fill: parent
                                anchors.margins: 2
                                source: "qrc:/images/clear.png"
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        tabs.getTab(styleData.index).close(styleData.index)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            frame: Rectangle {
                color: "#cccccc"

                Rectangle {
                    color: "white"
                    anchors.fill: parent
                    anchors.bottomMargin: 1
                    anchors.leftMargin: 1
                    anchors.rightMargin: 1
                    anchors.topMargin: 1
                }
            }
        }

    }


    MessageDialog {
        id: errorNotification
        objectName: "rdm_qml_error_dialog"
        visible: false
        modality: Qt.WindowModal
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Ok
    }

    AddKeyDialog {
        id: addNewKeyDialog
        objectName: "rdm_qml_new_key_dialog"
    }

    Connections {
        target: viewModel
        onKeyError: {
            if (index != -1)
                tabs.currentIndex = index + 1
            errorNotification.text = error
            errorNotification.open()
        }
        onCloseWelcomeTab: {

            var welcomeTab = tabs.getTab(0)

            if (welcomeTab && welcomeTab.not_mapped)
                tabs.removeTab(0)
        }

        onNewKeyDialog: {
            console.log(dbIdentificationString, keyPrefix)
            addNewKeyDialog.open()
        }
    }
}
