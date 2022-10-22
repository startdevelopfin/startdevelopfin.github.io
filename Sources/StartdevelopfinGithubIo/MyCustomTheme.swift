/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation
import Plot
import Publish

public extension Theme {
    /// The default "Foundation" theme that Publish ships with, a very
    /// basic theme mostly implemented for demonstration purposes.
    static var myCustomTheme: Self {
        Theme(
            htmlFactory: MyCustomTheme(),
            resourcePaths: ["Resources/MyCustomTheme/styles.css"]
        )
    }
}

private struct MyCustomTheme<Site: Website>: HTMLFactory {
    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: index, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil)
                Wrapper {
                    Div {
                        H1(index.title)
                        Paragraph(context.site.description)
                            .class("description")
                    }
                    .class("main-intro")
                    H2("Latest content")
                    ItemList(
                        items: context.allItems(
                            sortedBy: \.date,
                            order: .descending
                        ),
                        site: context.site
                    )
                }
                SiteFooter()
            }
        )
    }

    func makeSectionHTML(for section: Section<Site>,
                         context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: section, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: section.id)
                Wrapper {
                    H1(section.title)
                    ItemList(items: section.items, site: context.site)
                }
                SiteFooter()
            }
        )
    }

    func makeItemHTML(for item: Item<Site>,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: item, on: context.site),
            .body(
                .class("item-page"),
                .components {
                    SiteHeader(context: context, selectedSelectionID: item.sectionID)
                    Wrapper {
                        Article {
                            Div(item.content.body).class("content")
                            Span("Tagged with: ")
                            ItemTagList(item: item, site: context.site)
                        }
                    }
                    SiteFooter()
                }
            )
        )
    }

    func makePageHTML(for page: Page,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                // alternative header
                Header {
                    Wrapper {
                        Div {
                            Link(context.site.name, url: "/")
                                .class("site-name")
                        }
                        .class("title")
                        
                        Div {
                            if Site.SectionID.allCases.count > 1 {
                                Navigation {
                                    List(Site.SectionID.allCases) { sectionID in
                                        let section = context.sections[sectionID]
                                        return Link(section.title,
                                            url: section.path.absoluteString
                                        )
                                        .class(sectionID.rawValue == page.title ? "selected" : "")
                                    }
                                }
                            }
                        }
                        .class("navigation")
                    }
                }
                // alternative header end
                Wrapper(page.body)
                SiteFooter()
            }
        )
    }

    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil)
                Wrapper {
                    H1("Browse all tags")
                    List(page.tags.sorted()) { tag in
                        ListItem {
                            Link(tag.string,
                                 url: context.site.path(for: tag).absoluteString
                            )
                        }
                        .class("tag")
                    }
                    .class("all-tags")
                }
                SiteFooter()
            }
        )
    }

    func makeTagDetailsHTML(for page: TagDetailsPage,
                            context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil)
                Wrapper {
                    H1 {
                        Text("Tagged with ")
                        Span(page.tag.string).class("tag")
                    }

                    Link("Browse all tags",
                        url: context.site.tagListPath.absoluteString
                    )
                    .class("browse-all")

                    ItemList(
                        items: context.items(
                            taggedWith: page.tag,
                            sortedBy: \.date,
                            order: .descending
                        ),
                        site: context.site
                    )
                }
                SiteFooter()
            }
        )
    }
}

private struct Wrapper: ComponentContainer {
    @ComponentBuilder var content: ContentProvider

    var body: Component {
        Div(content: content).class("wrapper")
    }
}

private struct SiteHeader<Site: Website>: Component {
    var context: PublishingContext<Site>
    var selectedSelectionID: Site.SectionID?

    var body: Component {
        
        Header {
            Wrapper {
                Div {
                    Link(context.site.name, url: "/")
                        .class("site-name")
                }
                .class("title")
                
                Div {
                    if Site.SectionID.allCases.count > 1 {
                        navigation
                    }
                }
                .class("navigation")
            }
        }
    }

