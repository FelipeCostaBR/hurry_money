let slider = document.getElementById("myRange");
let totalValue = document.querySelectorAll(".total");
let months = document.querySelectorAll(".months");
let fee = document.querySelector(".fee");
let totalRepayment = document.querySelector(".total-repayment");

months.forEach((month) => {
  month.addEventListener("click", (e) => {
    months.forEach((element) => element.classList.remove("months_active"));
    e.currentTarget.classList.add("months_active");
    current_fee = (Number(e.target.value) * Number(slider.value)) / 100;
    totalValue.forEach((total_loan) => {
      total_loan.innerHTML = slider.value;
      fee.innerHTML = current_fee;
      totalRepayment.innerHTML = current_fee + Number(slider.value);
    });

    slider.oninput = () => {
      current_fee = (Number(month.value) * Number(slider.value)) / 100;
      totalValue.forEach((total_loan) => {
        total_loan.innerHTML = slider.value;
        fee.innerHTML = current_fee;
        totalRepayment.innerHTML = this.current_fee + Number(slider.value);
      });
    };
  });
});

slider.oninput = () => {
  debugger;
  current_fee = (Number(months[0].value) * Number(slider.value)) / 100;
  totalValue.forEach((total_loan) => {
    total_loan.innerHTML = slider.value;
    fee.innerHTML = current_fee;
    totalRepayment.innerHTML = this.current_fee + Number(slider.value);
  });
};
