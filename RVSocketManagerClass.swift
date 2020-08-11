//
//  RVSocketManagerClass.swift
//  RVSocketIO
//
//  Created by Ram Vinay on 03/01/20.
//  Copyright © 2020 Ram Vinay. All rights reserved.
//


import UIKit
import SocketIO


//MARK:- RVSocketManagerClass
public class RVSocketManagerClass  {
    
    public static let manager = RVSocketManagerClass(url: RVSocketURL.socketURl!)
    let managerClass:SocketManager?
    public var connectionClosure :(( _ isConnected: Bool) -> Void)?

    
    private init() {
        managerClass = nil
    }
    
    //init socket
    public init(url:URL) {
        managerClass = SocketManager(socketURL: url, config: [.log(true), .reconnects(true), .compress])
        guard let socket = managerClass?.defaultSocket else {
            return
        }
        socket.connect()
        connectSocket(socket: socket)
    }
    
    public func connect() {
        guard let socket = managerClass?.defaultSocket else {
            return
        }
        socket.connect()
        connectSocket(socket: socket)
    }
    
    //check socket connection status
    public func isSocketConnected() -> Bool {
        guard let socket = managerClass?.defaultSocket else {
            return false
        }
        return socket.status == .connected ? true : false
    }
    
    // dis-connecting socket
    public func disConnectSocket() {
        guard let socket = managerClass?.defaultSocket else{
            return
        }
        socket.disconnect()
    }
    
    fileprivate func connectSocket(socket: SocketIOClient) {
        socket.on(clientEvent: .connect) { [weak self]  (data, ack ) in
            self?.connectionClosure?(true)
        }
    }
    
}


//MARK:- All event request details
extension RVSocketManagerClass {
    
    public func emitEvent(with params:[String:Any], eventName:String) {
        
        guard let socket = managerClass?.defaultSocket else {
            return
        }
        socket.emit(eventName, params)
    }
    
    public func onEvent<RVSocketModel: Decodable>(eventName:String, completion: @escaping (RVSocketModel) -> ()) {
        guard let socket = managerClass?.defaultSocket else {
            return
        }
        socket.on(eventName) {  [weak self] data, ack in
            if data.count > 0 {
                debugPrint("=== RVSocket on event: === ", eventName)
                self?.decodeObject(data[0]) { (socketModel:RVSocketModel) in
                    completion(socketModel)
                }
                
            }
        }
    }
    
    public func offEvent(eventName:String) {
        guard let socket = managerClass?.defaultSocket else {
            return
        }
        debugPrint("=== RVSocket off event: === ", eventName)
        socket.off(eventName)
    }

}


//MARK:- Encode-Decode functionality
extension RVSocketManagerClass  {
    func decodeObject<Y: Decodable>(_ object:Any,decoder: JSONDecoder = .init(), completion: @escaping (Y) -> ()) {
        do {
            let data = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            let model = try decoder.decode(Y.self, from: data)
            completion(model)
        } catch let jsonErr {
            print("failed to decode, \(jsonErr)")
        }
    }
}
