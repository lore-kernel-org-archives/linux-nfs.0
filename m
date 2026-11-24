Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795490539;
	b=D2gl4MP6PbeG+EHYqwazgWIgJVyRt6g70vQDmA0275zXmFLPbSDMNS540Zl0UGDPSycR
	 OYPNkHIPR8Kk9JfUXON9teHo3roN0UMp+9MWmnHUQ45rCxTwsihaRRnr15jwGFyCOOnhG
	 DTja+WDXOtrOLCgV5gIW838ZCUT6gSYUeJETQaFgaqsheX9bOGQ18o1qVm0Qmnb9DfsRJ
	 LPJxpCTIvpA2uSKEy5nzwqsj+x1I8I5Ao3W+yf6q/bsg7mYkyqH0tky157ZViTnbChWzf
	 yYgqhF+4dzhhHBrIDmdrv4qeBYS2HFzLGwyGlYqZgL5beNTDyklBemK8L1RD+TNszLw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795490539;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=VjOlC9SSC+gauMTQY/hYsCKbHZJF+rdwhtGvXj2EDb4=;
	b=LjaIyU5YS/0l8yMAcfQYmVf8+PIbLHYVkr32JyeoB7/rCxbnzwxN7GEtMdstkLR3ece7
	 xEUqYgaHrnO50u3tGHN0qpJV5n01weJzJDrjT3/SMaSYSar80Il1VrVrDW+poGQxC5GQy
	 HQ5C7gqX71R0PUGAbPmMm9f69PWmQD8TPvJiKy2IexLJKT1e0Th5v2dODhPIB3HDqYOBZ
	 96oexe/MOWnHbHvcvzdzEWsyUhp9fsJdZwCpFvA15NQrVij3NRDiJyAdF11riZ36BjR6M
	 O3ukBrpIn4CqOt0CM6zpntf0VYszQHAJlqWGgngXQJ84TPxhsqa3oaI3QsXx7Sijluw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Gpb5ZJdb;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6CAB5606A31E
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 03:22:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Gpb5ZJdb
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5F2F31F000D2;
	Tue, 24 Nov 2026 03:22:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795490539;
	bh=VjOlC9SSC+gauMTQY/hYsCKbHZJF+rdwhtGvXj2EDb4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Gpb5ZJdb2XDlhg3vOXNPAm2+92W/IMBqShQVDj2C9CI3h8FscG9zQuuAfQWnPd/0n
	 ptVYvlpNHi7VXMGyf19if/oXnQvs5K6FZk1+DJ4zGaKUV5fIeVF8rcJS2ngJa19mqd
	 peEQgg+24gsk1TZQvIsWbckTMvQn4q+eDbArzc2+O0Mlmc3L7xBP0swCOH5UXXh6S5
	 MQR1yCWjXfbUKyPwDCCQWTQ9BwHoykUDhfwxTFG48jUq2fgaAxRkr8QA1B1gBxj0jG
	 IwlByLUASVON2uq0UhlRZfDhEU8NRW13Tg3/wHTEA2/MWpf+q2dX2U1vhahlC5zGZF
	 8NbeilDBSMzdg==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 23 Nov 2026 22:22:06 -0500
Subject: [PATCH 5/7] SUNRPC: Drop replies to plaintext requests on a TLS
 transport
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
Message-Id: <20261123-xprtsec-recv-snapshot-v1-5-90564efc4cff@kernel.org>
References: <20261123-xprtsec-recv-snapshot-v1-0-90564efc4cff@kernel.org>
In-Reply-To: <20261123-xprtsec-recv-snapshot-v1-0-90564efc4cff@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, sashiko-bot <sashiko-bot@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=6945; i=cel@kernel.org;
 h=from:subject:message-id; bh=nVrDlLIJoT1n4P9X4hARE0bH280cHvssjypHCVCQh5g=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBrBQLh/EbBY+OHQKJmAPAFwwdhDMojEMTFbjCFQ
 7bdwOSHOJSJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCawUC4QAKCRAzarMzb2Z/
 l6x/EACO9huWFn9nHkoBti3LUzeT7m+f/zZePfhZiBTgLYZ9hnrNNwgwEfOg+50dX17jUdlUjnL
 PK5WO79zrJTX9IGfRj0VFzdK+y5VdDih50hx2Dhi+EqlLF/o16nCzMvsiNMOgQmExRv6YM1RE+h
 f0FuWwjLFtyDFflM8wufvfqq4BtBXt24MN8VKi1m+TXpFKmuIrQODybObRy576xc7XNSPiFfZK3
 oIpgu+0Vf2YOynphdW8rXxhwG2fAfLdtjgoJcHgZDr3HJ2l8Exm/7wftiOB8axiURHN19svIvDF
 a3xiOVIdzEDf4pIWSk3gGjHUtFSg3DFSEuXwPA6z8hkbRpJGtgXRDqaVWElDRghjUNiDm414JmE
 W5iUkIAsoFmM7sUoh1qnynYjOFMrx0P46c13BuV0HOsMPiuhI/tsF2vT1aNbAP1TZE9ZlaxoKMj
 P+i3Juo6TLKOqbFvFDtTEqzxMRckqdNud8RqBSnR1KlocjSCQhx4PbGChL0MI0UdGru5HVXtv8k
 AX1FyV1pxDS4URnujun0s/jzSRzoYl1Dk6BLQZQvleKAmk7K3/O4RGtdoraQaQBNUa/EpYIgghN
 bLugmUEfog0TFyTU0TCM2jl49ajiQuwW0Mw43AwpfX3HtacMnuYU9fkqWGwJZFLoK253t7dgDbA
 nTpNbGuI121QAzg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

