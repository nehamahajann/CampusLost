import SwiftUI

struct HomeView: View {
    @State private var sharedPhoto: UIImage?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        iconBadge(icon: "questionmark.circle.fill", color: AppTheme.lost)
                        Image(systemName: "arrow.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        iconBadge(icon: "checkmark.circle.fill", color: AppTheme.found)
                    }
                    Text("CampusLost").font(.largeTitle.bold())
                    Text("Lost it? Found it? Let's sort it out.")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)

                if let sharedPhoto {
                    NavigationLink {
                        ReportFoundItemView(sharedPhoto: sharedPhoto)
                    } label: {
                        HStack(spacing: 12) {
                            Image(uiImage: sharedPhoto)
                                .resizable().scaledToFill()
                                .frame(width: 48, height: 48)
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
                }

                VStack(spacing: 14) {
                    NavigationLink {
                        ReportLostItemView()
                    } label: {
                        actionRow(icon: "questionmark.circle.fill", title: "I lost something",
                                  subtitle: "Report a missing item", color: AppTheme.lost)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        ReportFoundItemView()
                    } label: {
                        actionRow(icon: "checkmark.circle.fill", title: "I found something",
                                  subtitle: "Help reunite it with its owner", color: AppTheme.found)
                    }
                    .buttonStyle(.plain)
                }
                .cardStyle()

                VStack(spacing: 10) {
                    NavigationLink {
                        MyReportsView()
                    } label: {
                        HStack {
                            Image(systemName: "list.bullet.rectangle").foregroundStyle(AppTheme.accent)
                            Text("My reports").font(.subheadline.weight(.medium))
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)

                    Divider()

                    NavigationLink {
                        BrowseFoundItemsView()
                    } label: {
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundStyle(AppTheme.found)
                            Text("Browse found items").font(.subheadline.weight(.medium))
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .cardStyle()

                Spacer()
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                sharedPhoto = SharedPhotoStore.pendingPhoto()
            }
        }
    }

    private func actionRow(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 46, height: 46)
                Image(systemName: icon).foregroundStyle(color).font(.system(size: 20))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.secondary).font(.caption)
        }
    }

    private func iconBadge(icon: String, color: Color) -> some View {
        ZStack {
            Circle().fill(color.opacity(0.15)).frame(width: 36, height: 36)
            Image(systemName: icon).font(.system(size: 16, weight: .semibold)).foregroundStyle(color)
        }
    }
}
