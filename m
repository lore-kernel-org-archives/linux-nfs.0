Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.42
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792745306;
	b=DJFq0lytpU7VbUM9Q+NkeCkB0OPuMI7e2LZSK0cd7zjlTq4KWsSa78I9WyJBWfqFcdc4
	 GUi6KwOPHusPeRSIj2fUAeWywoOsA6ra8gwcIxtck63KkSfYqQABWhdFFORdcCLdMGOdq
	 thZJTMuI90dHDJFkIT2OAXTvyFvqyUVuVggcnhKBMC4IIp3WdPu/tZ/cSp+ou/cfovXvj
	 tymbv6aPzsulnOoj6rcYZc6IWP5h+edWUlCHC0zRe2EkSuwvkoQeICr4Mq8NPQlQfVQbF
	 sMA4YjqAkelL9I3zlKj3Ra8TrAYjYCfVhS72EU3vj+QwvNtbvx1w+sAiEOrsGTaEWfw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792745306;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=F6Klyh0k2DMvnciL91BfEqRQ5lu6e2socN2fUvplmJA=;
	b=iKhEBxcnvPDYbqwYBFrrWsoCxwWPq2U5yQgcS2RL/+ZsXEtyMGQNHfw39GnadqNTC4xU
	 dx7U5c2pdWdpy2NJzobuBrJPC2hGeuhGmSCcsUkOGzdbG0okzQqyRfJSrdm2eYY23qdEc
	 ehAh498oxrwTecjN2z7QwkVQGG9HKhCkxZxpQZNcEVF3+G2kzt4scDyFdyS3dBlBObQWc
	 dV7YzDs+w0VJJSTewZs5QiZy/XZpoL+hL9D8SNTW1U8AQafQSf+qrJZ6rDWUNDHE+rjRx
	 jZeHtVapWUrs9bH38S91jpfrNanAXpqPGp3jNwE+dvtWN03nlxXZxLLL7OJwtqO+Dhg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=Pc7S+pI0;
	arc=none smtp.remote-ip=209.85.128.42
