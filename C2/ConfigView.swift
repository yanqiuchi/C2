//
//  ConfigView.swift
//  C2
//
//  Created by chengxin on 2023/8/10.
//

import SwiftUI
import UserNotifications

struct ConfigView: View {
    
    @State private var newLabel = ""
    
    @State private var newSecret = ""
    
    @State private var searchText: String = ""
    
    @State private var isBlackToWhite = true
    
    @State private var isFocused: Bool = false
    
    @State private var showingAddSheet = false
    
    @State private var showAlertForDuplicate = false
    
    @State private var selectedTab: Int = 0
    
    @State private var buttonColor: Color = Color.black
    
    let focusedBorderColor: Color = Color.blue
    
    let tabColor: Color = Color.green.opacity(0.8)
    
    @State private var g2faItems: [G2FAItem] = DataManager.shared.loadItems() ?? []
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack {
                    Spacer(minLength: 0)
                    modernTabs(width: geometry.size.width)
                        .frame(width: geometry.size.width * 0.75)
                    Spacer(minLength: 0)
                    ZStack {
                        Button(action: {
                            showingAddSheet.toggle()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(buttonColor)
                                .background(Color.clear)
                                .onAppear {
                                    animateButtonColor()
                                }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.trailing, 15)
                }

                Spacer().frame(height: 20)

                if selectedTab == 0 {
                    centerContent(width: geometry.size.width)
                        .frame(height: geometry.size.height * 0.75)
                        .transition(.opacity)
                } else {
                    centerContent(width: geometry.size.width)
                        .frame(height: geometry.size.height * 0.75)
                        .transition(.opacity)
                }

                content(width: geometry.size.width)
                    .frame(height: geometry.size.height * 0.025)
                Spacer(minLength: geometry.size.height * 0.025)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(isPresented: $showingAddSheet, content: {
                VStack(spacing: 20) {
                    Text("Add New G2FA Item")
                        .font(.headline)
                    TextField("Label", text: $newLabel)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8.0)
                    TextField("Secret", text: $newSecret)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8.0)
                    HStack(spacing: 10) {
                        Button("Cancel") {
                            showingAddSheet = false
                            newLabel = ""
                            newSecret = ""
                        }
                        Button("Add") {
                            addG2FAItem()
                            showingAddSheet = false
                        }
                    }
                    .padding()
                }
                .padding()
            })
        }
        .alert(isPresented: $showAlertForDuplicate) {
            Alert(title: Text("Error"), message: Text("Duplicate label. Item not added."), dismissButton: .default(Text("OK")))
        }
    }

    func animateButtonColor() {
        withAnimation(Animation.linear(duration: 4).repeatForever(autoreverses: true)) {
            if isBlackToWhite {
                buttonColor = Color.white
            } else {
                buttonColor = Color.black
            }
        }
        isBlackToWhite.toggle()
    }

    func addG2FAItem() {
        // Check for a duplicate label
        let isDuplicate = g2faItems.contains(where: { $0.label == newLabel })
        if isDuplicate {
            // Show an alert
            showAlertForDuplicate = true
        } else {
            // Add the item
            let newItem = G2FAItem(label: newLabel, secret: newSecret)
            g2faItems.append(newItem)
            DataManager.shared.saveItems(g2faItems)
            newLabel = ""
            newSecret = ""
            NotificationCenter.default.post(name: Notification.Name("UpdateStatusBarNotification"), object: nil)
        }
    }


    func modernTabs(width: CGFloat) -> some View {
        HStack(spacing: width * 0.10) {
            Text("G2FA")
                .underline(selectedTab == 1, color: tabColor)
                .onTapGesture {
                    withAnimation {
                        selectedTab = 1
                    }
                }
        }
        .frame(width: width * 0.80)
        .font(.title2)
    }

    func centerContent(width: CGFloat) -> some View {
        ScrollView {
            VStack(spacing: 0.5) {
                ForEach(Array(g2faItems.enumerated()), id: \.element.id) { index, item in
                    CustomListRow(index: index + 1, item: item) {
                        deleteItem(at: index)
                    }
                    .background(Color.clear)
                }
            }
            .frame(width: width * 0.75)
        }
    }

    func content(width: CGFloat) -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(maxWidth: .infinity)
            .frame(width: width * 0.80)
    }
    
    func deleteItem(at index: Int) {
        g2faItems.remove(at: index)
        DataManager.shared.saveItems(g2faItems)
        NotificationCenter.default.post(name: Notification.Name("UpdateStatusBarNotification"), object: nil)
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigView()
    }
}

