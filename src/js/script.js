//;(function() {
//  console.log('Hello, world!');
//})();

const main = document.querySelector('main');

function updateWidth() {
  const ratio = window.innerWidth / window.innerHeight;
  const width = Math.min(Math.max(60 + (30 * (1 - ratio)), 60), 100);
  main.style.width = `${width}vw`;
}

window.addEventListener('resize', updateWidth);
updateWidth();
