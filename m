Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795490538;
	b=pZaTQ3aQOJSqrdU4ldszb0MaPezD8fIwznQ39NY9+Y1yEm++IK4JJnOBUGhXamfVP0Up
	 o6EFqhVxnciYvK2c/xdEfZAWlZWZNHVLJpURLF90gpIouCJe+4aOyuwAJeAXcdvqWyjRC
	 Yt6J8IFHJ/Auo5dJizeoQdASPOkOwgleVVHdmBxZErnaXkBOG8ZeqHvGWFMjbD/p5+mdk
	 ZFv4YtHXOzWBwHwpPFsh1K1xbp8muqE1BBosQpdfN6daSapKFbvJbdNMquCRLcHaqW2QJ
	 jHnalIHMbYltFDuzbhWI6PUUusjx+DBiRgvZxrD/9Rzik98fOgZeAfusSDfzaCYujBw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795490538;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=wI9qAXfyby86S39X4gVtqmbkWQV7njWq9Skm9e3xrso=;
	b=j8I6+Aq6SpNP+MRLx1AsVl/O220MJLa5RQiny/lVnDuE42t4G9x8JTvwLtOMTALOksXm
	 FbX4Gm1/EDG1vITfa2TQXiO7Uv2V5bvc2v6DlhJ5/dc3DGJzKS78e4GNpU/8T7Jgg/qF1
	 9nMUdjNpewwHT7S0wG+4kzM0aJERuCBjQVzT+t8j9XDvXOFKpkdKMYREZUxPgeS/AF1v/
	 2wKVViNUk5vtQfOtNZqcC6iYG2wTXhRLBTmOf9uSpUpbLnlCAoBAhM1j57RjpW8jRg7tR
	 wxq935fD9YGyAqUqA1+9hVKrI98m8Et6SlVCQi57WTXQRb0/GFiJ6Hn2EdXykMRB6og==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gdBBeeOl;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F1C55606A31E
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 03:22:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gdBBeeOl
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E24C41F000C0;
	Tue, 24 Nov 2026 03:22:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795490537;
	bh=wI9qAXfyby86S39X4gVtqmbkWQV7njWq9Skm9e3xrso=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gdBBeeOlGiS8ExQGVCURfMvSsWp7ptLW274/8rJmoQ6+F8cjfZv59lfoVs8rm7Nmv
	 DlWX7TzhGKon/LxW51pvjRP+VYKkpwdZ6tm+HcCrHBpGdUf+E1wrhev+2tWFiuzkwr
	 QuxT8xsNJC5DDXQa4J43GUSht4BQ/nVa/UrIceYzsc2sgv9FxGZOZbR1r7vLCwhGjn
	 VgirfAcqc6/FHj6502Dg14EP/NsHjqrg1hFyLUN8PYNHNXtMgUOen5fJ4zHoK/UOdc
	 jxlJRbWz/YC5yJvaFQJRMwEtKM0DMe3A9ZoC+PmgaBsHo7dV+vfqWSgr3BmJxisbEY
	 xazqEJmXcF1Vg==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 23 Nov 2026 22:22:05 -0500