RFC 9289 Section 5.1.1 requires a receiver to discard, without
response, traffic that arrives between the AUTH_TLS probe and the TLS
handshake, and recommends dropping the connection. A plaintext RPC
record that follows the probe can be read before the handshake
starts. If svc_tcp_sendto() sends its reply while the handshake is
under way, the reply lands in the middle of the handshake. If the
reply goes out after tlshd installs kTLS but before the completion
downcall, it travels on the new TLS session.

Mark the request whose AUTH_TLS probe starts the handshake. Drop the
reply and close the connection when svc_tcp_sendto() finds a request
that arrived in plaintext on a transport that now carries a TLS session,
or on a handshaking transport unless the request is the marked probe.
A second probe that arrives during the handshake is not marked, so its
reply is dropped too. The request has already executed by then.
check_xprtsec_policy() limits what the request can reach by testing the
TLS state recorded when the request arrived.

A failed handshake clears XPT_HANDSHAKE without setting
XPT_TLS_SESSION, which would let a plaintext reply through. Set
XPT_CLOSE before clearing XPT_HANDSHAKE when the handshake fails,
and close the connection when the handshake upcall cannot start.
svc_tcp_sendto() then tests XPT_CLOSE and XPT_DEAD in the same
snapshot of the transport flags as the TLS bits.

Suggested-by: sashiko-bot <sashiko-bot@kernel.org>
Fixes: b3cbf98e2fdf ("SUNRPC: Support TLS handshake in the server-side TCP socket code")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc.h    |  1 +
 include/trace/events/sunrpc.h |  4 +++-
 net/sunrpc/svc.c              |  1 +
 net/sunrpc/svcauth_unix.c     |  3 ++-
 net/sunrpc/svcsock.c          | 25 ++++++++++++++++++++++---
 5 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index ba71de72127f..19d81c7e3d81 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -289,6 +289,7 @@ enum {
 	RQ_DATA,		/* request has data */
 	RQ_TLS_SESSION,		/* request arrived on a TLS session */
 	RQ_PEER_AUTH,		/* request arrived from an authenticated peer */
+	RQ_TLS_PROBE,		/* request started a TLS handshake */
 };
 
 #define SVC_NET(rqst) (rqst->rq_xprt ? rqst->rq_xprt->xpt_net : rqst->rq_bc_net)
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 09b975a7e2a6..d759b01a8fa5 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -1675,7 +1675,8 @@ DEFINE_SVCXDRBUF_EVENT(sendto);
 	svc_rqst_flag(VICTIM)						\
 	svc_rqst_flag(DATA)						\
 	svc_rqst_flag(TLS_SESSION)					\
-	svc_rqst_flag_end(PEER_AUTH)
+	svc_rqst_flag(PEER_AUTH)					\
+	svc_rqst_flag_end(TLS_PROBE)
 
 #undef svc_rqst_flag
 #undef svc_rqst_flag_end
@@ -2097,6 +2098,7 @@ DEFINE_SVC_TLS_EVENT(upcall);
 DEFINE_SVC_TLS_EVENT(unavailable);
 DEFINE_SVC_TLS_EVENT(not_started);
 DEFINE_SVC_TLS_EVENT(timed_out);
