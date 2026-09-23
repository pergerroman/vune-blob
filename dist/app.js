const activeSession = sessionStorage.getItem("vune-session") || localStorage.getItem("vune-session");
if (!activeSession) window.location.replace("./index.html");

const demoFiles = [
  { id: 8, name: "hero-vune-2026.jpg", size: 2480000, modified: "Hoy, 14:32", type: "image", access: "public", extension: "JPG", color: "#274e87", folderId: "web" },
  { id: 7, name: "presentacion-comercial.pdf", size: 8200000, modified: "Hoy, 11:08", type: "document", access: "public", extension: "PDF", folderId: null },
  { id: 6, name: "demo-plataforma.mp4", size: 24700000, modified: "Ayer, 18:45", type: "video", access: "private", extension: "MP4", folderId: "videos" },
  { id: 5, name: "isologo-vune.svg", size: 148000, modified: "Ayer, 16:20", type: "image", access: "public", extension: "SVG", color: "#3976f6", folderId: "brand" },
  { id: 4, name: "kit-de-marca.zip", size: 15400000, modified: "19 sep 2026", type: "archive", access: "private", extension: "ZIP", folderId: "brand" },
  { id: 3, name: "equipo-oficina.webp", size: 3100000, modified: "18 sep 2026", type: "image", access: "public", extension: "WEBP", color: "#49716c", folderId: "images" },
  { id: 2, name: "terminos-y-condiciones.docx", size: 684000, modified: "16 sep 2026", type: "document", access: "private", extension: "DOCX", folderId: "documents" },
  { id: 1, name: "animacion-logo.mov", size: 38600000, modified: "15 sep 2026", type: "video", access: "public", extension: "MOV", folderId: "videos" }
];

let folders = [
  { id: "images", name: "Imágenes", parentId: null },
  { id: "videos", name: "Videos", parentId: null },
  { id: "documents", name: "Documentos", parentId: null },
  { id: "brand", name: "Identidad", parentId: null },
  { id: "web", name: "Web", parentId: "images" }
];
let files = [...demoFiles];
let currentSection = "recent";
let currentFolderId = null;
let currentView = "list";
let sortNewestFirst = true;
let toastTimer;
const savedStorageLimit = Number(localStorage.getItem("vune-project-storage-limit"));
let projectStorageLimitGb = Number.isFinite(savedStorageLimit) && savedStorageLimit > 0 ? savedStorageLimit : 10;

const elements = {
  allCount: document.querySelector("#allCount"),
  breadcrumbs: document.querySelector("#breadcrumbs"),
  browseButton: document.querySelector("#browseButton"),
  clearQueue: document.querySelector("#clearQueue"),
  copyDialogUrl: document.querySelector("#copyDialogUrl"),
  currentUsageNote: document.querySelector("#currentUsageNote"),
  dialog: document.querySelector("#fileDialog"),
  dialogAccess: document.querySelector("#dialogAccess"),
  dialogClose: document.querySelector("#dialogClose"),
  dialogDate: document.querySelector("#dialogDate"),
  dialogName: document.querySelector("#dialogName"),
  dialogPreview: document.querySelector("#dialogPreview"),
  dialogSize: document.querySelector("#dialogSize"),
  dialogType: document.querySelector("#dialogType"),
  dialogUrl: document.querySelector("#dialogUrl"),
  dialogUrlLabel: document.querySelector("#dialogUrlLabel"),
  dropZone: document.querySelector("#dropZone"),
  emptyState: document.querySelector("#emptyState"),
  fileGrid: document.querySelector("#fileGrid"),
  fileInput: document.querySelector("#fileInput"),
  fileList: document.querySelector("#fileList"),
  folderDialog: document.querySelector("#folderDialog"),
  folderDialogPath: document.querySelector("#folderDialogPath"),
  folderForm: document.querySelector("#folderForm"),
  folderNameInput: document.querySelector("#folderNameInput"),
  gridViewButton: document.querySelector("#gridViewButton"),
  listViewButton: document.querySelector("#listViewButton"),
  logoutButton: document.querySelector("#logoutButton"),
  menuButton: document.querySelector("#menuButton"),
  newFolderButton: document.querySelector("#newFolderButton"),
  pageDescription: document.querySelector("#pageDescription"),
  pageTitle: document.querySelector("#pageTitle"),
  queueItems: document.querySelector("#queueItems"),
  queueTitle: document.querySelector("#queueTitle"),
  resultCount: document.querySelector("#resultCount"),
  searchInput: document.querySelector("#searchInput"),
  settingsButton: document.querySelector("#settingsButton"),
  settingsDialog: document.querySelector("#settingsDialog"),
  settingsForm: document.querySelector("#settingsForm"),
  sidebar: document.querySelector("#sidebar"),
  sidebarBackdrop: document.querySelector("#sidebarBackdrop"),
  sortButton: document.querySelector("#sortButton"),
  storageLimitInput: document.querySelector("#storageLimitInput"),
  storagePercent: document.querySelector("#storagePercent"),
  storageTrackFill: document.querySelector("#storageTrackFill"),
  storageUsageText: document.querySelector("#storageUsageText"),
  projectItemCount: document.querySelector("#projectItemCount"),
  itemBreakdown: document.querySelector("#itemBreakdown"),
  toast: document.querySelector("#toast"),
  uploadButton: document.querySelector("#uploadButton"),
  uploadQueue: document.querySelector("#uploadQueue")
};

