const stats = []
const statsEl = document.getElementById("results-table")
const inputEl = document.getElementById("text-input")
const submitButtonEl = document.getElementById("submit-button")

let languageCount = 5;

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

function resetStats() {
    stats.length = 0
    statsEl.classList.add("hidden")
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

    const langs = [...langMap.entries()]
        .sort((a, b) => b[1] - a[1])
        .slice(0, languageCount); // Limit the number of languages

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

function getProfile(profileUrl) {
    fetch(`http://localhost:8080/api?profile_url=${profileUrl}`)
        .then(resp => resp.json())
        .then(resp => {
            stats.push(resp)
            renderStatsTable(statsEl, stats)
        })
        .catch(console.error)
}

submitButtonEl.addEventListener("click", ev => {
    getProfile(inputEl.value)
    inputEl.value = ""
})
inputEl.addEventListener("keydown", (ev) => {
    if (ev.key == "Enter") {
        getProfile(inputEl.value)
        inputEl.value = ""
    }
})

document.addEventListener("DOMContentLoaded", () => {
    // https://codepen.io/libneko/pen/NWGbEqE
    const range = document.querySelector(".language-count input[type=range]");
    const barHoverBox = document.querySelector(".language-count .language-count-bar-hoverbox");
    const fill = document.querySelector(".language-count .language-count-bar .language-count-bar-fill");
    
    range.addEventListener("change", (e) => {
      console.log("value", e.target.value);
      // min 5 max 30
      languageCount = 5 + Math.floor(25 * e.target.value / 100)
      renderStatsTable(statsEl, stats)
    });
    
    const setValue = (value) => {
      fill.style.width = value + "%";
      range.setAttribute("value", value)
      range.dispatchEvent(new Event("change"))
    }
    
    // Default
    setValue(range.value);
    
    const calculateFill = (e) => {
      let offsetX = e.offsetX
      
      if (e.type === "touchmove") {
        offsetX = e.touches[0].pageX - e.touches[0].target.offsetLeft
      }
      
      const width = e.target.offsetWidth - 30;
  
      setValue(
        Math.max(
          Math.min(
            (offsetX - 15) / width * 100.0,
            100.0
          ),
          0
        )
      );
    }
    
    let barStillDown = false;
  
    barHoverBox.addEventListener("touchstart", (e) => {
      barStillDown = true;
  
      calculateFill(e);
    }, true);
    
    barHoverBox.addEventListener("touchmove", (e) => {
      if (barStillDown) {
        calculateFill(e);
      }
    }, true);
    
    barHoverBox.addEventListener("mousedown", (e) => {
      barStillDown = true;
      
      calculateFill(e);
    }, true);
    
    barHoverBox.addEventListener("mousemove", (e) => {
      if (barStillDown) {
        calculateFill(e);
      }
    });
    
    barHoverBox.addEventListener("wheel", (e) => {
      const newValue = +range.value + e.deltaY * 0.5;
      
      setValue(Math.max(
        Math.min(
          newValue,
          100.0
        ),
        0
      ))
    });
    
    document.addEventListener("mouseup", (e) => {
      barStillDown = false;
    }, true);
    
    document.addEventListener("touchend", (e) => {
      barStillDown = false;
    }, true);
  })
  