export function getPrice() {
	const SELS = [
		".priceToPay .a-offscreen",
		".apexPriceToPay .a-offscreen",
		"#apex_offerDisplay_desktop .a-offscreen",
		"#corePrice_feature_div .a-offscreen",
		"#corePrice_desktop .a-offscreen",
		"#priceblock_ourprice",
		"#priceblock_dealprice",
		"#priceblock_saleprice",
		".reinventPricePriceToPayMargin .a-offscreen",
		"#price_inside_buybox",
		"#newBuyBoxPrice",
		"#price",
	];
	for (let s of SELS) {
		let el = document.querySelector(s);
		if (el) {
			let v = parseFloat((el.innerText || el.textContent || "").replace(/[^0-9.]/g, ""));
			if (v > 0) return v;
		}
	}
	let whole = document.querySelector(
		".priceToPay .a-price-whole,.apexPriceToPay .a-price-whole,#corePrice_feature_div .a-price-whole",
	);
	if (whole) {
		let frac =
			whole.closest(".a-price") && whole.closest(".a-price").querySelector(".a-price-fraction");
		let w = parseFloat((whole.innerText || "").replace(/[^0-9]/g, ""));
		let f = frac ? parseFloat((frac.innerText || "0").replace(/[^0-9]/g, "")) / 100 : 0;
		if (w > 0) return w + f;
	}
	for (let el of document.querySelectorAll(".a-offscreen")) {
		let txt = (el.innerText || el.textContent || "").trim();
		if (/[₹]/.test(txt) || /^\d[\d,]+(\.\d{2})?$/.test(txt)) {
			let v = parseFloat(txt.replace(/[^0-9.]/g, ""));
			if (v > 10) return v;
		}
	}
	let matches = (document.body.innerText || "").match(/₹\s?([\d,]+(?:\.\d{1,2})?)/g);
	if (matches) {
		for (let m of matches) {
			let v = parseFloat(m.replace(/[^0-9.]/g, ""));
			if (v > 10) return v;
		}
	}
	return 0;
}

export function getRating() {
	for (let s of [".a-icon-alt", "#averageCustomerReviews .a-icon-alt"]) {
		let el = document.querySelector(s);
		if (el && el.innerText) return parseFloat(el.innerText) || 0;
	}
	return 0;
}

export function getReviews() {
	for (let s of ["#acrCustomerReviewText", "#acrCustomerReviewLink"]) {
		let el = document.querySelector(s);
		if (el && el.innerText) return parseInt(el.innerText.replace(/[^0-9]/g, "")) || 0;
	}
	return 0;
}

export function getTitle() {
	let titleEl = document.querySelector("#productTitle,h1");
	return titleEl ? (titleEl.innerText || "").trim() : "";
}

export function getFeatures() {
	const SELS = [
		"#feature-bullets li span",
		"#featurebullets_feature_div li",
		".a-unordered-list .a-list-item",
		"#productDescription p",
		"#productDescription_feature_div p",
		"#aplus p",
		"#aplus li",
		"#technicalSpecifications_section_1 td",
		"#technicalSpecifications_section_2 td",
		"#prodDetails td",
		"#detailBullets_feature_div li",
		"#detailBulletsWrapper_feature_div li",
		'[data-feature-name="technicalSpecifications"] td',
		'[data-feature-name="productDetails"] td',
		".product-facts-detail",
		"#productFactsDesktop td",
		"#productFactsMobile td",
	];
	let parts = [];
	for (let s of SELS) {
		document.querySelectorAll(s).forEach((el) => {
			let t = (el.innerText || el.textContent || "").trim();
			if (t) parts.push(t);
		});
	}
	let m = document.querySelector('meta[name="description"]');
	if (m && m.content) parts.push(m.content);
	return parts.join(" ");
}

export function detectMaterial(text) {
	text = text.toLowerCase();
	if (text.includes("100% cotton") || text.includes("pure cotton")) return "cotton";
	if (text.includes("cotton")) return "cotton";
	if (text.includes("polyester")) return "polyester";
	if (text.includes("nylon")) return "nylon";
	if (text.includes("wool")) return "wool";
	if (text.includes("silk")) return "silk";
	if (text.includes("leather")) return "leather";
	if (text.includes("denim")) return "denim";
	if (text.includes("linen")) return "linen";
	if (text.includes("fabric") || text.includes("textile")) return "fabric";
	if (text.includes("stainless steel")) return "stainless steel";
	if (text.includes("steel")) return "steel";
	if (text.includes("aluminium") || text.includes("aluminum")) return "aluminium";
	if (text.includes("plastic") || text.includes("abs") || text.includes("polypropylene"))
		return "plastic";
	if (text.includes("glass")) return "glass";
	if (text.includes("wood") || text.includes("wooden")) return "wood";
	if (text.includes("rubber")) return "rubber";
	if (text.includes("ceramic")) return "ceramic";
	if (text.includes("silicone")) return "silicone";
	return null;
}

