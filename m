Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795490541;
	b=Eq5MxTAjy9TnYmwJzW8hFXfZjXLkZZ3wY7S6o0odHexuKnGZVY/Mvy7Ozrnhma6WrBVS
	 1Fy2TGc3TAgq3K3iXFHbrel61+U6w1J+k8KEO7fPBdj4DF7KMHIniYf6a3wpwP563QP5/
	 0zEWPEW2WpG9PAjZ1be2d7ZvwmuHmGJUiOMKijE6cjqZM5ro1CD2FKeAy0vT4/vHzC069
	 BK+7xIno3w0lIcMbj7xRqv3YXPJUn3HaxIPMxI+x5BVtFeMX6xPPW2zt+Z28SihXGOL8b
	 kaZcC0FYRHUey2ld6g6x7J0Ma60MBy1oo/+FYla4lvK10M0MRtRWROGzZgAkiaZA8Bw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795490541;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=bMqZ60SL8h5XaGjVNGF7bG1bb9uOmQML1ZmOnm1ycAg=;
	b=KdpgGPrNdO0jJhpE7E1H9ErtOxOsr+GAd6LcglMbHWUlZnLp9pP/Dxgk2Jcm4km63Hxz
	 fy+PQ5FhfJ9mdjcYvAV4zeAjX890h2xTJnJs9BeGoQvj/TVFc2aI9qyJKH3KasBXuDrwa
	 DSoF9C0/cGzK7vTAKsaWbew/ggd5rRRSA4njW6jY3mzr5/fKDUXDp8a+WfBSNTcP3GZ1w
	 ERQdl9L7fbdOi3AsdMkxXknk0A4UvpxpYgnJqjBB/fb5HqtlDPvRJWqe9iA5Az3uSdbTu
	 wQDuvX7BWUgs+zQwspbltP4do4JR/BnNDkkiCtq+DrITqOKEKZHIJ83I41k5/io3AOQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bcGgVFjc;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 92E99606A326
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 03:22:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bcGgVFjc
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 690F11F000D2;
	Tue, 24 Nov 2026 03:22:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795490541;
	bh=bMqZ60SL8h5XaGjVNGF7bG1bb9uOmQML1ZmOnm1ycAg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=bcGgVFjcaskvhYW5lHipL8K72kydv9067uGmcEun8iY51vJpLLs0qN+NH1NxxwvkU
	 4A455wkUMcVbHV/HkuoOd6ckMqL7B/YBwfOBoCXVCYieTJVzUqWU2gePkOPydkXVXk
	 qnc5wDDQ5enr8/xKbofyYOdgeuUTV8ETZruwkVDMvjk51wY6iDKlpOA4y8TDoVgHUj
	 lGf6mScTCePDeaunkLeiIDdZBNsj5iAfrzWGf/S10c5aGZrsxfGB0UxBfM9p70zR/L
	 K/gFabBXgEzYgEK4GoytWX9CeIpDHGVzhUWMRPbjzxnTGvxJSRvSUUc34tlyHgHAEo
	 Qi7lsNgLZcUmQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 23 Nov 2026 22:22:07 -0500