const icons = {
  archive: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 4h14v16H5Z M8 4v4h8V4 M9 12h6" /></svg>',
  copy: '<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="8" y="8" width="11" height="11" rx="2"/><path d="M16 8V6a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h2"/></svg>',
  document: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 3.5h8l4 4V20H6Z"/><path d="M14 3.5V8h4M9 12h6M9 15.5h6"/></svg>',
  folder: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 6.5A2.5 2.5 0 0 1 6.5 4h3l2 2h6A2.5 2.5 0 0 1 20 8.5v8A3.5 3.5 0 0 1 16.5 20h-10A2.5 2.5 0 0 1 4 17.5Z"/></svg>',
  image: '<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3.5" y="4" width="17" height="16" rx="3"/><circle cx="9" cy="9" r="1.5"/><path d="m5 17 4.3-4.3a1.5 1.5 0 0 1 2.1 0l2 2 1.4-1.4a1.5 1.5 0 0 1 2.1 0L20 16.5"/></svg>',
  more: '<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="5" cy="12" r="1"/><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/></svg>',
  other: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 3.5h8l4 4V20H6Z"/><path d="M14 3.5V8h4"/></svg>',
  video: '<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3.5" y="5" width="13" height="14" rx="3"/><path d="m16.5 10 3.2-2v8l-3.2-2Z"/></svg>'
};

function escapeHtml(value) {
  const node = document.createElement("div");
  node.textContent = value;
  return node.innerHTML;
}

function formatBytes(bytes) {
  if (bytes === 0) return "0 B";
  const units = ["B", "KB", "MB", "GB"];
  const unitIndex = Math.min(Math.floor(Math.log(bytes) / Math.log(1024)), units.length - 1);
  const amount = bytes / 1024 ** unitIndex;
  return `${amount >= 10 || unitIndex === 0 ? amount.toFixed(0) : amount.toFixed(1)} ${units[unitIndex]}`;
}

function updateProjectStats() {
  const usedBytes = files.reduce((total, file) => total + file.size, 0);
  const limitBytes = projectStorageLimitGb * 1024 ** 3;
  const rawPercent = limitBytes ? (usedBytes / limitBytes) * 100 : 0;
  const displayedPercent = rawPercent > 0 && rawPercent < 1 ? "<1%" : `${Math.round(rawPercent)}%`;
  const totalItems = files.length + folders.length;

  elements.storagePercent.textContent = displayedPercent;
  elements.storageTrackFill.style.width = `${Math.min(100, Math.max(rawPercent > 0 ? 1 : 0, rawPercent))}%`;
  elements.storageUsageText.textContent = `${formatBytes(usedBytes)} / ${projectStorageLimitGb} GB`;
  elements.projectItemCount.textContent = totalItems;
  elements.itemBreakdown.textContent = `${files.length} ${files.length === 1 ? "archivo" : "archivos"} · ${folders.length} ${folders.length === 1 ? "carpeta" : "carpetas"}`;
  elements.currentUsageNote.textContent = `Uso actual del proyecto: ${formatBytes(usedBytes)}.`;
}

