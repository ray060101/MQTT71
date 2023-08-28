//
//  ContentView.swift
//  MQTT7
//
//  Created by 林宇瑞 on 2023/8/26.
//
/*
 @Published var receivedMessage: String = "y"
 let host = "18.198.102.231"
 let username = "powerglow"
 let password = "aeg54160469"
 let topic = "topic/powerglow"  // 要發佈訊息的主題
 let payload = "測試訊息ray"   // 訊息內容
 
 let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
 var mqtt: CocoaMQTT!
 */

import SwiftUI
import CocoaMQTT
import Combine

final class MQTTAppStateContainer: ObservableObject {
    @Published var currentAppState = MQTTAppState() // Instantiate MQTTAppState here

    init() {
        // Workaround to support nested Observables, without this code changes to state is not propagated
        _ = currentAppState.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
}



struct ContentView: View {
    @ObservedObject var mqttManager = MQTTManager()
    @ObservedObject var appStateContainer = MQTTAppStateContainer()
    
    var body: some View {
        Text("MQTT Example")
            .onAppear {
                mqttManager.connect()
            }
    }
}

final class MQTTManager: ObservableObject {
    let host = "18.198.102.231"
    let username = "powerglow"
    let password = "aeg54160469"
    let topic = "topic/powerglow"
    let payload = "測試訊息ray"

    private var mqttClient: CocoaMQTT?

    func connect() {
        // Set up and connect MQTT client here
        mqttClient = CocoaMQTT(clientID: "iOS Device", host: host, port: 1883)
        mqttClient?.username = username
        mqttClient?.password = password
        mqttClient?.willMessage = CocoaMQTTMessage(topic: topic, string: payload)
        mqttClient?.keepAlive = 60
        //mqttClient?.delegate = self

        _ = mqttClient?.connect()
    }
    
    
}

enum MQTTAppConnectionState {
    case connected
    case disconnected
    case connecting
    case connectedSubscribed
    case connectedUnSubscribed

    var description: String {
        switch self {
        case .connected:
            return "Connected"
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting"
        case .connectedSubscribed:
            return "Subscribed"
        case .connectedUnSubscribed:
            return "Connected Unsubscribed"
        }
    }
    var isConnected: Bool {
        switch self {
        case .connected, .connectedSubscribed, .connectedUnSubscribed:
            return true
        case .disconnected,.connecting:
            return false
        }
    }
    
    var isSubscribed: Bool {
        switch self {
        case .connectedSubscribed:
            return true
        case .disconnected,.connecting, .connected,.connectedUnSubscribed:
            return false
        }
    }
}


final class MQTTAppState: ObservableObject {
    @Published var appConnectionState: MQTTAppConnectionState = .disconnected
    @Published var historyText: String = ""
    private var receivedMessage: String = ""

    func setReceivedMessage(text: String) {
        receivedMessage = text
        historyText = historyText + "\n" + receivedMessage
    }

    func clearData() {
        receivedMessage = ""
        historyText = ""
    }

    func setAppConnectionState(state: MQTTAppConnectionState) {
        appConnectionState = state
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
