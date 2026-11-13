Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794597752;
	b=X08c1cnV0J6IDUhiL6FqIA9QMFg/Cr2OqUNzTq9WTxPkqSPmspFF2DbV5Xy9NiLRB/FZ
	 IdP87ZHDUqpVhhPK9WJTa831fcHd8KRxgb2kTH1f4pqZhaiEuXHra57DW5jdAGZdK8uk9
	 2cKGo7saVvywvAfxCVN3ffi/Ptg6GIZkrsiyVfZcHNMXHbeSgju2C2/SftX6/3WsM94py
	 rheHyvERPtiRBvZf/xSk5+DL8Vx/voTw4Jkrn0GADYhpOReylVLxtrxbdz81bKR1WaBP+
	 wyrZVGRZDOGVII9EHTYUbgab+l5R1tItH7Rir7ESMhdIKPOoiDYPalqXPp+JQw9PWBQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794597752;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=gbgVWRTFJj3atrBM1yeEu2drtyZ8Gb4aCVYzc7wRAEU=;
	b=KQqRmyBK3ctl7z4fBIB1Y94NEWpygH+twyKGHFr9GFCLZw6x4fqCvr6o/O0j+MXtRxLA
	 gt6cO8yKC+c12vNbJcjT6rltDpGwKau6jrNTFYEGIjHNtSbCbTfNZaUOoMr1e48pBR3oI
	 3+OetPMzXckq/E/4X675yBd4/0CzbWON546U6+HfGBJqg+PMHnBt7tQIPKd860e8zArd0
	 x4KpalScEiR9r1Qh9/Ae8dvLdLARUWLIFgkYBtHgX6LSarCB0S/N3Pi2oYCxIxWOhykFm
	 QOTX8x7j31vEq1faOYG9tFUQ9066pxNB6zA/q05y6o6ghfvvABtcfHCu0LIiLaMwCJA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BaZIGAD6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9D35160A263A;
	Fri, 13 Nov 2026 19:22:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BaZIGAD6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5C1761F000CF;
	Fri, 13 Nov 2026 19:22:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794597752;
	bh=gbgVWRTFJj3atrBM1yeEu2drtyZ8Gb4aCVYzc7wRAEU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BaZIGAD6qaBRJ8TZAoLI+AHgwTnuiiHhmxS6PuOVN86CI1DiIlz+LjHnLRXNwgIKh
	 v3C2rG+CSrW1BcbNWmpKhHiR/p/yAMU+9WjZQExhK/TEgk/j/n5cyfQMvVCdszRvdb
	 C94whIXzbJH+uD2lKHzXapIqqw+PKrKt8+YpL4rYokV+7iHlUsYxXBPnoVM1uCy0Rj
	 miHFd0ZG8Q1GAYTUrg40BZh8SW1D0v9sgaTBWlfV3X2GqyXqmOqpMLbF67l6xNlGkZ
	 1xQFsru8fegViPtonOvjpYJ8xo93Jsr+4fo/ibrRIWJyYOrksqkzXCGpmoZ198n7XA
	 RRIO77120CSkw==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 13 Nov 2026 14:22:06 -0500
Subject: [PATCH net-next v3 08/10] SUNRPC: Copy the TLS session tags when
 they are available
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261113-tls-session-tags-v3-8-91271964cdb0@kernel.org>
References: <20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org>
In-Reply-To: <20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org>
To: Donald Hunter <donald.hunter@gmail.com>, 
 Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 John Fastabend <john.fastabend@gmail.com>, 
 Sabrina Dubroca <sd@queasysnail.net>, Keith Busch <kbusch@kernel.org>, 
 Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>, 
 Sagi Grimberg <sagi@grimberg.me>, Chaitanya Kulkarni <kch@nvidia.com>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Eric Dumazet <edumazet@kernel.org>
Cc: kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org, 
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=8676; i=cel@kernel.org;
 h=from:subject:message-id; bh=LkJFfzUU9q5TXI8W0b3TVe6IvuQ1UCGQ5vsToR9z/Ro=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq92NfssmE85+VewPyaPivLzdflrkaTpjQvbQgw
 wUEdPKIVdSJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavdjXwAKCRAzarMzb2Z/
 lzq7D/wMndXT0LpTMdkzOhBlMB3SCP6UmHTxHdVR1nbbMQhUtIoT5xwIx+9iA4VuZCoi6NghB22
 RdwzMpvTVZYxRvS0pfdn0efX8IIbSjSB+NezuldhhVJP58AvxjDaxPNFOwjR8HsrRBaXi/YRoBN
 bhbAD2hHeEbt5o4mwtOqK1ry+QV1XVN1RYExGk2NLNpNoDoJQ2FusIdc8kCYtSmg9Fh9cmiYyQb
 WFyI8iuhOQqLs6h1AgVYdRQD1GsbPFtCG390SDxIeNyux0LU08WxiyC6QQKjdlXbOLMyQuZsEoQ
 oqrbXlqyzTGMj73W8IpGKzZ7pgj0OtTD6hvIBOp29WjiiEQOdnolWn1+kQK/t8YbImKMLuW73W+
 ffCky96aYXV+vhwpPm53ZlnuYDa81Y2g93NZcgQzboqdqkryFzch7952jkki15Kv/vZYWtrp2cv
 6vfWzzliU3VAZmDBbiKfEhMI+wOD7Nu1PVNz4D3ONaF22zit64I9cWNN4wVfDErPbWi459gRKpE
 Xn+h+yokq7yNlFRfFM+cXTEQopmPIk9ROgKfzaCNNfjPCxzxJSvZ4oHsroj00A/1idMSjFcFlxM
 HaVWfDBz6N9u1D59Mo0eEr1RXKKYJ8km+99UNyNeikA7a56MPG1gnM5Zn06bdWGDMosMMLWRHsb
 Wlgm78lJpdXVrwQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

