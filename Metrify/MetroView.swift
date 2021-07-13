//
//  MetroView.swift
//  Metrify
//
//  Created by Kai Azim on 2021-07-02.
//

import SwiftUI
import AVFoundation

var player: AVAudioPlayer!

struct MetroView: View {
    
    @ObservedObject var metroManager = metroTimer()
    
    @State private var effectIndex = 2
    @State private var effect = ["Metronome","Typewriter","Electronic"]
    @State private var beatsIndex:Double = 4
    @State private var fastPlus = false
    @State private var fastMinus = false
    @State private var timer: Timer?
    @State private var wasRunning = false
    
    @State private var BPM: Double = 120
    @State private var difference1:Float = 0
    @State private var difference2:Float = 0
    @State private var currentNum = 1
    @State private var meas1 = -1
    @State private var meas2 = -1
    @State private var meas3 = -1
    @State private var calc1 = -1
    @State private var speedString = "Allegro"
    
    func runRestart() {
        if(metroManager.mode == .running) {
            wasRunning = true
        }
        else {
            wasRunning = false
        }
        metroManager.stop()
        if(wasRunning == true) {
            metroManager.start(interval: 60/BPM,
                               effect: effectIndex,
                               time: Int(beatsIndex))
        }
    }
    
    let blueGradient = LinearGradient(
                            gradient: Gradient(colors: [Color("Blue1"), Color("Blue2")]),
                            startPoint: .topLeading, endPoint: .bottomTrailing)
    let grayGradient = LinearGradient(
                            gradient: Gradient(colors: [Color(.systemGray4), Color(.systemGray4)]),
                            startPoint: .topLeading, endPoint: .bottomTrailing)
    let BPMtimer = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .foregroundColor(Color(.systemGray6))
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            difference2 = 60000/difference1
                            BPM = Double(Int(difference2/1000))
                            
                            if(currentNum == 1) {
                                meas1 = Int(BPM)
                                currentNum = 2
                            }
                            else if(currentNum == 2) {
                                meas2 = Int(BPM)
                                currentNum = 3
                            }
                            else if(currentNum == 3) {
                                meas3 = Int(BPM)
                                currentNum = 1
                            }
                            
