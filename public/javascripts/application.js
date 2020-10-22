let slider = document.getElementById("myRange");
let output = document.querySelectorAll(".total");
let months = document.querySelectorAll(".months");
let fee = document.querySelector(".fee");
let totalRepayment = document.querySelector(".total-repayment");

//  output[0].innerHTML = slider.value;
//  output[1].innerHTML = slider.value;

months.forEach(function (month) {
  month.addEventListener("click", function (e) {
    months.forEach((element) => {
      element.classList.remove("months_active");
    });

    e.currentTarget.classList.add("months_active");
    slider.oninput = function () {
      output.forEach(function (value) {
        current_range = document.getElementById("myRange");
        current_value = document.querySelector(".total");
        current_fee =
          (Number(e.target.value) * Number(current_value.innerText)) / 100;
        value.innerHTML = current_range.value; // updating the borrow wish
        fee.innerHTML = current_fee; // update the fee
        totalRepayment.innerHTML = current_fee + Number(current_range.value);
      });
    };
  });
});
