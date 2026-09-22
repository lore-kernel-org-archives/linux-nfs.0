Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2A73337E5F1;
	Tue, 22 Sep 2026 01:51:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790041895; cv=none; b=GakO7jbNIEOw0+k4vv/exzek1if3LY+T2TVfOXQRJ8mkcAW7nifPhtl3eKe3ei/sdoD3NtvftybdOYzdvPs90/GSXtCiD7au1/Y1q5/wLpvC/09XDJtg/1LxlFBbH8QfE312qPTD4U2PLJdR6gJc4kaLMRnqEd3d4j7Ji9ANBss=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790041895; c=relaxed/simple;
	bh=SsJlfalME/BNzxS/bc8f9zdmcLYZQV496Y8d5gloUbU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=OE888TqqwcZ++IIzBmJAufxbWFa2tae9br5fxMv4PpIgtHldy5HuMn6HrkJuWTeosKkpZnnHu5pMLlOK2yismpnlYB6ns+YbFrwtFqfqhrwedN6epImsc3uM7c6n7Vx4Fy31SBH4DSJIdLipQWGmHBKDIZkhpMJJt0+6YGgF9Wg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FGADwoAk; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FGADwoAk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6EDAA1F00898;
	Tue, 22 Sep 2026 01:51:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790041894;
	bh=seS+UxDkdMQS6FB0KWK0qr+/1zZRub4CzJjJhSdCzcw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=FGADwoAkIhqgmuBwSbSn/F2oGRxmlpx6UWk4nl6a/K8jlJWTqCe+W4WkfvEW4JDm8
	 wfMQnLT+xpu8P1qGr9TPccVfHVrClBMrHiPgO0DpgHqUcUOvySm3nMseYte8xtzQHf
	 KOxmips4Jh7MuDA8VzuR+41q1HGbD5+EdiLzirupvvN1PqhU5klxlGnyJG9SSXUIKr
	 qdffFS4NW494meBlGb+hNFn5n7uZaiK+06z3P4I5PJtVnXK8QgAt6KPuAbhNVWSNHE
	 Loambr7UsEY7/7vuREd8Yvh8y5Of030EuKR6fIgQfTpFU5H3u4iSU0SAAEPu34EtBk
	 oeed6r6Qw3f0A==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>
Subject: [PATCH v1 5/5] svcrdma: release a receive context stranded by a partial Read post
Date: Mon, 21 Sep 2026 21:51:28 -0400
Message-ID: <20260922015128.240977-5-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260922015128.240977-1-cel@kernel.org>
References: <20260922015128.240977-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When ib_post_send() rejects a WR mid-chain, svc_rdma_post_send_err()
returns zero and svc_rdma_post_chunk_ctxt() reports the Read chain
as posted. The only signaled WR in the chain is its tail, so a chain
cut before the tail posts nothing that completes.
svc_rdma_process_read_list() then reports the Read in progress, and
the receive context waits for svc_rdma_wc_read_done(), which never
runs. No list the transport destructor walks holds the context, so
it leaks past teardown along with its rw contexts and their DMA
mappings.

The caller cannot release the context on the error, because the
posted Read WRs still write into pages it owns. Nor can the error
path drain the Send Queue. The drain's marker WR needs an SQ slot,
and a provider that has just rejected a WR cannot be trusted to
have one.

Park the receive context on a per-transport list, as the Send path
does, and release it from svc_rdma_free() after the drain and before
the rw contexts are destroyed. svc_rdma_post_chunk_ctxt() posts only
Read chains, so pass it the receive context itself rather than the
embedded chunk context.

Reaching this path needs a provider to reject a WR after accepting
earlier ones in the same chain. That has not been observed.

Fixes: f13193f50b64 ("svcrdma: Introduce local rdma_rw API helpers")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc_rdma.h          |  2 ++
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  | 18 ++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_rw.c        | 31 ++++++++++++++++++------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  2 ++
 4 files changed, 46 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index b52f83f97d64..87af38878b37 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -118,6 +118,7 @@ struct svcxprt_rdma {
 
 	struct llist_head    sc_send_release_list;
 	struct llist_head    sc_send_stranded_ctxts;
+	struct llist_head    sc_recv_stranded_ctxts;
 
 	atomic_t	     sc_completion_ids;
 };
