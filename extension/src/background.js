const BACKEND_URL = "http://localhost:8000/analyze";

chrome.runtime.onInstalled.addListener(() => {
	chrome.action.setBadgeText({ text: "" });
});

chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
	if (changeInfo.status === "complete" && tab.url) {
		if (isProductPage(tab.url)) {
			chrome.action.setBadgeText({ text: "●", tabId });
			chrome.action.setBadgeBackgroundColor({ color: "#16a34a", tabId });
		} else {
			chrome.action.setBadgeText({ text: "", tabId });
		}
	}
});

chrome.runtime.onMessage.addListener((message, _sender, sendResponse) => {
	if (message.type === "GET_TAB_INFO") {
		chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
			if (tabs.length > 0) {
				const tab = tabs[0];
				sendResponse({
					url: tab.url || "",
					title: tab.title || "",
					isProduct: isProductPage(tab.url || ""),
				});
			} else {
				sendResponse({ url: "", title: "", isProduct: false });
			}
		});
		return true;
	}

	if (message.type === "RUN_ANALYSIS") {
		chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
			if (!tabs.length) {
				sendResponse({ error: "No active tab." });
				return;
			}
			const url = tabs[0].url || "";
			if (!isProductPage(url)) {
				sendResponse({ error: "Not a supported product page. Navigate to Amazon or Flipkart." });
				return;
			}
			callBackend(url)
				.then((data) => sendResponse({ data }))
				.catch((err) => sendResponse({ error: err.message }));
		});
		return true;
	}
});

async function callBackend(url) {
	const controller = new AbortController();
	const timeout = setTimeout(() => controller.abort(), 60000);
	try {
		const res = await fetch(BACKEND_URL, {
			method: "POST",
			headers: { "Content-Type": "application/json" },
			body: JSON.stringify({ url }),
			signal: controller.signal,
		});
		if (!res.ok) throw new Error(`Backend error: ${res.status}`);
		return await res.json();
	} catch (err) {
		if (err.name === "AbortError")
			throw new Error("Analysis timed out. The AI agent took too long.");
		if (err.message.includes("fetch"))
			throw new Error("Backend not reachable. Make sure the server is running on localhost:8000.");
		throw err;
	} finally {
		clearTimeout(timeout);
	}
}

function isProductPage(url) {
	if (!url) return false;
	try {
		const u = new URL(url);
		const host = u.hostname;
		const path = u.pathname + u.search;
		if (/amazon\.(in|com)/.test(host) && (/\/dp\//i.test(path) || /\/gp\/product\//i.test(path)))
			return true;
		if (/flipkart\.com/.test(host) && (/\/p\//i.test(path) || /pid=/i.test(path))) return true;
		if (/nykaa\.com/.test(host) && (/\/p\//i.test(path) || /-product-/i.test(path))) return true;
		return false;
	} catch {
		return false;
	}
}
