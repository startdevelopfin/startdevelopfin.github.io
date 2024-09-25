import Foundation
import Publish
import Plot

// This type acts as the configuration for your website.
struct StartdevelopfinGithubIo: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case posts
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://startdevelopfin.github.io")!
    var name = "Start. Develop. Fin."
    var description = "Enjoy blog posts focused primarily on the Swift programming language. Be sure to check out the latest content to stay up to date. Thank you for reading!"
    var language: Language { .english }
    var imagePath: Path? { Path("Images") }
}

// This will generate your website using the built-in Foundation theme:
try StartdevelopfinGithubIo().publish(
    withTheme: .myCustomTheme,
    deployedUsing: .gitHub("startdevelopfin/startdevelopfin.github.io", branch: "live", useSSH: false)
)
