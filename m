Received: from oss.cyber.gouv.fr (oss.cyber.gouv.fr [51.159.188.251])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 00CCE3D47A1;
	Sun,  9 Aug 2026 17:08:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=51.159.188.251
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786295301; cv=none; b=Qe4EWegv1bgK2eR7aGeW5USx/zrQAuksQz0xCN2NgTHHXW9B/qWSRMful2qjoxWajIo4zsgMZEHVpaZcMXQmA+mDt4gAhMYXZSJp/rlg+m/dwY1Bks3leZxiWUKZyRnTKid+IuZnH9TNUjan2d3ORYkJJG1kJT7iaHDerN1WEwM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786295301; c=relaxed/simple;
	bh=7aNEHYfyslsP7oX+R4PWoJMClHJzuQH/4ZEHQ8y03mE=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=o2ANU5N2TFDwnf/L/CqB8oS14x/YMpKRwyomvT7SNBsHgFuP/IEOzPxfLUjjAVtnjAsB8oSwtDhlyHbzb/NTs3OKQlxvX5KsHdVNtAVWKB7D8pGqCIVriOk/dpB7nsBMgtz3E6SQ1gmXGkGKpwFku0FWWKdcGCebbOhIYGFQ3WU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr; spf=pass smtp.mailfrom=oss.cyber.gouv.fr; dkim=pass (2048-bit key) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.b=QhhD8JH3; arc=none smtp.client-ip=51.159.188.251
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=oss.cyber.gouv.fr
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=oss.cyber.gouv.fr header.i=@oss.cyber.gouv.fr header.b="QhhD8JH3"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=oss.cyber.gouv.fr; s=default; h=Content-Transfer-Encoding:Content-Type:
	MIME-Version:Message-ID:Date:Subject:Cc:To:From:Sender:Reply-To:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=u9fWn4ygqx+uQhvS2EUG15adx5MNgmyBETfH/glUia4=; b=QhhD8JH3TtrtEB1xTD/wje7rS9
	2mVZ/FZ0/+WpMt0ns4TZsst6uGdcYcTfhoEj6vWuIANGc3d0WA8INuvgZOiUt65tvek9RuEC538BI
	twAJEi3boVDRMJqIB04JuIvF5NAq3m7eG0B24ouQPRETJvl/MrBFcjmP6Bswt8pd4NwB2NsNXajAq
	zgOvDgRsixQwd96h5VGdWvFLXJDRxfGFXVoY4l3B0IItzMLT+8vzRf8hc9dkVyIhXbr+dJ8kd/6wt
	snY85QxmMflszm53ZlwrZ+c0h6eSp9VKtk12wS1BdYYbwmYkcLK8+Prjnd2Is7OgbBMOV5RsRKehn
	wmpnVDjg==;
Received: from [151.115.150.205] (port=54320 helo=gepetto..)
	by pf-012.whm.fr-par.scw.cloud with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.99.5)
	(envelope-from <Jeremy.Jean@oss.cyber.gouv.fr>)
	id 1wt70N-0000000B9wA-3Dss;
	Sun, 09 Aug 2026 19:08:11 +0200
From: =?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	=?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>,
	stable@vger.kernel.org
Subject: [PATCH] SUNRPC: wait for in-flight client TLS handshake callback
Date: Sun,  9 Aug 2026 17:07:48 +0000
Message-ID: <20260809170748.1223617-1-Jeremy.Jean@oss.cyber.gouv.fr>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-AntiAbuse: This header was added to track abuse, please include it with any abuse report
X-AntiAbuse: Primary Hostname - pf-012.whm.fr-par.scw.cloud
X-AntiAbuse: Original Domain - vger.kernel.org
X-AntiAbuse: Originator/Caller UID/GID - [47 12] / [47 12]
X-AntiAbuse: Sender Address Domain - oss.cyber.gouv.fr
X-Get-Message-Sender-Via: pf-012.whm.fr-par.scw.cloud: authenticated_id: jeremy.jean@oss.cyber.gouv.fr
X-Authenticated-Sender: pf-012.whm.fr-par.scw.cloud: jeremy.jean@oss.cyber.gouv.fr
X-Source: 
X-Source-Args: 
X-Source-Dir: 

xs_tls_handshake_sync() gives xs_tls_handshake_done() a reference to the
lower transport before submitting the handshake request. On timeout or
signal, the synchronous waiter drops that reference after calling
tls_handshake_cancel().

handshake_req_cancel() returns false when handshake_complete() has
already marked the request complete. In that case the completion callback
can still be running, so dropping the callback-owned reference in the
waiter can free the lower transport before xs_tls_handshake_done() stores
xprt_err or drops its own reference.

If cancellation loses to completion, wait until xs_tls_handshake_done()
signals handshake_done and let the callback release its reference. This
mirrors the server-side handshake lifetime handling and keeps the timeout
or signal return value unchanged.

Fixes: 75eb6af7acdf ("SUNRPC: Add a TCP-with-TLS RPC transport class")
Cc: stable@vger.kernel.org
Assisted-by: Codex:gpt-5
Signed-off-by: Jérémy Jean <Jeremy.Jean@oss.cyber.gouv.fr>
---
 net/sunrpc/xprtsock.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 359407aae03e..5f7955e4c404 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2648,7 +2648,17 @@ static int xs_tls_handshake_sync(struct rpc_xprt *lower_xprt, struct xprtsec_par
 	rc = wait_for_completion_interruptible_timeout(&lower_transport->handshake_done,
 						       XS_TLS_HANDSHAKE_TO);
 	if (rc <= 0) {
-		tls_handshake_cancel(sk);
+		if (!tls_handshake_cancel(sk)) {
+			/*
+			 * Cancellation lost to handshake_complete(): the
+			 * callback still owns its xprt reference and is in
+			 * flight. Wait for it to finish before returning.
+			 */
+			wait_for_completion(&lower_transport->handshake_done);
+			if (rc == 0)
+				rc = -ETIMEDOUT;
+			goto out;
+		}
 		if (rc == 0)
 			rc = -ETIMEDOUT;
 		goto out_put_xprt;
-- 
2.47.3