function slugifyFileName(name) {
  return name
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9.]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function getPublicUrl(file) {
  return `https://cdn.vune.app/vune/${file.id}-${slugifyFileName(file.name)}`;
}

function getFileType(file) {
  if (file.type.startsWith("image/")) return "image";
  if (file.type.startsWith("video/")) return "video";
  if (file.type.includes("pdf") || file.type.includes("document") || file.type.includes("text")) return "document";
  if (file.type.includes("zip") || file.type.includes("compressed")) return "archive";
  return "other";
}

function getVisibleFiles() {
  const query = elements.searchInput.value.trim().toLowerCase();
  return files
    .filter((file) => {
      let matchesSection = true;
      if (currentSection === "all") matchesSection = file.folderId === currentFolderId;
      if (["image", "video", "document"].includes(currentSection)) matchesSection = file.type === currentSection;
      if (currentSection === "shared") matchesSection = file.access === "public";
      return matchesSection && file.name.toLowerCase().includes(query);
    })
    .sort((a, b) => (sortNewestFirst ? b.id - a.id : a.id - b.id));
}

function getVisibleFolders() {
  if (currentSection !== "all") return [];
  const query = elements.searchInput.value.trim().toLowerCase();
  return folders
    .filter((folder) => folder.parentId === currentFolderId && folder.name.toLowerCase().includes(query))
    .sort((a, b) => a.name.localeCompare(b.name, "es"));
}

function getFolderItemCount(folderId) {
  return folders.filter((folder) => folder.parentId === folderId).length + files.filter((file) => file.folderId === folderId).length;
}

function getFolderPath() {
  const path = [];
  let folder = folders.find((item) => item.id === currentFolderId);
  while (folder) {
    path.unshift(folder);
    folder = folders.find((item) => item.id === folder.parentId);
  }
  return path;
}

function renderFolderNavigation() {
  const isFolderView = currentSection === "all";
  elements.breadcrumbs.hidden = !isFolderView;
  elements.newFolderButton.hidden = !isFolderView;
  if (!isFolderView) return;

  const path = getFolderPath();
  elements.breadcrumbs.innerHTML = [
    `<button type="button" data-folder-root ${currentFolderId === null ? 'aria-current="page"' : ""}>Vuné</button>`,
    ...path.flatMap((folder, index) => [
      '<span class="breadcrumb-separator" aria-hidden="true">/</span>',
      `<button type="button" data-folder-id="${folder.id}" ${index === path.length - 1 ? 'aria-current="page"' : ""}>${escapeHtml(folder.name)}</button>`
    ])
  ].join("");

}

function previewMarkup(file, grid = false) {
  if (file.previewUrl && file.type === "image") {
    return `<img src="${file.previewUrl}" alt="Vista previa de ${escapeHtml(file.name)}" />`;
  }
  if (file.type === "image" && file.color) {
    const initials = file.extension === "SVG" ? "V" : "";
    return `<span class="generated-thumb" style="display:grid;place-items:center;width:100%;height:100%;color:white;background:${file.color};font-size:${grid ? "2rem" : ".8rem"};font-weight:800">${initials}</span>`;
  }
  return icons[file.type] || icons.other;
}

