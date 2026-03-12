import { getAuthState, login, logout } from "./auth.js";

const state = {
	isLoggedIn: false,
	email: "",
	currentTab: { url: "", title: "", isProduct: false },
	greenCount: 0,
	analysisData: null,
};

const $ = (id) => document.getElementById(id);

const STAR_FILLED = `<svg width="11" height="11" viewBox="0 0 24 24" fill="#facc15" stroke="#facc15" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>`;
const STAR_EMPTY = `<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#4b5563" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>`;

function showScreen(name) {
	["login", "home", "analysis"].forEach((key) => {
		const el = $(`${key}-screen`);
		if (!el) return;
		if (key === name) {
			el.classList.remove("hidden");
			el.classList.add("flex");
		} else {
			el.classList.add("hidden");
			el.classList.remove("flex");
		}
	});
}

function renderHome() {
	const urlBar = $("current-tab-url-bar");
	if (urlBar) urlBar.textContent = state.currentTab.url || "arkai://home";

	const analyzeCard = $("analyze-card");
	const tabUrlDisplay = $("tab-url-display");
	const tabStatusBadge = $("tab-status-badge");

	if (state.currentTab.isProduct && state.currentTab.url) {
		if (analyzeCard) {
			analyzeCard.classList.remove("hidden");
			analyzeCard.classList.add("flex");
		}
		if (tabStatusBadge) {
			tabStatusBadge.classList.remove("hidden");
			tabStatusBadge.classList.add("flex");
		}
		if (tabUrlDisplay) {
			try {
				const u = new URL(state.currentTab.url);
				const path = u.pathname.slice(0, 28);
				tabUrlDisplay.textContent = u.hostname + path + (u.pathname.length > 28 ? "…" : "");
			} catch {
				tabUrlDisplay.textContent = state.currentTab.url.slice(0, 50);
			}
		}
	} else {
		if (analyzeCard) {
			analyzeCard.classList.add("hidden");
			analyzeCard.classList.remove("flex");
		}
		if (tabStatusBadge) {
			tabStatusBadge.classList.add("hidden");
			tabStatusBadge.classList.remove("flex");
		}
	}

	const greenCount = $("green-count");
	if (greenCount) greenCount.textContent = state.greenCount;
}

function renderStars(count) {
	let html = "";
	for (let i = 1; i <= 5; i++) html += i <= count ? STAR_FILLED : STAR_EMPTY;
	return html;
}

function renderAnalysis(data) {
	const titleRow = $("product-title-row");
	const titleText = $("product-title-text");
	if (data.title && titleRow && titleText) {
		titleText.textContent = data.title.length > 120 ? data.title.slice(0, 120) + "…" : data.title;
		titleRow.classList.remove("hidden");
		titleRow.classList.add("flex");
	} else if (titleRow) {
		titleRow.classList.add("hidden");
	}

	const pocketScore = $("pocket-score");
	if (pocketScore) pocketScore.textContent = data.budget_score ?? "—";

	const priceDisplay = $("price-display");
	if (priceDisplay) {
		priceDisplay.textContent = data.price || "—";
	}

	const healthScore = $("health-score");
	if (healthScore) {
		const hs = data.health_score;
		healthScore.textContent = hs != null ? `${hs}/10` : "—";
		healthScore.className =
			"text-[11px] font-bold leading-snug " +
			(hs != null && hs < 5 ? "text-amber-400" : "text-green-400");
	}

	const materialDisplay = $("material-display");
	if (materialDisplay) {
		materialDisplay.textContent = data.about
			? data.about.slice(0, 60) + (data.about.length > 60 ? "…" : "")
			: "—";
	}

	const planetScore = $("planet-score");
	if (planetScore) {
		const ps = data.planet_score;
		planetScore.textContent = ps != null ? `${ps}/10` : "—";
		const color =
			ps == null
				? "text-white"
				: ps >= 7
					? "text-green-400"
					: ps >= 4
						? "text-amber-400"
						: "text-red-400";
		planetScore.className = "text-[11px] font-bold leading-snug " + color;
	}

	const lifeScoreEl = $("life-score");
	if (lifeScoreEl) {
		const ls = data.life_score;
		lifeScoreEl.textContent = ls != null ? `${ls}/10` : "—";
		const color =
			ls == null
				? "text-purple-400"
				: ls >= 7
					? "text-green-400"
					: ls >= 4
						? "text-amber-400"
						: "text-red-400";
		lifeScoreEl.className = "text-[13px] font-black leading-none " + color;
	}

	const starBar = $("star-bar");
	if (starBar) {
		const avg =
			data.budget_score != null &&
			data.health_score != null &&
			data.planet_score != null &&
			data.life_score != null
				? Math.round(
						(data.budget_score + data.health_score + data.planet_score + data.life_score) / 4 / 2,
					)
				: 0;
		starBar.innerHTML = renderStars(Math.max(1, Math.min(5, avg)));
	}

	const reviewCount = $("review-count");
	if (reviewCount) reviewCount.textContent = "";

	const offersSection = $("offers-section");
	if (offersSection) offersSection.classList.add("hidden");
}

