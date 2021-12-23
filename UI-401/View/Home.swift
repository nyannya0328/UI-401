//
//  Home.swift
//  UI-401
//
//  Created by nyannyan0328 on 2021/12/23.
//

import SwiftUI

struct Home: View {
    @SceneStorage("isZooming") var isZoom : Bool = false
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack{
                
                
                
                ForEach(1...5,id:\.self){index in
                    
                    Image("p\(index)")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: getRect().width - 30, height: 250)
                        .cornerRadius(15)
                        .addPintchZoom()
                    
                }
            
                
              
                
                
            }
            .padding()
            
            
        }
        .safeAreaInset(edge: .top) {
            
            
            HStack{
                
                
                Button {
                    
                    
                } label: {
                    
                    Image(systemName: "camera.fill")
                }
                
                Spacer()
                
                
                
                Button {
                    
                    
                } label: {
                    
                    Image(systemName: "paperplane.circle.fill")
                }


                
            }
            .font(.system(size: 20, weight: .bold))
            .padding([.horizontal,.top])
            .foregroundColor(.primary)
            .overlay(
            
            Text("InstaGram")
                .font(.title)
            
            
            )
            .background(.ultraThickMaterial)
            .offset(y: isZoom ? -200 : 0)
            .animation(.easeInOut, value: isZoom)



        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View{
    
    func addPintchZoom()->some View{
        
        pintchZoomContext {
            return self
        }
    }
}

struct pintchZoomContext<Content : View> : View{
    
    var content : Content
    
    init(@ViewBuilder content : @escaping()->Content) {
        
        self.content = content()
    }
    
    @State var offset : CGPoint = .zero
    @State var scale : CGFloat = 0
    @State var scalePotision : CGPoint = .zero
    
    @SceneStorage("isZooming") var isZoom : Bool = false
    
    var body: some View{
        
        content
            .overlay(
            
                GeometryReader{proxy in
                    
                    let size = proxy.size
                    
                    ZoomGesture(size: size, scale: $scale, offset: $offset, scalePoticion: $scalePotision)
                    
                    
                }
            
            
            )
            .scaleEffect(1 + (scale < 0 ? 0 :scale),anchor: .init(x: offset.x, y: offset.y))
            .offset(x: offset.x, y: offset.y)
            .zIndex(scale != 0 && offset != .zero ? 1000 : 0)
            .onChange(of: scale) { newValue in
                
                
                if scale == -1{
                    
                    isZoom = (scale != 0)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25){
                        
                        scale = 0
                        
                    }
                    
                }
                
            }
            .onChange(of: offset) { newValue in
                
                isZoom = (offset != .zero)
                
            }
        
        
    }
    
}

struct ZoomGesture : UIViewRepresentable{
    
    var size : CGSize
    @Binding var scale : CGFloat
    @Binding var offset : CGPoint
    @Binding var scalePoticion : CGPoint
    
    func makeCoordinator() -> Coordinator {
        
        return Coordinator(parent: self)
        
    }
    
    func makeUIView(context: Context) ->UIView {
        
        let view = UIView()
        view.backgroundColor = .clear
        
        let pintchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePintch(sender:)))
        
        view.addGestureRecognizer(pintchGesture)
        
        
        let panGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.hanlePan(sender:)))
        
        panGesture.delegate = context.coordinator
        
        view.addGestureRecognizer(panGesture)
        
        
        return view
        
        
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
    class Coordinator : NSObject,UIGestureRecognizerDelegate{
        
        var parent : ZoomGesture
        
        var isPinchReleaced : Bool = false
        
        init(parent : ZoomGesture) {
            self.parent = parent
        }
        
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            
            return true
        }
        
        @objc
        func hanlePan(sender : UIPanGestureRecognizer){
            
            
            sender.maximumNumberOfTouches = 2
            
            if (sender.state == .began || sender.state == .changed){
                
                if let view = sender.view,parent.scalePoticion != .zero{
                    
                    
                    
                    let translation = sender.translation(in: view)
                    
                    parent.offset = translation
                    
                    
                }
                
                
               
                
                
                
            }
            else{
                
                
                withAnimation(.easeInOut(duration: 0.5)){
                    
                    
                    parent.offset = .zero
                    parent.scalePoticion = .zero
                }
            }
            
            
        }
        
        
        @objc
        func handlePintch(sender : UIPinchGestureRecognizer){
            
            isPinchReleaced = (sender.numberOfTouches != 2 || isPinchReleaced)
            
            
            if sender.state == .began || sender.state == .changed{
                
                
                parent.scale = (sender.scale - 1)
                
                
                let scalePoint = CGPoint(x: sender.location(in: sender.view).x / sender.view!.frame.width, y: sender.location(in: sender.view).y / sender.view!.frame.height)
                
                parent.scalePoticion = (parent.scalePoticion == .zero ? scalePoint : parent.scalePoticion)
                
                
            }
            
            else{
                
                withAnimation(.easeInOut(duration: 0.5)){
                    
                    parent.scale = -1
                    parent.scalePoticion = .zero
                    isPinchReleaced = false
                    
                    
                    
                }
                
                
                
                
            }
            
            
            
            
            
            
        }
    }
    
    

}


