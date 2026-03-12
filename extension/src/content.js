import { runFullAnalysis } from "./analysis.js";

const LEAF_SVG = `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19 2c1 2 2 4.18 2 8 0 5.5-4.78 10-10 10z"/><path d="M2 21c0-3 1.85-5.36 5.08-6C9.5 14.52 12 13 13 12"/></svg>`;

const SUPPORTED = [
	{ host: /amazon\.(in|com)/, path: /\/dp\//i },
	{ host: /amazon\.(in|com)/, path: /\/gp\/product\//i },
	{ host: /flipkart\.com/, path: /\/p\//i },
	{ host: /flipkart\.com/, path: /pid=/i },
	{ host: /nykaa\.com/, path: /\/p\//i },
	{ host: /nykaa\.com/, path: /-product-/i },
];

function isProductPage(url) {
	try {
		const u = new URL(url);
		return SUPPORTED.some(
			(p) => p.host.test(u.hostname) && (p.path.test(u.pathname) || p.path.test(u.search)),
		);
	} catch {
		return false;
	}
}

function tagStyle(tag) {
	const map = {
		SAVE: "background:#dcfce7;color:#15803d;",
		COUPON: "background:#fef9c3;color:#854d0e;",
		EMI: "background:#dbeafe;color:#1e40af;",
		EXCHANGE: "background:#fce7f3;color:#9d174d;",
		OFFER: "background:#ede9fe;color:#5b21b6;",
		DEAL: "background:#ffedd5;color:#9a3412;",
	};
	return map[tag] || "background:#f3f4f6;color:#374151;";
}

function closeSheet(overlay) {
	const sheet = document.getElementById("arkai-ext-sheet");
	if (sheet) {
		sheet.style.transform = "translateY(100%)";
		setTimeout(() => {
			overlay.remove();
			const st = document.getElementById("arkai-ext-style");
			if (st) st.remove();
		}, 350);
	}
}

function showAnalysisSheet() {
	const existing = document.getElementById("arkai-ext-overlay");
	if (existing) existing.remove();
	const existingStyle = document.getElementById("arkai-ext-style");
	if (existingStyle) existingStyle.remove();

	const st = document.createElement("style");
	st.id = "arkai-ext-style";
	st.textContent = "#arkai-ext-sheet::-webkit-scrollbar{display:none}";
	document.head.appendChild(st);

	let data;
	try {
		data = runFullAnalysis();
	} catch {
		return;
	}

	const priceText = data.price ? `₹${data.price.toLocaleString("en-IN")}` : "N/A";
	const carbonText = data.carbon ? `${data.carbon} kg CO₂` : "—";
	const stars = Array.from(
		{ length: 5 },
		(_, i) =>
			`<span style="color:${i < (data.arkaiRating || 0) ? "#facc15" : "#d1d5db"};font-size:18px;">★</span>`,
	).join("");
	const reviewText = data.reviews ? `(${data.reviews.toLocaleString("en-IN")})` : "";

	const healthColor = data.healthScore === "Caution" ? "#f59e0b" : "#22c55e";
	const planetColor =
		data.planetScore === "High Impact"
			? "#ef4444"
			: data.planetScore === "Moderate"
				? "#f59e0b"
				: "#22c55e";

	const offerCards = (data.offers || [])
		.map(
			(o) => `
		<div style="min-width:185px;max-width:185px;background:#fff;border:1.5px solid #e5e7eb;border-radius:12px;padding:10px 12px;display:flex;flex-direction:column;gap:5px;flex-shrink:0;">
			<div style="display:flex;align-items:center;gap:6px;">
				<span style="font-weight:700;font-size:12px;color:#111;flex:1;line-height:1.2;">${o.title}</span>
				<span style="font-size:9px;font-weight:700;padding:2px 6px;border-radius:99px;white-space:nowrap;${tagStyle(o.tag)}">${o.tag}</span>
			</div>
			<div style="font-size:11px;color:#4b5563;line-height:1.5;">${o.desc}</div>
		</div>`,
		)
		.join("");

	const offersSection =
		data.offers && data.offers.length > 0
			? `<div style="border-top:1px solid #e5e7eb;margin:14px 0 10px;"></div>
			<div style="font-weight:700;font-size:13px;color:#111;margin-bottom:8px;">Best Offers</div>
			<div style="display:flex;gap:8px;overflow-x:auto;margin:0 -20px;padding:0 20px 4px;-webkit-overflow-scrolling:touch;scrollbar-width:none;">${offerCards}</div>`
			: "";

	const overlay = document.createElement("div");
	overlay.id = "arkai-ext-overlay";
	overlay.style.cssText =
		"position:fixed;inset:0;background:rgba(0,0,0,0.5);display:flex;align-items:flex-end;justify-content:center;z-index:2147483647;";

	overlay.innerHTML = `
	<div id="arkai-ext-sheet" style="width:100%;max-width:520px;background:#fff;border-radius:20px 20px 0 0;padding:18px 20px 32px;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;color:#111;box-shadow:0 -6px 32px rgba(0,0,0,0.15);transform:translateY(100%);transition:transform 0.3s cubic-bezier(.4,0,.2,1);max-height:85vh;overflow-y:auto;box-sizing:border-box;">

		<div style="width:32px;height:4px;background:#e5e7eb;border-radius:99px;margin:0 auto 14px;"></div>

		<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;">
			<span style="font-size:19px;font-weight:800;background:linear-gradient(90deg,#ef4444,#3b82f6);-webkit-background-clip:text;-webkit-text-fill-color:transparent;">ArkAI</span>
			<button id="arkai-ext-close" style="background:#f3f4f6;border:none;width:28px;height:28px;border-radius:50%;cursor:pointer;font-size:13px;color:#6b7280;display:flex;align-items:center;justify-content:center;line-height:1;">✕</button>
		</div>

		${data.title ? `<div style="font-size:11px;color:#6b7280;background:#f9fafb;border-radius:8px;padding:8px 10px;margin-bottom:12px;line-height:1.5;border:1px solid #e5e7eb;">${data.title.slice(0, 110)}${data.title.length > 110 ? "…" : ""}</div>` : ""}

		<div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:8px;margin-bottom:12px;">
			<div style="background:#f0fdf4;border-radius:12px;padding:10px 12px;">
				<div style="font-size:10px;font-weight:700;color:#16a34a;margin-bottom:4px;text-transform:uppercase;letter-spacing:.5px;">Pocket</div>
				<div style="font-size:22px;font-weight:800;color:#16a34a;line-height:1;">${data.pocketScore}<span style="font-size:10px;color:#9ca3af;">/10</span></div>
				<div style="font-size:10px;color:#6b7280;margin-top:3px;">${priceText}</div>
			</div>
			<div style="background:#fefce8;border-radius:12px;padding:10px 12px;">
				<div style="font-size:10px;font-weight:700;color:#92400e;margin-bottom:4px;text-transform:uppercase;letter-spacing:.5px;">Health</div>
				<div style="font-size:13px;font-weight:700;color:${healthColor};line-height:1.2;">${data.healthScore}</div>
				<div style="font-size:10px;color:#6b7280;margin-top:3px;">${data.material || "—"}</div>
			</div>
			<div style="background:#eff6ff;border-radius:12px;padding:10px 12px;">
				<div style="font-size:10px;font-weight:700;color:#1e40af;margin-bottom:4px;text-transform:uppercase;letter-spacing:.5px;">Planet</div>
				<div style="font-size:12px;font-weight:700;color:${planetColor};line-height:1.2;">${data.planetScore}</div>
				<div style="font-size:10px;color:#6b7280;margin-top:3px;">${carbonText}</div>
			</div>
		</div>

		<div style="display:flex;justify-content:space-between;align-items:center;padding:10px 14px;background:#f9fafb;border-radius:10px;">
			<span style="font-weight:700;font-size:13px;">ArkAI Rating</span>
			<div style="display:flex;align-items:center;gap:5px;">
				<span style="line-height:1;">${stars}</span>
				<span style="font-size:11px;color:#9ca3af;">${reviewText}</span>
			</div>
		</div>

		${offersSection}
	</div>`;

	overlay.addEventListener("click", (e) => {
		if (e.target.id === "arkai-ext-overlay") closeSheet(overlay);
	});

	document.body.appendChild(overlay);

	requestAnimationFrame(() =>
		requestAnimationFrame(() => {
			const sheet = document.getElementById("arkai-ext-sheet");
			if (sheet) sheet.style.transform = "translateY(0)";
			const closeBtn = document.getElementById("arkai-ext-close");
			if (closeBtn) closeBtn.addEventListener("click", () => closeSheet(overlay));
		}),
	);
}

function injectFAB() {
	if (!isProductPage(location.href)) return;
	if (document.getElementById("arkai-ext-fab")) return;

	const fab = document.createElement("button");
	fab.id = "arkai-ext-fab";
	fab.style.cssText = [
		"position:fixed",
		"bottom:24px",
		"right:20px",
		"width:52px",
		"height:52px",
		"border-radius:50%",
		"background:linear-gradient(135deg,#16a34a,#22c55e)",
		"border:none",
		"cursor:pointer",
		"box-shadow:0 4px 18px rgba(22,163,74,0.4)",
		"z-index:2147483646",
		"display:flex",
		"align-items:center",
		"justify-content:center",
		"transition:transform 0.15s,box-shadow 0.15s",
		"-webkit-tap-highlight-color:transparent",
	].join(";");
	fab.innerHTML = LEAF_SVG;
	fab.title = "ArkAI Green Analysis";

	fab.addEventListener("mouseenter", () => {
		fab.style.transform = "scale(1.08)";
		fab.style.boxShadow = "0 6px 24px rgba(22,163,74,0.55)";
	});
	fab.addEventListener("mouseleave", () => {
		fab.style.transform = "scale(1)";
		fab.style.boxShadow = "0 4px 18px rgba(22,163,74,0.4)";
	});
	fab.addEventListener("click", showAnalysisSheet);

	document.body.appendChild(fab);
}

chrome.runtime.onMessage.addListener((message, _sender, sendResponse) => {
	if (message.type === "TRIGGER_ANALYSIS") {
		try {
			const data = runFullAnalysis();
			sendResponse({ data });
		} catch (e) {
			sendResponse({ error: e.message || "Analysis failed" });
		}
	}
	return true;
});

function init() {
	injectFAB();
}

if (document.readyState === "loading") {
	document.addEventListener("DOMContentLoaded", init);
} else {
	init();
}

let _lastHref = location.href;
const _observer = new MutationObserver(() => {
	if (location.href !== _lastHref) {
		_lastHref = location.href;
		setTimeout(() => {
			const old = document.getElementById("arkai-ext-fab");
			if (old) old.remove();
			injectFAB();
		}, 800);
	}
});
_observer.observe(document.body, { childList: true, subtree: true });