Subject: [PATCH 4/7] NFSD: Check xprtsec policy against the state at
 receive time
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
Message-Id: <20261123-xprtsec-recv-snapshot-v1-4-90564efc4cff@kernel.org>
References: <20261123-xprtsec-recv-snapshot-v1-0-90564efc4cff@kernel.org>
In-Reply-To: <20261123-xprtsec-recv-snapshot-v1-0-90564efc4cff@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, sashiko-bot <sashiko-bot@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=6167; i=cel@kernel.org;
 h=from:subject:message-id; bh=SFn5nCBV7XgVl+zfqxBTqhaGKuDJTuMImr9R1zP2QRI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBrBQLhkhDZTdvvlcjvM1nWwSD7+i6xy2M5c3JtA
 iwPvUnSRyKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCawUC4QAKCRAzarMzb2Z/
 l45zEACy5SkD40YS2/Mn/rgaXEhr3ZlRji6T0f6uHdl7bJ3vbZ1SCpb9H8YaanNBBhjpflMUwNO
 927PNEtUbX/4NWEg9UnVKMoCzEtqPb8KiazgBQ9EYamYVvnloQclv88nDNWCdpfGzXTIj5n/bFJ
 FuPo42ZzOaFzXkZcyDa2zLTCltIJ0hJgLG6pLt3Y3n2tNZYyqMzyMNpyROYGrIcN8YGZDfHlbQd
 uBuUp6ZDpnrYXbjq466+NlhtS01xHfhpK3FFFppwTYGwS3RxwTPwlQVr+lPRe231IzXKBwEldKQ
 A31dQjaYqlJqXnphhS0Nx5Wzc/CC0sGntFNJTuxDVxh8o8cnJAAxMBb/ANKccsv2vUipPQ9/o5u
 qHPTwXQhWREtT9HBxzcXwP6LkOa/Kp4RvBqan7Cv7ItidmRb2NEaD0Q8J9tuekUp+WkRAVjnMew
 NNok9pHBoUZNQBOmdKE0CNkRgcMGS4u0SCihIfzN7Fn3D/2EhYGbkt7O0i+Uc1pdhpx+B3L7Ie+
 ZtLdunxcR0hZBIat3JE05xwY8EPT9/Mw8KQVLDi4xZQZ68oetuq7NtQOv5YObuBV3hoO2odb3sr
 9WaRMfHdRJBPsblOF+LoCC6LNQfJGVikfnK8hOj2ZvfULn9YPdAnR9dRYRLJNPncqb/AGHtYLwK
 /Yw4P6CT3sfGQng==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

check_xprtsec_policy() tests XPT_TLS_SESSION and XPT_PEER_AUTH on
the transport at the time NFSD processes a request, not at the time
the request arrived. After reading an AUTH_TLS probe,
svc_tcp_recvfrom() re-queues the transport before
svcauth_tls_accept() sets XPT_HANDSHAKE. A second thread can then
read a plaintext RPC record that follows the probe.

If that request waits on an export cache upcall or is deferred, NFSD
processes it after the handshake completes. check_xprtsec_policy() then
grants it access to an xprtsec=tls or xprtsec=mtls export under the TLS
identity of the peer. An on-path attacker who appends such a record to a
client's AUTH_TLS probe can act under that identity. The replies go out
encrypted, so the attacker cannot read them.

Record the transport's TLS state in rq_flags when svc_handle_xprt()
receives a request, and carry it across deferral in struct
svc_deferred_req. The handshake runs with XPT_BUSY held, so these
bits do not change during a receive. Have check_xprtsec_policy()
test the recorded state instead of the transport's.