struct CustomListRow: View {
    
    var index: Int
    
    var item: G2FAItem
    
    var onDelete: () -> Void
    
    @State private var displayedCode: String?
    
    @State private var isCopyButtonPressed: Bool = false
    
    @State private var verificationCode: String = ""
    
    @State private var showCode: Bool = true
    
    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    init(index: Int, item: G2FAItem, onDelete: @escaping () -> Void) {
        self.index = index
        self.item = item
        self.onDelete = onDelete
        self._verificationCode = State(initialValue: DataManager.shared.getCode(secret: item.secret))
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Text("\(index).")
                    .font(.title3)
                    .foregroundColor(.black)
                    .frame(width: geometry.size.width * 0.08)
                
                Text(item.label)
                    .font(.title3)
                    .foregroundColor(.black)
                    .frame(maxWidth: geometry.size.width * 0.1, alignment: .leading)
                    .truncationMode(.tail)
                
                Text(item.secret)
                    .font(.title3)
                    .foregroundColor(.gray)
                    .frame(maxWidth: geometry.size.width * 0.4, alignment: .leading)
                    .truncationMode(.tail)
                    .layoutPriority(1)
                
                Rectangle().fill(Color.clear).frame(width: geometry.size.width * 0.04)
                
                Button(action: {
                    withAnimation {
                        isCopyButtonPressed.toggle()
                    }
                    
                    let pasteboard = NSPasteboard.general
                    pasteboard.declareTypes([.string], owner: nil)
                    pasteboard.setString(item.secret, forType: .string)
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Copied!"
                    content.body = "Secret has been copied to clipboard."
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                    UNUserNotificationCenter.current().add(request)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            isCopyButtonPressed.toggle()
                        }
                    }
                }) {
                    Image(systemName: "doc.on.doc")
                        .resizable()
                        .foregroundColor(Color.blue)
                        .font(Font.system(size: 16))
                        .frame(width: 14, height: 14)
                        .scaleEffect(isCopyButtonPressed ? 1.3 : 1.0)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Rectangle().fill(Color.clear).frame(width: geometry.size.width * 0.08)
                
                Button(action: {
                    onDelete()
                }) {
                    Image(systemName: "trash")
                        .resizable()
                        .foregroundColor(.red)
                        .font(Font.system(size: 16))
                        .frame(width: 14, height: 14)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Rectangle().fill(Color.clear).frame(width: geometry.size.width * 0.08)
                
                Button(action: {
                    let code = DataManager.shared.getCode(secret: item.secret)
                    
                    let pasteboard = NSPasteboard.general
                    pasteboard.declareTypes([.string], owner: nil)
                    pasteboard.setString(code, forType: .string)
                    
                    displayedCode = code
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        displayedCode = nil
                    }
                }) {
                    Image(systemName: displayedCode == nil ? "arrow.right.circle" : "checkmark.circle")
                        .resizable()
                        .font(Font.system(size: 16))
                        .frame(width: 14, height: 14)
                }
                .buttonStyle(BorderlessButtonStyle())
                
                if showCode {
                       Text(verificationCode)
                           .font(.title3)
                           .foregroundColor(.black)
                           .padding(.leading)
                           .transition(.opacity)
                   }
            }
            .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14))
            .background(Color.clear)
        }
        .frame(height: 48)
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 1.0)) { // 可以调整动画时长以适应新的时间间隔
                showCode = false
            }
            verificationCode = DataManager.shared.getCode(secret: item.secret)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) { // 0.5s后再次显示验证码，以便实现渐变效果
                withAnimation(.easeInOut(duration: 1.0)) {
                    showCode = true
                }
            }
        }
    }
}