export function estimateCarbon(material, price) {
	const base = price / 100;
	const impact = {
		cotton: 2,
		polyester: 4,
		nylon: 4,
		wool: 3,
		silk: 3,
		leather: 5,
		denim: 3,
		linen: 1,
		fabric: 2,
		"stainless steel": 3,
		steel: 3,
		aluminium: 4,
		plastic: 5,
		glass: 2,
		wood: 1,
		rubber: 3,
		ceramic: 2,
		silicone: 2,
	};
	return Math.round(base * (material && impact[material] ? impact[material] : 3));
}

export function computePocketScore(price) {
	if (price === 0) return 5;
	if (price < 500) return 9;
	if (price < 1000) return 9;
	if (price < 3000) return 8;
	if (price < 6000) return 6;
	return 4;
}

export function computeHealthScore(material) {
	const unsafe = ["plastic", "polyester", "nylon"];
	return material && unsafe.includes(material) ? "Caution" : "Safe";
}

export function computePlanetScore(carbon) {
	if (carbon < 50) return "Low Impact";
	if (carbon < 120) return "Moderate";
	return "High Impact";
}

export function computeArkAIRating(rating, pocketScore, reviews) {
	let arkaiRating = Math.round((rating + pocketScore / 2) / 2);
	if (reviews > 5000) arkaiRating = Math.min(5, arkaiRating + 1);
	if (reviews < 100) arkaiRating = Math.max(1, arkaiRating - 1);
	return Math.max(1, Math.min(5, arkaiRating));
}

export function getOffers() {
	let offers = [];

	function add(type, title, desc, tag) {
		desc = desc.replace(/\s+/g, " ").trim();
		if (desc.length > 6 && !offers.find((o) => o.desc === desc) && offers.length < 8) {
			offers.push({ type, title, desc: desc.slice(0, 88) + (desc.length > 88 ? "…" : ""), tag });
		}
	}

	[
		"#itembox-InstantBankDiscount li",
		"#sopp_feature_div li",
		"#instantBankDiscount li",
		"#bankOffers li",
		"#bank_offer_feature_div li",
		'.a-section[data-feature-name="instantBankDiscount"] li',
	].forEach((s) =>
		document
			.querySelectorAll(s)
			.forEach((el) => add("bank", "Bank Offer", el.innerText || "", "SAVE")),
	);

	[
		"#couponFeature",
		".couponBadge",
		"#promoPriceBlockMessage_feature_div",
		'[data-feature-name="couponFeature"]',
		"#couponText",
		"#promotions_feature_div li",
	].forEach((s) =>
		document
			.querySelectorAll(s)
			.forEach((el) => add("coupon", "Coupon", el.innerText || "", "COUPON")),
	);

	[
		"#emiFeature",
		"#emi_feature_div",
		"#installmentCalculator_feature_div",
		'[data-feature-name="emiFeature"]',
		".emi-link",
	].forEach((s) => {
		let el = document.querySelector(s);
		if (el) {
			let t = el.innerText || "";
			let m = t.match(/no.?cost emi.{0,60}/i) || t.match(/emi (available|starting|from).{0,60}/i);
			add("emi", "No Cost EMI", m ? m[0] : t, "EMI");
		}
	});

	[
		"#exchangeOffer",
		"#tradeInValue_feature_div",
		'[data-feature-name="exchangeOffer"]',
		"#exchange-offer-feature-div",
	].forEach((s) => {
		let el = document.querySelector(s);
		if (el) add("exchange", "Exchange Offer", el.innerText || "", "EXCHANGE");
	});

	[
		"#partnerOffers_feature_div li",
		"#partner-offers-feature-div li",
		"#rewards_feature_div",
	].forEach((s) =>
		document
			.querySelectorAll(s)
			.forEach((el) => add("partner", "Partner Offer", el.innerText || "", "OFFER")),
	);

	if (offers.length === 0) {
		document.querySelectorAll(".a-section li,.a-box li").forEach((el) => {
			let t = (el.innerText || "").trim();
			if (t.length > 10 && (/(offer|discount|save|emi|cashback|reward)/i.test(t) || /₹/.test(t))) {
				add("deal", "Offer", t, "DEAL");
			}
		});
	}

	return offers;
}

// ─── Full Analysis ─────────────────────────────────────────────────────────────
export function runFullAnalysis() {
	const title = getTitle();
	const price = getPrice();
	const rating = getRating();
	const reviews = getReviews();
	const fullText = title + " " + getFeatures();
	const material = detectMaterial(fullText);
	const carbon = estimateCarbon(material, price);
	const pocketScore = computePocketScore(price);
	const healthScore = computeHealthScore(material);
	const planetScore = computePlanetScore(carbon);
	const arkaiRating = computeArkAIRating(rating, pocketScore, reviews);
	const offers = getOffers();
	const matDisplay = material ? material.charAt(0).toUpperCase() + material.slice(1) : null;

	return {
		title: title || null,
		price: price > 0 ? price : null,
		rating: rating > 0 ? rating : null,
		reviews: reviews > 0 ? reviews : null,
		material: matDisplay,
		carbon: carbon > 0 ? carbon : null,
		pocketScore,
		healthScore,
		planetScore,
		arkaiRating,
		offers,
	};
}