function renderFiles() {
  updateProjectStats();
  renderFolderNavigation();
  const visibleFiles = getVisibleFiles();
  const visibleFolders = getVisibleFolders();
  const folderRows = visibleFolders.map((folder) => {
    const itemCount = getFolderItemCount(folder.id);
    return `
      <tr class="folder-row" data-folder-row="${folder.id}">
        <td>
          <div class="file-cell">
            <div class="file-thumb folder">${icons.folder}</div>
            <div class="file-name">
              <button type="button" data-folder-id="${folder.id}">${escapeHtml(folder.name)}</button>
              <small>CARPETA · ${itemCount} ${itemCount === 1 ? "ELEMENTO" : "ELEMENTOS"}</small>
            </div>
          </div>
        </td>
        <td>—</td>
        <td>—</td>
        <td>—</td>
        <td>
          <div class="row-actions">
            <button class="action-button" type="button" data-folder-id="${folder.id}" aria-label="Abrir ${escapeHtml(folder.name)}">
              <svg viewBox="0 0 24 24" aria-hidden="true"><path d="m9 6 6 6-6 6" /></svg>
            </button>
          </div>
        </td>
      </tr>`;
  }).join("");

  const fileRows = visibleFiles.map((file) => `
    <tr data-file-row="${file.id}">
      <td>
        <div class="file-cell">
          <div class="file-thumb ${file.type}">${previewMarkup(file)}</div>
          <div class="file-name">
            <button type="button" data-open="${file.id}">${escapeHtml(file.name)}</button>
            <small>${file.extension}</small>
          </div>
        </div>
      </td>
      <td>${formatBytes(file.size)}</td>
      <td>${file.modified}</td>
      <td><span class="access-badge ${file.access}">${file.access === "public" ? "Público" : "Privado"}</span></td>
      <td>
        <div class="row-actions">
          ${file.access === "public" ? `<button class="action-button" type="button" data-copy="${file.id}" aria-label="Copiar URL de ${escapeHtml(file.name)}">${icons.copy}</button>` : ""}
          <button class="action-button" type="button" data-open="${file.id}" aria-label="Ver detalles de ${escapeHtml(file.name)}">${icons.more}</button>
        </div>
      </td>
    </tr>
  `).join("");
  elements.fileList.innerHTML = folderRows + fileRows;

  const folderCards = visibleFolders.map((folder) => {
    const itemCount = getFolderItemCount(folder.id);
    return `
      <article class="file-card" data-folder-row="${folder.id}">
        <button class="grid-preview folder" type="button" data-folder-id="${folder.id}" aria-label="Abrir ${escapeHtml(folder.name)}">${icons.folder}</button>
        <h3>${escapeHtml(folder.name)}</h3>
        <div class="card-meta">
          <span>${itemCount} ${itemCount === 1 ? "elemento" : "elementos"}</span>
          <button class="action-button" type="button" data-folder-id="${folder.id}" aria-label="Abrir carpeta">
            <svg viewBox="0 0 24 24" aria-hidden="true"><path d="m9 6 6 6-6 6" /></svg>
          </button>
        </div>
      </article>`;
  }).join("");

  const fileCards = visibleFiles.map((file) => `
    <article class="file-card" data-file-row="${file.id}">
      <button class="grid-preview" type="button" data-open="${file.id}" aria-label="Ver ${escapeHtml(file.name)}">${previewMarkup(file, true)}</button>
      <h3>${escapeHtml(file.name)}</h3>
      <div class="card-meta">
        <span>${formatBytes(file.size)}</span>
        <span class="card-actions">
          ${file.access === "public" ? `<button class="action-button" type="button" data-copy="${file.id}" aria-label="Copiar URL">${icons.copy}</button>` : ""}
          <button class="action-button" type="button" data-open="${file.id}" aria-label="Ver detalles">${icons.more}</button>
        </span>
      </div>
    </article>
  `).join("");
  elements.fileGrid.innerHTML = folderCards + fileCards;

  const totalItems = visibleFiles.length + visibleFolders.length;
  const countLabel = totalItems === 1 ? "1 elemento" : `${totalItems} elementos`;
  elements.resultCount.textContent = countLabel;
  elements.allCount.textContent = files.length;
  elements.emptyState.hidden = totalItems > 0;
  document.querySelector(".file-table").style.display = totalItems && currentView === "list" ? "table" : "none";
  elements.fileGrid.style.display = totalItems && currentView === "grid" ? "grid" : "none";
}

