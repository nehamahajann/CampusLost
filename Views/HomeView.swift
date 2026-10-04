import SwiftUI

struct HomeView: View {
    @State private var sharedPhoto: UIImage?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                if let sharedPhoto {
                    NavigationLink {
                        ReportFoundItemView(sharedPhoto: sharedPhoto)
                    } label: {
                        HStack(spacing: 12) {
                            Image(uiImage: sharedPhoto)
                                .resizable().scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Continue found-item report").font(.subheadline.weight(.semibold))
                                Text("From your shared photo").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.secondary)
                        }
                        .cardStyle()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 4)
                }

                ZStack {
                    Circle().fill(AppTheme.accent.opacity(0.12)).frame(width: 104, height: 104)
                    Image(systemName: "location.magnifyingglass")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(AppTheme.accent)
                }

                VStack(spacing: 4) {
                    Text("CampusLost").font(.title.bold())
                    Text("Reuniting students with what\nthey've lost")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 12) {
                    NavigationLink {
                        ReportLostItemView()
                    } label: {
                        Label("I lost something", systemImage: "questionmark.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.lost)

                    NavigationLink {
                        ReportFoundItemView()
                    } label: {
                        Label("I found something", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.found)
                }

                Spacer()

                Divider()

                HStack(spacing: 0) {
                    NavigationLink {
                        MyReportsView()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "list.bullet.rectangle")
                                .font(.system(size: 20, weight: .semibold))
                            Text("My reports").font(.caption.weight(.medium))
                        }
                        .foregroundStyle(AppTheme.accent)
                        .frame(maxWidth: .infinity)
                    }

                    NavigationLink {
                        BrowseFoundItemsView()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Browse").font(.caption.weight(.medium))
                        }
                        .foregroundStyle(AppTheme.found)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 14)
                .padding(.bottom, 4)
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                sharedPhoto = SharedPhotoStore.pendingPhoto()
            }
        }
    }
}
