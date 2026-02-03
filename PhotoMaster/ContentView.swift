//
//  ContentView.swift
//  PhotoMaster
//
//  Created by 阪上八雲 on 2026/02/04.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var text:String = ""
    @State var selectedItem: PhotosPickerItem?
    @State var selectedImage:Image? = nil
    @State private var showAlert:Bool = false
    var body: some View {
        VStack {
            Spacer()
            imageWithFrame
            Spacer()
            TextField("テキストを入力",text: $text)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(.rect(cornerRadius:10))
                .padding(.bottom,8)
            Button{
                saveEditedImage()
            }label:{
                Label("保存する",systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity,minHeight:50)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .disabled(selectedImage == nil)
        }
        .padding(.horizontal)
        .onChange(of:selectedItem,initial:true){
            loadImage()
        }
        .alert(isPresented:$showAlert){
            Alert(title: Text("保存完了"),message: Text("画像がフォトライブラリに保存されました。"),dismissButton: .default(Text("OK")))
        }
    }
    
    var imageWithFrame: some View{
        Rectangle()
            .fill(Color.white)
            .frame(width:350,height:520)
            .shadow(radius:10)
            .overlay{
                ZStack{
                    VStack(spacing:25){
                    Rectangle()
                        .fill(Color.black)
                        .frame(width:300,height:400)
                        .overlay{
                            if let displayImage = selectedImage{
                                displayImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:300,height: 400)
                                    .clipped()
                            }else{
                                Image(systemName:"photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(.white)
                                    .padding(20)
                                    .background(Color.gray.opacity(0.7))
                                    .clipShape(.circle)
                            }
                        }
                        Text(text)
                            .font(.custom("yosugara ver12",size:40))
                            .foregroundStyle(.black)
                            .frame(height:40)
                            
                        }
                    
                    PhotosPicker(selection:$selectedItem,matching: .images,photoLibrary: .shared()){
                        Color.clear
                            .contentShape(.rect)
                    }
                }
            }
    }
    
    private func loadImage(){
        guard let item = selectedItem else {return}
        item.loadTransferable(type: Data.self){result in
            switch result{
            case.success(let data):
                if let data = data,let uiImage = UIImage(data:data){
                    selectedImage = Image(uiImage:uiImage)
                }else{
                    
                }
            case.failure(let error):
                print("画像の読み込みに失敗しました\(error.localizedDescription)")
            }
        }
    }
    
    private func saveEditedImage(){
        let renderer = ImageRenderer(content:imageWithFrame)
        renderer.scale = 3
        
        if let uiImage = renderer.uiImage{
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            showAlert = true
            selectedImage = nil
            selectedItem = nil
            text = ""
        }
    }
}
#Preview {
    ContentView()
}
