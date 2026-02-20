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

    // Folder Picker Demo
    @State private var showingFolderPicker = false
    @State private var folderPickerSelectedItems: [URL] = []
    @State private var folderPickerExtensions: Set<String> = []
    @State private var showFolderPickerExtensionPicker = false
    @State private var folderPickerItemType = 0       // 0=folderOnly, 1=fileOnly, 2=folderAndFile
    @State private var folderPickerAllowMultiple = true
    private let availableExtensions = [".txt", ".png", ".jpg", ".pdf", ".mp4", ".m3u8", "no extension"]

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

                // MARK: - Folder Picker Demo
                Section(header: Text("Folder Picker Demo")) {
                    // Selected items summary
                    if folderPickerSelectedItems.isEmpty {
                        Text("No items selected")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(folderPickerSelectedItems.count) item(s) selected")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ForEach(folderPickerSelectedItems, id: \.self) { url in
                                Text(url.lastPathComponent)
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }

                    // Item type picker
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Item Type")
                            .font(.subheadline)
                        Picker("Item Type", selection: $folderPickerItemType) {
                            Text("Folder Only").tag(0)
                            Text("File Only").tag(1)
                            Text("Folder & File").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    // Allow multiple selection toggle
                    Toggle("Allow Multiple Selection", isOn: $folderPickerAllowMultiple)

                    // Extension filter
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Allowed Extensions")
                                .font(.subheadline)
                            Text(folderPickerExtensions.isEmpty ? "All types" : folderPickerExtensions.sorted().joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Configure") {
                            showFolderPickerExtensionPicker = true
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                    }

                    Button(action: { showingFolderPicker = true }) {
                        HStack {
                            Image(systemName: "folder.badge.person.crop")
                            Text("Open Folder Picker")
                        }
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
        .overlay {
            if showingFolderPicker, let base = getDocumentsDirectory() {
                FolderPickerOverlay(
                    rootURL: base,
                    itemType: [.folderOnly, .fileOnly, .folderAndFile][folderPickerItemType],
                    allowMultipleSelection: folderPickerAllowMultiple,
                    allowedExtensions: folderPickerExtensions,
                    onSelect: { urls in
                        folderPickerSelectedItems = urls
                        showingFolderPicker = false
                    },
                    onDismiss: { showingFolderPicker = false }
                )
            }
        }
        .sheet(isPresented: $showFolderPickerExtensionPicker) {
            ExtensionPickerView(selectedExtensions: $folderPickerExtensions, availableExtensions: availableExtensions)
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

// MARK: - FolderPickerDemoDelegate
private class FolderPickerDemoDelegate: NSObject, FolderPickerDelegate {
    var onSelect: ([URL]) -> Void
    var onCancel: () -> Void

    init(onSelect: @escaping ([URL]) -> Void, onCancel: @escaping () -> Void) {
        self.onSelect = onSelect
        self.onCancel = onCancel
    }

    func folderPicker(_ picker: FolderPickerView, selectItems urls: [URL]) {
        print("Selected \(urls.count) item(s):")
        urls.enumerated().forEach { print("  \($0.offset + 1). \($0.element.path)") }
        onSelect(urls)
    }

    func folderPickerDidCancel(_ picker: FolderPickerView) {
        onCancel()
    }
}

// MARK: - FolderPickerOverlay (matches FileBrowserLayout moveViewOverlay pattern)
private struct FolderPickerOverlay: View {
    let rootURL: URL
    let itemType: ItemType
    let allowMultipleSelection: Bool
    let allowedExtensions: Set<String>
    let onSelect: ([URL]) -> Void
    let onDismiss: () -> Void

    @State private var delegate: FolderPickerDemoDelegate? = nil

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { onDismiss() }

            VStack {
                Spacer()
                FolderPickerView(
                    configuration: FolderPickerConfiguration(
                        title: "Choose Files",
                        allowedRootPath: rootURL,
                        showCancelButton: true,
                        confirmButtonTitle: "Select",
                        lockDisplayMode: .showAsLocked,
                        lockSelectabilityMode: .selectable,
                        lockExpandable: true,
                        itemType: itemType,
                        allowMultipleSelection: allowMultipleSelection,
                        allowedExtensions: allowedExtensions.isEmpty ? nil : processedExtensions
                    ),
                    delegate: delegate
                )
                .clipShape(RoundedCornerShape(radius: 16, corners: [.topLeft, .topRight]))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -2)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            if delegate == nil {
                delegate = FolderPickerDemoDelegate(onSelect: onSelect, onCancel: onDismiss)
            }
        }
    }

    private var processedExtensions: Set<String> {
        Set(allowedExtensions.map { $0 == "no extension" ? "" : $0 })
    }
}

// MARK: - RoundedCornerShape
private struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - ExtensionPickerView
struct ExtensionPickerView: View {
    @Binding var selectedExtensions: Set<String>
    let availableExtensions: [String]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Select File Extensions")) {
                    ForEach(availableExtensions, id: \.self) { ext in
                        HStack {
                            Text(ext)
                            Spacer()
                            if selectedExtensions.contains(ext) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedExtensions.contains(ext) {
                                selectedExtensions.remove(ext)
                            } else {
                                selectedExtensions.insert(ext)
                            }
                        }
                    }
                }
                Section(footer: Text("Leave empty to allow all file types. 'no extension' filters files without extensions.")) {
                    Button("Clear All") { selectedExtensions.removeAll() }
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("File Extensions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
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