When a server handshake completes successfully, tlshd might provide
a set of TLS session tags. SUNRPC can save these within the svc_xprt.
NFSD can later use them to authorize or reject operations that target
NFS exports whose allow_tags list intersects those tags.

A second handshake on the same transport would destroy the saved tags
while other workers read them. svcauth_tls_accept() refuses AUTH_TLS
on a transport that already carries a TLS session, and
svc_tcp_handshake() rechecks the session flag under XPT_BUSY to close
the race with a handshake that completes concurrently.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc_xprt.h |  7 ++++-
 net/sunrpc/Kconfig              |  1 +
 net/sunrpc/svc_xprt.c           | 11 +++++---
 net/sunrpc/svcauth_unix.c       | 14 +++++++++-
 net/sunrpc/svcsock.c            | 59 ++++++++++++++++++++++++++++++++++-------
 5 files changed, 78 insertions(+), 14 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 2af222f3ea2c..e52d5d4e7941 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -9,6 +9,7 @@
 #define SUNRPC_SVC_XPRT_H
 
 #include <linux/sunrpc/svc.h>
+#include <linux/stringset.h>
 
 struct module;
 
@@ -82,6 +83,7 @@ struct svc_xprt {
 	const struct cred	*xpt_cred;
 	struct rpc_xprt		*xpt_bc_xprt;	/* NFSv4.1 backchannel */
 	struct rpc_xprt_switch	*xpt_bc_xps;	/* NFSv4.1 backchannel */
+	struct stringset	xpt_handshake_tags;	/* TLS session tags */
 };
 
 /* flag bits for xpt_flags */