function setSection(section) {
  currentSection = section;
  if (section === "all") currentFolderId = null;

  const labels = {
    recent: ["Archivos recientes", "Los últimos recursos agregados o modificados en el proyecto.", "Archivos recientes"],
    all: ["Todos los archivos", "Navegá por las carpetas y archivos del proyecto.", "Contenido"],
    image: ["Imágenes", "Todos los recursos gráficos del proyecto.", "Imágenes"],
    video: ["Videos", "Todos los videos del proyecto.", "Videos"],
    document: ["Documentos", "Todos los documentos del proyecto.", "Documentos"],
    shared: ["Compartidos", "Archivos que cuentan con una URL pública.", "Archivos compartidos"]
  };
  const [title, description, libraryTitle] = labels[section];
  elements.pageTitle.textContent = title;
  elements.pageDescription.textContent = description;
  document.querySelector("#libraryTitle").textContent = libraryTitle;
  document.querySelectorAll(".nav-item").forEach((item) => item.classList.toggle("active", item.dataset.section === section));
  renderFiles();
}

function setView(view) {
  currentView = view;
  const isList = view === "list";
  elements.listViewButton.classList.toggle("active", isList);
  elements.gridViewButton.classList.toggle("active", !isList);
  elements.listViewButton.setAttribute("aria-pressed", String(isList));
  elements.gridViewButton.setAttribute("aria-pressed", String(!isList));
  renderFiles();
}

function showToast(message) {
  elements.toast.querySelector("span").textContent = message;
  elements.toast.classList.add("show");
  window.clearTimeout(toastTimer);
  toastTimer = window.setTimeout(() => elements.toast.classList.remove("show"), 2200);
}

async function copyUrl(file) {
  const url = getPublicUrl(file);
  try {
    await navigator.clipboard.writeText(url);
  } catch {
    const input = document.createElement("input");
    input.value = url;
    document.body.appendChild(input);
    input.select();
    document.execCommand("copy");
    input.remove();
  }
  showToast("URL pública copiada");
}

function openFile(file) {
  elements.dialogName.textContent = file.name;
  elements.dialogType.textContent = file.type.toUpperCase();
  elements.dialogSize.textContent = formatBytes(file.size);
  elements.dialogDate.textContent = file.modified;
  elements.dialogAccess.textContent = file.access === "public" ? "Público" : "Privado";
  elements.dialogAccess.classList.toggle("public", file.access === "public");
  elements.dialogUrlLabel.textContent = file.access === "public" ? "URL pública" : "URL pública no disponible";
  elements.dialogUrl.value = file.access === "public" ? getPublicUrl(file) : "Hacé público el archivo para generar su URL";
  elements.copyDialogUrl.hidden = file.access !== "public";

  if (file.previewUrl && file.type === "image") {
    elements.dialogPreview.innerHTML = `<img src="${file.previewUrl}" alt="Vista previa de ${escapeHtml(file.name)}" />`;
  } else if (file.previewUrl && file.type === "video") {
    elements.dialogPreview.innerHTML = `<video src="${file.previewUrl}" controls aria-label="Vista previa de ${escapeHtml(file.name)}"></video>`;
  } else {
    elements.dialogPreview.innerHTML = previewMarkup(file, true);
  }

  elements.dialog.showModal();
}

function handleFileActions(event) {
  const folderButton = event.target.closest("[data-folder-id]");
  const copyButton = event.target.closest("[data-copy]");
  const openButton = event.target.closest("[data-open]");
  const folderRow = event.target.closest("[data-folder-row]");
  const fileRow = event.target.closest("[data-file-row]");
  if (copyButton) {
    const file = files.find((item) => item.id === Number(copyButton.dataset.copy));
    if (file) copyUrl(file);
    return;
  }
  if (folderButton) {
    openFolder(folderButton.dataset.folderId);
    return;
  }
  if (openButton) {
    const file = files.find((item) => item.id === Number(openButton.dataset.open));
    if (file) openFile(file);
    return;
  }
  if (folderRow) openFolder(folderRow.dataset.folderRow);
  if (fileRow) {
    const file = files.find((item) => item.id === Number(fileRow.dataset.fileRow));
    if (file) openFile(file);
  }
}

