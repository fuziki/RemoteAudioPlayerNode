//
//  main.swift
//  
//
//  Created by fuziki on 2021/05/17.
//

import ServerApp
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
try app.run()
