
function editForm() {
  const bioText = document.getElementById("bio-text");
  const inputField = document.getElementById("formTarget")

  bioText.addEventListener("click", (event) => {
    event.currentTarget.classList.toggle('hidden');
    inputField.classList.toggle('hidden');
  });

  const form = document.querySelector(".simple_form.edit_user");

  form.addEventListener("submit", () => {
    bioText.classList.toggle("hidden");
    inputField.classList.toggle("hidden");
    console.log("just submitted");
  })
}
