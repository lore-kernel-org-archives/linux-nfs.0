Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794599058;
	b=jEFvsaxGtn+7vm0T7YL9BgDEsCljGrEPmVd4OJ14HsloxqNiwwcaaq5G3xPR/aM+pu4Q
	 pPEjfQRLpcnROwYhQE/CGC8F20k5pQgFoHXc9W+NQ/EIINsiJQuHXXTIsddPcJEZI7FNI
	 chRUntwpxKdeTw+p6bY5QfyZTVnp3aAtwoWgfun6a5J+b4pGer5qSmWOgW3gI7OiJ7OC3
	 cLHHWcZHVtmANIUSq8w/yGPhi8eXi7XckxDd9Q0WFbLjSCS7W9kJ/lO9dnYIrg6X9X42q
	 QIBak6oXbNhLykGgyJKpG4JAj3XMMa8QxLgC5Qb7TZJNM5gr8CPwbhJquLTwa6osYEg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794599058;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=qI4uhRcp/n5ztbG7n5fXFQE3jhszdLuNf6s7bLdAbP0=;
	b=fRkdeAgNj8l5WaofC++2oTyWL5zatbn0VjwyDYiqxp6NLYYF5B7gt/tQ/rmcjSMtif1X
	 wpgOh8C6HrhWuN/OW3e2SUfhUXyjNXiG4QyNSFJhSK9c6NnJAK50Mcf2DWmSpZiL3WkT6
	 J6eqahOnVXvq0GVQcY5NyB9r5OkYxGAQE1tcENsQyf7+XDFYlhlDgYEw316F4ae69S3pk
	 eaWmk6Lu9gnZCINOEMKpPSFh6jvbZ6pmwOL7kgMhfZ9PHgKbe2zts7nMlCOVurfEi0Opk
	 aiLYgcpaqjgwDQDdzK4NXUrzOx7oqvHvSyAfUHvxVPp5OTByr4le9vc3mFQ7cFyac/A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XPbSLbOR;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99D10606A334
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 19:44:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XPbSLbOR
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 74C931F000C4;
	Fri, 13 Nov 2026 19:44:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794599058;
	bh=qI4uhRcp/n5ztbG7n5fXFQE3jhszdLuNf6s7bLdAbP0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=XPbSLbORhiRAtUvTUCTduc5EON82vflRE3lFsO3n5YWsPnKukT4SXeNuYJrQQQ8xC
	 vToaRGRMCYol+CGPzhXrqlR1OvuwWRnvbM0tnBeJx5+czzlusEIBjA+jVZlXeNG5Xb
	 JmIct6LT3ly6qnb8bi6s8TPDTcOhxQJaqzvWz0LBfqMIKwxieCiCfafhEbrEvWXRdV
	 kDAEP/K1p2RgQYWMdps1XVRb3EJL+as9HaPimwQAYE0cvN7yjdxcAbxXpLC4EhV15p
	 gpr/PnxBt3yeKe/bRxTZ6ndHBq96YB93hb4euE1cLbnjQZ0gnFuC3HZU7vjj0S6WAf
	 4M9tBwd3H53SA==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 13 Nov 2026 14:44:06 -0500
