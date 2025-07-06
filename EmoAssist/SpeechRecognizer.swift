//
//  SpeechRecognizer.swift
//  EmoAssist
//
//  Created by Aditi More on 7/6/25.
//


import Foundation
import Speech

class SpeechRecognizer: NSObject, SFSpeechRecognizerDelegate {
    private let recognizer = SFSpeechRecognizer()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let engine = AVAudioEngine()

    func startTranscribing(onResult: @escaping (String) -> Void) {
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request else { return }

        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        engine.prepare()
        try? engine.start()

        task = recognizer?.recognitionTask(with: request) { result, _ in
            if let result = result {
                onResult(result.bestTranscription.formattedString)
            }
        }
    }

    func stopTranscribing() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
    }
}
