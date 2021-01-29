/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

enum Prop: CaseIterable, Equatable {
  case fancyHat
  case glasses
  case mustache
  case eyeball
  case robot
  
  private func nextCase(_ cases: [Self]) -> Self? {
    if self == cases.last {
      return cases.first
    } else {
      return cases
        .drop(while: ) { $0 != self }
        .dropFirst()
        .first
    }
  }
  
  func next() -> Self {
    nextCase(Self.allCases) ?? .eyeball
  }
  
  func previous() -> Self {
    nextCase(Self.allCases.reversed()) ?? .fancyHat
  }
}

struct PropChooser: View {
  
  @Binding var currentProp: Prop
  
  func takeSnapshot() {
    arView.snapshot(saveToHDR: false) { (image) in
      let compressedImage = UIImage(data: (image?.pngData())!)
      UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil, nil)
    }
  }
  
  var body: some View {
    HStack {
      Button(action: {
        currentProp = currentProp.previous()
      }) {
        Image(systemName: "arrowtriangle.left.fill")
          .resizable()
          .frame(width: 44, height: 44)
      }
      
      Spacer()
      
      Button(action: {
        takeSnapshot()
      }) {
        Circle().stroke(lineWidth: 12.0)
      }
      
      Spacer()
      
      Button(action: {
        currentProp = currentProp.next()
      }) {
        Image(systemName: "arrowtriangle.right.fill")
          .resizable()
          .frame(width: 44, height: 44)
      }
    }
    .frame(height: 100)
    .foregroundColor(.primary)
    .padding(.horizontal)
  }
}

struct PropChooser_Previews: PreviewProvider {
    static var previews: some View {
      PropChooser(currentProp: .constant(.eyeball))
    }
}