function simulateUpload(selectedFiles) {
  const acceptedFiles = [...selectedFiles].filter((file) => file.size <= 100 * 1024 * 1024);
  const rejectedCount = selectedFiles.length - acceptedFiles.length;
  if (rejectedCount) showToast(`${rejectedCount} archivo${rejectedCount > 1 ? "s" : ""} supera${rejectedCount > 1 ? "n" : ""} los 100 MB`);
  if (!acceptedFiles.length) return;

  elements.uploadQueue.hidden = false;
  elements.queueTitle.textContent = `Subiendo ${acceptedFiles.length} archivo${acceptedFiles.length > 1 ? "s" : ""}`;
  elements.queueItems.innerHTML = acceptedFiles.map((file, index) => `
    <div class="queue-item" data-queue="${index}">
      <span class="queue-file-icon">${icons[getFileType(file)] || icons.other}</span>
      <div class="queue-info">
        <div class="queue-label"><span>${escapeHtml(file.name)}</span><span>0%</span></div>
        <div class="queue-progress"><span></span></div>
      </div>
      <span class="queue-status">Subiendo</span>
    </div>
  `).join("");

  let completedUploads = 0;
  acceptedFiles.forEach((file, index) => {
    let progress = 0;
    const interval = window.setInterval(() => {
      progress = Math.min(100, progress + 9 + Math.floor(Math.random() * 17));
      const row = elements.queueItems.querySelector(`[data-queue="${index}"]`);
      if (!row) return window.clearInterval(interval);
      row.querySelector(".queue-progress span").style.width = `${progress}%`;
      row.querySelector(".queue-label span:last-child").textContent = `${progress}%`;
      if (progress === 100) {
        window.clearInterval(interval);
        row.querySelector(".queue-status").textContent = "Listo";
        const type = getFileType(file);
        const extension = file.name.includes(".") ? file.name.split(".").pop().toUpperCase() : "ARCHIVO";
        files.unshift({
          id: Date.now() + index,
          name: file.name,
          size: file.size,
          modified: "Ahora",
          type,
          access: "public",
          extension,
          previewUrl: type === "image" || type === "video" ? URL.createObjectURL(file) : null,
          folderId: currentSection === "all" ? currentFolderId : null
        });
        completedUploads += 1;
        if (completedUploads === acceptedFiles.length) {
          elements.queueTitle.textContent = "Carga completada";
          renderFiles();
          showToast(`${acceptedFiles.length} archivo${acceptedFiles.length > 1 ? "s cargados" : " cargado"}`);
        }
      }
    }, 160 + index * 30);
  });
}

function toggleSidebar(forceClose = false) {
  const willOpen = forceClose ? false : !elements.sidebar.classList.contains("open");
  elements.sidebar.classList.toggle("open", willOpen);
  elements.sidebarBackdrop.classList.toggle("show", willOpen);
  elements.menuButton.setAttribute("aria-expanded", String(willOpen));
}

elements.uploadButton.addEventListener("click", () => elements.fileInput.click());
elements.browseButton.addEventListener("click", () => elements.fileInput.click());
elements.fileInput.addEventListener("change", (event) => {
  simulateUpload(event.target.files);
  event.target.value = "";
});

["dragenter", "dragover"].forEach((type) => elements.dropZone.addEventListener(type, (event) => {
  event.preventDefault();
  elements.dropZone.classList.add("dragging");
}));
["dragleave", "drop"].forEach((type) => elements.dropZone.addEventListener(type, (event) => {
  event.preventDefault();
  elements.dropZone.classList.remove("dragging");
}));
elements.dropZone.addEventListener("drop", (event) => simulateUpload(event.dataTransfer.files));

document.querySelectorAll(".nav-item[data-section]").forEach((item) => item.addEventListener("click", () => {
  setSection(item.dataset.section);
  if (window.innerWidth <= 760) toggleSidebar(true);
}));

function openFolder(folderId) {
  currentFolderId = folderId;
  elements.searchInput.value = "";
  renderFiles();
}

elements.breadcrumbs.addEventListener("click", (event) => {
  const rootButton = event.target.closest("[data-folder-root]");
  const folderButton = event.target.closest("[data-folder-id]");
  if (rootButton) openFolder(null);
  if (folderButton) openFolder(folderButton.dataset.folderId);
});

