import UIKit

/// Generates a sample folder/file tree inside a given base directory.
struct TestDataPopulator {

    // MARK: - Public API

    /// Writes sample folders and files into `baseURL`.
    /// Skips files that already exist.
    /// - Returns: A user-facing message describing the result.
    static func populate(into baseURL: URL) -> String {
        let fm = FileManager.default

        // Structure: top-level folder -> [(subfolder, [(filename, isImage)])]
        // An empty subfolder string means files go directly into the top-level folder.
        let structure: [(String, [(String, [(String, Bool)])])] = [
            ("Photos", [
                ("Vacation", [("beach.png", true), ("sunset.png", true), ("notes.txt", false)]),
                ("Family",   [("portrait.png", true), ("caption.txt", false)]),
                ("",         [("cover.png", true)])
            ]),
            ("Documents", [
                ("Reports", [("annual_report.txt", false), ("summary.txt", false)]),
                ("Notes",   [("meeting_notes.txt", false), ("todo.txt", false)]),
                ("",        [("readme.txt", false)])
            ]),
            ("Projects", [
                ("AppDev",  [("notes.txt", false), ("screenshot.png", true)]),
                ("Design",  [("brief.txt", false), ("mockup.png", true)])
            ])
        ]

        var colorIndex = 0
        let imageColors: [UIColor] = [
            UIColor(red: 0.26, green: 0.53, blue: 0.96, alpha: 1), // blue
            UIColor(red: 0.96, green: 0.49, blue: 0.20, alpha: 1), // orange
            UIColor(red: 0.25, green: 0.72, blue: 0.45, alpha: 1), // green
            UIColor(red: 0.80, green: 0.25, blue: 0.33, alpha: 1), // red
            UIColor(red: 0.56, green: 0.35, blue: 0.80, alpha: 1), // purple
        ]

        var created = 0

        for (folder, subgroups) in structure {
            let folderURL = baseURL.appendingPathComponent(folder)
            try? fm.createDirectory(at: folderURL, withIntermediateDirectories: true)

            for (sub, files) in subgroups {
                let dirURL = sub.isEmpty ? folderURL : folderURL.appendingPathComponent(sub)
                try? fm.createDirectory(at: dirURL, withIntermediateDirectories: true)

                for (filename, isImage) in files {
                    let fileURL = dirURL.appendingPathComponent(filename)
                    guard !fm.fileExists(atPath: fileURL.path) else { continue }

                    if isImage {
                        let color = imageColors[colorIndex % imageColors.count]
                        colorIndex += 1
                        if let data = makeImage(color: color) {
                            try? data.write(to: fileURL)
                            created += 1
                        }
                    } else {
                        let text = sampleText(for: filename)
                        try? text.write(to: fileURL, atomically: true, encoding: .utf8)
                        created += 1
                    }
                }
            }
        }

        return created > 0
            ? "Created \(created) new file(s) across Photos, Documents, and Projects folders inside MyTestFiles."
            : "All sample files already exist – nothing new was created."
    }

    // MARK: - Image Generation