@@ -263,6 +264,7 @@ extern void svc_rdma_handle_bc_reply(struct svc_rqst *rqstp,
 
 /* svc_rdma_recvfrom.c */
 extern void svc_rdma_recv_ctxts_destroy(struct svcxprt_rdma *rdma);
+extern void svc_rdma_recv_ctxts_stranded_release(struct svcxprt_rdma *rdma);
 extern bool svc_rdma_post_recvs(struct svcxprt_rdma *rdma);
 extern struct svc_rdma_recv_ctxt *
 		svc_rdma_recv_ctxt_get(struct svcxprt_rdma *rdma);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index d029bcb7a5c0..ed5a83e9edd2 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -234,6 +234,24 @@ void svc_rdma_recv_ctxt_put(struct svcxprt_rdma *rdma,
 	llist_add(&ctxt->rc_node, &rdma->sc_recv_ctxts);
 }
 
+/**
+ * svc_rdma_recv_ctxts_stranded_release - Release stranded recv_ctxts
+ * @rdma: svcxprt_rdma being torn down
+ *
+ * Context: transport destructor only, after the QP has been drained
+ * and before its rw contexts and recv_ctxts are destroyed.
+ */
+void svc_rdma_recv_ctxts_stranded_release(struct svcxprt_rdma *rdma)
+{
+	struct svc_rdma_recv_ctxt *ctxt;
+	struct llist_node *node;
+
+	while ((node = llist_del_first(&rdma->sc_recv_stranded_ctxts)) != NULL) {
+		ctxt = llist_entry(node, struct svc_rdma_recv_ctxt, rc_node);
+		svc_rdma_recv_ctxt_put(rdma, ctxt);
+	}
+}
+
 /**
  * svc_rdma_release_ctxt - Release transport-specific per-rqst resources
  * @xprt: the transport which owned the context
diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
index 7b7879b2cc88..63d00f0cc1db 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -389,10 +389,18 @@ static void svc_rdma_wc_read_done(struct ib_cq *cq, struct ib_wc *wc)
  * - If ib_post_send() succeeds, only one completion is expected,
  *   even if one or more WRs are flushed. This is true when posting
  *   an rdma_rw_ctx or when posting a single signaled WR.
+ *
+ * Return values:
+ *   %0: The chain was posted; svc_rdma_wc_read_done() releases
+ *       @head. Or a prefix of the chain was posted; no completion
+ *       follows, and the transport destructor releases @head.
+ *   %-ENOTCONN: No WR was posted; the caller still owns @head.
+ *   %-EINVAL: @head's Read chain needs more SQ entries than exist.
  */
 static int svc_rdma_post_chunk_ctxt(struct svcxprt_rdma *rdma,
-				    struct svc_rdma_chunk_ctxt *cc)
+				    struct svc_rdma_recv_ctxt *head)
 {
+	struct svc_rdma_chunk_ctxt *cc = &head->rc_cc;
 	struct ib_send_wr *first_wr;
 	const struct ib_send_wr *bad_wr;
 	struct list_head *tmp;
@@ -422,10 +430,18 @@ static int svc_rdma_post_chunk_ctxt(struct svcxprt_rdma *rdma,
 	cc->cc_posttime = ktime_get();
 	bad_wr = first_wr;
 	ret = ib_post_send(rdma->sc_qp, first_wr, &bad_wr);
-	if (ret)
-		return svc_rdma_post_send_err(rdma, &cc->cc_cid, bad_wr,
-					      first_wr, cc->cc_sqecount,
-					      ret);
+	if (ret) {
+		ret = svc_rdma_post_send_err(rdma, &cc->cc_cid, bad_wr,
+					     first_wr, cc->cc_sqecount,
+					     ret);
+		if (ret)
+			return ret;
+
+		/* The posted prefix still references @head. Only the
+		 * transport destructor may release it.
+		 */
+		llist_add(&head->rc_node, &rdma->sc_recv_stranded_ctxts);
+	}
 	return 0;
 }
 
@@ -1169,7 +1185,8 @@ static void svc_rdma_clear_rqst_pages(struct svc_rqst *rqstp,
  * RDMA Reads have completed.
  *
  * Return values:
- *   %1: all needed RDMA Reads were posted successfully,
+ *   %1: RDMA Reads were posted; the transport now owns @head, and
+ *       a Read completion or the transport destructor releases it,
  *   %-EINVAL: client provided too many chunks or segments,
  *   %-ENOMEM: rdma_rw context pool was exhausted,
  *   %-ENOTCONN: posting failed (connection is lost),
@@ -1200,6 +1217,6 @@ int svc_rdma_process_read_list(struct svcxprt_rdma *rdma,
 		return ret;
 
 	trace_svcrdma_post_read_chunk(&cc->cc_cid, cc->cc_sqecount);
-	ret = svc_rdma_post_chunk_ctxt(rdma, cc);
+	ret = svc_rdma_post_chunk_ctxt(rdma, head);
 	return ret < 0 ? ret : 1;
 }
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index d449460e8f1e..df6c3501f97c 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -198,6 +198,7 @@ static struct svcxprt_rdma *svc_rdma_create_xprt(struct svc_serv *serv,
 	init_llist_head(&cma_xprt->sc_rw_ctxts);
 	init_llist_head(&cma_xprt->sc_send_release_list);
 	init_llist_head(&cma_xprt->sc_send_stranded_ctxts);
+	init_llist_head(&cma_xprt->sc_recv_stranded_ctxts);
 	init_waitqueue_head(&cma_xprt->sc_send_wait);
 	init_waitqueue_head(&cma_xprt->sc_sq_ticket_wait);
 
@@ -677,6 +678,7 @@ static void svc_rdma_free(struct svc_xprt *xprt)
 	svc_rdma_send_ctxts_stranded_release(rdma);
 
 	svc_rdma_flush_recv_queues(rdma);
+	svc_rdma_recv_ctxts_stranded_release(rdma);
 
 	svc_rdma_destroy_rw_ctxts(rdma);
 	svc_rdma_send_ctxts_destroy(rdma);
-- 
2.55.0