Received: from mail-wm1-f42.google.com (mail-wm1-f42.google.com [209.85.128.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C1E0B606A31F
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 08:48:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C1E0B606A31F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=Pc7S+pI0
Received: by mail-wm1-f42.google.com with SMTP id 5b1f17b1804b1-4a1fe9efc0eso6345565e9.2
        for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 01:48:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792745304; x=1793350104; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=F6Klyh0k2DMvnciL91BfEqRQ5lu6e2socN2fUvplmJA=;
        b=Pc7S+pI0JXKhYwN2qAfpmiYFWvf0iq4V1IM2XBk0p5KiC6vtCBllx2sjknvhh1LNT7
         uorj6HxSdCzFMzFOsj2zY8Y36vMbEqMkBbBRlfxH6wVloK8QQP8VUaQn57++bWCjgoJ+
         J4g2kCzi0/bxvJnyObGj//7NJnQM41djmObkoJRuO8ENzftSYUG76YnBInFZpbR1QMtx
         NCJ29sBladKrAVZz5RloPAfeSdQQdLv4UOO3bbRFn8BhxrycQLefpblL/cysyN24B6pG
         j8gKU1uT1kPzWzPtzzSwIZoDWYXS7OfYj7vqNlUrDAaSR46w/A9wnM1fyhQmhmtClaaR
         a3GA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792745304; x=1793350104;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=F6Klyh0k2DMvnciL91BfEqRQ5lu6e2socN2fUvplmJA=;
        b=wQz+sEY/1pldru1Ul/OlKDfLTGeTbhWR3th2buzMHGSPEn15gWBKfw0ATa1b2CO/2w
         fCcdUpztQl1kpeNfyojxt4x0ht+wiNxLpmjS2WHdeJhlulSyWHmeumYvFRrmVd8YOsVM
         ijclDGYMQzpyX7TjCogSghi+ABnK5jh4eAxIu6DZvBKyg6te8+pamjo5vxS6A1JxxCjb
         zX4Okt9OPfI2r9U2aHjOrGbmtBVL6UO9PQf3eoqAeSEgUZ9L6yI/4+BYrCwHgvec4S99
         SbvcJpEA8mu4Pksj1H7GxDYR84XfTOjxNFsRWA+dYs4EFha8IkcqUREiQpX2z9Y4W81B
         0WSg==
X-Gm-Message-State: AFq9FYJt2XD/B4qKMX0nSsHHJwJ4txpvZbryUMjSRhP+arFEdQEvkOGx
	sBa3wL9ht/aUIFTmL/LVj+JdJrhD0twqHI1wN8EvCMzOsZIOfaBxeGfl
X-Gm-Gg: AYBFou1nOfm/XBiudeRQX5fPfsFdh9se1TkJbpKZe9IL8Q3z3XvcxHQnbgAiEfF1U/R
	9+GS2yp6I6sq8rvKc5amgjrkrI9KejMJc3A0ywuE/m3qVybFvoicX3nXnPJomZYuhmk0ablHw5k
	37vxQJjX90jg8mqzcnjd5fe1JgF0Um8PYEvWwjcNiINmdjWVVW5h9HkYt3hvjvd5/yt7Oezsh43
	L8tTOpb5WZEULvxFZV2w0A91ZVsRjte3JtOBce7E1GDcGlc2DSzOrnTI33ieNb9WC0T5vO/a6v4
	CXSVhCQxlVqVnQydot36NzqG23QRUaqduWYKQ67kiV4RohlEKlvJUqgDTg2Z2avi828eGRJh8Qu
	l8QJkaIfCuDFXzYAEXsuGlbzHRwIu/RZ9XkgEqWP9xXhdhXJbEWWiH8zBYWYaszaE099jmcAbHy
	xzm9P9ECCIHPqb2yKtw8SzYRPDAnI14G77kcRTdXSLXe13JAarZ9oUIgpBVXmkUWuKLaXA/OaUz
	od/J7aVxFDLx/GzR7MsU1VSom5fAJ2EuOyE9AgLJ6ZgOVuho1RkakT7dwbmhVV0qSHKPXpQ3g==
X-Received: by 2002:a05:600c:3b96:b0:4a1:eccb:53eb with SMTP id 5b1f17b1804b1-4a211cb88a6mr29706125e9.6.1792745303675;
        Fri, 23 Oct 2026 01:48:23 -0700 (PDT)
Received: from localhost.localdomain ([2a06:c701:4778:c500:4fad:2c9a:1a55:76b5])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4a211b291b8sm41702955e9.1.2026.10.23.01.48.22
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 23 Oct 2026 01:48:23 -0700 (PDT)
From: Avi Weiss <thnkslprpt@gmail.com>
To: trondmy@kernel.org,
	anna@kernel.org,
	cel@kernel.org
Cc: linux-nfs@vger.kernel.org,
	Avi Weiss <thnkslprpt@gmail.com>,
	stable@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix TCP-with-TLS transport class identification
Date: Fri, 23 Oct 2026 11:48:19 +0300
Message-ID: <20261023084819.609293-1-thnkslprpt@gmail.com>
X-Mailer: git-send-email 2.43.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

xs_setup_tcp_tls() assigns the ordinary TCP transport class to
a TCP-with-TLS transport. When rpc_clnt_add_xprt() is called
with an unspecified transport type, it inherits the class
identifier and can create an unencrypted TCP transport.

Looks like a copy-paste error from the commit 3 years ago.

NFSv4 trunk discovery uses an unspecified transport type when
adding server-advertised addresses. If the additional transport
passes server-identity validation, it can be admitted to the
client's transport switch.

An isolated loopback test reproduced plaintext application RPC
transmission for TLS- and mTLS-configured clients, including
an unpinned TLS-client RPC that selected the added transport.

Assign the TCP-with-TLS class instead. With the fix, the
plaintext-only test peer receives TLS negotiation probes but
no application payloads.

Fixes: 75eb6af7acdf ("SUNRPC: Add a TCP-with-TLS RPC transport class")
Cc: stable@vger.kernel.org
Signed-off-by: Avi Weiss <thnkslprpt@gmail.com>
---
 net/sunrpc/xprtsock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7f60723fa64d..62a51eabc353 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -3499,7 +3499,7 @@ static struct rpc_xprt *xs_setup_tcp_tls(struct xprt_create *args)
 	transport = container_of(xprt, struct sock_xprt, xprt);
 
 	xprt->prot = IPPROTO_TCP;
-	xprt->xprt_class = &xs_tcp_transport;
+	xprt->xprt_class = &xs_tcp_tls_transport;
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
 
 	xprt->bind_timeout = XS_BIND_TO;
-- 
2.43.0

