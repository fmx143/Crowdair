const showChartAll = () => {
  const b1 = document.getElementById("set-day");
  const b2 = document.getElementById("set-hour");
  const lc1 = document.getElementById("chart-all");
  const lc2 = document.getElementById("chart-1h");
  if (lc1) {
    lc1.classList.remove("hidden-chart");
    b1.classList.add("highlighted");
    lc2.classList.add("hidden-chart");
    b2.classList.remove("highlighted");
  }
};

const showChart1h = () => {
  const b1 = document.getElementById("set-day");
  const b2 = document.getElementById("set-hour");
  const lc1 = document.getElementById("chart-all");
  const lc2 = document.getElementById("chart-1h");
  if (lc1) {
    lc1.classList.add("hidden-chart");
    b1.classList.remove("highlighted");
    lc2.classList.remove("hidden-chart");
    b2.classList.add("highlighted");
  }
};

const initDynamicChart = () => {
  showChartAll();
  const b1 = document.getElementById("set-day");
  const b2 = document.getElementById("set-hour");
  if (b1) {
    b1.addEventListener("click", () => {
      showChartAll();
    });
    b2.addEventListener("click", () => {
      showChart1h();
    });
  }
};

export { initDynamicChart };