Reported-by: sashiko-bot <sashiko-bot@kernel.org>
Closes: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org?part=8
Fixes: 9280c5774314 ("NFSD: Handle new xprtsec= export option")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/export.c              | 12 ++++++------
 include/linux/sunrpc/svc.h    |  4 ++++
 include/trace/events/sunrpc.h |  4 +++-
 net/sunrpc/svc_xprt.c         | 17 +++++++++++++++--
 4 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index f8a9bfbf652f..5f72bbd54661 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1985,20 +1985,20 @@ static struct svc_export *exp_find(struct cache_detail *cd,
  */
 __be32 check_xprtsec_policy(struct svc_export *exp, struct svc_rqst *rqstp)
 {
-	struct svc_xprt *xprt = rqstp->rq_xprt;
+	/* A TLS handshake can complete between receipt and this check. */
+	bool tls = test_bit(RQ_TLS_SESSION, &rqstp->rq_flags);
+	bool peer_auth = test_bit(RQ_PEER_AUTH, &rqstp->rq_flags);
 
 	if (exp->ex_xprtsec_modes & NFSEXP_XPRTSEC_NONE) {
-		if (!test_bit(XPT_TLS_SESSION, &xprt->xpt_flags))
+		if (!tls)
 			return nfs_ok;
 	}
 	if (exp->ex_xprtsec_modes & NFSEXP_XPRTSEC_TLS) {
-		if (test_bit(XPT_TLS_SESSION, &xprt->xpt_flags) &&
-		    !test_bit(XPT_PEER_AUTH, &xprt->xpt_flags))
+		if (tls && !peer_auth)
 			return nfs_ok;
 	}
 	if (exp->ex_xprtsec_modes & NFSEXP_XPRTSEC_MTLS) {
-		if (test_bit(XPT_TLS_SESSION, &xprt->xpt_flags) &&
-		    test_bit(XPT_PEER_AUTH, &xprt->xpt_flags))
+		if (tls && peer_auth)
 			return nfs_ok;
 	}
 	return nfserr_wrongsec;
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 51ed435c32ce..ba71de72127f 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -287,6 +287,8 @@ enum {
 	RQ_DROPME,		/* drop current reply */
 	RQ_VICTIM,		/* Have agreed to shut down */
 	RQ_DATA,		/* request has data */
+	RQ_TLS_SESSION,		/* request arrived on a TLS session */
+	RQ_PEER_AUTH,		/* request arrived from an authenticated peer */
 };
 
 #define SVC_NET(rqst) (rqst->rq_xprt ? rqst->rq_xprt->xpt_net : rqst->rq_bc_net)
@@ -374,6 +376,8 @@ struct svc_deferred_req {
 	size_t			addrlen;
 	struct sockaddr_storage	daddr;	/* where reply must come from */
 	size_t			daddrlen;
+	bool			tls_session;	/* RQ_TLS_SESSION at receive */
+	bool			peer_auth;	/* RQ_PEER_AUTH at receive */
 	void			*xprt_ctxt;
 	struct cache_deferred_req handle;
 	int			argslen;
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index dde2d7dac305..09b975a7e2a6 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -1673,7 +1673,9 @@ DEFINE_SVCXDRBUF_EVENT(sendto);
 	svc_rqst_flag(USEDEFERRAL)					\
 	svc_rqst_flag(DROPME)						\
 	svc_rqst_flag(VICTIM)						\
-	svc_rqst_flag_end(DATA)
+	svc_rqst_flag(DATA)						\
+	svc_rqst_flag(TLS_SESSION)					\
+	svc_rqst_flag_end(PEER_AUTH)
 
 #undef svc_rqst_flag
 #undef svc_rqst_flag_end
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 61d5749a22da..5b583351ab13 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -969,10 +969,19 @@ static void svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 		assign_bit(RQ_LOCAL, &rqstp->rq_flags,
 			   test_bit(XPT_LOCAL, &xprt->xpt_flags));
 		rqstp->rq_deferred = svc_deferred_dequeue(xprt);
-		if (rqstp->rq_deferred)
+		if (rqstp->rq_deferred) {
 			len = svc_deferred_recv(rqstp);
-		else
+		} else {
+			/* XPT_BUSY holds off a handshake during the receive,
+			 * and svc_tcp_handshake() closes the transport rather
+			 * than start one partway through a record.
+			 */
+			assign_bit(RQ_TLS_SESSION, &rqstp->rq_flags,
+				   test_bit(XPT_TLS_SESSION, &xprt->xpt_flags));
+			assign_bit(RQ_PEER_AUTH, &rqstp->rq_flags,
+				   test_bit(XPT_PEER_AUTH, &xprt->xpt_flags));
 			len = xprt->xpt_ops->xpo_recvfrom(rqstp);
+		}
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		if (xprt->xpt_class->xcl_flags & SVC_XPRT_FLAG_WSPACE_RESERVE)
 			atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
@@ -1422,6 +1431,8 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 		dr->daddrlen = rqstp->rq_daddrlen;
 		dr->secure = test_bit(RQ_SECURE, &rqstp->rq_flags);
 		dr->argslen = rqstp->rq_arg.len >> 2;
+		dr->tls_session = test_bit(RQ_TLS_SESSION, &rqstp->rq_flags);
+		dr->peer_auth = test_bit(RQ_PEER_AUTH, &rqstp->rq_flags);
 
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base,
 		       dr->argslen << 2);
@@ -1462,6 +1473,8 @@ static noinline int svc_deferred_recv(struct svc_rqst *rqstp)
 	 * it handled last. Restore the value computed at receive time.
 	 */
 	assign_bit(RQ_SECURE, &rqstp->rq_flags, dr->secure);
+	assign_bit(RQ_TLS_SESSION, &rqstp->rq_flags, dr->tls_session);
+	assign_bit(RQ_PEER_AUTH, &rqstp->rq_flags, dr->peer_auth);
 
 	dr->xprt_ctxt = NULL;
 	svc_xprt_received(rqstp->rq_xprt);

-- 
2.56.0

