const AUTH_KEY = "arkai_auth";

export async function getAuthState() {
	return new Promise((resolve) => {
		chrome.storage.local.get([AUTH_KEY], (result) => {
			resolve(result[AUTH_KEY] || { isLoggedIn: false, email: "" });
		});
	});
}

export async function login(email, password) {
	if (!email || email.trim().length === 0) return { success: false, error: "Email is required." };
	if (!password || password.length === 0) return { success: false, error: "Password is required." };
	if (!email.includes("@")) return { success: false, error: "Enter a valid email address." };
	const authState = { isLoggedIn: true, email: email.trim() };
	await new Promise((resolve) => {
		chrome.storage.local.set({ [AUTH_KEY]: authState }, resolve);
	});
	return { success: true };
}

export async function logout() {
	await new Promise((resolve) => {
		chrome.storage.local.set({ [AUTH_KEY]: { isLoggedIn: false, email: "" } }, resolve);
	});
}
