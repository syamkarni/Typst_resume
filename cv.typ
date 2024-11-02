#let setrules(uservars, doc) = {
    set text(
        font: uservars.bodyfont,
        size: uservars.fontsize,
        hyphenate: false,
    )

    set list(
        spacing: uservars.linespacing
    )

    set par(
        leading: uservars.linespacing,
        justify: true,
    )

    doc
}


#let showrules(uservars, doc) = {
    show heading.where(
        level: 2,
    ): it => block(width: 100%)[
        #set align(left)
        #set text(font: uservars.headingfont, size: 1em, weight: "bold")
        #if (uservars.at("headingsmallcaps", default:false)) {
            smallcaps(it.body)
        } else {
            upper(it.body)
        }
        #v(-0.75em) #line(length: 100%, stroke: 1pt + black)
    ]


    show heading.where(
        level: 1,
    ): it => block(width: 100%)[
        #set text(font: uservars.headingfont, size: 1.5em, weight: "bold")
        #if (uservars.at("headingsmallcaps", default:false)) {
            smallcaps(it.body)
        } else {
            upper(it.body)
        }
        #v(2pt)
    ]

    doc
}


#let cvinit(doc) = {
    doc = setrules(doc)
    doc = showrules(doc)
    doc
}


#let format_date(date_str) = {
    if date_str == "" or date_str == none {
        ""
    } else if lower(date_str) == "present" {
        "Present"
    } else {
        let year = date_str.slice(0,4)
        let month_num = date_str.slice(5,7)
        let month_names = ("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")
        let month = month_names.at(int(month_num) - 1)
        month + " " + year
    }
}


#let addresstext(info, uservars) = {
    if uservars.showAddress {
        block(width: 100%)[
            #info.personal.address, #info.personal.city, #info.personal.country #info.personal.zip
            #v(-4pt)
        ]
    } else {none}
}


#let contacttext(info, uservars) = block(width: 100%)[
    #let profiles = (
        box(link("mailto:" + info.personal.email)),
        if uservars.showNumber {box(link("tel:" + info.personal.phone))} else {none},
        if info.personal.plink != none {
            box(link(info.personal.plink)[#info.personal.plink.split("//").at(1)])
        } else {none},
        if info.personal.github != none {
            box(link(info.personal.github)[#info.personal.github.split("//").at(1)])
        } else {none},
        if info.personal.linkedin != none {
            box(link(info.personal.linkedin)[#info.personal.linkedin.split("//").at(1)])
        } else {none}
    ).filter(it => it != none) 

    #set text(font: uservars.bodyfont, weight: "medium", size: uservars.fontsize * 1)
    #pad(x: 0em)[
        #profiles.join([#sym.space.en #sym.diamond.filled #sym.space.en])
    ]
]


#let cvheading(info, uservars) = {
    align(center)[
        = #info.personal.fname #info.personal.sname
        #addresstext(info, uservars)
        #contacttext(info, uservars)
    ]
}


#let cvabout(info, isbreakable: true) = {
    if info.description != none {block(breakable: isbreakable)[
        == Introduction
        #info.description
    ]}
}


#let cvwork(info, isbreakable: true) = {
    if info.work != none {block[
        == Work Experience
        #for w in info.work {
            block(width: 100%, breakable: isbreakable)[

                *#w.companyName* #h(1fr) *#w.location* \
            ]
            block(width: 100%, breakable: isbreakable)[

                #text(style: "italic", weight: "semibold")[#w.position] #h(1fr)
                #format_date(w.startDate) #sym.dash.en #format_date(w.endDate) \

                #for hi in w.descriptions [
                    - #eval(hi, mode: "markup")
                ]
            ]
        }
    ]}
}


#let cveducation(info, isbreakable: true)={
  if info.education != none {block[
    == Education
    #for edu in info.education.educations {
      block(width: 100%, breakable: isbreakable)[

                #if edu.url != none [
                  #if edu.location != none [
                    *#link(edu.url)[#edu.instituteName]* #h(1fr) *#edu.location* \
                  ] else[
                    *#link(edu.url)[#edu.instituteName]* #h(1fr) \
                ]] else [
                    *#edu.instituteName* #h(1fr) *#edu.location* \
                ]

                #text(style: "italic")[#edu.studyType in #edu.area] #h(1fr)
                #format_date(edu.startDate) #sym.dash.en #format_date(edu.endDate) \
            ]
    }
  ]}
}


