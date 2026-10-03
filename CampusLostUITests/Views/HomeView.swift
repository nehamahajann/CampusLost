import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("What happened?")
                    .font(.title2.weight(.semibold))
                    .padding(.top, 40)

                NavigationLink {
                    ReportLostItemView()
                } label: {
                    Label("I lost something", systemImage: "questionmark.circle")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)

                NavigationLink {
                    ReportFoundItemView()
                } label: {
                    Label("I found something", systemImage: "checkmark.circle")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)

                Spacer()

                NavigationLink {
                    MyReportsView()
                } label: {
                    Label("My reports", systemImage: "list.bullet")
                }
                .padding(.bottom, 20)
            }
            .padding()
            .navigationTitle("CampusLost")
        }
    }
}