    private var navigation: Component {
        Navigation {
            List(Site.SectionID.allCases) { sectionID in
                let section = context.sections[sectionID]
                return Link(section.title,
                    url: section.path.absoluteString
                )
                .class(sectionID == selectedSelectionID ? "selected" : "")
            }
        }
    }
}

private struct ItemList<Site: Website>: Component {
    var items: [Item<Site>]
    var site: Site

    var body: Component {
        List(items) { item in
            Article {
                H1(Link(item.title, url: item.path.absoluteString))
                ItemTagList(item: item, site: site)
                Paragraph(item.description)
            }
        }
        .class("item-list")
    }
}

private struct ItemTagList<Site: Website>: Component {
    var item: Item<Site>
    var site: Site

    var body: Component {
        List(item.tags) { tag in
            Link(tag.string, url: site.path(for: tag).absoluteString)
        }
        .class("tag-list")
    }
}

private struct SiteFooter: Component {
    var body: Component {
        Footer {
            Wrapper {
                Node.ul(
//                    .li(
//                        .a(
//                            .img(.class("github"), .src("/images/github.svg"), .title("GitHub")),
//                            .href("https://github.com/startdevelopfin")
//                        )
//                    )
                )
                .class("icon")
                Paragraph {
                    Text("Generated using ")
                    Link("Publish", url: "https://github.com/johnsundell/publish")
                }
            }
        }
    }
}

//var url = "https://firebasestorage.googleapis.com/v0/b/by-rule-90fbd.appspot.com/o/CardImage3.png?alt=media&token=74e5ec39-e269-4163-8e31-d54eb2491f37"


//<!-- HTML Meta Tags -->
//<title>DTC UB Coding 2022 | Start. Develop. Fin.</title>
//<meta name="description" content="In this post, I reflect on my time instructing Denmark Technical College's coding class as a part of their Upward Bound summer enrichment program. I'll also explain how students with little to no coding experience leveraged the power of SwiftUI and Swift Playgrounds to build apps using an iPad (8 min read).">
//
//<!-- Facebook Meta Tags -->
//<meta property="og:url" content="https://startdevelopfin.github.io/posts/first-post/">
//<meta property="og:type" content="website">
//<meta property="og:title" content="DTC UB Coding 2022 | Start. Develop. Fin.">
//<meta property="og:description" content="In this post, I reflect on my time instructing Denmark Technical College's coding class as a part of their Upward Bound summer enrichment program. I'll also explain how students with little to no coding experience leveraged the power of SwiftUI and Swift Playgrounds to build apps using an iPad (8 min read).">
//<meta property="og:image" content="https://firebasestorage.googleapis.com/v0/b/by-rule-90fbd.appspot.com/o/CardImage3.png?alt=media&token=74e5ec39-e269-4163-8e31-d54eb2491f37">
//
//<!-- Twitter Meta Tags -->
//<meta name="twitter:card" content="summary_large_image">
//<meta property="twitter:domain" content="startdevelopfin.github.io">
//<meta property="twitter:url" content="https://startdevelopfin.github.io/posts/first-post/">
//<meta name="twitter:title" content="DTC UB Coding 2022 | Start. Develop. Fin.">
//<meta name="twitter:description" content="In this post, I reflect on my time instructing Denmark Technical College's coding class as a part of their Upward Bound summer enrichment program. I'll also explain how students with little to no coding experience leveraged the power of SwiftUI and Swift Playgrounds to build apps using an iPad (8 min read).">
//<meta name="twitter:image" content="https://firebasestorage.googleapis.com/v0/b/by-rule-90fbd.appspot.com/o/CardImage3.png?alt=media&token=74e5ec39-e269-4163-8e31-d54eb2491f37">
//
//<!-- Meta Tags Generated via https://www.opengraph.xyz -->
      