    private static func makeImage(color: UIColor) -> Data? {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            UIColor.white.withAlphaComponent(0.3).setStroke()
            let path = UIBezierPath()
            stride(from: 0, to: Int(size.width), by: 40).forEach { x in
                path.move(to: CGPoint(x: CGFloat(x), y: 0))
                path.addLine(to: CGPoint(x: CGFloat(x), y: size.height))
            }
            stride(from: 0, to: Int(size.height), by: 40).forEach { y in
                path.move(to: CGPoint(x: 0, y: CGFloat(y)))
                path.addLine(to: CGPoint(x: size.width, y: CGFloat(y)))
            }
            path.lineWidth = 1
            path.stroke()
        }
        return img.pngData()
    }

    // MARK: - Sample Text Content

    private static func sampleText(for filename: String) -> String {
        switch filename {
        case "notes.txt":
            return """
                Project Notes – AppDev Initiative
                ==================================

                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque habitant
                morbi tristique senectus et netus et malesuada fames ac turpis egestas.

                Key Observations:
                - Initial setup complete; repository initialised and CI pipeline configured.
                - Unit-test coverage is currently at 74 %; target is 90 % by end of sprint.
                - Review milestones scheduled for next week with the full engineering team.

                Next Steps:
                1. Refactor the networking layer to use async/await.
                2. Address three open tickets tagged `critical` in the backlog.
                3. Conduct a design-review session with the UX team on Thursday.

                Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad
                minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea
                commodo consequat.
                """

        case "caption.txt":
            return """
                Family Portrait – Summer 2025
                ==============================

                Taken on a warm Saturday afternoon at Riverside Park. The whole family gathered
                for the first time in two years – grandparents, cousins, and the new puppy Max
                made a surprise appearance.

                Photographer: Sarah J. (aunt)
                Location: Riverside Park, Pavilion B
                Camera: Canon EOS R6, 50 mm f/1.8

                "In every conceivable manner, the family is link to our past, bridge to our
                future." – Alex Haley
                """

        case "annual_report.txt":
            return """
                Annual Report 2025
                ==================

                EXECUTIVE OVERVIEW
                ------------------
                Fiscal year 2025 marked a period of sustained growth and operational excellence.
                Despite macroeconomic headwinds, the organisation outperformed its targets across
                all key performance indicators.

                FINANCIAL SUMMARY
                -----------------
                Revenue:          $1,240,000
                Operating Costs:    $680,000
                Gross Profit:       $560,000
                Tax (28 %):         $156,800
                Net Income:         $403,200

                HIGHLIGHTS
                ----------
                • Launched three new product lines, contributing 22 % of total revenue.
                • Reduced customer churn by 14 % through the new loyalty programme.
                • Expanded into two new regional markets (South-East Asia & LATAM).
                • Headcount grew from 42 to 67 full-time employees.

                OUTLOOK FOR 2026
                ----------------
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque accumsan nisl
                vitae feugiat tempus. Praesent ullamcorper arcu at tortor lobortis, ac auctor
                turpis vulputate. The board has approved a capital expenditure of $350,000 to
                accelerate platform infrastructure upgrades in H1 2026.
                """

        case "summary.txt":
            return """
                Executive Summary – Q4 2025
                ============================

                This document provides a concise overview of business performance for the fourth
                quarter of fiscal year 2025, covering the period October 1 – December 31, 2025.

                TOP-LINE RESULTS
                ----------------
                • Total revenue: $342,000 (↑ 18 % YoY)
                • New customers acquired: 1,204
                • Net Promoter Score: 71 (up from 64 in Q3)

                OPERATIONAL HIGHLIGHTS
                ----------------------
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio.
                Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh
                elementum imperdiet. Duis sagittis ipsum. Praesent mauris.

                The engineering team shipped 7 major releases, resolving 213 reported issues and
                introducing 34 new features requested by enterprise clients.

                RISKS & MITIGATIONS
                -------------------
                Supply-chain delays in hardware procurement remain a concern. Mitigation plans
                include dual-sourcing agreements negotiated in November 2025.
                """

        case "meeting_notes.txt":
            return """
                Meeting Notes – 15 January 2026
                ================================

                Attendees : Alice Nguyen (PM), Bob Martinez (Engineering Lead),
                            Carol Singh (Design), David Okafor (QA)
                Location  : Conference Room C / Zoom hybrid
                Duration  : 60 minutes

                AGENDA ITEMS
                ------------
                1. Sprint 22 retrospective
                2. Roadmap priorities for Q1 2026
                3. Design handoff checklist update
                4. AOB

                DISCUSSION NOTES
                ----------------
                Alice opened the meeting by reviewing the sprint-22 burndown chart. The team
                completed 38 of 42 story points; four items were carried over due to unexpected
                API latency issues discovered during integration testing.

                Bob raised concerns about technical debt in the authentication module. The team
                agreed to allocate 20 % of sprint-23 capacity to refactoring work.

                Carol presented updated onboarding screens. Feedback was positive; minor tweaks
                to typography and button sizing were requested before final handoff.

                ACTIONS
                -------
                [ ] Bob   – Submit refactoring proposal by 22 Jan 2026
                [ ] Carol – Apply UI tweaks and share Figma link by 19 Jan 2026
                [ ] David – Draft regression-test plan for authentication module
                [x] Alice – Send Q1 roadmap draft to stakeholders (done 16 Jan)
                """

        case "todo.txt":
            return """
                TODO – Personal & Work Tasks
                =============================

                URGENT
                ------
                [ ] Review open pull requests (#204, #207, #211)
                [ ] Respond to client email re: data export feature
                [ ] Update project README with new setup instructions

                IN PROGRESS
                -----------
                [~] Migrate unit tests to Swift Testing framework
                [~] Investigate memory leak reported in issue #198

                COMPLETED
                ---------
                [x] Fix crash on launch (iOS 17.2 regression) – merged 14 Jan
                [x] Update CocoaPods dependencies to latest versions
                [x] Set up nightly build notifications in Slack

                BACKLOG
                -------
                [ ] Add dark-mode support for custom HTML provider
                [ ] Write integration tests for WiFi server module
                [ ] Localise app into French and German

                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus magna.
                Cras in mi at felis aliquet congue. Ut a est eget ligula molestie gravida.
                """

        case "readme.txt":
            return """
                MyTestFiles
                ===========

                This directory contains sample files generated by the MRFileBrowserDemo app for
                testing and demonstration purposes.

                STRUCTURE
                ---------
                MyTestFiles/
                ├── Photos/
                │   ├── Vacation/   (beach.png, sunset.png, notes.txt)
                │   ├── Family/     (portrait.png, caption.txt)
                │   └── cover.png
                ├── Documents/
                │   ├── Reports/    (annual_report.txt, summary.txt)
                │   ├── Notes/      (meeting_notes.txt, todo.txt)
                │   └── readme.txt
                └── Projects/
                    ├── AppDev/     (notes.txt, screenshot.png)
                    └── Design/     (brief.txt, mockup.png)

                USAGE
                -----
                Launch the File Browser from the demo app to browse, share, or preview these
                files over the built-in WiFi server.

                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sit amet
                accumsan tortor. Donec non enim in turpis pulvinar facilisis. Ut felis.
                """

        case "brief.txt":
            return """
                Design Brief – Onboarding Flow Redesign
                ========================================

                CLIENT    : Internal Product Team
                PROJECT   : MRFileBrowserDemo v2.0 Onboarding
                DATE      : 20 February 2026
                DEADLINE  : 31 March 2026

                OBJECTIVE
                ---------
                Redesign the first-run onboarding experience to reduce drop-off by at least 30 %
                and improve feature discoverability for new users.

                BACKGROUND
                -----------
                Current analytics show that 41 % of new users do not reach the main file-browser
                screen on their first session. Exit surveys indicate confusion around permissions
                prompts and the initial folder-selection step.

                SCOPE OF WORK
                -------------
                1. Redesign the 3-step onboarding carousel (welcome, permissions, quick-start).
                2. Introduce contextual tooltips on the main toolbar.
                3. Create a "sample files" state for users who have no local files yet.

                DELIVERABLES
                ------------
                • High-fidelity Figma prototypes (light & dark mode)
                • Annotated handoff file for engineering
                • Motion spec for transition animations

                CONSTRAINTS
                -----------
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas porttitor
                congue massa. Fusce posuere, magna sed pulvinar ultricies, purus lectus malesuada
                libero, sit amet commodo magna eros quis urna.

                • Must comply with Apple Human Interface Guidelines.
                • Minimum deployment target: iOS 16.0.
                • Cannot exceed 4 screens in the onboarding flow.
                """

        default:
            return "Sample content for \(filename)"
        }
    }
}
