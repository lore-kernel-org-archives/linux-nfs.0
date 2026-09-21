Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5BD0849E121
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 13:22:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789996969; cv=none; b=ch0RsMdx0qL/q5mAdH937adzEmwg7ITAqGCt1b/y5fev/vGaa1YeYDs4WlWNMD3QuB6pZzbKWbqO3x0VwGXGh4+g8xyEG9JdcUBdHR7d0oEpYO9e7SrHYKhI4LNU979ukWkDo0BzqewfzXNEgfbNeB2HtaT9efkp8ISDA6EhZII=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789996969; c=relaxed/simple;
	bh=zR6fAZJfQfLGcNxL3A7MUZIuznBiVVDPb+h27cZgsTY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=QcPopcpAAuEit/hbRqkEyvnggiK8/20tFSnalTIiTGeloIU0Y4WdwgbQl+Ie+gkoTrNwsO8pBZbo5+6xN9URFDuURQZ0IZ+tbU9XgQAOwQpyA/7+W1ikxRz19RDNhlAq75uBMZVjaPvLZTCS5pAR+4/YdK59TNO1QrZuB00wHPs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=C8+AH5w/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="C8+AH5w/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9C5231F0089A;
	Mon, 21 Sep 2026 13:22:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789996968;
	bh=0v8zqHaWcC2Eu+T6ZH7OEPuhYw+nYjf/6/eiol6+c6A=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=C8+AH5w/QMqGgNATO4a8alTbdD+a8oqO9550BcjkSldsPN6vemM2AXoSPPK75txLw
	 67GQISGwg4VEnqNVhgCoZVPBQGGgUhHAQxVwYAjARMG09ViUgt2eBOlrb1Fm+z9b/j
	 yZqJTpjj9ntZ1Zz4OOySu7JO+k06d9Q3mZm5l4bdiM7ciRjuZV2eNbnFsEXdINt+xM
	 fxNGzJnAYnPQNXaHTkiFNj0veZxb2mcyvl51tJ1iKbBpgZVTyTZgNVCSouMUcBQOcF
	 kR74+zv1R/OdoYQoXYj1QWQAzt5lBlXc88x7aTptDytH8M2I0rO4l8CfUWMJYiZvf6
	 MduFpfjuZSmvw==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 21 Sep 2026 09:22:36 -0400
Subject: [PATCH v6 10/12] svcrdma: Publish RDMA reply positions
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260921-duplicate-reply-cache-v6-10-db5e13fd9944@kernel.org>
References: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
In-Reply-To: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=6895; i=cel@kernel.org;
 h=from:subject:message-id; bh=zR6fAZJfQfLGcNxL3A7MUZIuznBiVVDPb+h27cZgsTY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqsS+ejvkMxC78/ZmdA6OGfjAistz5nPqW+c0e2
 V32l0rfwRWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCarEvngAKCRAzarMzb2Z/
 ly9zD/9H2Xjy6Vd535WIqL63W1yCZ3pvbqCe4nR1q2FJuXoMbbGAhyWaZC6DrjgHX1HB6M42BsF
 Ej/jt00JuLAuhVTv4mpoTAZbPfjjV+HYlYDf93O9z5g+ufcpS41H4koYQ/aTQO4Dv8KBkSy3hvP
 GQFOp0VmffWOWuwjL3S+1Xbs5ITsYNhcw9rQ+rzFwJNxlQDCljc+y+AmAOCrNfFyfvDUAUn4Cxy
 dKYDyfBuSfniNaaJ0ByKpgLg9lRmR1A1ZIX6Hf6oRWOFXsvcuzq30T7e+kkiJVguaOS5zzmFri9
 iOUz/zHKb2qpCd6giRsJvTk0YepH2RMwgbJYsddHez+SLSmc2lwP6qxGtL3bKes3JyRpn9AFzPv
 qdh3GvVf5aZfHwDF6LPf8Na1IEs/zXeVRw/H02uGSIQEd8PJbZ06ZUaS5k1NsxNwHXszxPJmTtA
 io521OX41TiPuq264mWiqLVYTfMwWW2y5JfbIFLHWBoy/MCCHm5+o4nXOLhocbvxEAuwscHhVzI
 6bf7CwCTOq75+32csk5sjDfcTkB9WH37TLQKxltZB3S+7Z4xdaBnuDqW4mRaowD4iAOBx8GY0kG
 9fRmr8u06/9ulw90P5331E3Y3vunmJYAy9Tjj2pnDRETl12DHTZPiLKQGldo0zBWMnpnBwsLVSN
 7A+7HeGXLeKSP0Q==
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

