  console.log('hello');

  const bioText = document.getElementById("bio-text");
  const inputField = document.getElementById("formTarget");
  const editBioIcon = document.getElementById("edit-bio");
  const cancelBioUpdateButton = document.getElementById("cancel-bio-update");
  const abilityInputField = document.getElementById("ability-target");
  const userAbilityText = document.getElementById("user-ability-text");
  const editAbilityIcon = document.getElementById("edit-ability-icon");
  const cancelAbilityUpdateButton = document.getElementById("cancel-ability-update-button");
  const abilityForm = document.getElementById("user-ability-form");

  editBioIcon.addEventListener("click", (event) => {
    bioText.classList.toggle('hidden');
    inputField.classList.toggle('hidden');
    cancelBioUpdateButton.classList.toggle('hidden');
  });

  const form = document.getElementById("bio-form");

  form.addEventListener("submit", () => {
    bioText.classList.toggle("hidden");
    inputField.classList.toggle("hidden");
    cancelBioUpdateButton.classList.toggle("hidden");
  });

  cancelBioUpdateButton.addEventListener("click", (event) => {
    cancelBioUpdateButton.classList.toggle("hidden");
    bioText.classList.toggle("hidden");
    inputField.classList.toggle("hidden");
  });

  editAbilityIcon.addEventListener("click", (e) => {
    editAbilityIcon.classList.toggle('hidden');
    userAbilityText.classList.toggle('hidden');
    abilityInputField.classList.toggle('hidden');
  });

  abilityForm.addEventListener("submit", (e) => {
    abilityInputField.classList.toggle('hidden');
    userAbilityText.classList.toggle('hidden');
    editAbilityIcon.classList.toggle('hidden');
  });

  cancelAbilityUpdateButton.addEventListener("click", (e) => {
    editAbilityIcon.classList.toggle('hidden');
    abilityInputField.classList.toggle('hidden');
    userAbilityText.classList.toggle('hidden');
  });
