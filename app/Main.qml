import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import Ubuntu.Components 1.3
import "UCSComponents"
//import Morph.Web 0.1
import QtWebEngine 1.10
import QtSystemInfo 5.5

Item {

    id: window
    visible: true



    ScreenSaver {
        id: screenSaver
        screenSaverEnabled: !Qt.application.active || !webview.recentlyAudible
    }

    width: units.gu(45)
    height: units.gu(75)


    objectName: "mainView"
    property bool loaded: false



        property QtObject defaultProfile: WebEngineProfile {
        storageName: "YABProfile"
        offTheRecord: false
        id: webContext
           persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
       property alias dataPath: webContext.persistentStoragePath

            dataPath: dataLocation




        httpUserAgent: "Mozilla/5.0 (Linux; Ubuntu 16.04 like Android 4.4) AppleWebKit/537.36 Chrome/77.0.3865.129 Mobile Safari/537.36"
    }

    WebEngineView {

        id: webview
        anchors.fill: parent
                profile: defaultProfile
        settings.fullScreenSupportEnabled: true
        settings.dnsPrefetchEnabled: true

       // enableSelectOverride: true

       property var currentWebview: webview
       property ContextMenuRequest contextMenuRequest: null
       settings.pluginsEnabled: true
     //settings.showScrollBars: false
       settings.javascriptCanAccessClipboard: true

       onFullScreenRequested: function(request) {
         nav.visible = !nav.visible
         if (request.toggleOn) {
           window.showFullScreen();
       }
       else {
           window.showNormal();
       }

         request.accept();
     }

     userScripts: [
           WebEngineScript {
               id: cssinjection
               injectionPoint: WebEngineScript.DocumentCreation
               sourceUrl: Qt.resolvedUrl('ubuntutheme.js')
               worldId: WebEngineScript.UserWorld
           }
       ]
        url: "https://www.mercadolibre.com/jms/mla/lgz/msl/login/H4sIAAAAAAAEAzWNwWrDMBAF_-WdFfuuY-h_iI385IisLLNak7Yh_15MyXFgmHlB-1q35D87EcHvXWuujoBdxUu3luqCiKYIGNX5QTkVMWl02kB8naGVy5Wl25kqooMIkMPvqWh_Iv6_ELB2RNzd9xHnOVMPFeOYGi3L0rXejFPubRKb0xdF08KRD24uv31cqMxufatZ8A4oMjy5SX4guh18_wF-DJxN1AAAAA/user"

        onLoadingChanged: {
            if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus) {
                window.loaded = true
            }
        }


        //handle click on links
        onNewViewRequested: function(request) {
            console.log(request.destination, request.requestedUrl)

            var url = request.requestedUrl.toString()
            //handle redirection links
            if (url.startsWith('https://www.mercadolibre.com/jms/mla/lgz/msl/login/H4sIAAAAAAAEAzWNwWrDMBAF_-WdFfuuY-h_iI385IisLLNak7Yh_15MyXFgmHlB-1q35D87EcHvXWuujoBdxUu3luqCiKYIGNX5QTkVMWl02kB8naGVy5Wl25kqooMIkMPvqWh_Iv6_ELB2RNzd9xHnOVMPFeOYGi3L0rXejFPubRKb0xdF08KRD24uv31cqMxufatZ8A4oMjy5SX4guh18_wF-DJxN1AAAAA/user')) {
                //get query params
                var reg = new RegExp('[?&]q=([^&#]*)', 'i');
                var param = reg.exec(url);
                if (param) {
                    console.log("url to open:", decodeURIComponent(param[1]))
                    Qt.openUrlExternally(decodeURIComponent(param[1]))
                } else {
                    Qt.openUrlExternally(url)
                                    request.action = WebEngineNavigationRequest.IgnoreRequest;
                }
            } else {
                Qt.openUrlExternally(url)
            }
        }

        onContextMenuRequested: function(request) {
            if (!Qt.inputMethod.visible) { //don't open it on when address bar is open
                request.accepted = true;
                contextMenuRequest = request
                contextMenu.x = request.x;
                contextMenu.y = request.y;
                contextMenu.open();
            }
        }


    }
    Menu {
        id: contextMenu

        MenuItem {
            id: copyItem
            text: i18n.tr("Copy link")
            enabled: webview.contextMenuRequest
            onTriggered: {
                console.log(webview.contextMenuRequest.linkUrl.toString())
                var url = ''
                if (webview.contextMenuRequest.linkUrl.toString().length > 0) {
                    url = webview.contextMenuRequest.linkUrl.toString()
                } else {
                    //when clicking on the video
                    url = webview.url
                }

                Clipboard.push(url)
                webview.contextMenuRequest = null;
            }
        }
    }

    RadialBottomEdge {
        id: nav
        visible: window.loaded
        actions: [
            RadialAction {
                id: reload
                iconName: "reload"
                onTriggered: {
                    webview.reload()
                }
                text: qsTr("")
            },

            RadialAction {
              id: back
              enabled: webview.canGoBack
              iconName: "go-previous"
              onTriggered: {
                webview.goBack()
              }
              text: qsTr("")

            },

            RadialAction {
                id: home
                iconName: "home"
                onTriggered: {
                    webview.url = 'https://www.mercadolibre.com/jms/mla/lgz/msl/login/H4sIAAAAAAAEAzWNwWrDMBAF_-WdFfuuY-h_iI385IisLLNak7Yh_15MyXFgmHlB-1q35D87EcHvXWuujoBdxUu3luqCiKYIGNX5QTkVMWl02kB8naGVy5Wl25kqooMIkMPvqWh_Iv6_ELB2RNzd9xHnOVMPFeOYGi3L0rXejFPubRKb0xdF08KRD24uv31cqMxufatZ8A4oMjy5SX4guh18_wF-DJxN1AAAAA/user'
                }
                text: qsTr("")
            },

            RadialAction {
              id: forward
              enabled: webview.canGoForward
              iconName: "go-next"
              onTriggered: {
                webview.goForward()
              }
              text: qsTr("")
            }
        ]
    }
    
        Rectangle {
        id: splashScreen
        color: "#ffffff"
        anchors.fill: parent

        ActivityIndicator{
            id:loadingflg
            anchors.centerIn: parent

            running: splashScreen.visible
        }

        states: [
            State { when: !window.loaded;
                PropertyChanges { target: splashScreen; opacity: 1.0 }
            },
            State { when: window.loaded;
                PropertyChanges { target: splashScreen; opacity: 0.0 }
            }
        ]

        transitions: Transition {
            NumberAnimation { property: "opacity"; duration: 400}
        }

    }
    Connections {
        target: webview

        onIsFullScreenChanged: {
            console.log('onIsFullScreenChanged:')
            window.setFullscreen(webview.isFullScreen)
            if (webview.isFullScreen) {
                nav.state = "hidden"
            }
            else {
                nav.state = "shown"
            }
        }
    }


        Connections {
            target: UriHandler

            onOpened: {

                if (uris.length > 0) {
                    console.log('Incoming call from UriHandler ' + uris[0]);
                    webview.url = uris[0];
                }
            }
        }

        Component.onCompleted: {
            //Check if opened the app because we have an incoming call
            if (Qt.application.arguments && Qt.application.arguments.length > 0) {
                for (var i = 0; i < Qt.application.arguments.length; i++) {
                    if (Qt.application.arguments[i].match(/^http/)) {
                        console.log(' open video to:', Qt.application.arguments[i])
                        webview.url = Qt.application.arguments[i];
                    }
                }
            }
            else {
            webview.url = myurl;
            }
        }

        function setFullscreen(fullscreen) {
            if (fullscreen) {
                if (window.visibility != ApplicationWindow.FullScreen) {
                    window.visibility = ApplicationWindow.FullScreen
                }
            } else {
                window.visibility = ApplicationWindow.Windowed
            }
        }
        
        
              function toggleApplicationLevelFullscreen() {
                setFullscreen(visibility !== ApplicationWindow.FullScreen)
            }

            Shortcut {
                sequence: StandardKey.FullScreen
                onActivated: window.toggleApplicationLevelFullscreen()
            }

            Shortcut {
                sequence: "F11"
                onActivated: window.toggleApplicationLevelFullscreen()
            }
}