                            calc1 = meas1 + meas2 + meas3
                            BPM = Double(calc1/3)
                            difference1 = 0
                            
                        }, label: {
                            VStack {
                                Label("BPM", systemImage: "speedometer")
                                Text("\(Int(BPM))")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                Text(speedString)
                                    .font(.footnote)
                            }
                            .foregroundColor(Color("ButtonAccent"))
                        })
                        
                        Spacer()
                        
                        HStack {
                            Button(action: {
                                if(self.fastMinus) {
                                    self.fastMinus.toggle()
                                    self.timer?.invalidate()
                                } else {
                                    BPM = BPM - 1
                                }
                            }, label: {
                                if(metroManager.mode == .stopped) {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(grayGradient)
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Image(systemName: "minus.square")
                                                .resizable()
                                                .frame(width: 90, height: 90)
                                                .foregroundColor(Color("ButtonAccent"))
                                                .font(Font.title.weight(.light))
                                        )
                                } else {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(blueGradient)
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Image(systemName: "minus.square")
                                                .resizable()
                                                .frame(width: 90, height: 90)
                                                .foregroundColor(Color("ButtonAccent"))
                                                .font(Font.title.weight(.light))
                                        )
                                }
                            })
                            .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                                self.fastMinus = true
                                //or fastforward has started to start the timer
                                self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                                    self.BPM -= 1
                                })
                            })
                            
                            Button(action: {
                                if(self.fastPlus) {
                                    self.fastPlus.toggle()
                                    self.timer?.invalidate()
                                } else {
                                    BPM = BPM + 1
                                }
                            }, label: {
                                if(metroManager.mode == .stopped) {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(grayGradient)
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Image(systemName: "plus.square")
                                                .resizable()
                                                .frame(width: 90, height: 90)
                                                .foregroundColor(Color("ButtonAccent"))
                                                .font(Font.title.weight(.light))
                                        )
                                } else {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(blueGradient)
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Image(systemName: "plus.square")
                                                .resizable()
                                                .frame(width: 90, height: 90)
                                                .foregroundColor(Color("ButtonAccent"))
                                                .font(Font.title.weight(.light))
                                        )
                                }
                            })
                            .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                                self.fastPlus = true
                                //or fastforward has started to start the timer
                                self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                                    self.BPM += 1
                                })
                            })
                        }   //the plus and minus buttons
                        
                        .animation(.easeIn)
                        .onChange(of: BPM) { _ in
                            if(BPM <= 15) {
                                BPM = 15
                            }
                            if(BPM >= 500) {
                                BPM = 500
                            }
                            
                            if(BPM >= 15) {                 //if BPM is greater than 15
                                speedString = "Grave"
                            }
                            if(BPM >= 40) {                 //if BPM is greater than 40
                                speedString = "Lento"
                            }
                            if(BPM >= 45) {                 //if BPM is greater than 45
                                speedString = "Largo"
                            }
                            if(BPM >= 55) {                 //if BPM is greater than 55
                                speedString = "Adagio"
                            }
                            if(BPM >= 65) {                 //if BPM is greater than 65
                                speedString = "Adagietto"
                            }
                            if(BPM >= 73) {                 //if BPM is greater than 73
                                speedString = "Andante"
                            }
                            if(BPM >= 86) {                 //if BPM is greater than 86
                                speedString = "Moderato"
                            }
                            if(BPM >= 98) {                 //if BPM is greater than 98
                                speedString = "Allegretto"
                            }
                            if(BPM >= 109) {                 //if BPM is greater than 109
                                speedString = "Allegro"
                            }
                            if(BPM >= 132) {                 //if BPM is greater than 132
                                speedString = "Vivace"
                            }
                            if(BPM >= 168) {                 //if BPM is greater than 168
                                speedString = "Presto"
                            }
                            if(BPM >= 178) {                 //if BPM is greater than 178
                                speedString = "Prestissimo"
                            }
                            
                            runRestart()
                        }
                    }   //BPM chooser
                    
                    HStack {
                        Image(systemName: "hands.clap")
                        Picker("Effect", selection: $effectIndex) {
                            ForEach(0 ..< effect.count) { index in
                                    Text(self.effect[index]).tag(index)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: effectIndex) { _ in
                            runRestart()
                        }
                    }   //Effect chooser
                    
                    HStack {
                        Image(systemName: "music.quarternote.3")
                        Slider(value: $beatsIndex, in: 1...15, step: 1)
                        Text("\(Int(beatsIndex))")
                            .onChange(of: beatsIndex) { _ in
                                runRestart()
                            }
                    }   //Beat chooser
                    
                    ZStack {
                        VStack {
                            if(metroManager.mode == .stopped) {
                                RoundedRectangle(cornerRadius: 25.0)
                                    .fill(grayGradient)
                            } else {
                                RoundedRectangle(cornerRadius: 25.0)
                                    .fill(blueGradient)
                            }
                        }
                        .animation(.easeIn)
                        
                        VStack {
                            Text("\(metroManager.beat)")
                                .font(Font.system(size: 60))
                            
                            if(metroManager.mode == .stopped) {
                                Button(action: {
                                    metroManager.start(interval: 60/BPM,
                                                       effect: effectIndex,
                                                       time: Int(beatsIndex))
                                }, label: {
                                    Image(systemName: "play.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(Color("ButtonAccent"))
                                        .font(.largeTitle)
                                        
                                })
                            } else {
                                Button(action: {
                                    metroManager.stop()
                                }, label: {
                                    Image(systemName: "pause.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(Color("ButtonAccent"))
                                        .font(.largeTitle)
                                })
                            }
                        }
                    }   //Play/Pause
                }
                .padding()
            }
            Spacer()
        }
        .onReceive(BPMtimer) { _ in difference1 += 0.001}
        .padding()
    }
}   //metronome view

enum isMetroRunning {
    case running
    case stopped
}   //variables for the metronome state

class metroTimer: ObservableObject {
    @Published var mode:isMetroRunning = .stopped
    @Published var beat = 0
    
    var timer = Timer()
    
    func start(interval: Double, effect: Int, time: Int) {
        mode = .running
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true) { timer in
                self.playSound(effect: effect)
                self.beat = self.beat + 1
                if(self.beat >= time+1) {
                    self.beat = 1
                }
            }
    }      //this starts the metronome
    func stop() {
        mode = .stopped
        timer.invalidate()
        self.beat = 0
    }                                               //this stops the metronome
    func playSound(effect: Int) {
        var url = Bundle.main.url(forResource: "Metronome", withExtension: "mp3")
        
        switch effect {
        case 0:
            url = Bundle.main.url(forResource: "Click", withExtension: "mp3")
        
        case 1:
            url = Bundle.main.url(forResource: "Typewriter", withExtension: "mp3")
        
        case 2:
            url = Bundle.main.url(forResource: "Electronic", withExtension: "mp3")
            
        default:
            url = Bundle.main.url(forResource: "Metronome", withExtension: "mp3")
        }
        
        guard url != nil else {
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url!)
            player?.play()
        } catch {
            print("\(error)")
        }
    }   //this function plays the sound for the metronome
}   //play, stop, play sounds functions