@@ -101,7 +103,10 @@ enum {
 	XPT_KILL_TEMP,		/* call xpo_kill_temp_xprt before closing */
 	XPT_CONG_CTRL,		/* has congestion control */
 	XPT_HANDSHAKE,		/* xprt requests a handshake */
-	XPT_TLS_SESSION,	/* transport-layer security established */
+	XPT_TLS_SESSION,	/* transport-layer security established;
+				 * also gates xpt_handshake_tags
+				 * visibility and destruction
+				 */
 	XPT_PEER_AUTH,		/* peer has been authenticated */
 	XPT_PEER_VALID,		/* peer has presented a filehandle that
 				 * it has access to.  It is NOT counted
diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index e7808e5714dc..5a7250b42a24 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -2,6 +2,7 @@
 config SUNRPC
 	tristate
 	depends on MULTIUSER
+	select STRINGSET
 
 config SUNRPC_GSS
 	tristate
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 08cfe8a31189..7a8cfc7c3d75 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -170,6 +170,8 @@ static void svc_xprt_free(struct kref *kref)
 	struct svc_xprt *xprt =
 		container_of(kref, struct svc_xprt, xpt_ref);
 	struct module *owner = xprt->xpt_class->xcl_owner;
+
+	stringset_destroy(&xprt->xpt_handshake_tags);
 	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags))
 		svcauth_unix_info_release(xprt);
 	put_cred(xprt->xpt_cred);
@@ -190,9 +192,12 @@ void svc_xprt_put(struct svc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(svc_xprt_put);
 
-/*
- * Called by transport drivers to initialize the transport independent
- * portion of the transport instance.
+/**
+ * svc_xprt_init - initialize transport-independent fields of an xprt
+ * @net: Network namespace
+ * @xcl: Transport class
+ * @xprt: Transport to be initialized
+ * @serv: RPC service
  */
 void svc_xprt_init(struct net *net, struct svc_xprt_class *xcl,
 		   struct svc_xprt *xprt, struct svc_serv *serv)
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 1380d0946401..f5ed20e267b9 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -1100,7 +1100,8 @@ struct auth_ops svcauth_null = {
  *
  * Return values:
  *   %SVC_OK: Both credential and verifier are valid
- *   %SVC_DENIED: Credential or verifier is not valid
+ *   %SVC_DENIED: Credential or verifier is not valid, or a TLS
+ *                session already exists on this transport
  *   %SVC_GARBAGE: Failed to decode credential or verifier
  *   %SVC_CLOSE: Temporary failure
  *
@@ -1138,6 +1139,17 @@ svcauth_tls_accept(struct svc_rqst *rqstp)
 		return SVC_DENIED;
 	}
 
+	/*
+	 * AUTH_TLS initiates a handshake, and a second handshake
+	 * would destroy xpt_handshake_tags while other workers read
+	 * them. This test can pass before a concurrent handshake
+	 * completes; svc_tcp_handshake() rechecks under XPT_BUSY.
+	 */
+	if (test_bit(XPT_TLS_SESSION, &xprt->xpt_flags)) {
+		rqstp->rq_auth_stat = rpc_autherr_badcred;
+		return SVC_DENIED;
+	}
+
 	/* Signal that mapping to nobody uid/gid is required */
 	cred->cr_uid = INVALID_UID;
 	cred->cr_gid = INVALID_GID;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index f21522dd51f2..96a84b51328b 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -416,10 +416,10 @@ static void svc_tcp_kill_temp_xprt(struct svc_xprt *xprt)
  * @peerid: serial number of key containing the remote peer's identity
  * @tags: session tags assigned by the handshake agent
  *
- * If a security policy is specified as an export option, we don't
- * have a specific export here to check. So we set a "TLS session
- * is present" flag on the xprt and let an upper layer enforce local
- * security policy.
+ * No export is available here to check against a security policy
+ * specified as an export option. The callback copies the session
+ * tags, sets a "TLS session is present" flag on the xprt, and
+ * leaves enforcement of local security policy to an upper layer.
  */
 static void svc_tcp_handshake_done(void *data, int status, key_serial_t peerid,
 				   const struct stringset *tags)
@@ -428,9 +428,35 @@ static void svc_tcp_handshake_done(void *data, int status, key_serial_t peerid,
 	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
 
 	if (!status) {
-		if (peerid != TLS_NO_PEERID)
-			set_bit(XPT_PEER_AUTH, &xprt->xpt_flags);
-		set_bit(XPT_TLS_SESSION, &xprt->xpt_flags);
+		/*
+		 * The tag copy can sleep. The xprt is pinned, and
+		 * svc_tcp_handshake() waits for sk_handshake_done
+		 * when it cannot cancel the handshake.
+		 *
+		 * XPT_TLS_SESSION left clear on copy failure makes
+		 * svc_tcp_handshake() close the connection; a
+		 * reconnect retries both the handshake and the copy.
+		 */
+		if (stringset_copy(&xprt->xpt_handshake_tags, tags, GFP_KERNEL)) {
+			/*
+			 * XPT_PEER_AUTH is set first so no reader
+			 * observes XPT_TLS_SESSION without it:
+			 * check_xprtsec_policy() would read that
+			 * combination as anonymous TLS. The reverse
+			 * is harmless; it reads as plaintext.
+			 */
+			if (peerid != TLS_NO_PEERID)
+				set_bit(XPT_PEER_AUTH, &xprt->xpt_flags);
+			/*
+			 * Order the tag stores and XPT_PEER_AUTH
+			 * before XPT_TLS_SESSION. Pairs with the
+			 * reader's test_bit_acquire(XPT_TLS_SESSION).
+			 */
+			smp_wmb();
+			set_bit(XPT_TLS_SESSION, &xprt->xpt_flags);
+		} else {
+			pr_warn_ratelimited("svc: failed to copy TLS session tags\n");
+		}
 	}
 	clear_bit(XPT_HANDSHAKE, &xprt->xpt_flags);
 	complete_all(&svsk->sk_handshake_done);
@@ -441,6 +467,8 @@ static void svc_tcp_handshake_done(void *data, int status, key_serial_t peerid,
  * svc_tcp_handshake - Perform a transport-layer security handshake
  * @xprt: connected transport endpoint
  *
+ * The handshake request is declined if the transport already
+ * carries a TLS session.
  */
 static void svc_tcp_handshake(struct svc_xprt *xprt)
 {
@@ -453,9 +481,21 @@ static void svc_tcp_handshake(struct svc_xprt *xprt)
 	};
 	int ret;
 
+	/*
+	 * svcauth_tls_accept()'s XPT_TLS_SESSION test can race a
+	 * handshake that completes just after it; recheck under
+	 * XPT_BUSY before destroying the saved tags.
+	 */
+	if (test_bit(XPT_TLS_SESSION, &xprt->xpt_flags)) {
+		clear_bit(XPT_HANDSHAKE, &xprt->xpt_flags);
+		set_bit(XPT_DATA, &xprt->xpt_flags);
+		svc_xprt_enqueue(xprt);
+		return;
+	}
+
 	trace_svc_tls_upcall(xprt);
 
-	clear_bit(XPT_TLS_SESSION, &xprt->xpt_flags);
+	stringset_destroy(&xprt->xpt_handshake_tags);
 	init_completion(&svsk->sk_handshake_done);
 
 	/* Pin the transport across the asynchronous handshake callback. */
@@ -477,7 +517,8 @@ static void svc_tcp_handshake(struct svc_xprt *xprt)
 			goto out_close;
 		}
 		/* Cancellation lost to handshake_complete(): the
-		 * callback is in flight and should finish quickly.
+		 * callback is in flight. Its tag copy can sleep in
+		 * the allocator before the completion fires.
 		 */
 		wait_for_completion(&svsk->sk_handshake_done);
 	}

-- 
2.56.0