Subject: [PATCH 8/8] SUNRPC: Receive UDP datagrams into rq_pages through a
 bvec iterator
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
Message-Id: <20261113-svcsock-bvecs-v1-8-5dd41f205aeb@kernel.org>
References: <20261113-svcsock-bvecs-v1-0-5dd41f205aeb@kernel.org>
In-Reply-To: <20261113-svcsock-bvecs-v1-0-5dd41f205aeb@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=6272; i=cel@kernel.org;
 h=from:subject:message-id; bh=es0hClf0XCOgge4gnEWvhyiLAloatTONy54lLfoTfAE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq92iHZZId7RR7hJZJpCQBFzykW6VB/kIVNjm7g
 J1OoFXsA/eJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavdohwAKCRAzarMzb2Z/
 l/uiEACpbciIaSVu1W5gGKFloVka7CbruP9IBiapUgeMjEiTEgr17Awa2cP2D+GeNkKHEmg4mqS
 8WM4D8Lkn31cvlJSTh+BCzZ1O7bY6E5DLD7/xJmb828BHjRR6oGK/P9qCFluR+9FwRCKhw6a+WX
 WQcZ/2r4viK5COng9j5Peqoi+IHBOV+5EwCyWpGrEJ1bS/otHYo7SlJPi8VPk1LPrwSaqIjE63s
 yMzI5nz4xgQJklU+EhU/FFuafom/P5vbQWh55B/vPZdZmlegC19bL7QzRz5GIz+JISnMAvBL+Cx
 B4vz2MJkyKLOnv+CxizsV7Fg+IOaNJTzEM3HYXGqgvg2dw2IOS3gv4r7dAl8k5B/Xyl3MjDeF5A
 hcdDRTqJf8kAxrI140owfb4nrA0GFTsaP0CduGXj34RewVpfzO6lNCNXzEm6DgSu9lr4Ox8ze36
 rFbUFWboqKuixTGIJSGjxxkwoMAxnBKLZY/V5rbAgAKLzifpJB0K9rWtphf5Spf23tqMMJWRY0a
 DWBfwan7Q0H66LtAYbtp/Am+Ag3u6hrWK6PX7a/5a0/9gwnOcfcdMkeR+anaklJMuKk/iG8k4Hh
 xYIZQvvh/XrJakeTko1N3wD1ezje4tKl7yMoCKjMX3Dipwcx0X/qz8Yn2S8H8ybuefhrUCvYbDS
 UAJd/SYO8IIBtcg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svc_udp_recvfrom() copies a nonlinear skb into rq_arg through
csum_partial_copy_to_xdr() but aliases a linear one: rq_arg.head
points into the skb, and the skb rides in rq_xprt_ctxt until the
reply is sent or the deferred request is revisited. The alias is
the one case that keeps svcsock from handing every receive buffer
around as a bvec array, and the last UDP code that cannot share
the receive helpers with TCP.

Copy every datagram into rq_pages through an ITER_DEST bvec
iterator. A datagram larger than the capacity svc_alloc_arg() left
in rq_arg is dropped before the copy and reported through the
svcsock_udp_recv_err tracepoint with -EMSGSIZE. Lockd's buffer is
near 16 KB and no conformant NLM Call exceeds 5 KB. With
rq_xprt_ctxt unused, both transports share one empty
svc_sock_release_ctxt().

skb_copy_datagram_iter() and skb_copy_and_csum_datagram_msg()
replace the two branches of csum_partial_copy_to_xdr(), except
that a checksum fault is reported without the receiving device's
name. The local_bh_disable() around the copy goes, because
udp_recvmsg() calls the same helpers in process context.

The alias set head[0].iov_len to the datagram length, so
svc_defer() accepted any linear datagram. After this patch the
head is capped at PAGE_SIZE, and a request over one page whose
upcall outlasts cache_defer_req()'s inline wait is dropped for the
client to retransmit, as a nonlinear datagram already is. In an
NFSv3 run over an igb NIC with a 1500-byte MTU, svc_udp_recvfrom()
received 4721 datagrams and none was both linear and over one page.
All 2224 nonlinear datagrams were reassembled from IP fragments. At
that MTU a datagram over one page is always fragmented, so the
patch does not change which requests svc_defer() drops.

The copy costs at most one MTU of data per small request, and a
copying checksum replaces skb_checksum_complete() on linear skbs.
The effect on NFSv3 NULL and GETATTR rates has not been measured.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcsock.c | 57 ++++++++++++++++------------------------------------
 1 file changed, 17 insertions(+), 40 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 4c33a1d95594..1586c8f3c78f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -53,7 +53,6 @@
 #include <trace/events/sock.h>
 #include <trace/events/sunrpc.h>
 
-#include "socklib.h"
 #include "sunrpc.h"
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
@@ -113,29 +112,15 @@ static void svc_reclassify_socket(struct socket *sock)
 #endif
 
 /**
- * svc_tcp_release_ctxt - Release transport-related resources
+ * svc_sock_release_ctxt - Release transport-related resources
  * @xprt: the transport which owned the context
  * @ctxt: the context from rqstp->rq_xprt_ctxt or dr->xprt_ctxt
  *
  */
-static void svc_tcp_release_ctxt(struct svc_xprt *xprt, void *ctxt)
+static void svc_sock_release_ctxt(struct svc_xprt *xprt, void *ctxt)
 {
 }
 