Subject: [PATCH 6/7] SUNRPC: Discard plaintext records that follow an
 AUTH_TLS probe
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
Message-Id: <20261123-xprtsec-recv-snapshot-v1-6-90564efc4cff@kernel.org>
References: <20261123-xprtsec-recv-snapshot-v1-0-90564efc4cff@kernel.org>
In-Reply-To: <20261123-xprtsec-recv-snapshot-v1-0-90564efc4cff@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=6180; i=cel@kernel.org;
 h=from:subject:message-id; bh=yjmgXjxmW8F3Z109qMXArMzCZu0SKQER5UlrtQNF84Y=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBrBQLiVaqWfmr9Ptma0R6ZDYLwXitrxdzxskyZu
 zgKZ5YOIGSJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCawUC4gAKCRAzarMzb2Z/
 l59gEACrrQgH3vdeiZn6BNZ9dkPp1jz6qvBC/7pnH8v7IZpJd4B0HwHo6IeejJG4uq7Ujo+loP0
 NQr8IB0p/sVS9n6BjjKguvKySn0U2zbl7x3HoQ58vmHhjhhcy0Kk83wPUYTIN0FZLfgL+68+Z6X
 9ZwO0E4BcP9on1tPrvA4ssGsUsWxac26Y/wdNyZpfjV8F874OERhDltlXepOWNSFkOinR41Hsod
 Fy21jdNOF2K8k5bFJP+fCZ9VJPIcZeXZieXP101XRnejf1+eP4brACCzkQkRhizKGFmjYHO7oMb
 ZnDBZXGYf9KMEJBA9RJv6Vz13qhZChghdI/nQBki4YhEwcyQgaTolX0tKwf9SLYNBe0rcvPbv9z
 MU6E9LKR03qlK3OPaqtJiGaYiMA2Rs99eeiCkwUb/MXpHunxUvPLaQnrpvvpeCnQ3qeBPzBMvxN
 iPZ5yyK1kmkY22ApbRNjb4KmHQNKD6RJRXs9wyIOMh/qpmSKBqKX4v+a8qqUQA9gGQd7ck7CbFd
 IilGQKQFNrla4l0O4obs1zYS9foEJpyStR3YOItn45faarFl+wqgGirIKJOfrDodICiGD0Ociws
 6+B4TQ9/3VR1jxa4HHyPt7cP//bhk2MFkaO8LzXxbRnAsyYC4f9kNEDQhz/By6JSXsxYvrW2+QE
 2SYTSJUqRrHMuyQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

RFC 9289 Section 5.1.1 requires a receiver to discard traffic that
arrives between the AUTH_TLS probe and the TLS handshake.
svc_tcp_sendto() drops the replies to such requests, but the requests
themselves still execute. svcauth_tls_accept() sets XPT_HANDSHAKE only
when the probe is dispatched. By then another thread may already have
received and dispatched a plaintext record that followed the probe,
so an injected REMOVE or WRITE runs before its reply is dropped.

Record the probe in svc_tcp_recvfrom(), while XPT_BUSY still holds
off other receives. Discard any later Call record that arrives before
XPT_TLS_SESSION is set, and close the connection. When the reply to
the probe does not carry STARTTLS, clear XPT_TLS_PROBE before
svc_tcp_sendto() sends that reply. A client whose probe was rejected
can then continue in plaintext, as RFC 9289 Section 4.1 permits.

Fixes: b3cbf98e2fdf ("SUNRPC: Support TLS handshake in the server-side TCP socket code")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc.h      |  1 +
 include/linux/sunrpc/svc_xprt.h |  1 +
 include/trace/events/sunrpc.h   |  6 ++++--
 net/sunrpc/svc_xprt.c           |  1 +
 net/sunrpc/svcsock.c            | 37 ++++++++++++++++++++++++++++++++++++-
 5 files changed, 43 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 19d81c7e3d81..70aad8fa9c68 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -290,6 +290,7 @@ enum {
 	RQ_TLS_SESSION,		/* request arrived on a TLS session */
 	RQ_PEER_AUTH,		/* request arrived from an authenticated peer */
 	RQ_TLS_PROBE,		/* request started a TLS handshake */
+	RQ_TLS_PROBE_RECV,	/* request set XPT_TLS_PROBE */
 };
 
 #define SVC_NET(rqst) (rqst->rq_xprt ? rqst->rq_xprt->xpt_net : rqst->rq_bc_net)
diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 2af222f3ea2c..c10dea8c42a2 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -110,6 +110,7 @@ enum {
 	XPT_RPCB_UNREG,		/* transport that needs unregistering
 				 * with rpcbind (TCP, UDP) on destroy
 				 */
+	XPT_TLS_PROBE,		/* AUTH_TLS probe pending or accepted */
 };
 
 /*
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index d759b01a8fa5..5b5ad7778ca4 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -1676,7 +1676,8 @@ DEFINE_SVCXDRBUF_EVENT(sendto);
 	svc_rqst_flag(DATA)						\
 	svc_rqst_flag(TLS_SESSION)					\
 	svc_rqst_flag(PEER_AUTH)					\
-	svc_rqst_flag_end(TLS_PROBE)
+	svc_rqst_flag(TLS_PROBE)					\
+	svc_rqst_flag_end(TLS_PROBE_RECV)
 
 #undef svc_rqst_flag
 #undef svc_rqst_flag_end
@@ -1938,7 +1939,8 @@ TRACE_EVENT(svc_stats_latency,
 	svc_xprt_flag(TLS_SESSION)					\
 	svc_xprt_flag(PEER_AUTH)					\
 	svc_xprt_flag(PEER_VALID)					\
-	svc_xprt_flag_end(RPCB_UNREG)
+	svc_xprt_flag(RPCB_UNREG)					\
+	svc_xprt_flag_end(TLS_PROBE)
 
 #undef svc_xprt_flag
 #undef svc_xprt_flag_end
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 5b583351ab13..4f3606ac5541 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -968,6 +968,7 @@ static void svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 		/* XPT_DATA|XPT_DEFERRED case: */
 		assign_bit(RQ_LOCAL, &rqstp->rq_flags,
 			   test_bit(XPT_LOCAL, &xprt->xpt_flags));
