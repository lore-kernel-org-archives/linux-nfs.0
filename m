Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297191;
	b=kpYfUGOzmDtEf2zREA4Npt59mnRVxpNZlfDOyEwjFijySwwvX4B+STlU6uiZ6tS0CQIW
	 MvgInDptTxQS5PTsGlwLYy4I4v2BN0FWR89E+DBi5nBnUh9Mi/7l3O0WQKblETwgyCtKw
	 rQasCUmhskHIGxiH0kttyM5fAhEObAqszV05L/5Z/gdUWOf9nZVjaSuKFpGlUo/CIVmD2
	 HuJf4lMehVT/sQd+ky7GeHdNmmCMyQFenL/t3OEhWhTTMolcFDWMeYdS0W6+U0Lj5ZRPT
	 dyM2o1df9JKiDhXYDrONmLyO2L6rsiPaq0vPmPubF2qa8+AXWMRvs9rzsqDbOG5+7sQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297191;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=D2oEykR5u8WfYRfoRk/3oe0L2vKVnYHqwQ0s8CxCV3U=;
	b=IaQjh41EzIhGkEflCslbVkty/EzBNroHk4X9AX6GgAUGgCHoL7gmUZ0cRPzRo9Nmg6xH
	 R1JF3G89zMY3vPZdaCado2vuXrWQAnwBxOUy8JSa6gAcjAG91JmKu9+BUuWUXt4Yr+3dg
	 18q1s6PLVTtazbHxwCeleMttDB1uQqdYjSDX3NJWShYukPxDFXCb8+XQNQ5O5JuquZ4gs
	 vyn0WgVcXu30rVn2WSrVSGTzv61qcySsXBORCR0aGTJlptIsUMIK/1LXpQdyVa6Wjfrm3
	 6D5p1Rv5kCgbxmpRUqFznXKX48VqgCtXGFCPFhSnHprkwA7VJDujYkSqovOFo8IpYkA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=M5LnO4i6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E987D606A323
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:06:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=M5LnO4i6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 325011F031E0;
	Thu, 29 Oct 2026 18:06:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793297190;
	bh=D2oEykR5u8WfYRfoRk/3oe0L2vKVnYHqwQ0s8CxCV3U=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=M5LnO4i6j4cRVJEb77uwKLvcHXA5b8CHaxb3PcE+XuauGZ/9iR0F+8PW0d+BGr8Kx
	 GB8U6SsoYyKop6EfGuDzwRxaStOr1lj8EnZyeDd+3YUtvG+AhWMi6CaEqx4UXnF57n
	 rAooVimN2st/voJSrnvrb/5F0bDQ2KJBC+RnvN8lm+dwL1ge2XjgqBU1s1tPTFN5fK
	 6akg7qVlHUhtx4FGIuKH284dWn17WlekQCCMPz/q9hodUz2lCJ4eL6NITbFDMECjKn
	 88ZthREiq0P4HPdegCRwHCgJSOEgmDp58dBMYGbrdNZCFCavY+UxWpzf6S0a6/lQuj
	 7ITxUKzWFO/1Q==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 14:06:16 -0400
Subject: [PATCH v7 10/13] svcrdma: Publish RDMA reply positions
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
Message-Id: <20261029-duplicate-reply-cache-v7-10-f3b0f3cf5bc7@kernel.org>
References: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
In-Reply-To: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=8963; i=cel@kernel.org;
 h=from:subject:message-id; bh=xtvE58C7uyKohW3ykSEpnl/+nMRoxEkrXd+TkdFRTpA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq44scNkaDpzp976QP3Cu+Z1brWt9DlAN6fVlCe
 prS4adB6D2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauOLHAAKCRAzarMzb2Z/
 l+TDEACpEvQySzO71gliBPALyB+GeISCZ75bctOLi2A/kiqPV1NuiTQwroDUbk0uKHng2cfuPgX
 /oQHOEARpRL3Ob4sJnd1qAoIKAqLNPtAKaLSSByvTK/ZOMEv2b6i3BT8Zt8VokyDETB6NFhRaRV
 WjE8rZILY37irgjbp4te/FK4pvjbswclp6AbEb7N1ebqEbiMN0W4MESGV2aY4jeILsvGf2mZQc+
 JMCtJX+QWrIPhxV+ACtbs7F054AWaS8YM+j+wXSCCQadjeLp0K63m3GpR1yG0fjU2wJWODA3V9c
 tzoUKnMbVYsnn+2qnv/Nbdm8RWzwSB62dN+kDEzWeiSGpLLoZrKY/aAdhp8cIgZcCxB3yp9Gk9N
 2MWXXdV90KgMdug9Jt8DPTAlX/b9cgI3pO9B8/BCkQuyQnzOtOuTjeQaTwbNV4g45Usb0uV+aZe
 nw7+tYzsCQOslGk4JDWF+behfMWRpqjc649hgv+wN2fqTw9Hp21cIOYIb3Fx0rYEUFzc1fqhr/x
 I3VP43b+9R1c63yfpRNS9pJDYdKAcBAIvnuHHwftXoCilDBx1lzi0N/Wj4fmt4nmBwWcVlwWzAx
 7Dv/Ex/My/Hz1FOtVrQBRHRD6woOilSKSX8GhQehey88/+QHZ7t0WE9CKbk9ddYI0zxl2TvlIxL
 nl8QTTMhcKTgUCg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Add the svcrdma side of reply-position reporting. A reply's position
