const b1 = document.getElementById('set-day');
const b2 = document.getElementById("set-hour");
const lc1 = document.getElementById("chart-all");
const lc2 = document.getElementById("chart-1h");

const showChartAll = () => {
  console.log("ran all");
  if (lc1) {
    lc1.classList.remove("hidden-chart");
    lc2.classList.add("hidden-chart");
  }
}

const showChart1h = () => {
  console.log("ran 1h");
  if (lc1) {
    lc1.classList.add("hidden-chart");
    lc2.classList.remove("hidden-chart");
  }
}

const initDynamicChart = () => {
  showChartAll();
  console.log("ran showChartAll");
  if (b1) {
    b1.addEventListener('click', () => { showChartAll() })
    b2.addEventListener("click", () => { showChart1h() });
  }
};

export { initDynamicChart }
