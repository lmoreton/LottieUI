//
//  AsyncLottieView.swift
//
//
//  Created by Tomas Martins on 20/04/22.
//

import Lottie
import SwiftUI

/// A SwiftUI view to present a Lottie animation from a remote URL. To present an animation from a local file, use ``LottieView`` instead.
public struct AsyncLottieView<Content: View>: View {
    let content: (AsyncLottiePhase) -> Content
    let url: URL
    let cacheProvider: AnimationCacheProvider?

    @State private var phase: AsyncLottiePhase = .loading
    
    /// Creates a view that presents a Lottie animation from a remote URL to be displayed in phases
    /// - Parameters:
    ///   - url: The URL of the Lottie animation to be displayed
    ///   - animationCache: Cache to improve performance when playing recurrent animations.
    ///   - content: A closure that takes the current phase as an input and returns the view to be displayed in each phase
    public init(
        url: URL,
        animationCache: AnimationCacheProvider? = LRUAnimationCache.sharedCache,
        @ViewBuilder content: @escaping (AsyncLottiePhase) -> Content
    ) {
        self.url = url
        self.cacheProvider = animationCache
        self.content = content
    }

    public var body: some View {
        content(phase)
            .onAppear {
                Animation.loadedFrom(url: url, closure: { animation in
                    if let animation = animation {
                        self.phase = .success(.init(animation: animation))
                    } else {
                        self.phase = .error
                    }
                }, animationCache: cacheProvider)
            }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLottieView(url: .init(string: "https://assets3.lottiefiles.com/packages/lf20_hbdelex6.json")!) { phase in
            switch phase {
            case .loading:
                Text("Loading...")
            case .error:
                Text("Error")
            case .success(let lottieView):
                lottieView
                    .loopMode(.loop)
                    .renderingEngine(.coreAnimation)
            }
        }
//        AsyncLottieView(url: .init(string: "https://assets3.lottiefiles.com/packages/lf20_hbdelex6.json")!) { lottieView in
//            lottieView
//                .loopMode(.loop)
//        } placeholder: {
//            Text("Loading")
//        }
    }
}