Assisted-by: LLM
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc_rdma.h            |  5 ++++-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  2 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      | 27 ++++++++++++++++++++++++---
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |  1 +
 4 files changed, 30 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 76aa5ec4ab40..7627afed16bb 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -96,6 +96,8 @@ struct svcxprt_rdma {
 
 	spinlock_t	     sc_send_lock;
 	struct llist_head    sc_send_ctxts;
+	spinlock_t	     sc_post_lock;	/* orders Send posting */
+	u64		     sc_post_seq;	/* Sends posted so far */
 	spinlock_t	     sc_rw_ctxt_lock;
 	struct llist_head    sc_rw_ctxts;
 
@@ -242,6 +244,7 @@ struct svc_rdma_send_ctxt {
 	struct ib_send_wr	*sc_wr_chain;
 	int			sc_sqecount;
 	struct ib_cqe		sc_cqe;
+	u64			sc_pos;
 	struct xdr_buf		sc_hdrbuf;
 	struct xdr_stream	sc_stream;
 
@@ -305,7 +308,7 @@ extern struct svc_rdma_send_ctxt *
 extern void svc_rdma_send_ctxt_put(struct svcxprt_rdma *rdma,
 				   struct svc_rdma_send_ctxt *ctxt);
 extern int svc_rdma_post_send(struct svcxprt_rdma *rdma,
-			      struct svc_rdma_send_ctxt *ctxt);
+			      struct svc_rdma_send_ctxt *ctxt, u64 *pos);
 extern int svc_rdma_map_reply_msg(struct svcxprt_rdma *rdma,
 				  struct svc_rdma_send_ctxt *sctxt,
 				  const struct svc_rdma_pcl *write_pcl,
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index e5a78b761012..549c0c39a97a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -90,7 +90,7 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	 */
 	get_page(virt_to_page(rqst->rq_buffer));
 	sctxt->sc_send_wr.opcode = IB_WR_SEND;
-	return svc_rdma_post_send(rdma, sctxt);
+	return svc_rdma_post_send(rdma, sctxt, NULL);
 }
 
 /* Server-side transport endpoint wants a whole page for its send
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index c09659b17351..47391cc9d750 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -222,6 +222,7 @@ struct svc_rdma_send_ctxt *svc_rdma_send_ctxt_get(struct svcxprt_rdma *rdma)
 	ctxt->sc_page_count = 0;
 	ctxt->sc_wr_chain = &ctxt->sc_send_wr;
 	ctxt->sc_sqecount = 1;
+	ctxt->sc_pos = 0;
 
 	return ctxt;
 
@@ -471,6 +472,8 @@ static void svc_rdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
 		goto flushed;
 
 	trace_svcrdma_wc_send(&ctxt->sc_cid);
+	if (ctxt->sc_pos > atomic64_read(&rdma->sc_xprt.xpt_acked_pos))
+		atomic64_set(&rdma->sc_xprt.xpt_acked_pos, ctxt->sc_pos);
 	svc_rdma_send_ctxt_put(rdma, ctxt);
 	return;
 
@@ -487,23 +490,29 @@ static void svc_rdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
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
  *   %0: @ctxt's WR chain was posted successfully
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
 
@@ -518,10 +527,22 @@ int svc_rdma_post_send(struct svcxprt_rdma *rdma,
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
 	if (ret)
 		return svc_rdma_post_send_err(rdma, &cid, bad_wr,
 					      first_wr, sqecount, ret);
+	if (pos)
+		*pos = seq;
 	return 0;
 }
 
@@ -1052,7 +1073,7 @@ static int svc_rdma_send_reply_msg(struct svcxprt_rdma *rdma,
 		send_wr->opcode = IB_WR_SEND;
 	}
 
-	return svc_rdma_post_send(rdma, sctxt);
+	return svc_rdma_post_send(rdma, sctxt, &rqstp->rq_reply_pos);
 }
 
 /**
@@ -1122,7 +1143,7 @@ void svc_rdma_send_error_msg(struct svcxprt_rdma *rdma,
 	 */
 	sctxt->sc_wr_chain = &sctxt->sc_send_wr;
 	sctxt->sc_sqecount = 1;
-	if (svc_rdma_post_send(rdma, sctxt))
+	if (svc_rdma_post_send(rdma, sctxt, NULL))
 		goto put_ctxt;
 	return;
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index f949601b2144..84042688bb3d 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -207,6 +207,7 @@ static struct svcxprt_rdma *svc_rdma_create_xprt(struct svc_serv *serv,
 	lockdep_set_class(&cma_xprt->sc_send_lock, &svcrdma_sctx_lock);
 	spin_lock_init(&cma_xprt->sc_rw_ctxt_lock);
 	lockdep_set_class(&cma_xprt->sc_rw_ctxt_lock, &svcrdma_rwctx_lock);
+	spin_lock_init(&cma_xprt->sc_post_lock);
 
 	/*
 	 * Note that this implies that the underlying transport support

-- 
2.55.0