is the sequence number of its Send on the transport, and the Send
completion for that reply publishes the same number as the
transport's acknowledged position. A successful Send completion means
the peer's HCA has acknowledged the message, so a reply whose Send
has completed is in the client's receive buffer.

Completions on one queue pair arrive in posting order. Several nfsd
threads post on one queue pair with no serialization above the
provider, so the order in which Sends are queued is decided inside
the provider. Assign the sequence number and post the Send under one
lock so positions match queuing order. ib_post_send() does not
sleep; the Send Queue wait stays outside the lock.

Only a posted RPC Reply reports a position. The RDMA_ERROR message
and backchannel calls post with no position pointer, and a Send that
fails to post leaves rq_reply_pos at zero.

svcrdma publishes the position as the Send completion raised it,
with neither the request count nor the receive mark that svcsock
keeps. xprtrdma does not retransmit on a live connection:
xprt_rdma_timer() disconnects on an RPC timeout, and the retransmit
arrives on a new transport, whose lookups do not evict the old
transport's entries. RFC 8166 does not forbid a retransmit on the
same connection. A client that sends one needs the mark as well as
the count, and svcrdma has no rcv_nxt to record. Send and Receive
completions arrive on separate queues with no common lock, so the
mark needs an ordering between the two completion handlers that
svcrdma does not provide. The gate waits for a client that
retransmits on a live connection.