-/**
- * svc_udp_release_ctxt - Release transport-related resources
- * @xprt: the transport which owned the context
- * @ctxt: the context from rqstp->rq_xprt_ctxt or dr->xprt_ctxt
- *
- */
-static void svc_udp_release_ctxt(struct svc_xprt *xprt, void *ctxt)
-{
-	struct sk_buff *skb = ctxt;
-
-	if (skb)
-		consume_skb(skb);
-}
-
 union svc_pktinfo_u {
 	struct in_pktinfo pkti;
 	struct in6_pktinfo pkti6;
@@ -613,22 +598,20 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 		goto out_cmsg_err;
 	rqstp->rq_daddrlen = svc_addr_len(svc_daddr(rqstp));
 
-	if (skb_is_nonlinear(skb)) {
-		/* we have to copy */
-		local_bh_disable();
-		if (csum_partial_copy_to_xdr(&rqstp->rq_arg, skb))
-			goto out_bh_enable;
-		local_bh_enable();
-		consume_skb(skb);
-	} else {
-		/* we can use it in-place */
-		rqstp->rq_arg.head[0].iov_base = skb->data;
-		rqstp->rq_arg.head[0].iov_len = len;
-		if (skb_checksum_complete(skb))
-			goto out_free;
-		rqstp->rq_xprt_ctxt = skb;
+	if (len > rqstp->rq_arg.head[0].iov_len + rqstp->rq_arg.page_len ||
+	    svc_rqst_arg_iter_init(rqstp, &msg.msg_iter, 0, len)) {
+		trace_svcsock_udp_recv_err(&svsk->sk_xprt, -EMSGSIZE);
+		goto out_free;
 	}
+	if (skb_csum_unnecessary(skb))
+		err = skb_copy_datagram_iter(skb, 0, &msg.msg_iter, len);
+	else
+		err = skb_copy_and_csum_datagram_msg(skb, 0, &msg);
+	if (err)
+		goto out_free;
+	consume_skb(skb);
 
+	svc_rqst_arg_flush(rqstp, len);
 	svc_rqst_set_arg_len(rqstp, len);
 
 	if (serv->sv_stats)
@@ -648,9 +631,6 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 out_cmsg_err:
 	net_warn_ratelimited("svc: received unknown control message %d/%d; dropping RPC reply datagram\n",
 			     cmh->cmsg_level, cmh->cmsg_type);
-	goto out_free;
-out_bh_enable:
-	local_bh_enable();
 out_free:
 	kfree_skb(skb);
 out_clear_busy:
@@ -683,9 +663,6 @@ static int svc_udp_sendto(struct svc_rqst *rqstp)
 	int count;
 	int err;
 
-	svc_udp_release_ctxt(xprt, rqstp->rq_xprt_ctxt);
-	rqstp->rq_xprt_ctxt = NULL;
-
 	svc_set_cmsg_data(rqstp, cmh);
 
 	count = svc_rqst_res_to_bvec(rqstp, 0);
@@ -762,7 +739,7 @@ static const struct svc_xprt_ops svc_udp_ops = {
 	.xpo_recvfrom = svc_udp_recvfrom,
 	.xpo_sendto = svc_udp_sendto,
 	.xpo_result_payload = svc_sock_result_payload,
-	.xpo_release_ctxt = svc_udp_release_ctxt,
+	.xpo_release_ctxt = svc_sock_release_ctxt,
 	.xpo_detach = svc_sock_detach,
 	.xpo_free = svc_sock_free,
 	.xpo_has_wspace = svc_udp_has_wspace,
@@ -1345,7 +1322,7 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
 					 (u32)xdr->len);
 	int count, sent;
 
-	svc_tcp_release_ctxt(xprt, rqstp->rq_xprt_ctxt);
+	svc_sock_release_ctxt(xprt, rqstp->rq_xprt_ctxt);
 	rqstp->rq_xprt_ctxt = NULL;
 
 	BUILD_BUG_ON(SVC_TCP_MARKER_BVECS > RPCSVC_BVEC_HEADROOM);
@@ -1389,7 +1366,7 @@ static const struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_recvfrom = svc_tcp_recvfrom,
 	.xpo_sendto = svc_tcp_sendto,
 	.xpo_result_payload = svc_sock_result_payload,
-	.xpo_release_ctxt = svc_tcp_release_ctxt,
+	.xpo_release_ctxt = svc_sock_release_ctxt,
 	.xpo_detach = svc_tcp_sock_detach,
 	.xpo_free = svc_sock_free,
 	.xpo_has_wspace = svc_tcp_has_wspace,

-- 
2.56.0

