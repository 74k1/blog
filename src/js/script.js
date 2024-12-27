// custom width calc

const main = document.querySelector('main');

function updateWidth() {
  const ratio = window.innerWidth / window.innerHeight;
  const width = Math.min(Math.max(60 + (30 * (1 - ratio)), 60), 100);
  main.style.width = `${width}vw`;
}

window.addEventListener('resize', updateWidth);
updateWidth();

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