Assisted-by: LLM
Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-10-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc_rdma.h            |  5 ++++-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  2 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      | 26 +++++++++++++++++++++++---
 net/sunrpc/xprtrdma/svc_rdma_transport.c   | 12 ++++++++++++
 4 files changed, 40 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 60966f92e8c8..71bd5bcc5ce2 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -96,6 +96,8 @@ struct svcxprt_rdma {
 
 	spinlock_t	     sc_send_lock;
 	struct llist_head    sc_send_ctxts;
+	spinlock_t	     sc_post_lock;	/* orders Send posting */
+	u64		     sc_post_seq;	/* Sends posted so far */
 	spinlock_t	     sc_rw_ctxt_lock;
 	struct llist_head    sc_rw_ctxts;
 
@@ -244,6 +246,7 @@ struct svc_rdma_send_ctxt {
 	struct ib_send_wr	*sc_wr_chain;
 	int			sc_sqecount;
 	struct ib_cqe		sc_cqe;
+	u64			sc_pos;
 	struct xdr_buf		sc_hdrbuf;
 	struct xdr_stream	sc_stream;
 
@@ -309,7 +312,7 @@ extern struct svc_rdma_send_ctxt *
 extern void svc_rdma_send_ctxt_put(struct svcxprt_rdma *rdma,
 				   struct svc_rdma_send_ctxt *ctxt);
 extern int svc_rdma_post_send(struct svcxprt_rdma *rdma,
-			      struct svc_rdma_send_ctxt *ctxt);
+			      struct svc_rdma_send_ctxt *ctxt, u64 *pos);
 extern int svc_rdma_map_reply_msg(struct svcxprt_rdma *rdma,
 				  struct svc_rdma_send_ctxt *sctxt,
 				  const struct svc_rdma_pcl *write_pcl,
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index e0768d1ee556..20b7dfc20d2b 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -94,7 +94,7 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	sctxt->sc_page_count = 1;
 
 	sctxt->sc_send_wr.opcode = IB_WR_SEND;
-	return svc_rdma_post_send(rdma, sctxt);
+	return svc_rdma_post_send(rdma, sctxt, NULL);
 }
 
 /* Server-side transport endpoint wants a whole page for its send
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index b9eee2150ea1..07df06480294 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -222,6 +222,7 @@ struct svc_rdma_send_ctxt *svc_rdma_send_ctxt_get(struct svcxprt_rdma *rdma)
 	ctxt->sc_page_count = 0;
 	ctxt->sc_wr_chain = &ctxt->sc_send_wr;
 	ctxt->sc_sqecount = 1;
+	ctxt->sc_pos = 0;
 
 	return ctxt;
 
@@ -491,6 +492,7 @@ static void svc_rdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
 		goto flushed;
 
 	trace_svcrdma_wc_send(&ctxt->sc_cid);
+	svc_xprt_advance_acked(&rdma->sc_xprt, ctxt->sc_pos);
 	svc_rdma_send_ctxt_put(rdma, ctxt);
 	return;
 
@@ -507,24 +509,30 @@ static void svc_rdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
  * svc_rdma_post_send - Post a WR chain to the Send Queue
  * @rdma: transport context
  * @ctxt: WR chain to post
+ * @pos: OUT: position of this Send on @rdma, or NULL
  *
  * Copy fields in @ctxt to stack variables in order to guarantee
  * that these values remain available after the ib_post_send() call.
  * In some error flow cases, svc_rdma_wc_send() releases @ctxt.
  *
+ * @pos is written only when the chain was posted. Positions on one
+ * transport increase in posting order, and the Send completion of
+ * @ctxt publishes its position in xpt_acked_pos.
+ *
  * Return values:
  *   %0: The transport owns @ctxt; a Send completion or the
  *       transport destructor releases it
  *   %-ENOTCONN: The connection was lost
  */
 int svc_rdma_post_send(struct svcxprt_rdma *rdma,
-		       struct svc_rdma_send_ctxt *ctxt)
+		       struct svc_rdma_send_ctxt *ctxt, u64 *pos)
 {
 	struct ib_send_wr *first_wr = ctxt->sc_wr_chain;
 	struct ib_send_wr *send_wr = &ctxt->sc_send_wr;
 	const struct ib_send_wr *bad_wr = first_wr;
 	struct rpc_rdma_cid cid = ctxt->sc_cid;
 	int ret, sqecount = ctxt->sc_sqecount;
+	u64 seq;
 
 	might_sleep();
 
@@ -539,7 +547,17 @@ int svc_rdma_post_send(struct svcxprt_rdma *rdma,
 		return ret;
 
 	trace_svcrdma_post_send(ctxt);
+
+	/*
+	 * Assign the position and post under one lock so positions
+	 * match the order the provider queues the Sends, and thus
+	 * completion order.
+	 */
+	spin_lock(&rdma->sc_post_lock);
+	seq = ++rdma->sc_post_seq;
+	ctxt->sc_pos = seq;
 	ret = ib_post_send(rdma->sc_qp, first_wr, &bad_wr);
+	spin_unlock(&rdma->sc_post_lock);
 	if (ret) {
 		ret = svc_rdma_post_send_err(rdma, &cid, bad_wr,
 					     first_wr, sqecount, ret);
@@ -552,6 +570,8 @@ int svc_rdma_post_send(struct svcxprt_rdma *rdma,
 		llist_add(&ctxt->sc_node, &rdma->sc_send_stranded_ctxts);
 		return 0;
 	}
+	if (pos)
+		*pos = seq;
 	return 0;
 }
 
@@ -1082,7 +1102,7 @@ static int svc_rdma_send_reply_msg(struct svcxprt_rdma *rdma,
 		send_wr->opcode = IB_WR_SEND;
 	}
 
-	return svc_rdma_post_send(rdma, sctxt);
+	return svc_rdma_post_send(rdma, sctxt, &rqstp->rq_reply_pos);
 }
 
 /**
@@ -1152,7 +1172,7 @@ void svc_rdma_send_error_msg(struct svcxprt_rdma *rdma,
 	 */
 	sctxt->sc_wr_chain = &sctxt->sc_send_wr;
 	sctxt->sc_sqecount = 1;
-	if (svc_rdma_post_send(rdma, sctxt))
+	if (svc_rdma_post_send(rdma, sctxt, NULL))
 		goto put_ctxt;
 	return;
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index df6c3501f97c..7f0c66c8bfd3 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -77,6 +77,7 @@ static void svc_rdma_detach(struct svc_xprt *xprt);
 static void svc_rdma_free(struct svc_xprt *xprt);
 static int svc_rdma_has_wspace(struct svc_xprt *xprt);
 static void svc_rdma_kill_temp_xprt(struct svc_xprt *);
+static u64 svc_rdma_acked_pos(struct svc_rqst *rqstp);
 
 static const struct svc_xprt_ops svc_rdma_ops = {
 	.xpo_create = svc_rdma_create,
@@ -89,6 +90,7 @@ static const struct svc_xprt_ops svc_rdma_ops = {
 	.xpo_has_wspace = svc_rdma_has_wspace,
 	.xpo_accept = svc_rdma_accept,
 	.xpo_kill_temp_xprt = svc_rdma_kill_temp_xprt,
+	.xpo_acked_pos = svc_rdma_acked_pos,
 };
 
 struct svc_xprt_class svc_rdma_class = {
@@ -209,6 +211,7 @@ static struct svcxprt_rdma *svc_rdma_create_xprt(struct svc_serv *serv,
 	lockdep_set_class(&cma_xprt->sc_send_lock, &svcrdma_sctx_lock);
 	spin_lock_init(&cma_xprt->sc_rw_ctxt_lock);
 	lockdep_set_class(&cma_xprt->sc_rw_ctxt_lock, &svcrdma_rwctx_lock);
+	spin_lock_init(&cma_xprt->sc_post_lock);
 
 	/*
 	 * Note that this implies that the underlying transport support
@@ -724,6 +727,15 @@ static int svc_rdma_has_wspace(struct svc_xprt *xprt)
 	return 1;
 }
 
+/*
+ * svcrdma does not count requests in xpt_recv_pending, so the
+ * position is published as the Send completion raised it.
+ */
+static u64 svc_rdma_acked_pos(struct svc_rqst *rqstp)
+{
+	return atomic64_read(&rqstp->rq_xprt->xpt_acked_pos);
+}
+
 static void svc_rdma_kill_temp_xprt(struct svc_xprt *xprt)
 {
 }

-- 
2.56.0

