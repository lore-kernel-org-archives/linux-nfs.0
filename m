Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794495159;
	b=WZ/9s6y3Q1FbHsl+ssEwDY/gSD577Ma3VsB9IxeJkNnZhxClWsQgPpCJdRY5jLkOSKzb
	 dI9Bv34L3Deh4N+nywbiwIlw2psDex+Bpjf3qcxaDvirr6vCpG1jQmZsj5BDYyPpxexFq
	 IGds8jUHVCGpUo6mdIJ47ZuI5evwFnZWZ2x6TbePLVvCpcLx1wxXTLN2duyy3Yrv7aOtC
	 uuViyINo0xZ/QQmT0fSswNkiOOu6CqCe+2LvWnctI2+qW7Vfx7Dsp2gjVaGdspvnQFy71
	 YQtpEJS+YTgdhBzu7VjifAti+0VKS4DCTTyGhSBprBDPw40vw5nBEwP9QwzxKCJy10g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794495159;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=RRP91mEJ4yrMx9ob3PnEo32Xm1czCHCCxXiRmH/urvU=;
	b=mBu/wMf9/+KbC3aGR7PaZE9i11c5ZHEwE3W32d9P3KRLXID9BkSYMSffZVx5eKr2Ms0r
	 oRSNUvALVO+3ZFpNPA2Z6TV4Z+ZCy3F1vKoK3oG9TZRfHq5BHEe1bgxWIxPMSpfPbsKXn
	 UH8WLaCZf4x6ySAuH2aOFcy4ObrupxqOG43cP8Ch8CiXV93sdJHzEP3BcJom1Fce7FP0/
	 MqpffDL2MsgCb99bF6l8MMzR9saU55kFGJsGTDuHtxU+iRZTdLierGDmEOiBb88USoXfG
	 dA5S9/r0n4iOM/xK7o9PHvNJ4GiielVg6f7Xsmy3K+TS8pdr24TTwWceitgmDo8HShw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="REf/VFZw";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 58100606A8B8;
	Thu, 12 Nov 2026 14:52:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=REf/VFZw
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 172A41F00A0F;
	Thu, 12 Nov 2026 14:52:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794495159;
	bh=RRP91mEJ4yrMx9ob3PnEo32Xm1czCHCCxXiRmH/urvU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=REf/VFZw2lXHlYCacAWvCRX44uVabK+xAB057ckcOELnVCclhItOq5JbxoIo24oQX
	 AmyKrJFv5FVEHUdB43cUTMBUXkpcQ22J3A93Phv9llUESwyjp2UDdi4ZqhDz3qNmLI
	 Y+P7jhheH77dytvpFpatGxY83QDWp52bRhPMRlpCSTzTxOjA6JGmz6ikbPfyFrajrs
	 DOIZyCQEYS83jD4LTz+/b01OQZkAD4i3ZrhOZRL/nIcZg8orXwM8hV7at1U9MEFFKd
	 Q3TDXXvk76OEH+WiYNaZ5lzWyRmh8RUqEv/YckyXxuy44VqgNRXuDxwMsIJzFo8tnV
	 qoRhs9WMhBSLQ==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 12 Nov 2026 09:52:12 -0500
Subject: [PATCH net-next v2 08/10] SUNRPC: Copy the TLS session tags when
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
Message-Id: <20261112-tls-session-tags-v2-8-a587a50de7fc@kernel.org>
References: <20261112-tls-session-tags-v2-0-a587a50de7fc@kernel.org>
In-Reply-To: <20261112-tls-session-tags-v2-0-a587a50de7fc@kernel.org>
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
 h=from:subject:message-id; bh=ZiRsnrHuFRNA7V8q1wCrXPaVQGWSrm/h1N48Q0HOo6c=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9dKg1N5nvhJCxkiDPXH9oqrnSz8IL2vfLg34b
 1e6rI7QFB2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavXSoAAKCRAzarMzb2Z/
 l3JED/9ggPA4n3wWNpM1VC4xfOYG0nYGAU/s29BNA9iE/+iu1QAm0CCtEy3KQHeNAxh6Peh2uX1
 H6kSlLFphBwqKgInykAjq5QhzgJ8R9typB65uQNbuQbQCVRNrwd4SwZojy09+Fb2BVl+bGPR4Lt
 GwO2zdnSeARq1qLjFejoWFhN2PC9zj6Ofu/4l/hc0siMZZ3N7Y2VVz3vehy/HDzoH00IS2eQZLm
 w86dScS9HPLHzIzUPHmWGpzQNIl+scJL0P99xe2sZZvG9/60b/XRWF4ek0EpFyiuqtZKeKMLytt
 rVfs61coR2Spn547GQ4FnstI+qMPAlZMjPaWwP4ES1qgKcywHt0NM8mM/bicUcw1wd5j4kohQSC
 KyCz90TxQl7g/nrgAPD0FOfq1vplgYPBke0nVeNiGEJIkjP7vX3JFASHPB1Ec3Nu+LXNoXk7NN2
 Z5Nv6X0XkSnb7wfawAGhiaj3V77fjE+7uY3v/ZPS/huDk86JQ93iUQx8qiBG/uR0ixKuU5wrD00
 nLQS1SJvDdmsOSN8u10W0S7jQ9+6YDhonxPK+iTw8kGWqjZPEGlnqAcZz2GUIzlVqH73ETHpCUt
 JmzMOfPBt6A4cY+mgKcVzwJICbQwGx2+QYt7bxW82JZImeT6rgvdvBPLi2bJL2V21GqqATxWylB
 L7O3VuxTWuvvThg==
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
index a68fe44d1f62..958b565617c4 100644
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

