// replaces "STATS_TABLE" in template.html with generated stats
// (this script is intended to be executed with `node generate.js`)

// list of profiles to fetch
const PROFILES = [
    "https://code.golf/golfers/Andriamanitra",
]

const stats = []

// some language names don't exactly match their css classes
// because of special characters
const langClasses = {
    "C++": "Cplusplus",
    "C#": "Csharp",
    "F#": "Fsharp",
    "Q#": "Qsharp",
    "JS": "JavaScript",
    "TS": "TypeScript"
}


function roundUpToPowerOfTwo(num) {
    return 1 << 32 - Math.clz32(num)
}

function renderStatsTable(stats) {
    if (!stats) return

    const langMap = new Map()
    for (const siteStats of stats) {
        const solvedByLang = siteStats["solved_by_language"]
        for (const lang in solvedByLang) {
            if (langMap.has(lang)) {
                langMap.set(lang, langMap.get(lang) + solvedByLang[lang])
            } else {
                langMap.set(lang, solvedByLang[lang])
            }
        }
    }
    const langs = [...langMap.entries()].sort((a, b) => b[1] - a[1])

    const maxH = Math.max(...langMap.values())
    const height = roundUpToPowerOfTwo(maxH)

    markup = '<table id="results-table">\n  <tbody>\n'

    // bar graph
    markup += '    <tr class="bars-row"><td></td>'
    for (const [langName, numSolved] of langs) {
        const className = langClasses[langName] ?? langName.replaceAll(/\s/g, "-")
        const percentage = Math.round(100 * numSolved / height)
        markup += `<td><div class="bar ${className}" style="height: ${percentage}px;"></div></td>`
    }
    markup += '</tr>\n'

    // header (all the language names)
    markup += '    <tr class="lang-header-row"><td></td>'
    for (const [langName, numSolved] of langs) {
        markup += `<td>${langName}</td>`
    }
    markup += '</tr>\n'

    // one row per site
    for (const siteStats of stats) {
        let siteName = siteStats["profile_url"].split("/")[2]
        const solvedByLang = siteStats["solved_by_language"]
        let row = `<td><a href="${siteStats["profile_url"]}">${siteStats["username"]} @ ${siteName}</a></td>`
        for (const [langName, numSolved] of langs) {
            row += `<td>${solvedByLang[langName] || "-"}</td>`
        }
        markup += `    <tr>${row}</tr>\n`
    }

    // last row has totals per language
    let totalRow = ""
    for (const [langName, numSolved] of langs) {
        totalRow += `<td>${numSolved}</td>`
    }
    markup += `    <tr class="total-row"><td>Total</td>${totalRow}</tr>\n`
    markup += `  </tbody>\n</table>\n`
    return markup
}

function getProfile(profileUrl) {
    return fetch(`http://localhost:8080/api?profile_url=${profileUrl}`)
        .then(resp => resp.json())
        .then(resp => {
            stats.push(resp)
        })
}

function ordinalize(n) {
    const mod10 = n % 10
    const mod100 = n % 100
    if (mod10 == 1 && mod100 != 11) return `${n}st`
    if (mod10 == 2 && mod100 != 12) return `${n}nd`
    if (mod10 == 3 && mod100 != 13) return `${n}rd`
    return `${n}th`
}

(async () => {
    const now = new Date();

    const month = now.toLocaleString("en-US", {month: "long"})
    const dayOrdinal = ordinalize(now.getDate())
    const year = now.toLocaleString("en-US", {year: "numeric"})
    const dateStr = `${month} ${dayOrdinal} ${year}`

    for (const prof of PROFILES) {
        await getProfile(prof)
    }

    const fs = require("fs")
    const statsTable = renderStatsTable(stats)
    fs.readFile("template.html", "utf8", (err, data) => {
        let m = data.match(/\s+STATS_TABLE/)
        if (m) {
            let indent = " ".repeat(m[0].length - 11)
            const statsTableWithIndent = statsTable.replaceAll(/(?<=\n)/g, indent)
            data = data.replaceAll(/STATS_TABLE/g, statsTableWithIndent)
        }
        data = data.replaceAll(/CURRENT_DATE/g, dateStr)
        console.log(data)
    })
})();
