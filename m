Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793801488;
	b=LsLoLm56b2zCwUA2+nu2uXFS2jKL88kK3V+6PeGuutdMidLq4EL2idby1CXbzNvbtFV6
	 xM4TErEMZACOV2vEUZ/7MUkFSUdQERhhlR9M8STcKJXuDLqtqMKCGdC2Sxoc2gdDXDkbs
	 gnWGBPEIGNWnLF7+AQZjwZCio0t6+FpsVEaK+i+t9AxU/idvoL71taUlLuz4DJ699/SzA
	 3+ZucmM82NBPmiqvUyWo7SkE2k7A/HBnmmOTh+/MORutBJe4E5Yce/cmsRCFEjdapPM99
	 XLW06DENghn88+4F023Bh8ybqLjbiK5NCK8xi2gFRu7Av+RP/3gjM2GgpRjhwSARjDw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793801488;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=WnS8qgnJdqr+fS1jLMgWR5ypVYvLXjObvhLNFtl2ZPY=;
	b=PqjRR56/XWWXAZVvHQ3OaHl6R3smTkoeAifMh3RVN4nqxlvHJHfNvSpuGfoFQawPeWzC
	 O9TBXlJ4qNQA0LELBBa3GqAof36XriYv9KeW9S3HDgRlxpTmbNL43igAYiyEVNC5QHcja
	 AD+QXXV0R17+qhCfAqeQfLk2nGDks97g70oOnHuoylphA6TKXuA/faPwrmcybv0X/70pH
	 3hJ43YbgVHjnzmlkBr43XFHO1stTQ1Jxq/K38NsUYtdd9wZArw+9U1dbzkpBJEjUlp78v
	 7PNv6yAGGNjlTzHrHCAosMNsDXVL0nMuqA48qEMYglHm9O9L8H0l0Wk6VqCDGzjTRvA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oEy1Ywp9;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6D0E7606EEB5;
	Wed,  4 Nov 2026 14:11:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=oEy1Ywp9
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 13A8F1F0093A;
	Wed,  4 Nov 2026 14:11:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793801488;
	bh=WnS8qgnJdqr+fS1jLMgWR5ypVYvLXjObvhLNFtl2ZPY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=oEy1Ywp9k/zQBfNrbYtVjfHEvlobjBSVZULBB8LUJFJIkuRybiwACJIeX2Wc1aAIP
	 FdaZvS9wGW79N2IZVjpYPNSTqD/wUMwuL7Ns+rv8eqbnvHuhRYMAQ6xRMd0E4SMHn4
	 MaLtNIEO6psHOSFYt8TH8MQ6lbdVlCVE6ktNibc9reCtU/8kP847tF2ymCc0ix9o0T
	 MRfezOZ5l+mtH+rMDVe+w+Y4WOP4xseHVeaUzmJDCpqd7WFA+EGaNhbmh5sAihTIIQ
	 Aee+3QVw/hclBbcLencNbn+lUqMKUtZeRcLQyB3iwxtsFC+Y+HWRIflHi/j0PabLCN
	 8AWQlhri78stg==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 09:11:11 -0500
Subject: [PATCH v8 11/14] svcrdma: Publish RDMA reply positions
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
Message-Id: <20261104-duplicate-reply-cache-v8-11-eea5b90e4318@kernel.org>
References: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
In-Reply-To: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=9095; i=cel@kernel.org;
 h=from:subject:message-id; bh=yiBdXfPj2xfzeZeLL//hh+3DniWFOuAWuaZXbNxf7p0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6z0BrD1w/hh3pKjLCULnt15/M8iCSoVTjWJhm
 xTVMWfV59iJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaus9AQAKCRAzarMzb2Z/
 l/6jEACWsZCd7x1kmS2RoJtmB/QhQDLwzQVzeR8536ncQLF2scUGNfdeP3e8jmMDHw5uYftp+Ov
 PGfUmmYQtmyAzE9vOdSlpZqzWpbQ/Rwy8J2pIcvyxCPpKYUIwqzw1qNsS070oFB35z5rztviwuV
 MXoVIb8x8JPtdPVoCBMM5bPm7xotjYEguUByLtIBKCOS/3Tq9IofX5ff5tH6Y22idQ2d/EgW4Cp
 qx5pgOMCxfigYm3m/v2dMFKDuRNKktj+5uRRL/SJJibNyYw7NjMP2P6xvtchTmAOwF2ZQ9CiCNd
 ND0ZOiYVNN1oQRaTKyWFFGSB0jeqkfU6pD1OdEMDIplgs22hOwjTr7YnbCYxv6PJNL68zi1kcLv
 Qvb2dKKi7dvCKLbBBUCteEfEB39sJfk4I55jKjmYtY0dgp1bmGnSwlKVr/VZrkivbstAtqn0HL2
 lsp+CU618G445tLf8YQ+bHgfqN398QvbxolDeH9o4+KOdl7eibzbgqzZMVvVyisSp3kJx7B4eBi
 i4+BqNOl2sVFqgrRZowXkV6d6BXwyLGtRRtGOZm8146xSGA85mstUa/9UIvsVqmuExau0ZZ1AHT
 +1prZD61vTjnBYJkK8Ao2Xfy2jWVcU1PBC92S7ZLLez81eR2MPsP7RXh+Z1S34Xa+y/WLVtu4lZ
 9TMmwtH2H41mX5A==
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

Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-10-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc_rdma.h            |  5 ++++-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  2 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      | 26 +++++++++++++++++++++++---
 net/sunrpc/xprtrdma/svc_rdma_transport.c   | 15 +++++++++++++++
 4 files changed, 43 insertions(+), 5 deletions(-)

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
index df6c3501f97c..fd007296caf0 100644
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
@@ -724,6 +727,18 @@ static int svc_rdma_has_wspace(struct svc_xprt *xprt)
 	return 1;
 }
 
+/*
+ * Publish the position as the Send completion raised it. The
+ * xpt_recv_pending count covers only a deferred request. A
+ * retransmit still in flight needs a receive mark as well, and
+ * svcrdma keeps none: xprtrdma does not retransmit on a live
+ * connection.
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