+DEFINE_SVC_TLS_EVENT(spurious);
 
 TRACE_EVENT(svc_xprt_accept,
 	TP_PROTO(
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 6be2020a4907..48518c3f1109 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1526,6 +1526,7 @@ svc_process_common(struct svc_rqst *rqstp)
 	/* Will be turned off only when NFSv4 Sessions are used */
 	set_bit(RQ_USEDEFERRAL, &rqstp->rq_flags);
 	clear_bit(RQ_DROPME, &rqstp->rq_flags);
+	clear_bit(RQ_TLS_PROBE, &rqstp->rq_flags);
 
 	/* Construct the first words of the reply: */
 	svcxdr_init_encode(rqstp);
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 0c4654c2f6c9..a32d8f7412ca 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -1161,7 +1161,8 @@ svcauth_tls_accept(struct svc_rqst *rqstp)
 		*p++ = cpu_to_be32(8);
 		memcpy(p, "STARTTLS", 8);
 
-		set_bit(XPT_HANDSHAKE, &xprt->xpt_flags);
+		if (!test_and_set_bit(XPT_HANDSHAKE, &xprt->xpt_flags))
+			set_bit(RQ_TLS_PROBE, &rqstp->rq_flags);
 		svc_xprt_enqueue(xprt);
 	} else {
 		trace_svc_tls_unavailable(xprt);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index c6d5adb78cb2..57f98470e9c8 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -402,6 +402,8 @@ static void svc_tcp_handshake_done(void *data, int status, key_serial_t peerid)
 		if (peerid != TLS_NO_PEERID)
 			set_bit(XPT_PEER_AUTH, &xprt->xpt_flags);
 		set_bit(XPT_TLS_SESSION, &xprt->xpt_flags);
+	} else {
+		set_bit(XPT_CLOSE, &xprt->xpt_flags);
 	}
 	clear_bit(XPT_HANDSHAKE, &xprt->xpt_flags);
 	complete_all(&svsk->sk_handshake_done);
@@ -442,7 +444,7 @@ static void svc_tcp_handshake(struct svc_xprt *xprt)
 	if (ret) {
 		trace_svc_tls_not_started(xprt);
 		svc_xprt_put(xprt);
-		goto out_failed;
+		goto out_close;
 	}
 
 	ret = wait_for_completion_interruptible_timeout(&svsk->sk_handshake_done,
@@ -474,7 +476,6 @@ static void svc_tcp_handshake(struct svc_xprt *xprt)
 
 out_close:
 	set_bit(XPT_CLOSE, &xprt->xpt_flags);
-out_failed:
 	clear_bit(XPT_HANDSHAKE, &xprt->xpt_flags);
 	set_bit(XPT_DATA, &xprt->xpt_flags);
 	svc_xprt_enqueue(xprt);
@@ -1336,6 +1337,7 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
 	struct xdr_buf *xdr = &rqstp->rq_res;
 	rpc_fraghdr marker = cpu_to_be32(RPC_LAST_STREAM_FRAGMENT |
 					 (u32)xdr->len);
+	unsigned long xpt_flags;
 	int count, sent;
 
 	svc_sock_release_ctxt(xprt, rqstp->rq_xprt_ctxt);
@@ -1345,8 +1347,20 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
 	count = svc_rqst_res_to_bvec(rqstp, SVC_TCP_MARKER_BVECS);
 
 	mutex_lock(&xprt->xpt_mutex);
-	if (svc_xprt_is_dead(xprt))
+	/* RFC 9289 Section 5.1.1: a plaintext reply does not go out once the
+	 * AUTH_TLS probe starts a handshake, and the connection is dropped.
+	 * Every path that clears XPT_HANDSHAKE sets XPT_TLS_SESSION or
+	 * XPT_CLOSE first, so once the probe sets XPT_HANDSHAKE, one read of
+	 * xpt_flags sees at least one of the three.
+	 */
+	xpt_flags = READ_ONCE(xprt->xpt_flags);
+	if (xpt_flags & (BIT(XPT_DEAD) | BIT(XPT_CLOSE)))
 		goto out_notconn;
+	if (!test_bit(RQ_TLS_SESSION, &rqstp->rq_flags) &&
+	    (xpt_flags & BIT(XPT_TLS_SESSION) ||
+	     (xpt_flags & BIT(XPT_HANDSHAKE) &&
+	      !test_bit(RQ_TLS_PROBE, &rqstp->rq_flags))))
+		goto out_spurious;
 	sent = count;
 	if (count >= 0)
 		sent = svc_tcp_sendmsg(svsk, rqstp, marker, count);
@@ -1359,6 +1373,11 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
 out_notconn:
 	mutex_unlock(&xprt->xpt_mutex);
 	return -ENOTCONN;
+out_spurious:
+	trace_svc_tls_spurious(xprt);
+	svc_xprt_deferred_close(xprt);
+	mutex_unlock(&xprt->xpt_mutex);
+	return -ENOTCONN;
 out_close:
 	pr_notice("rpc-srv/tcp: %s: %s %d when sending %zu bytes - shutting down socket\n",
 		  xprt->xpt_server->sv_name,

-- 
2.56.0

