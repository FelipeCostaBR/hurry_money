let slider = document.getElementById("myRange");
let totalValue = document.querySelectorAll(".total");
let months = document.querySelectorAll(".months");
let fee = document.querySelector(".fee");
let totalRepayment = document.querySelector(".total-repayment");

months.forEach((month) => {
  month.addEventListener("change", (e) => {
    months.forEach((element) => (element.checked = false));
    e.currentTarget.checked = true;
    current_fee = (Number(e.target.value) * Number(slider.value)) / 100;
    totalValue.forEach((total_loan) => {
      total_loan.value = slider.value;
      fee.value = current_fee;
      totalRepayment.value = current_fee + Number(slider.value);
    });

    slider.oninput = () => {
      current_fee = (Number(month.value) * Number(slider.value)) / 100;
      totalValue.forEach((total_loan) => {
        total_loan.value = slider.value;
        fee.value = current_fee;
        totalRepayment.value = this.current_fee + Number(slider.value);
      });
    };
  });
});

function set_initial() {
  slider.oninput = () => {
    current_fee = (Number(months[0].value) * Number(slider.value)) / 100;
    totalValue.forEach((total_loan) => {
      total_loan.value = slider.value;
      fee.value = current_fee;
      totalRepayment.value = this.current_fee + Number(slider.value);
    });
  };
}

set_initial();

// months[0].formAction