+		clear_bit(RQ_TLS_PROBE_RECV, &rqstp->rq_flags);
 		rqstp->rq_deferred = svc_deferred_dequeue(xprt);
 		if (rqstp->rq_deferred) {
 			len = svc_deferred_recv(rqstp);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 57f98470e9c8..31c1b25d8415 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1119,6 +1119,17 @@ static int svc_tcp_recv_actor(read_descriptor_t *desc, struct sk_buff *skb,
 	return consumed;
 }
 
+static bool svc_tcp_is_tls_probe(const struct svc_rqst *rqstp)
+{
+	const struct kvec *head = &rqstp->rq_arg.head[0];
+	const __be32 *p = head->iov_base;
+
+	/* p[5] is the procedure, p[6] the credential flavor. */
+	if (head->iov_len < 7 * XDR_UNIT)
+		return false;
+	return p[5] == xdr_zero && p[6] == rpc_auth_tls;
+}
+
 static bool svc_tcp_at_urg_mark(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
@@ -1155,6 +1166,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		.count		= serv->sv_max_mesg + sizeof(rpc_fraghdr),
 	};
 	struct socket *sock = svsk->sk_sock;
+	bool spurious = false;
 	ssize_t len;
 	__be32 *p;
 	__be32 calldir;
@@ -1241,13 +1253,30 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	p = (__be32 *)rqstp->rq_arg.head[0].iov_base;
 	calldir = p[1];
-	if (calldir)
+	if (calldir) {
 		len = receive_cb_reply(svsk, rqstp);
+	} else if (!test_bit(XPT_TLS_SESSION, &svsk->sk_xprt.xpt_flags)) {
+		/* RFC 9289 Section 5.1.1 requires discarding plaintext Calls
+		 * that follow an AUTH_TLS probe. Only the receive path sees
+		 * records in order.
+		 */
+		if (test_bit(XPT_TLS_PROBE, &svsk->sk_xprt.xpt_flags)) {
+			spurious = true;
+		} else if (svc_tcp_is_tls_probe(rqstp)) {
+			set_bit(XPT_TLS_PROBE, &svsk->sk_xprt.xpt_flags);
+			set_bit(RQ_TLS_PROBE_RECV, &rqstp->rq_flags);
+		}
+	}
 
 	/* Reset TCP read info */
 	svsk->sk_datalen = 0;
 	svc_tcp_fragment_received(svsk);
 
+	if (spurious) {
+		trace_svc_tls_spurious(&svsk->sk_xprt);
+		svc_xprt_deferred_close(&svsk->sk_xprt);
+		goto err_noclose;
+	}
 	if (len < 0)
 		goto error;
 
@@ -1361,6 +1390,12 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
 	     (xpt_flags & BIT(XPT_HANDSHAKE) &&
 	      !test_bit(RQ_TLS_PROBE, &rqstp->rq_flags))))
 		goto out_spurious;
+	/* Clear XPT_TLS_PROBE before sending a reply without STARTTLS. The
+	 * client can send plaintext Calls as soon as the reply arrives.
+	 */
+	if (test_bit(RQ_TLS_PROBE_RECV, &rqstp->rq_flags) &&
+	    !test_bit(RQ_TLS_PROBE, &rqstp->rq_flags))
+		clear_bit(XPT_TLS_PROBE, &xprt->xpt_flags);
 	sent = count;
 	if (count >= 0)
 		sent = svc_tcp_sendmsg(svsk, rqstp, marker, count);

-- 
2.56.0

