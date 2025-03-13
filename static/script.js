// custom width calc

const main = document.querySelector('main');

function updateWidth() {
  const ratio = window.innerWidth / window.innerHeight;
  const width = Math.min(Math.max(60 + (30 * (1 - ratio)), 60), 100);
  main.style.width = `${width}vw`;
}

window.addEventListener('resize', updateWidth);
updateWidth();

// copy content
let isAnimating = false;

function animateText(element, originalText, tempText, onComplete) {
    if (isAnimating) return;
    isAnimating = true;

    const maxLength = Math.max(originalText.length, tempText.length);

    const animateIn = (counter, callback) => {
        let newText = '';
        for (let i = 0; i < maxLength; i++) {
            if (i < counter) {
                newText += tempText[i] || ' ';
            } else {
                newText += originalText[i] || ' ';
            }
        }
        element.textContent = newText;
        
        if (counter > maxLength) {
            callback();
            return;
        }
        
        setTimeout(() => animateIn(counter + 1, callback), 50);
    };

    const animateOut = (counter) => {
        let newText = '';
        for (let i = 0; i < maxLength; i++) {
            if (i < counter) {
                newText += originalText[i] || ' ';
            } else {
                newText += tempText[i] || ' ';
            }
        }
        element.textContent = newText;
        
        if (counter > maxLength) {
            element.textContent = originalText;
            isAnimating = false;
            if (onComplete) onComplete();
            return;
        }
        
        setTimeout(() => animateOut(counter + 1), 50);
    };

    // Start animation in
    animateIn(0, () => {
         //Wait a second with the temporary text
        setTimeout(() => animateOut(0), 1000);
    });
}

function copycontent(element) {
    const originalText = element.textContent;
    navigator.clipboard.writeText(originalText);
    animateText(element, originalText, "Copied!");
}

function copyurl(element) {
    const url = window.location.href;
    const originalText = element.textContent;
    navigator.clipboard.writeText(url);
    animateText(element, originalText, "URL Copied!");
}

// custom uptime

let showSeconds = false;
let uptimeInterval;

function uptime() {
  updateUptime();

  if (!uptimeInterval) {
    uptimeInterval = setInterval(updateUptime, 1000);
  }
}

function updateUptime() {
  const today = dayjs();
  const startDate = dayjs('2002-10-11');
  
  if (showSeconds) {
    const diffSeconds = today.diff(startDate, 'second');
    document.getElementById('uptime').innerHTML = diffSeconds + 's';
  } else {
    const diffDays = today.diff(startDate, 'day');
    document.getElementById('uptime').innerHTML = diffDays + 'd';
  }
}

function toggleUptimeFormat() {
  showSeconds = !showSeconds;
  updateUptime();
}

// custom utc time

function setutcnow() {
  function updateTime() {
    const utcPlusOne = dayjs().utc().add(1, 'hour').format('HH:mm:ss');
    document.getElementById('UTCNOW').innerHTML = utcPlusOne;
  }

  updateTime();
  setInterval(updateTime, 1000);
}