elements.newFolderButton.addEventListener("click", () => {
  const currentFolder = folders.find((folder) => folder.id === currentFolderId);
  elements.folderDialogPath.textContent = currentFolder
    ? `Se creará dentro de “${currentFolder.name}”.`
    : "Se creará en la raíz del proyecto.";
  elements.folderNameInput.value = "";
  elements.folderDialog.showModal();
  window.setTimeout(() => elements.folderNameInput.focus(), 0);
});
document.querySelector("#cancelFolderButton").addEventListener("click", () => elements.folderDialog.close());
elements.folderDialog.addEventListener("click", (event) => {
  if (event.target === elements.folderDialog) elements.folderDialog.close();
});
elements.folderForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const name = elements.folderNameInput.value.trim();
  if (!name) return;
  const alreadyExists = folders.some((folder) => folder.parentId === currentFolderId && folder.name.toLowerCase() === name.toLowerCase());
  if (alreadyExists) {
    elements.folderNameInput.setCustomValidity("Ya existe una carpeta con este nombre.");
    elements.folderNameInput.reportValidity();
    return;
  }
  elements.folderNameInput.setCustomValidity("");
  folders.push({ id: `folder-${Date.now()}`, name, parentId: currentFolderId });
  elements.folderDialog.close();
  renderFiles();
  showToast("Carpeta creada");
});
elements.folderNameInput.addEventListener("input", () => elements.folderNameInput.setCustomValidity(""));

elements.settingsButton.addEventListener("click", () => {
  elements.storageLimitInput.value = projectStorageLimitGb;
  updateProjectStats();
  elements.settingsDialog.showModal();
  window.setTimeout(() => elements.storageLimitInput.focus(), 0);
});
document.querySelector("#cancelSettingsButton").addEventListener("click", () => elements.settingsDialog.close());
elements.settingsDialog.addEventListener("click", (event) => {
  if (event.target === elements.settingsDialog) elements.settingsDialog.close();
});
elements.settingsForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const newLimit = Number(elements.storageLimitInput.value);
  if (!Number.isFinite(newLimit) || newLimit < 1 || newLimit > 10000) {
    elements.storageLimitInput.setCustomValidity("Ingresá un límite entre 1 y 10.000 GB.");
    elements.storageLimitInput.reportValidity();
    return;
  }
  elements.storageLimitInput.setCustomValidity("");
  projectStorageLimitGb = newLimit;
  localStorage.setItem("vune-project-storage-limit", String(newLimit));
  updateProjectStats();
  elements.settingsDialog.close();
  showToast("Límite del proyecto actualizado");
});
elements.storageLimitInput.addEventListener("input", () => elements.storageLimitInput.setCustomValidity(""));

elements.searchInput.addEventListener("input", renderFiles);
elements.listViewButton.addEventListener("click", () => setView("list"));
elements.gridViewButton.addEventListener("click", () => setView("grid"));
elements.sortButton.addEventListener("click", () => {
  sortNewestFirst = !sortNewestFirst;
  elements.sortButton.lastChild.textContent = sortNewestFirst ? " Más recientes" : " Más antiguos";
  renderFiles();
});
elements.fileList.addEventListener("click", handleFileActions);
elements.fileGrid.addEventListener("click", handleFileActions);
elements.clearQueue.addEventListener("click", () => { elements.uploadQueue.hidden = true; });
elements.dialogClose.addEventListener("click", () => elements.dialog.close());
elements.dialog.addEventListener("click", (event) => {
  if (event.target === elements.dialog) elements.dialog.close();
});
elements.copyDialogUrl.addEventListener("click", async () => {
  try { await navigator.clipboard.writeText(elements.dialogUrl.value); }
  catch { elements.dialogUrl.select(); document.execCommand("copy"); }
  showToast("URL pública copiada");
});
elements.menuButton.addEventListener("click", () => toggleSidebar());
elements.sidebarBackdrop.addEventListener("click", () => toggleSidebar(true));
elements.logoutButton.addEventListener("click", () => {
  sessionStorage.removeItem("vune-session");
  localStorage.removeItem("vune-session");
  window.location.replace("./index.html");
});
document.addEventListener("keydown", (event) => {
  if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k") {
    event.preventDefault();
    elements.searchInput.focus();
  }
});

setSection("recent");
