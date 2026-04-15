(function () {
    var root = document.getElementById("supportChatbox");
    if (!root) {
        return;
    }

    var toggle = document.getElementById("supportChatboxToggle");
    var closeButton = document.getElementById("supportChatboxClose");
    var panel = document.getElementById("supportChatboxPanel");
    var body = document.getElementById("supportChatboxBody");
    var form = document.getElementById("supportChatboxForm");
    var input = document.getElementById("supportChatboxInput");
    var quickActions = root.querySelectorAll("[data-chat-action]");

    var urls = {
        home: root.dataset.homeUrl,
        shop: root.dataset.shopUrl,
        cart: root.dataset.cartUrl,
        checkout: root.dataset.checkoutUrl,
        account: root.dataset.accountUrl,
        contact: root.dataset.contactUrl,
        compare: root.dataset.compareUrl,
        wishlist: root.dataset.wishlistUrl
    };

    var userName = root.dataset.userName || "b\u1ea1n";
    var isOpen = false;
    var initialized = false;

    function escapeHtml(value) {
        return value
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll("\"", "&quot;")
            .replaceAll("'", "&#39;");
    }

    function addMessage(role, html) {
        var message = document.createElement("div");
        message.className = "support-chatbox-message " + role;
        message.innerHTML = "<div class=\"support-chatbox-bubble\">" + html + "</div>";
        body.appendChild(message);
        body.scrollTop = body.scrollHeight;
    }

    function link(label, url) {
        return "<a href=\"" + escapeHtml(url) + "\">" + escapeHtml(label) + "</a>";
    }

    function respond(text) {
        var normalized = text.trim().toLowerCase();

        if (!normalized) {
            addMessage("bot", "B\u1ea1n c\u00f3 th\u1ec3 h\u1ecfi v\u1ec1 " + link("gi\u1ecf h\u00e0ng", urls.cart) + ", " + link("thanh to\u00e1n", urls.checkout) + ", " + link("t\u00e0i kho\u1ea3n", urls.account) + " ho\u1eb7c " + link("li\u00ean h\u1ec7", urls.contact) + ".");
            return;
        }

        if (normalized.includes("gi\u1ecf") || normalized.includes("cart")) {
            addMessage("bot", "M\u1edf nhanh " + link("gi\u1ecf h\u00e0ng", urls.cart) + ". N\u1ebfu c\u1ea7n thanh to\u00e1n ngay, v\u00e0o " + link("checkout", urls.checkout) + ".");
            return;
        }

        if (normalized.includes("qr") || normalized.includes("ng\u00e2n h\u00e0ng") || normalized.includes("chuy\u1ec3n kho\u1ea3n")) {
            addMessage("bot", "Trang " + link("thanh to\u00e1n", urls.checkout) + " \u0111\u00e3 c\u00f3 l\u1ef1a ch\u1ecdn QR ng\u00e2n h\u00e0ng. Sau khi \u0111\u1eb7t \u0111\u01a1n, h\u1ec7 th\u1ed1ng s\u1ebd m\u1edf m\u00e0n QR \u0111\u1ec3 b\u1ea1n qu\u00e9t v\u00e0 chuy\u1ec3n kho\u1ea3n \u0111\u00fang n\u1ed9i dung.");
            return;
        }

        if (normalized.includes("thanh to\u00e1n") || normalized.includes("checkout")) {
            addMessage("bot", "Hi\u1ec7n c\u00f3 3 c\u00e1ch: QR ng\u00e2n h\u00e0ng, thanh to\u00e1n t\u1ea1i c\u1eeda h\u00e0ng v\u00e0 thanh to\u00e1n khi nh\u1eadn h\u00e0ng. \u0110i t\u1edbi " + link("trang thanh to\u00e1n", urls.checkout) + " \u0111\u1ec3 ch\u1ecdn.");
            return;
        }

        if (normalized.includes("t\u00e0i kho\u1ea3n") || normalized.includes("\u0111\u0103ng nh\u1eadp") || normalized.includes("account")) {
            addMessage("bot", "B\u1ea1n c\u00f3 th\u1ec3 m\u1edf " + link("t\u00e0i kho\u1ea3n", urls.account) + " \u0111\u1ec3 xem th\u00f4ng tin c\u00e1 nh\u00e2n, \u0111\u01a1n g\u1ea7n \u0111\u00e2y v\u00e0 tr\u1ea1ng th\u00e1i mua h\u00e0ng.");
            return;
        }

        if (normalized.includes("so s\u00e1nh") || normalized.includes("compare")) {
            addMessage("bot", "Danh s\u00e1ch " + link("so s\u00e1nh s\u1ea3n ph\u1ea9m", urls.compare) + " \u0111ang hi\u1ec3n th\u1ecb chi ti\u1ebft h\u01a1n \u0111\u1ec3 \u0111\u1ed1i chi\u1ebfu c\u1ea5u h\u00ecnh v\u00e0 gi\u00e1.");
            return;
        }

        if (normalized.includes("y\u00eau th\u00edch") || normalized.includes("wishlist")) {
            addMessage("bot", "Danh s\u00e1ch " + link("y\u00eau th\u00edch", urls.wishlist) + " d\u00f9ng \u0111\u1ec3 l\u01b0u nhanh s\u1ea3n ph\u1ea9m b\u1ea1n quan t\u00e2m.");
            return;
        }

        if (normalized.includes("shop") || normalized.includes("s\u1ea3n ph\u1ea9m") || normalized.includes("mua")) {
            addMessage("bot", "B\u1ea1n c\u00f3 th\u1ec3 b\u1eaft \u0111\u1ea7u t\u1eeb " + link("c\u1eeda h\u00e0ng", urls.shop) + " r\u1ed3i l\u1ecdc theo danh m\u1ee5c, th\u01b0\u01a1ng hi\u1ec7u v\u00e0 gi\u00e1.");
            return;
        }

        if (normalized.includes("li\u00ean h\u1ec7") || normalized.includes("hotline") || normalized.includes("h\u1ed7 tr\u1ee3")) {
            addMessage("bot", "N\u1ebfu c\u1ea7n trao \u0111\u1ed5i tr\u1ef1c ti\u1ebfp, m\u1edf " + link("trang li\u00ean h\u1ec7", urls.contact) + " ho\u1eb7c g\u1ecdi hotline \u0111ang hi\u1ec3n th\u1ecb \u1edf \u0111\u1ea7u trang.");
            return;
        }

        if (normalized.includes("xin ch\u00e0o") || normalized.includes("hello") || normalized.includes("hi")) {
            addMessage("bot", "Xin ch\u00e0o " + escapeHtml(userName) + ". B\u1ea1n c\u1ea7n h\u1ed7 tr\u1ee3 v\u1ec1 s\u1ea3n ph\u1ea9m, gi\u1ecf h\u00e0ng, thanh to\u00e1n hay t\u00e0i kho\u1ea3n?");
            return;
        }

        addMessage("bot", "T\u00f4i ch\u01b0a hi\u1ec3u r\u00f5 c\u00e2u h\u1ecfi n\u00e0y. B\u1ea1n th\u1eed h\u1ecfi theo c\u00e1c ch\u1ee7 \u0111\u1ec1: s\u1ea3n ph\u1ea9m, gi\u1ecf h\u00e0ng, QR thanh to\u00e1n, t\u00e0i kho\u1ea3n ho\u1eb7c li\u00ean h\u1ec7 h\u1ed7 tr\u1ee3.");
    }

    function openPanel() {
        if (!initialized) {
            addMessage("bot", "Xin ch\u00e0o " + escapeHtml(userName) + ". T\u00f4i c\u00f3 th\u1ec3 h\u1ed7 tr\u1ee3 tra c\u1ee9u " + link("gi\u1ecf h\u00e0ng", urls.cart) + ", " + link("thanh to\u00e1n", urls.checkout) + ", " + link("t\u00e0i kho\u1ea3n", urls.account) + " v\u00e0 " + link("c\u1eeda h\u00e0ng", urls.shop) + ".");
            initialized = true;
        }

        isOpen = true;
        root.classList.add("is-open");
        toggle.setAttribute("aria-expanded", "true");
        panel.setAttribute("aria-hidden", "false");
        setTimeout(function () {
            input.focus();
        }, 120);
    }

    function closePanel() {
        isOpen = false;
        root.classList.remove("is-open");
        toggle.setAttribute("aria-expanded", "false");
        panel.setAttribute("aria-hidden", "true");
    }

    toggle.addEventListener("click", function () {
        if (isOpen) {
            closePanel();
            return;
        }

        openPanel();
    });

    closeButton.addEventListener("click", closePanel);

    quickActions.forEach(function (button) {
        button.addEventListener("click", function () {
            var action = button.getAttribute("data-chat-action");
            var labelMap = {
                cart: "Gi\u1ecf h\u00e0ng",
                checkout: "Thanh to\u00e1n",
                account: "T\u00e0i kho\u1ea3n",
                contact: "Li\u00ean h\u1ec7"
            };

            addMessage("user", escapeHtml(labelMap[action] || action || ""));
            respond(action || "");
        });
    });

    form.addEventListener("submit", function (event) {
        event.preventDefault();
        var value = input.value.trim();
        if (!value) {
            input.focus();
            return;
        }

        addMessage("user", escapeHtml(value));
        respond(value);
        input.value = "";
        input.focus();
    });

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape" && isOpen) {
            closePanel();
        }
    });
})();
