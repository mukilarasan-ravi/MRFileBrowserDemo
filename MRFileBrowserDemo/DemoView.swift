import SwiftUI
import MRFileBrowser

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

struct DemoView: View {
    @State private var folderURL: URL? = nil
    @State private var titleName: String = "My File Browser"
    private let selectedPath: String = "Documents/MyTestFiles"

    // Server Configuration Options
    @State private var selectedServerMode = 0
    @State private var selectedBackgroundMode = 0
    @State private var selectedTheme = 0
    @State private var selectedHtmlProvider = 0
    @State private var showLockedItems: Bool = false
    @State private var showParentLockedItems: Bool = false
    @State private var showPopulateAlert: Bool = false
    @State private var populateAlertMessage: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Form {
                // MARK: - Test Data
                Section(header: Text("Test Data")) {
                    Button(action: {
                        populateTestFiles()
                    }) {
                        HStack {
                            Image(systemName: "folder.badge.plus")
                            Text("Populate Sample Folders & Files")
                        }
                    }
                    .alert(isPresented: $showPopulateAlert) {
                        Alert(
                            title: Text("Test Files"),
                            message: Text(populateAlertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }

                // MARK: - Server Configuration
                Section(header: Text("Server Configuration")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Server Button Mode")
                            .font(.headline)

                        Picker("Server Mode", selection: $selectedServerMode) {
                            Text("Show Default").tag(0)
                            Text("Hidden").tag(1)
                            Text("Show Custom View").tag(2)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Background Mode")
                            .font(.headline)

                        Picker("Background", selection: $selectedBackgroundMode) {
                            Text("Stop on Background").tag(0)
                            Text("Continue in Background").tag(1)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }

                // MARK: - Theme Configuration
                Section(header: Text("Theme Configuration")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Theme")
                            .font(.headline)

                        Picker("Theme", selection: $selectedTheme) {
                            Text("Blue").tag(0)
                            Text("Green").tag(1)
                            Text("Orange").tag(2)
                            Text("multi").tag(3)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }

                // MARK: - HTML Provider Configuration
                Section(header: Text("HTML Provider Options")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("HTML Provider Type")
                            .font(.headline)

                        Picker("HTML Provider", selection: $selectedHtmlProvider) {
                            Text("Default").tag(0)
                            Text("Dark Theme").tag(1)
                            Text("Theme Aware").tag(3)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }

                    Toggle("Show Locked Items", isOn: $showLockedItems)
                    Toggle("Show Parent Locked Items", isOn: $showParentLockedItems)

                }

                // MARK: - Preview Section
                Section(header: Text("Configuration Preview")) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Configuration:")
                            .font(.headline)
                        Text("Server Mode: \(serverModeDescription)")
                        Text("Background: \(backgroundModeDescription)")
                        Text("Theme: \(themeDescription)")
                        Text("HTML Provider: \(htmlProviderDescription)")
                        Text("Locked Items: \(showLockedItems ? "Visible" : "Hidden")")
                        Text("Parent Locked: \(showParentLockedItems ? "Visible" : "Hidden")")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .navigationTitle("FileBrowserRootView Demo")
            .navigationBarTitleDisplayMode(.large)

            // Fixed Launch Button at Bottom
            VStack {
                Divider()
                Button("Launch File Browser with Current Configuration") {
                    if let url = getDocumentsDirectory() {
                        folderURL = url
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .fullScreenCover(item: $folderURL) { url in
            let serverConfiguration = createServerConfiguration()

            let vwConfig = ViewConfiguration(viewMode: .both, gridConfiguration: .init(), startsInGridView: true)

            FileBrowserRootView(
                folderURL: url,
                titleName: $titleName,
                serverConfiguration: serverConfiguration,
                themeConfiguration: themeDescription,
                viewConfiguration: vwConfig
            )

            .navigationBarHidden(true)
            .interactiveDismissDisabled(true)
        }
    }

    // MARK: - Helper Methods
    private var serverModeDescription: String {
        switch selectedServerMode {
        case 0: return "Show Default"
        case 1: return "Hidden"
        case 2: return "Custom View"
        default: return "Unknown"
        }
    }

    private var backgroundModeDescription: String {
        switch selectedBackgroundMode {
        case 0: return "Stop on Background"
        case 1: return "Continue in Background"
        default: return "Unknown"
        }
    }

    private var themeDescription: ThemeConfiguration {
        switch selectedTheme {
        case 0: return .blue
        case 1: return .green
        case 2: return .orange
        case 3: return .multi
        default: return .blue
        }
    }

    private var htmlProviderDescription: String {
        switch selectedHtmlProvider {
        case 0: return "Default"
        case 1: return "Dark Theme"
        case 3: return "Theme Aware"
        default: return "Unknown"
        }
    }


    private func createServerConfiguration() -> ServerConfiguration {
        switch selectedServerMode {
        case 0: // Show Default

            /*showLockedItems: showLockedItems,
             showParentLockedItems: showParentLockedItems
             */
            var htmlProvider = DefaultHTMLProvider(showLockedItems: showLockedItems, showParentLockedItems: showParentLockedItems)
            if(selectedHtmlProvider == 3){
                htmlProvider = ThemeAwareHTMLProvider(theme: themeDescription, showLockedItems: showLockedItems, showParentLockedItems: showParentLockedItems)
            }
            return ServerConfiguration(
                serverButtonMode: .show,
                backgroundMode: selectedBackgroundMode == 0 ? .stopOnBackground : .continueInBackground,
                htmlProvider: htmlProvider
            )
        case 1: // Hidden
            return ServerConfiguration(
                serverButtonMode: .hidden
            )
        case 2: // Show Premium Support
            return ServerConfiguration(
                serverButtonMode: .showCustomView { dismissCallback in
                    AnyView(
                        PremiumBottomSheet(
                            onDismiss: {
                                dismissCallback()
                            },
                            onSubscribeTap: {
                                // Handle subscription logic here
                                print("User tapped Subscribe Now")
                                // Navigate to subscription screen or handle in-app purchase
                            }
                        )
                    )
                },
                backgroundMode: selectedBackgroundMode == 0 ? .stopOnBackground : .continueInBackground
            )
        case 3: // using default
            return ServerConfiguration(
                serverButtonMode: .show,
                backgroundMode: selectedBackgroundMode == 0 ? .stopOnBackground : .continueInBackground
            )
        default: // using default
            return ServerConfiguration(
                serverButtonMode: .show,
                backgroundMode: selectedBackgroundMode == 0 ? .stopOnBackground : .continueInBackground
            )
        }
    }

    // MARK: - Populate Test Files
    private func populateTestFiles() {
        guard let base = getDocumentsDirectory() else {
            populateAlertMessage = "Could not access Documents directory."
            showPopulateAlert = true
            return
        }
        populateAlertMessage = TestDataPopulator.populate(into: base)
        showPopulateAlert = true
    }

    private func getDocumentsDirectory() -> URL? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let myTestFilesURL = documentsURL.appendingPathComponent("MyTestFiles")

        // Create the directory if it doesn't exist
        do {
            try FileManager.default.createDirectory(at: myTestFilesURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create MyTestFiles directory: \(error)")
        }

        return myTestFilesURL
    }
}

struct DemoView_Previews: PreviewProvider {
    static var previews: some View {
        DemoView()
    }
}

struct PremiumBottomSheet: View {
    var onDismiss: () -> Void
    var onSubscribeTap: () -> Void

    @State private var offsetY: CGFloat = 0

    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.35)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismiss()
                }

            // Sheet
            VStack(spacing: 16) {

                // Handle bar
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                Text("🌟 Premium Feature")
                    .font(.headline)

                Text("WiFi sharing is a premium feature.\nUpgrade to access all features.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Divider()

                Button(action: {
                    dismiss()
                    onSubscribeTap()
                }) {
                    Text("Upgrade Now")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button(action: dismiss) {
                    Text("Cancel")
                        .foregroundColor(.red)
                        .padding(.bottom, 8)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .offset(y: offsetY)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 0 {
                            offsetY = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > 120 {
                            dismiss()
                        } else {
                            withAnimation(.easeOut(duration: 0.25)) {
                                offsetY = 0
                            }
                        }
                    }
            )
            .transition(.move(edge: .bottom))
            .edgesIgnoringSafeArea(.bottom)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) {
            onDismiss()
        }
        offsetY = 0
    }
}