function renderOfferCard(offer) {
	const tagColors = {
		SAVE: "bg-green-500/15 text-green-400",
		COUPON: "bg-yellow-500/15 text-yellow-400",
		EMI: "bg-blue-500/15 text-blue-400",
		EXCHANGE: "bg-pink-500/15 text-pink-400",
		OFFER: "bg-purple-500/15 text-purple-400",
		DEAL: "bg-orange-500/15 text-orange-400",
	};
	const tagColor = tagColors[offer.tag] || "bg-white/10 text-white/50";
	return `<div class="flex flex-col gap-1 px-3 py-2.5 bg-white/3 border border-white/7 rounded-lg">
		<div class="flex items-center gap-1.5">
			<span class="text-[11px] font-semibold text-white/70 flex-1 leading-tight">${offer.title}</span>
			<span class="text-[9px] font-bold px-1.5 py-0.5 rounded-md ${tagColor}">${offer.tag}</span>
		</div>
		<p class="text-[10px] text-white/35 leading-snug">${offer.desc}</p>
	</div>`;
}

async function triggerAnalysis() {
	showScreen("analysis");

	const loading = $("analysis-loading");
	const errorEl = $("analysis-error");
	const results = $("analysis-results");

	if (loading) {
		loading.classList.remove("hidden");
		loading.classList.add("flex");
	}
	if (errorEl) {
		errorEl.classList.add("hidden");
		errorEl.classList.remove("flex");
	}
	if (results) {
		results.classList.add("hidden");
		results.classList.remove("flex");
	}

	try {
		const response = await new Promise((resolve, reject) => {
			const timeout = setTimeout(() => reject(new Error("Request timed out")), 65000);
			chrome.runtime.sendMessage({ type: "RUN_ANALYSIS" }, (res) => {
				clearTimeout(timeout);
				if (chrome.runtime.lastError) {
					reject(new Error(chrome.runtime.lastError.message));
				} else {
					resolve(res);
				}
			});
		});

		if (loading) {
			loading.classList.add("hidden");
			loading.classList.remove("flex");
		}

		if (response && response.data) {
			state.analysisData = response.data;
			state.greenCount = (state.greenCount || 0) + 1;
			chrome.storage.local.set({ arkai_green_count: state.greenCount });
			renderAnalysis(response.data);
			if (results) {
				results.classList.remove("hidden");
				results.classList.add("flex");
			}
		} else {
			showAnalysisError(
				response?.error ||
					"Could not read this page. Make sure you are on a supported product page (Amazon, Flipkart, Nykaa).",
			);
		}
	} catch (e) {
		if (loading) {
			loading.classList.add("hidden");
			loading.classList.remove("flex");
		}
		showAnalysisError(
			e.message === "Request timed out"
				? "Analysis timed out. The AI agent took too long — please try again."
				: e.message || "Could not connect to the backend. Make sure the server is running.",
		);
	}
}