#let cvprojects(info, isbreakable: true) = {
    if info.projects != none {block[
        == Projects
        #for project in info.projects.projects {
            block(width: 100%, breakable: isbreakable)[

                #if project.url != none [
                    *#link(project.url)[#project.projectName]* #h(1fr)
                    #format_date(project.startDate) #sym.dash.en #format_date(project.endDate) \
                ] else [
                    *#project.projectName* #h(1fr) #format_date(project.startDate) #sym.dash.en #format_date(project.endDate) \
                ]

                #if project.subtitle != none [
                    #text(style: "italic")[#project.subtitle]  
                ]

                #for hi in project.descriptions [
                    - #eval(hi, mode: "markup")
                ]
            ]
        }
    ]}
}


#let cvskills(info, isbreakable: false) = {
    if (info.languages != none) or (info.skills != none) or (info.interests != none) {block(breakable: isbreakable)[
        == Skills, Languages, Interests
        #if (info.languages != none) [
            #let langs = ()
            #for lang in info.languages {
                langs.push([#lang.language (#lang.fluency)])
            }
            - *Languages*: #langs.join(", ")
        ]
        #if (info.skills != none) [
            #for group in info.skills [
                - *#group.category*: #group.skills.join(", ")
            ]
        ]
        #if (info.interests != none) [
            - *Interests*: #info.interests.join(", ")
        ]
    ]}
}


#let cvawards(info, isbreakable: true) = {
    if info.awards != none {block[
        == Awards
        #for award in info.awards.awards {
            block(width: 100%, breakable: isbreakable)[

                #if award.url != none [
                    *#link(award.url)[#award.title]* #h(1fr) *#award.location* \
                ] else [
                    *#award.title* #h(1fr) *#award.location* \
                ]

                Issued by #text(style: "italic")[#award.issuer]  #h(1fr) #format_date(award.date) \

                #if award.highlights != none {
                    for hi in award.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                } else {}
            ]
        }
    ]}
}


#let cvaffiliations(info, isbreakable: true) = {
    if info.extracurricular != none {block[
        == Extracurricular Activities
        #for activity in info.extracurricular.activities {
            block(width: 100%, breakable: isbreakable)[

                #if activity.url != none [
                    *#link(activity.url)[#activity.organization]* #h(1fr) *#activity.location* \
                ] else [
                    *#activity.organization* #h(1fr) *#activity.location* \
                ]

                #text(style: "italic")[#activity.position] #h(1fr)
                #format_date(activity.startDate) #sym.dash.en #format_date(activity.endDate) \

                #if activity.highlights != none {
                    for hi in activity.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                } else {}
            ]
        }
    ]}
}


#let cvvdata(info, isbreakable: true) = {
    if info.volunteer_data != none {block[
        == Volunteer Experience
        #for vol in info.volunteer_data.volunteerData {
            block(width: 100%, breakable: isbreakable)[
                #if vol.url != none [
                    *#link(vol.url)[#vol.organization]* #h(1fr) *#vol.location* \
                ] else [
                    *#vol.organization* #h(1fr) *#vol.location* \
                ]
                
                #text(style: "italic")[#vol.position] #h(1fr)
                #format_date(vol.startDate) #sym.dash.en #format_date(vol.endDate) \
                
                #if vol.highlights != none {
                    for hi in vol.highlights [
                        - #eval(hi, mode: "markup")
                    ]
                } else {}
            ]
        }
    ]}
}


#let endnote() = {
    place(
        bottom + right,
        block[
            #set text(size: 5pt, font: "Consolas", fill: silver)
            \*This document was last updated on #datetime.today().display("[year]-[month]-[day]") using #link("https://typst.app")[Typst].
        ]
    )
}
