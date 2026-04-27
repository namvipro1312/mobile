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
    var sendButton = form.querySelector(".support-chatbox-send");
    var quickActions = root.querySelectorAll("[data-chat-prompt]");

    var apiUrl = root.dataset.chatApiUrl || "/api/chatbox";
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

    var userName = root.dataset.userName || "bạn";
    var isOpen = false;
    var initialized = false;
    var isSending = false;
    var sendButtonDefaultText = sendButton ? sendButton.textContent : "Gửi";
    var history = [];

    function escapeHtml(value) {
        return String(value || "")
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll("\"", "&quot;")
            .replaceAll("'", "&#39;");
    }

    function addMessage(role, html, extraClass) {
        var message = document.createElement("div");
        message.className = "support-chatbox-message " + role + (extraClass ? " " + extraClass : "");
        message.innerHTML = "<div class=\"support-chatbox-bubble\">" + html + "</div>";
        body.appendChild(message);
        body.scrollTop = body.scrollHeight;
        return message;
    }

    function pushHistory(role, text) {
        history.push({
            role: role,
            text: text
        });

        if (history.length > 12) {
            history = history.slice(history.length - 12);
        }
    }

    function addUserText(text) {
        addMessage("user", escapeHtml(text));
        pushHistory("user", text);
    }

    function addBotText(text) {
        addMessage("bot", renderText(text));
        pushHistory("assistant", text);
    }

    function renderText(text) {
        var raw = String(text || "").trim();
        if (!raw) {
            return "";
        }

        var parts = [];
        var lastIndex = 0;
        var urlRegex = /https?:\/\/[^\s<]+/g;
        var match;

        while ((match = urlRegex.exec(raw)) !== null) {
            var url = match[0];
            parts.push(escapeHtml(raw.slice(lastIndex, match.index)));
            parts.push("<a href=\"" + escapeHtml(url) + "\" target=\"_blank\" rel=\"noopener noreferrer\">" + escapeHtml(url) + "</a>");
            lastIndex = match.index + url.length;
        }

        parts.push(escapeHtml(raw.slice(lastIndex)));
        return parts.join("").replace(/\r?\n/g, "<br>");
    }

    function link(label, url) {
        return "<a href=\"" + escapeHtml(url || "#") + "\">" + escapeHtml(label) + "</a>";
    }

    function setBusy(value) {
        isSending = value;
        input.disabled = value;

        if (sendButton) {
            sendButton.disabled = value;
            sendButton.textContent = value ? "Đang gửi..." : sendButtonDefaultText;
        }

        quickActions.forEach(function (button) {
            button.disabled = value;
        });
    }

    function buildStoreContext() {
        return {
            homeUrl: urls.home || "",
            shopUrl: urls.shop || "",
            cartUrl: urls.cart || "",
            checkoutUrl: urls.checkout || "",
            accountUrl: urls.account || "",
            contactUrl: urls.contact || "",
            compareUrl: urls.compare || "",
            wishlistUrl: urls.wishlist || ""
        };
    }

    function addWelcomeMessage() {
        var welcomeHtml = "Xin chào " + escapeHtml(userName) + ". Bạn có thể hỏi về " + link("cửa hàng", urls.shop) + ", " + link("giỏ hàng", urls.cart) + ", " + link("thanh toán", urls.checkout) + " hoặc hỏi kiến thức chung như một trợ lý AI bình thường.";
        addMessage("bot", welcomeHtml);
        pushHistory("assistant", "Xin chào " + userName + ". Bạn có thể hỏi về cửa hàng, giỏ hàng, thanh toán hoặc hỏi kiến thức chung như một trợ lý AI bình thường.");
    }

    function sendMessage(text) {
        var message = String(text || "").trim();
        if (!message || isSending) {
            return;
        }

        var historyPayload = history.slice();
        addUserText(message);
        input.value = "";

        var loadingMessage = addMessage("bot", "Đang suy nghĩ...", "is-loading");
        setBusy(true);

        fetch(apiUrl, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                message: message,
                userName: userName,
                storeContext: buildStoreContext(),
                history: historyPayload
            })
        })
            .then(function (response) {
                return response.text().then(function (rawText) {
                    var payload = null;

                    if (rawText) {
                        try {
                            payload = JSON.parse(rawText);
                        } catch (error) {
                            payload = null;
                        }
                    }

                    if (!response.ok) {
                        var failureMessage = payload && payload.message
                            ? payload.message
                            : "Chatbox đang tạm bận. Vui lòng thử lại.";
                        throw new Error(failureMessage);
                    }

                    var answer = payload && payload.answer ? String(payload.answer).trim() : "";
                    if (!answer) {
                        throw new Error("Gemini không trả về nội dung hợp lệ.");
                    }

                    return answer;
                });
            })
            .then(function (answer) {
                loadingMessage.remove();
                addBotText(answer);
            })
            .catch(function (error) {
                loadingMessage.remove();
                addBotText(error && error.message
                    ? error.message
                    : "Không thể kết nối chatbox lúc này. Vui lòng thử lại.");
            })
            .finally(function () {
                setBusy(false);
                input.focus();
            });
    }

    function openPanel() {
        if (!initialized) {
            addWelcomeMessage();
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
            var prompt = button.getAttribute("data-chat-prompt") || button.textContent || "";
            if (!isOpen) {
                openPanel();
            }

            sendMessage(prompt);
        });
    });

    form.addEventListener("submit", function (event) {
        event.preventDefault();
        if (!isOpen) {
            openPanel();
        }

        sendMessage(input.value);
    });

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape" && isOpen) {
            closePanel();
        }
    });
})();
