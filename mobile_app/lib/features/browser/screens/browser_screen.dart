import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dio/dio.dart';
import '../providers/browser_provider.dart';

class BrowserScreen extends StatefulWidget {
  final String? initialUrl;

  const BrowserScreen({super.key, this.initialUrl});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnJavaScriptAlertDialog((
        JavaScriptAlertDialogRequest request,
      ) async {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Message from Website'),
            content: Text(request.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      })
      ..addJavaScriptChannel(
        'ArkAIChannel',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint('ArkAI JS Message Received: ${message.message}');
          if (mounted) {
            context.read<BrowserProvider>().setWebsite(message.message);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              context.read<BrowserProvider>().setLoading(true);
              context.read<BrowserProvider>().setUrl(url);
            }
          },
          onPageFinished: (String url) async {
            if (mounted) {
              context.read<BrowserProvider>().setLoading(false);
            }

            // Inject JavaScript
            const String script = r'''
javascript:(function(){

  if(!location.href.includes('/dp/'))return;
  if(document.getElementById('arkai-fab'))return;

  function getPrice(){
    const SELS=[
      '.priceToPay .a-offscreen','.apexPriceToPay .a-offscreen',
      '#apex_offerDisplay_desktop .a-offscreen',
      '#corePrice_feature_div .a-offscreen','#corePrice_desktop .a-offscreen',
      '#priceblock_ourprice','#priceblock_dealprice','#priceblock_saleprice',
      '.reinventPricePriceToPayMargin .a-offscreen',
      '#price_inside_buybox','#newBuyBoxPrice','#price',
    ];
    for(let s of SELS){
      let el=document.querySelector(s);
      if(el){let v=parseFloat((el.innerText||el.textContent||'').replace(/[^0-9.]/g,''));if(v>0)return v;}
    }
    let whole=document.querySelector('.priceToPay .a-price-whole,.apexPriceToPay .a-price-whole,#corePrice_feature_div .a-price-whole');
    if(whole){
      let frac=whole.closest('.a-price')&&whole.closest('.a-price').querySelector('.a-price-fraction');
      let w=parseFloat((whole.innerText||'').replace(/[^0-9]/g,''));
      let f=frac?parseFloat((frac.innerText||'0').replace(/[^0-9]/g,''))/100:0;
      if(w>0)return w+f;
    }
    for(let el of document.querySelectorAll('.a-offscreen')){
      let txt=(el.innerText||el.textContent||'').trim();
      if(/[₹]/.test(txt)||/^\d[\d,]+(\.\d{2})?$/.test(txt)){let v=parseFloat(txt.replace(/[^0-9.]/g,''));if(v>10)return v;}
    }
    let matches=(document.body.innerText||'').match(/₹\s?([\d,]+(?:\.\d{1,2})?)/g);
    if(matches){for(let m of matches){let v=parseFloat(m.replace(/[^0-9.]/g,''));if(v>10)return v;}}
    return 0;
  }

  function getRating(){
    for(let s of ['.a-icon-alt','#averageCustomerReviews .a-icon-alt']){
      let el=document.querySelector(s);if(el&&el.innerText)return parseFloat(el.innerText)||0;
    }
    return 0;
  }

  function getReviews(){
    for(let s of ['#acrCustomerReviewText','#acrCustomerReviewLink']){
      let el=document.querySelector(s);if(el&&el.innerText)return parseInt(el.innerText.replace(/[^0-9]/g,''))||0;
    }
    return 0;
  }

  function getFeatures(){
    const SELS=[
      '#feature-bullets li span','#featurebullets_feature_div li',
      '.a-unordered-list .a-list-item',
      '#productDescription p','#productDescription_feature_div p',
      '#aplus p','#aplus li',
      '#technicalSpecifications_section_1 td','#technicalSpecifications_section_2 td',
      '#prodDetails td','#detailBullets_feature_div li',
      '#detailBulletsWrapper_feature_div li',
      '[data-feature-name="technicalSpecifications"] td',
      '[data-feature-name="productDetails"] td',
      '.product-facts-detail','#productFactsDesktop td','#productFactsMobile td',
    ];
    let parts=[];
    for(let s of SELS){
      document.querySelectorAll(s).forEach(el=>{let t=(el.innerText||el.textContent||'').trim();if(t)parts.push(t);});
    }
    let m=document.querySelector('meta[name="description"]');
    if(m&&m.content)parts.push(m.content);
    return parts.join(' ');
  }

  function detectMaterial(text){
    text=text.toLowerCase();
    if(text.includes('100% cotton')||text.includes('pure cotton'))return'cotton';
    if(text.includes('cotton'))return'cotton';
    if(text.includes('polyester'))return'polyester';
    if(text.includes('nylon'))return'nylon';
    if(text.includes('wool'))return'wool';
    if(text.includes('silk'))return'silk';
    if(text.includes('leather'))return'leather';
    if(text.includes('denim'))return'denim';
    if(text.includes('linen'))return'linen';
    if(text.includes('fabric')||text.includes('textile'))return'fabric';
    if(text.includes('stainless steel'))return'stainless steel';
    if(text.includes('steel'))return'steel';
    if(text.includes('aluminium')||text.includes('aluminum'))return'aluminium';
    if(text.includes('plastic')||text.includes('abs')||text.includes('polypropylene'))return'plastic';
    if(text.includes('glass'))return'glass';
    if(text.includes('wood')||text.includes('wooden'))return'wood';
    if(text.includes('rubber'))return'rubber';
    if(text.includes('ceramic'))return'ceramic';
    if(text.includes('silicone'))return'silicone';
    return null;
  }

  function estimateCarbon(material,price){
    const base=price/100;
    const impact={'cotton':2,'polyester':4,'nylon':4,'wool':3,'silk':3,'leather':5,'denim':3,'linen':1,'fabric':2,'stainless steel':3,'steel':3,'aluminium':4,'plastic':5,'glass':2,'wood':1,'rubber':3,'ceramic':2,'silicone':2};
    return Math.round(base*(material&&impact[material]?impact[material]:3));
  }

  function stars(c){
    let s='';for(let i=1;i<=5;i++)s+=i<=c?'★':'☆';return s;
  }

  function tagStyle(tag){
    const map={
      SAVE:'background:#dcfce7;color:#15803d;',
      COUPON:'background:#fef9c3;color:#854d0e;',
      EMI:'background:#dbeafe;color:#1e40af;',
      EXCHANGE:'background:#fce7f3;color:#9d174d;',
      OFFER:'background:#ede9fe;color:#5b21b6;',
      DEAL:'background:#ffedd5;color:#9a3412;',
    };
    return map[tag]||'background:#f3f4f6;color:#374151;';
  }

  function getOffers(){
    let offers=[];
    function add(icon,title,desc,tag){
      desc=desc.replace(/\s+/g,' ').trim();
      if(desc.length>6&&!offers.find(o=>o.desc===desc)&&offers.length<8){
        offers.push({icon,title,desc:desc.slice(0,88)+(desc.length>88?'…':''),tag});
      }
    }

    [
      '#itembox-InstantBankDiscount li','#sopp_feature_div li',
      '#instantBankDiscount li','#bankOffers li',
      '#bank_offer_feature_div li',
      '.a-section[data-feature-name="instantBankDiscount"] li',
    ].forEach(s=>document.querySelectorAll(s).forEach(el=>add('🏦','Bank Offer',(el.innerText||''),'SAVE')));

    [
      '#couponFeature','.couponBadge',
      '#promoPriceBlockMessage_feature_div',
      '[data-feature-name="couponFeature"]',
      '#couponText','#promotions_feature_div li',
    ].forEach(s=>document.querySelectorAll(s).forEach(el=>add('🎟️','Coupon',(el.innerText||''),'COUPON')));

    [
      '#emiFeature','#emi_feature_div',
      '#installmentCalculator_feature_div',
      '[data-feature-name="emiFeature"]','.emi-link',
    ].forEach(s=>{
      let el=document.querySelector(s);
      if(el){
        let t=(el.innerText||'');
        let m=t.match(/no.?cost emi.{0,60}/i)||t.match(/emi (available|starting|from).{0,60}/i);
        add('💳','No Cost EMI',m?m[0]:t,'EMI');
      }
    });

    [
      '#exchangeOffer','#tradeInValue_feature_div',
      '[data-feature-name="exchangeOffer"]','#exchange-offer-feature-div',
    ].forEach(s=>{let el=document.querySelector(s);if(el)add('🔄','Exchange Offer',(el.innerText||''),'EXCHANGE');});

    [
      '#partnerOffers_feature_div li','#partner-offers-feature-div li','#rewards_feature_div',
    ].forEach(s=>document.querySelectorAll(s).forEach(el=>add('🎁','Partner Offer',(el.innerText||''),'OFFER')));

    if(offers.length===0){
      document.querySelectorAll('.a-section li,.a-box li').forEach(el=>{
        let t=(el.innerText||'').trim();
        if(t.length>10&&(/(offer|discount|save|emi|cashback|reward)/i.test(t)||/₹/.test(t))){
          add('🏷️','Offer',t,'DEAL');
        }
      });
    }

    return offers;
  }

  window.computeAndShow = function(){
    let apiData = window.arkaiApiData;
    let title = '';
    let price = 0;
    let pocketScore = 5;
    let healthScore = '⚠️ Caution';
    let planetScore = '🔴 High Impact';
    let lifeScore = null;
    let material = null;
    let carbon = 0;
    let rating = 0;
    let reviews = 0;
    let fullText = '';
    let matDisplay = 'Not detected';
    let arkaiRating = 3;
    let isApiData = false;

    if(apiData && typeof apiData === 'object'){
      isApiData = true;
      title = apiData.title || '';
      price = parseFloat((apiData.price || '').replace(/[^0-9.]/g, '')) || 0;
      rating = getRating();
      reviews = getReviews();
      pocketScore = !isNaN(Number(apiData.budget_score)) ? Number(apiData.budget_score) : 5;
      let ps = !isNaN(Number(apiData.planet_score)) ? Number(apiData.planet_score) : 5;
      planetScore = ps >= 7 ? '🟢 ' + ps : ps >= 4 ? '🟡 ' + ps : '🔴 ' + ps;
      let hs = !isNaN(Number(apiData.health_score)) ? Number(apiData.health_score) : 0;
      healthScore = hs >= 7 ? '✅ Safe' : hs >= 4 ? '🟡 Moderate' : '⚠️ Caution';
      lifeScore = !isNaN(Number(apiData.life_score)) ? Number(apiData.life_score) : null;
      material = null;
      carbon = 0;
      fullText = apiData.about || '';
      matDisplay = 'AI Analysis';
      arkaiRating = rating > 0 ? Math.round(rating) : pocketScore;
    } else {
      let titleEl=document.querySelector('#productTitle,h1');
      title=titleEl?(titleEl.innerText||'').trim():'';
      price=getPrice();
      rating=getRating();
      reviews=getReviews();
      fullText=title+' '+getFeatures();
      material=detectMaterial(fullText);
      carbon=estimateCarbon(material,price);
      pocketScore=price===0?5:price<500?9:price<1000?9:price<3000?8:price<6000?6:4;
      let unsafe=['plastic','polyester','nylon'];
      healthScore=material&&unsafe.includes(material)?'⚠️ Caution':'✅ Safe';
      planetScore=carbon<50?'🟢 Low Impact':carbon<120?'🟡 Moderate':'🔴 High Impact';
      arkaiRating=Math.round((rating+(pocketScore/2))/2);
      if(reviews>5000)arkaiRating=Math.min(5,arkaiRating+1);
      if(reviews<100)arkaiRating=Math.max(1,arkaiRating-1);
      matDisplay=material?(material.charAt(0).toUpperCase()+material.slice(1)):'Not detected';
    }

    let offers = getOffers();

    let offerCards=offers.map(o=>`
      <div style="min-width:195px;max-width:195px;background:#fff;border:1.5px solid #e5e7eb;border-radius:14px;padding:13px 13px 11px;display:flex;flex-direction:column;gap:7px;box-shadow:0 2px 8px rgba(0,0,0,0.05);box-sizing:border-box;flex-shrink:0;">
        <div style="display:flex;align-items:center;gap:6px;">
          <span style="font-size:18px;">${o.icon}</span>
          <span style="font-weight:700;font-size:12.5px;color:#111;flex:1;line-height:1.2;">${o.title}</span>
          <span style="font-size:9.5px;font-weight:700;padding:2px 6px;border-radius:99px;white-space:nowrap;${tagStyle(o.tag)}">${o.tag}</span>
        </div>
        <div style="font-size:11px;color:#4b5563;line-height:1.55;">${o.desc}</div>
      </div>
    `).join('');

    let offersSection=offers.length>0?`
      <div style="border-top:1px solid #e5e7eb;margin:18px 0 14px;"></div>
      <div style="font-weight:700;font-size:15px;margin-bottom:11px;">🏷️ Best Offers</div>
      <div style="display:flex;gap:10px;overflow-x:auto;margin:0 -20px;padding:0 20px 4px;-webkit-overflow-scrolling:touch;scrollbar-width:none;">${offerCards}</div>
    `:`<div style="border-top:1px solid #e5e7eb;margin:18px 0 14px;"></div>
      <div style="font-weight:700;font-size:15px;margin-bottom:8px;">🏷️ Best Offers</div>
      <div style="font-size:12px;color:#9ca3af;text-align:center;padding:10px 0;">No offers found on this page</div>
    `;

    let old=document.getElementById('arkai-overlay');
    if(old)old.remove();
    let oldStyle=document.getElementById('arkai-style');
    if(oldStyle)oldStyle.remove();

    let st=document.createElement('style');
    st.id='arkai-style';
    st.textContent='#arkai-sheet div::-webkit-scrollbar{display:none}';
    document.head.appendChild(st);

    const overlay=document.createElement('div');
    overlay.id='arkai-overlay';
    overlay.style.cssText='position:fixed;inset:0;background:rgba(0,0,0,0.5);display:flex;align-items:flex-end;justify-content:center;z-index:2147483647;';

    overlay.innerHTML=`
      <div id="arkai-sheet" style="width:100%;max-width:480px;background:#fff;border-radius:22px 22px 0 0;padding:20px 20px 36px;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;color:#111;box-shadow:0 -8px 40px rgba(0,0,0,0.18);transform:translateY(100%);transition:transform 0.35s cubic-bezier(.4,0,.2,1);box-sizing:border-box;max-height:88vh;overflow-y:auto;-webkit-overflow-scrolling:touch;">

        <div style="width:40px;height:4px;background:#e5e7eb;border-radius:99px;margin:0 auto 18px;"></div>

        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;">
          <div style="font-size:22px;font-weight:800;background:linear-gradient(90deg,#ef4444,#3b82f6);-webkit-background-clip:text;-webkit-text-fill-color:transparent;">ArkAI</div>
          <button onclick="document.getElementById('arkai-overlay').remove();document.getElementById('arkai-style')&&document.getElementById('arkai-style').remove();" style="background:#f3f4f6;border:none;width:32px;height:32px;border-radius:50%;cursor:pointer;font-size:15px;color:#6b7280;">✕</button>
        </div>

        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;">
          <div>
            <div style="font-size:24px;font-weight:800;color:#16a34a;line-height:1.1;">Green</div>
            <div style="font-size:24px;font-weight:800;line-height:1.1;">Analysis</div>
          </div>
          <div style="font-size:36px;">🌱</div>
        </div>

        ${title?`<div style="font-size:11.5px;color:#6b7280;background:#f9fafb;border-radius:10px;padding:9px 12px;margin-bottom:16px;line-height:1.5;">${title.slice(0,100)}${title.length>100?'…':''}</div>`:''}

        <div style="display:flex;flex-direction:column;gap:10px;margin-bottom:18px;">

          <div style="background:#f0fdf4;border-radius:14px;padding:13px 16px;display:flex;justify-content:space-between;align-items:center;">
            <div>
              <div style="font-weight:700;font-size:14px;">💰 Pocket Score</div>
              <div style="font-size:11.5px;color:#6b7280;margin-top:3px;">Price ₹${price?price.toLocaleString('en-IN'):'N/A'}</div>
            </div>
            <div style="font-size:26px;font-weight:800;color:#16a34a;">${pocketScore}<span style="font-size:13px;color:#9ca3af;">/10</span></div>
          </div>

          <div style="background:#fefce8;border-radius:14px;padding:13px 16px;display:flex;justify-content:space-between;align-items:center;">
            <div>
              <div style="font-weight:700;font-size:14px;">🧪 Health Score</div>
              <div style="font-size:11.5px;color:#6b7280;margin-top:3px;">Material: ${matDisplay}</div>
            </div>
            <div style="font-size:14px;font-weight:700;">${healthScore}</div>
          </div>

          <div style="background:#eff6ff;border-radius:14px;padding:13px 16px;display:flex;justify-content:space-between;align-items:center;">
            <div>
              <div style="font-weight:700;font-size:14px;">🌍 Planet Score</div>
              <div style="font-size:11.5px;color:#6b7280;margin-top:3px;">${isApiData ? 'Environmental impact' : 'Est. carbon: ' + carbon + ' kg CO₂'}</div>
            </div>
            <div style="font-size:12.5px;font-weight:700;">${planetScore}</div>
          </div>

          ${lifeScore !== null ? `
          <div style="background:#f3e8ff;border-radius:14px;padding:13px 16px;display:flex;justify-content:space-between;align-items:center;">
            <div>
              <div style="font-weight:700;font-size:14px;">🌿 Life Score</div>
              <div style="font-size:11.5px;color:#6b7280;margin-top:3px;">Overall sustainability</div>
            </div>
            <div style="font-size:26px;font-weight:800;color:#9333ea;">${lifeScore}<span style="font-size:13px;color:#9ca3af;">/10</span></div>
          </div>
          ` : ''}

        </div>

        <div style="border-top:1px solid #e5e7eb;padding-top:16px;display:flex;justify-content:space-between;align-items:center;">
          <div style="font-weight:700;font-size:15px;">ArkAI Rating</div>
          <div style="display:flex;align-items:center;gap:6px;">
            <span style="color:#facc15;font-size:22px;letter-spacing:1px;">${stars(arkaiRating)}</span>
            <span style="font-size:12px;color:#9ca3af;">${reviews > 0 ? '(' + reviews.toLocaleString('en-IN') + ')' : ''}</span>
          </div>
        </div>

        ${offersSection}

      </div>
    `;

    overlay.addEventListener('click',function(e){
      if(e.target.id==='arkai-overlay'){
        overlay.remove();
        let s=document.getElementById('arkai-style');if(s)s.remove();
      }
    });

    document.body.appendChild(overlay);
    requestAnimationFrame(()=>requestAnimationFrame(()=>{
      document.getElementById('arkai-sheet').style.transform='translateY(0)';
    }));
  }

  const fab=document.createElement('button');
  fab.id='arkai-fab';
  fab.style.cssText='position:fixed;bottom:80px;right:16px;width:56px;height:56px;border-radius:50%;background:linear-gradient(135deg,#16a34a,#22c55e);border:none;cursor:pointer;box-shadow:0 4px 20px rgba(22,163,74,0.45);z-index:2147483646;display:flex;align-items:center;justify-content:center;font-size:26px;transition:transform 0.15s,box-shadow 0.15s;-webkit-tap-highlight-color:transparent;';
  fab.innerHTML='🌱';
  fab.addEventListener('touchstart',()=>{fab.style.transform='scale(0.88)';fab.style.boxShadow='0 2px 8px rgba(22,163,74,0.25)';},{passive:true});
  fab.addEventListener('touchend',()=>{fab.style.transform='scale(1)';fab.style.boxShadow='0 4px 20px rgba(22,163,74,0.45)';},{passive:true});
  fab.addEventListener('click',function(){
    if(window.flutterWidget){
      window.flutterWidget.invokeMethod('onFabClicked');
    }else{
      computeAndShow();
    }
  });
  window.flutterWidget = {invokeMethod: function(method){
    if(method === 'onFabClicked'){
      window.location = 'arkai://fabClicked';
    }
  }};
  document.body.appendChild(fab);

})();
''';

            try {
              await _controller.runJavaScript(script);
            } catch (e) {
              debugPrint('Failed to run javascript: $e');
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('arkai://fabClicked')) {
              _onFabClicked();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
      _loadUrl(widget.initialUrl!);
    }
  }

  void _loadUrl(String url) {
    _controller.loadRequest(Uri.parse(url));
  }

  Future<Map<String, dynamic>?> _fetchApiData(String url) async {
    try {
      final response = await Dio().post(
        'http://192.168.0.102:8000/analyze',
        data: {'url': url},
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
    } on DioException catch (e) {
      debugPrint('API Error: ${e.message}');
    } catch (e) {
      debugPrint('Error fetching API data: $e');
    }
    return null;
  }

  Future<void> _onFabClicked() async {
    final url = context.read<BrowserProvider>().currentUrl;
    if (url.isEmpty) return;

    try {
      await _controller.runJavaScript('''
        (function(){
          let old=document.getElementById('arkai-overlay');
          if(old)old.remove();
          let oldStyle=document.getElementById('arkai-style');
          if(oldStyle)oldStyle.remove();
          let st=document.createElement('style');
          st.id='arkai-style';
          document.head.appendChild(st);
          const overlay=document.createElement('div');
          overlay.id='arkai-overlay';
          overlay.style.cssText='position:fixed;inset:0;background:rgba(0,0,0,0.5);display:flex;align-items:flex-end;justify-content:center;z-index:2147483647;';
          overlay.innerHTML='<div style="width:100%;max-width:480px;background:#fff;border-radius:22px 22px 0 0;padding:40px 20px;text-align:center;font-family:-apple-system,BlinkMacSystemFont,\\'Segoe UI\\',Roboto,sans-serif;"><div style="font-size:18px;font-weight:600;color:#111;margin-bottom:16px;">Analyzing Product...</div><div style="color:#6b7280;font-size:14px;">Please wait</div></div>';
          document.body.appendChild(overlay);
        })();
      ''');

      final apiData = await _fetchApiData(url);
      debugPrint('API Response: $apiData');

      if (apiData != null) {
        final jsonStr = jsonEncode(apiData);
        debugPrint('JSON String: $jsonStr');
        final encoded = Uri.encodeComponent(jsonStr);
        try {
          await _controller.runJavaScript(
            'window.arkaiApiData = JSON.parse(decodeURIComponent("$encoded")); if(typeof computeAndShow === "function"){ computeAndShow(); } else { var ol=document.getElementById("arkai-overlay"); if(ol) ol.remove(); }',
          );
        } catch (e) {
          debugPrint('JS Error: $e');
          await _controller.runJavaScript('''
            (function(){
              var ol = document.getElementById('arkai-overlay');
              if(ol) ol.remove();
              var st = document.getElementById('arkai-style');
              if(st) st.remove();
              if(typeof computeAndShow === 'function'){
                window.arkaiApiData = null;
                computeAndShow();
              }
            })();
          ''');
        }
      } else {
        await _controller.runJavaScript('''
          (function(){
            var ol = document.getElementById('arkai-overlay');
            if(ol) ol.remove();
            var st = document.getElementById('arkai-style');
            if(st) st.remove();
            if(typeof computeAndShow === 'function'){
              window.arkaiApiData = null;
              computeAndShow();
            } else {
              var fab = document.getElementById('arkai-fab');
              if(fab) fab.style.display = 'flex';
            }
          })();
        ''');
      }
    } catch (e) {
      debugPrint('Error in FAB click: $e');
      try {
        await _controller.runJavaScript('''
          (function(){
            var ol = document.getElementById('arkai-overlay');
            if(ol) ol.remove();
            var st = document.getElementById('arkai-style');
            if(st) st.remove();
            if(typeof computeAndShow === 'function'){
              window.arkaiApiData = null;
              computeAndShow();
            } else {
              var fab = document.getElementById('arkai-fab');
              if(fab) fab.style.display = 'flex';
            }
          })();
        ''');
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            Consumer<BrowserProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.currentUrl.isEmpty) {
                  return Center(
                    child: Text(
                      'Select a store to begin searching',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAddressBar(),
    );
  }

  Widget _buildBottomAddressBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              color: Colors.white,
              onPressed: () async {
                if (await _controller.canGoBack()) {
                  _controller.goBack();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 20),
              color: Colors.white,
              onPressed: () async {
                if (await _controller.canGoForward()) {
                  _controller.goForward();
                }
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Consumer<BrowserProvider>(
                  builder: (context, provider, child) {
                    String displayUrl = provider.currentUrl;
                    if (displayUrl.isEmpty) {
                      displayUrl = 'arkai://browser';
                    }
                    return Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(
                          provider.currentUrl.isEmpty
                              ? Icons.search
                              : Icons.lock_outline,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: displayUrl),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            readOnly: true,
                          ),
                        ),
                        if (provider.isLoading)
                          const Padding(
                            padding: EdgeInsets.only(right: 12.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.purpleAccent,
                              ),
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 16),
                            color: Colors.white.withValues(alpha: 0.5),
                            onPressed: () => _controller.reload(),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.only(right: 12),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.close),
              color: Colors.white,
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}