function showAnalysisError(msg) {
	const errorEl = $("analysis-error");
	const errorMsg = $("analysis-error-msg");
	if (errorMsg) errorMsg.textContent = msg;
	if (errorEl) {
		errorEl.classList.remove("hidden");
		errorEl.classList.add("flex");
	}
}

async function init() {
	const auth = await getAuthState();
	state.isLoggedIn = auth.isLoggedIn;
	state.email = auth.email;

	await new Promise((resolve) => {
		chrome.storage.local.get(["arkai_green_count"], (result) => {
			state.greenCount = result.arkai_green_count || 0;
			resolve();
		});
	});

	chrome.runtime.sendMessage({ type: "GET_TAB_INFO" }, (tabInfo) => {
		if (tabInfo) state.currentTab = tabInfo;
		if (state.isLoggedIn) {
			showScreen("home");
			renderHome();
		} else {
			showScreen("login");
		}
	});

	const loginForm = $("login-form");
	if (loginForm) {
		loginForm.addEventListener("submit", async (e) => {
			e.preventDefault();
			const email = $("email")?.value?.trim() || "";
			const password = $("password")?.value || "";
			const errorEl = $("login-error");
			const loginBtn = $("login-btn");

			if (loginBtn) loginBtn.disabled = true;
			if (errorEl) errorEl.textContent = "";

			if (!email || !password) {
				if (errorEl) errorEl.textContent = "Please fill in both fields.";
				if (loginBtn) loginBtn.disabled = false;
				return;
			}

			const result = await login(email, password);
			if (result.success) {
				state.isLoggedIn = true;
				state.email = email;
				chrome.runtime.sendMessage({ type: "GET_TAB_INFO" }, (tabInfo) => {
					if (tabInfo) state.currentTab = tabInfo;
					showScreen("home");
					renderHome();
				});
			} else {
				if (errorEl) errorEl.textContent = result.error || "Invalid credentials.";
				if (loginBtn) loginBtn.disabled = false;
			}
		});
	}

	const logoutBtn = $("logout-btn");
	if (logoutBtn) {
		logoutBtn.addEventListener("click", async () => {
			await logout();
			state.isLoggedIn = false;
			state.email = "";
			if ($("email")) $("email").value = "";
			if ($("password")) $("password").value = "";
			if ($("login-error")) $("login-error").textContent = "";
			showScreen("login");
		});
	}

	const runAnalysisBtn = $("run-analysis-btn");
	if (runAnalysisBtn) {
		runAnalysisBtn.addEventListener("click", triggerAnalysis);
	}

	const analyzeCurrentBtn = $("analyze-current-btn");
	if (analyzeCurrentBtn) {
		analyzeCurrentBtn.addEventListener("click", () => {
			if (state.currentTab.isProduct) {
				triggerAnalysis();
			} else {
				chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
					if (tabs.length > 0) {
						chrome.tabs.update(tabs[0].id, { url: "https://www.amazon.in" });
						window.close();
					}
				});
			}
		});
	}

	const backBtn = $("back-btn");
	if (backBtn) {
		backBtn.addEventListener("click", () => {
			showScreen("home");
			renderHome();
		});
	}

	const retryBtn = $("retry-btn");
	if (retryBtn) {
		retryBtn.addEventListener("click", triggerAnalysis);
	}

	const addFavBtn = $("add-fav-btn");
	if (addFavBtn) {
		addFavBtn.addEventListener("click", () => {
			chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
				if (tabs.length > 0 && tabs[0].url) {
					chrome.tabs.create({ url: tabs[0].url });
				}
			});
		});
	}
}

document.addEventListener("DOMContentLoaded", init);
