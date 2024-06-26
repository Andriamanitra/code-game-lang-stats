const stats = []
const statsEl = document.getElementById("results-table")
const profileInputEl = document.getElementById("profile-text-input")
const submitProfileButtonEl = document.getElementById("profile-submit-button")
const usernamesInputEl = document.getElementById("usernames-text-input")
const submitUsernamesButtonEl = document.getElementById("usernames-submit-button")

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

function renderStatsTable(el, stats) {
    if (stats.length === 0) return;
    el.innerHTML = ""

    const makeRow = () => {
        const row = document.createElement("tr")
        el.appendChild(row)
        return row
    }
    const makeCell = () => {
        const cell = document.createElement("td")
        el.lastChild.appendChild(cell)
        return cell
    }
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

    makeRow().classList.add("bars-row")
    makeCell()
    for (const [langName, numSolved] of langs) {
        const cell = makeCell()
        const bar = document.createElement("div")
        bar.classList.add("bar")
        bar.classList.add(langClasses[langName] ?? langName.replaceAll(/\s/g, "-"))
        const percentage = Math.round(100 * numSolved / height)
        bar.style.height = `${percentage}%`
        cell.appendChild(bar)
    }
    makeRow().classList.add("lang-header-row")
    makeCell()
    for (const [langName, numSolved] of langs) {
        let cell = makeCell()
        cell.innerText = langName
    }
    for (const siteStats of stats) {
        makeRow()
        let cell = makeCell()
        let siteName = siteStats["profile_url"].split("/")[2]
        cell.innerHTML = `<a href=${siteStats["profile_url"]}>${siteStats["username"]} @ ${siteName}</a>`
        const solvedByLang = siteStats["solved_by_language"]
        for (const [langName, numSolved] of langs) {
            let cell = makeCell()
            cell.innerText = solvedByLang[langName] || "-"
        }
    }
    makeRow().classList.add("total-row")
    let cell = makeCell()
    cell.innerText = "Total"
    for (const [langName, numSolved] of langs) {
        let cell = makeCell()
        cell.innerText = numSolved
    }
    el.classList.remove("hidden")
}

function getStatsFromProfile(profileUrl) {
    fetch(`http://localhost:8080/api?profile_url=${profileUrl}`)
        .then(resp => resp.json())
        .then(resp => {
            stats.push(resp)
            renderStatsTable(statsEl, stats)
        })
        .catch(console.error)
}

function getStatsFromUsernames(usernames) {
    const urls = [
        // Skipping CodinGame because of the handle indirection.
        // We could consider using: https://www.codingame.com/services/search/search
        // but I understand that it requires cookies/login to access the method.
        'https://www.codewars.com/users/',
        'https://leetcode.com/u/',
        'https://exercism.org/profiles/',
        'https://code.golf/golfers/',
        'https://atcoder.jp/users/',
        'https://codeforces.com/profile/',
    ]

    usernames.split(',').forEach(username => {
        urls.forEach(url => getStatsFromProfile(`${url}${username}`))
    })
}

submitProfileButtonEl.addEventListener("click", ev => {
    getStatsFromProfile(profileInputEl.value)
    profileInputEl.value = ""
})
submitUsernamesButtonEl.addEventListener("click", ev => {
    getStatsFromUsernames(usernamesInputEl.value)
    usernamesInputEl.value = ""
})

profileInputEl.addEventListener("keydown", (ev) => {
    if (ev.key == "Enter") {
        getStatsFromProfile(profileInputEl.value)
        profileInputEl.value = ""
    }
})
usernamesInputEl.addEventListener("keydown", (ev) => {
    if (ev.key == "Enter") {
        getStatsFromUsernames(usernamesInputEl.value)
        usernamesInputEl.value = ""
    }
})
