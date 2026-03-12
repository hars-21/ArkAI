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
			if (tabs.length > 0) {
				chrome.tabs.sendMessage(tabs[0].id, { type: "TRIGGER_ANALYSIS" }, (response) => {
					if (chrome.runtime.lastError) {
						sendResponse({
							error: "Content script not available. Navigate to a product page first.",
						});
					} else {
						sendResponse(response || { error: "No response from page." });
					}
				});
			} else {
				sendResponse({ error: "No active tab." });
			}
		});
		return true;
	}
});

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
