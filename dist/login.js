const form = document.querySelector("#loginForm");
const emailInput = document.querySelector("#emailInput");
const passwordInput = document.querySelector("#passwordInput");
const rememberInput = document.querySelector("#rememberInput");
const passwordToggle = document.querySelector("#passwordToggle");
const loginButton = document.querySelector("#loginButton");
const formMessage = document.querySelector("#formMessage");
const toast = document.querySelector("#loginToast");
let toastTimer;

if (sessionStorage.getItem("vune-session") || localStorage.getItem("vune-session")) {
  window.location.replace("./app.html");
}

function showToast(message) {
  toast.textContent = message;
  toast.classList.add("show");
  window.clearTimeout(toastTimer);
  toastTimer = window.setTimeout(() => toast.classList.remove("show"), 2300);
}

function setFieldError(input, message) {
  input.closest(".input-wrap").classList.toggle("invalid", Boolean(message));
  document.querySelector(`#${input.id.replace("Input", "Error")}`).textContent = message;
}

function validateForm() {
  let isValid = true;
  const email = emailInput.value.trim();
  const emailIsValid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);

  if (!email) {
    setFieldError(emailInput, "Ingresá tu correo electrónico.");
    isValid = false;
  } else if (!emailIsValid) {
    setFieldError(emailInput, "Ingresá un correo válido.");
    isValid = false;
  } else {
    setFieldError(emailInput, "");
  }

  if (!passwordInput.value) {
    setFieldError(passwordInput, "Ingresá tu contraseña.");
    isValid = false;
  } else if (passwordInput.value.length < 6) {
    setFieldError(passwordInput, "La contraseña debe tener al menos 6 caracteres.");
    isValid = false;
  } else {
    setFieldError(passwordInput, "");
  }

  return isValid;
}

passwordToggle.addEventListener("click", () => {
  const isVisible = passwordInput.type === "text";
  passwordInput.type = isVisible ? "password" : "text";
  passwordToggle.setAttribute("aria-pressed", String(!isVisible));
  passwordToggle.setAttribute("aria-label", isVisible ? "Mostrar contraseña" : "Ocultar contraseña");
  passwordInput.focus();
});

[emailInput, passwordInput].forEach((input) => input.addEventListener("input", () => {
  setFieldError(input, "");
  formMessage.textContent = "";
}));

form.addEventListener("submit", (event) => {
  event.preventDefault();
  formMessage.textContent = "";
  if (!validateForm()) return;

  loginButton.disabled = true;
  loginButton.classList.add("loading");
  loginButton.querySelector("span").textContent = "Ingresando...";

  window.setTimeout(() => {
    const storage = rememberInput.checked ? localStorage : sessionStorage;
    storage.setItem("vune-session", JSON.stringify({ email: emailInput.value.trim(), createdAt: Date.now() }));
    window.location.href = "./app.html";
  }, 650);
});

document.querySelector("#forgotButton").addEventListener("click", () => {
  showToast("La recuperación se habilitará al conectar la autenticación.");
});
document.querySelector("#supportButton").addEventListener("click", () => {
  showToast("El canal de soporte se configurará en la próxima etapa.");
});
