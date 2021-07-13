//
//  ContentView.swift
//  Metrify
//
//  Created by Kai Azim on 2021-06-30.
//

import SwiftUI

struct ContentView: View {
    
    @State var showSidebar: Bool = false
    
    var body: some View {
        MetroView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
