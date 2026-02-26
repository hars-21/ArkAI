class ProductAnalyzerScript {
  static const String script = r'''
(() => {
  "use strict";

  const CONFIG = {
    productPathIndicator: "/dp/",
    overlayId: "arkai-overlay",
    buttonId: "arkai-fab",
    zIndex: 2147483647,
  };

  function init() {
    if (!window.location.pathname.includes(CONFIG.productPathIndicator)) return;
    if (document.getElementById(CONFIG.buttonId)) return;
    injectFloatingButton();
  }

  function injectFloatingButton() {
    const button = document.createElement("div");
    button.id = CONFIG.buttonId;
    button.textContent = "✨";

    Object.assign(button.style, {
      position: "fixed",
      bottom: "40px",
      right: "20px",
      width: "60px",
      height: "60px",
      borderRadius: "50%",
      backgroundColor: "#6d28d9",
      color: "#fff",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      fontSize: "26px",
      cursor: "pointer",
      zIndex: CONFIG.zIndex,
      boxShadow: "0 8px 20px rgba(0,0,0,0.4)",
    });

    button.addEventListener("click", openOverlay);
    document.body.appendChild(button);
  }

  function openOverlay() {
    if (document.getElementById(CONFIG.overlayId)) return;
    const data = extractProductData();
    const analysis = analyze(data);
    renderOverlay(window.location.href, analysis);
  }

  function extractProductData() {
    const getText = (selector) =>
      document.querySelector(selector)?.textContent.trim() || null;

    const getAllText = (selector) =>
      Array.from(document.querySelectorAll(selector))
        .map((el) => el.textContent.trim())
        .filter(Boolean);

    const title =
      getText("#productTitle") || getText("#title") || "Unknown Product";

    function extractPrice() {
      const selectors = [
        ".a-price .a-offscreen",
        "#priceblock_ourprice",
        "#priceblock_dealprice",
        "#corePriceDisplay_desktop_feature_div .a-offscreen",
        "#corePrice_feature_div .a-offscreen",
        ".a-price-whole",
      ];

      for (const sel of selectors) {
        const el = document.querySelector(sel);
        if (el && el.textContent.trim()) {
          return el.textContent.trim();
        }
      }

      const whole = document.querySelector(".a-price-whole")?.textContent;
      const fraction = document.querySelector(".a-price-fraction")?.textContent;
      if (whole) return fraction ? `${whole}.${fraction}` : whole;

      return "Price unavailable";
    }

    const price = extractPrice();

    const rating = getText(".a-icon-alt") || "No rating";
    const reviewCount = getText("#acrCustomerReviewText") || "No reviews";

    const features = getAllText("#feature-bullets li span")
      .filter((t) => t.length > 20)
      .slice(0, 5);

    const reviews = getAllText(".review-text-content span").slice(0, 5);

    return { title, price, rating, reviewCount, features, reviews };
  }

  function analyze(data) {
    const ratingValue = parseFloat(data.rating) || 0;
    const priceNumber =
      parseFloat((data.price || "").replace(/[^0-9.]/g, "")) || 0;
    const textBlob = (
      data.features.join(" ") +
      " " +
      data.reviews.join(" ")
    ).toLowerCase();

    const pros = data.features.slice(0, 3);

    const negativeKeywords = ["not", "poor", "bad", "issue", "problem"];
    const cons = data.reviews
      .filter((r) => negativeKeywords.some((k) => r.toLowerCase().includes(k)))
      .slice(0, 2);

    let efficiencyScore = 5;
    if (ratingValue >= 4.3) efficiencyScore += 2;
    if (priceNumber && priceNumber < 50000) efficiencyScore += 1;
    if (textBlob.includes("energy efficient")) efficiencyScore += 2;
    efficiencyScore = Math.min(10, efficiencyScore);

    const efficiencyLabel =
      efficiencyScore >= 8
        ? "High Savings"
        : efficiencyScore >= 5
          ? "Moderate Efficiency"
          : "Low Efficiency";

    let safetyStatus = "Safe";
    if (
      textBlob.includes("radiation") ||
      textBlob.includes("overheat") ||
      textBlob.includes("fire")
    )
      safetyStatus = "Warning";
    if (
      textBlob.includes("toxic") ||
      textBlob.includes("hazard") ||
      textBlob.includes("explosion")
    )
      safetyStatus = "Hazardous";

    let carbonScore = 3;
    if (priceNumber > 70000) carbonScore = 6;
    if (textBlob.includes("low power") || textBlob.includes("eco mode"))
      carbonScore = 2;
    const treeEquivalent = Math.max(1, carbonScore);

    const summary = `
 ${data.title}

Price: ${data.price}
Rating: ${data.rating} (${data.reviewCount})

Customer feedback and extracted features suggest balanced performance with moderate long-term efficiency.
`.trim();

    const recommendation =
      ratingValue >= 4
        ? "Recommended based on rating and extracted signals."
        : "Mixed signals. Review carefully before purchase.";

    return {
      summary,
      pros: pros.length ? pros : ["No major strengths extracted"],
      cons: cons.length ? cons : ["No significant concerns detected"],
      recommendation,
      efficiencyScore,
      efficiencyLabel,
      safetyStatus,
      treeEquivalent,
    };
  }

  function renderOverlay(productUrl, analysis) {
    const overlay = document.createElement("div");
    overlay.id = CONFIG.overlayId;

    Object.assign(overlay.style, {
      position: "fixed",
      inset: "0",
      background: "#111",
      color: "#fff",
      zIndex: CONFIG.zIndex,
      overflowY: "auto",
      fontFamily: "system-ui, -apple-system, sans-serif",
      padding: "24px",
    });

    overlay.innerHTML = `
      <div style="max-width:720px;margin:0 auto;">
        ${renderHeader()}
        ${renderCard("AI Summary", analysis.summary)}
        ${renderSustainabilitySection(analysis)}
        ${renderProsCons(analysis.pros, analysis.cons)}
        ${renderCard("Final Recommendation", analysis.recommendation)}
      </div>
    `;

    document.body.appendChild(overlay);

    document
      .getElementById("arkai-close")
      .addEventListener("click", () => overlay.remove());
  }

  function renderHeader() {
    return `
      <div style="display:flex;align-items:center;margin-bottom:30px;">
        <div id="arkai-close" style="cursor:pointer;margin-right:16px;font-size:20px;">←</div>
        <h1 style="margin:0;font-size:24px;font-weight:600;">ArkAI Analysis</h1>
      </div>
    `;
  }

  function renderCard(title, content) {
    return `
      <div style="background:#1a1a1a;padding:20px;border-radius:14px;margin-bottom:20px;">
        <div style="font-weight:600;margin-bottom:8px;">${title}</div>
        <div style="opacity:0.85;line-height:1.6;white-space:pre-line;">${content}</div>
      </div>
    `;
  }

  function renderSustainabilitySection(analysis) {
    return `
      <div style="background:#1a1a1a;padding:22px;border-radius:14px;margin-bottom:20px;">
        <div style="font-weight:600;font-size:18px;margin-bottom:16px;">
          Sustainability Intelligence
        </div>
        <div style="display:flex;flex-direction:column;gap:14px;">

          <div style="display:flex;justify-content:space-between;">
            <span>Efficiency Grade (Pocket Score)</span>
            <span style="font-weight:600;">
              ${analysis.efficiencyScore}/10 — ${analysis.efficiencyLabel}
            </span>
          </div>

          <div style="display:flex;justify-content:space-between;">
            <span>Safety-Life Shield (Health Score)</span>
            <span style="font-weight:600;">
              ${analysis.safetyStatus}
            </span>
          </div>

          <div style="display:flex;justify-content:space-between;">
            <span>Carbon Footprint (Planet Score)</span>
            <span style="font-weight:600;">
              Equivalent to planting ${analysis.treeEquivalent} trees
            </span>
          </div>

        </div>
      </div>
    `;
  }

  function renderProsCons(pros, cons) {
    return `
      <div style="display:flex;gap:16px;flex-wrap:wrap;margin-bottom:20px;">
        ${renderListCard("Pros", pros, "#22c55e")}
        ${renderListCard("Cons", cons, "#ef4444")}
      </div>
    `;
  }

  function renderListCard(title, items, color) {
    return `
      <div style="flex:1;min-width:260px;background:#1a1a1a;padding:20px;border-radius:14px;">
        <div style="font-weight:600;margin-bottom:10px;color:${color};">${title}</div>
        <ul style="padding-left:18px;margin:0;">
          ${items.map((i) => `<li style="margin-bottom:6px;">${i}</li>`).join("")}
        </ul>
      </div>
    `;
  }

  init();
})();
''';
}
