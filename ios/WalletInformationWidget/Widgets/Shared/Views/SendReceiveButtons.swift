//
//  SendReceiveButtons.swift
//  Chess032Wallet
//
//  Copyright © 2020 Chess032Wallet. All rights reserved.
//

import SwiftUI
import WidgetKit

struct SendReceiveButtons: View {
    var body: some View {
      VStack(alignment: .center, spacing: nil, content: {
        HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 16, content: {
          Link("receive", destination: URL(string: "Chess032Wallet://widget?action=openReceive")!).frame(minWidth: 144, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 32, maxHeight: 32, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).lineLimit(1).foregroundColor(.textColor).font(Font.system(size:11, weight: .semibold, design: .default)).background(Color.widgetBackground).overlay(
            RoundedRectangle(cornerRadius: 4.0)
              .stroke(Color.widgetBackground, lineWidth: 4.0))
          Link("send", destination: URL(string: "Chess032Wallet://widget?action=openSend")!).frame(minWidth: 144, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 32, maxHeight: 32, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).lineLimit(1).foregroundColor(.textColor).font(Font.system(size:11, weight: .semibold, design: .default)).background(Color.widgetBackground).overlay(
            RoundedRectangle(cornerRadius: 4.0)
              .stroke(Color.widgetBackground, lineWidth: 4.0))
        })
      })
    }
}

struct SendReceiveButtons_Previews: PreviewProvider {
    static var previews: some View {
        SendReceiveButtons().previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
