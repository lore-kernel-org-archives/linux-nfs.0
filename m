Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27DEC20D4E9
	for <linux-nfs@vger.kernel.org>; Fri, 22 May 2026 01:48:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779414535; cv=none; b=bCmKJSWt59GTDOz7XznSuMLtJwvmy71u6a2S33qDkq8BL3KtAzFJekZ38zY7b7HK10ATNd8JaLPwCtI6FEsZKwcGR8yxd/1hUG8GX9vSPhXBGONFsNe6kew6Ta32FHUQeMv7M4ZGv5jY4XfdCIxy+u05yNc9tU2gscXIKx5QK3g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779414535; c=relaxed/simple;
	bh=iebWws6liK5bu7imJWsY0b7Q4p1JDtCwE2LpuMoYmfs=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=K2qJlnM2TGRD8ql5ZU6eyKByr3JsFaNG33g48AyXUJVVZ+B7NpTRylqhW46gDnrxkMNArNoHChISYzSagyg3KdeHDty2iDhT3AZq7K2SJh9wPtsAU4e/a52TE4sgL7p+1UAKI6J66NOctRD6tRFtFSvjzOZEm8eSJfDdTeWIaCY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=f70aXlSZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="f70aXlSZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4299A1F000E9;
	Fri, 22 May 2026 01:48:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779414533;
	bh=xokFNCH8xSVgdmzIaOh3bVmB5du/Yz4JUJ+ZZ/2crHQ=;
	h=From:To:Cc:Subject:Date;
	b=f70aXlSZqYNHt9M58BIUtdad60+o7iujvhdJX+0pDlySsfd/SGpyxPZFyvv2WNO6F
	 X3Fkcyk341mO+c13gAAHwXTlXMhbDZW2zWOFBZ8zxzPjIqzoM2uKgsZNjT1ittanX3
	 LswvE5sGiFl6+aN3wEF0AlrY5U+qzhuK6p6i3Z2QT1uvotdKm+chKhjqMZ66T40ocU
	 6ZUA4kTH7ybLJLkvdT5GviGg+wdeCb04otDPV4n+1u/eZi4QsCcmX8D33qLtADP+tl
	 qMp216blxCAikbq3eQMbblTDNjh1oikxqwYFOEF5tZzq6rLErh3c9OdMKnyMSpfchl
	 mQFQJrac2I4Xw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chris Mason <clm@meta.com>
Subject: [PATCH] sunrpc: pin svc_xprt across the asynchronous TLS handshake callback
Date: Thu, 21 May 2026 21:48:50 -0400
Message-ID: <20260522014850.206768-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chris Mason <clm@meta.com>

svc_tcp_handshake() stores the raw svc_xprt pointer in
tls_handshake_args.ta_data and submits the request through
tls_server_hello_x509(). The handshake core takes only
sock_hold(req->hr_sk); nothing references the embedding struct
svc_sock that svc_tcp_handshake_done() reaches via container_of().

Two close races leave the in-flight callback writing through a freed
svc_sock. svc_sock_free() calls tls_handshake_cancel() and discards
its return value: a false return means handshake_complete() has
already set HANDSHAKE_F_REQ_COMPLETED but hp_done() may not have
finished, yet svc_sock_free() proceeds to kfree(svsk). The
cancel-loser fall-through inside svc_tcp_handshake() itself produces
the same window: when wait_for_completion_interruptible_timeout()
returns <= 0 (timeout or signal) and tls_handshake_cancel() returns
false, the function does not drain, returns, and svc_handle_xprt()
calls svc_xprt_received(), which clears XPT_BUSY and can drop the
last reference. A concurrent close then runs svc_sock_free() while
svc_tcp_handshake_done() is still updating xpt_flags and walking
svsk->sk_handshake_done.

The corruption surfaces as set_bit/clear_bit RMW into the freed
xpt_flags slab slot and as complete_all() walking and writing the
freed wait_queue_head_t list embedded in sk_handshake_done -- a
slab-corruption primitive, not a benign read. The path is reachable
on any TLS-enabled NFS server whenever a connection close overlaps
the tlshd downcall delivery window; the interruptible wait means
signal delivery suffices, not just SVC_HANDSHAKE_TO expiry.

Take svc_xprt_get(xprt) immediately before tls_server_hello_x509()
so the in-flight callback owns its own reference. Release it on the
two edges where the callback is guaranteed not to fire -- submission
failure from tls_server_hello_x509() and a successful
tls_handshake_cancel() -- and at the tail of
svc_tcp_handshake_done() after complete_all().

Fixes: b3cbf98e2fdf ("SUNRPC: Support TLS handshake in the server-side TCP socket code")
Assisted-by: kres (claude-opus-4-7)
Signed-off-by: Chris Mason <clm@meta.com>
[cel: rewrote commit message to describe the actual change]
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/svcsock.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 7be3de1a1aed..c8e194fce622 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -471,6 +471,7 @@ static void svc_tcp_handshake_done(void *data, int status, key_serial_t peerid)
 	}
 	clear_bit(XPT_HANDSHAKE, &xprt->xpt_flags);
 	complete_all(&svsk->sk_handshake_done);
+	svc_xprt_put(xprt);
 }
 
 /**
@@ -494,9 +495,13 @@ static void svc_tcp_handshake(struct svc_xprt *xprt)
 	clear_bit(XPT_TLS_SESSION, &xprt->xpt_flags);
 	init_completion(&svsk->sk_handshake_done);
 
+	/* Pin the transport across the asynchronous handshake callback. */
+	svc_xprt_get(xprt);
+
 	ret = tls_server_hello_x509(&args, GFP_KERNEL);
 	if (ret) {
 		trace_svc_tls_not_started(xprt);
+		svc_xprt_put(xprt);
 		goto out_failed;
 	}
 
@@ -505,6 +510,7 @@ static void svc_tcp_handshake(struct svc_xprt *xprt)
 	if (ret <= 0) {
 		if (tls_handshake_cancel(sk)) {
 			trace_svc_tls_timed_out(xprt);
+			svc_xprt_put(xprt);
 			goto out_close;
 		}
 	}
-- 
2.54.0

