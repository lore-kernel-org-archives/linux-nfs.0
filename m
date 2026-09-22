Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C4E5F2F0C7E;
	Tue, 22 Sep 2026 01:51:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790041895; cv=none; b=Qoe9rNsbXO/nV2m74mRzt9ndhn5eCEY5mBctRrwuyqGbunksGA/7WUoF5u2SYwLh4R9Cf5WZybhbn6Kp+5vHdEGxFW1OYRbWCIXdEoKgHPF3acsK/XQsBPVO76ANouyecGPjXkuS8Ii29B4yns541GrO9mvTI+CCYhfCIXize5k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790041895; c=relaxed/simple;
	bh=Ncqz72qeLIgZ1eDNndHsX4QJa2pcjNyEk4QqdSYVTwk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ET65bQWrq+ijj+PyLI9uIbYdddht/kbQanUVNDW3XWWVW0Od4qaGMHUdQtgs/JzEPRtA+s+9DFpm1kKSfXY8HC/eLs2+OEdP3/eOsG3yGY9fxnDxEd1qf1I0ftTC9LZtQcQK1ZQLobu0kCYyPdjWHKUnCsUd1jfkDdcN2hflBmk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Y24wcges; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Y24wcges"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8D10F1F000FF;
	Tue, 22 Sep 2026 01:51:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790041893;
	bh=sMxrN/wrQptEvNmCKg52lHGQTo+wkpnWPOz0rdjZQXs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Y24wcgesPER3y1bThE3Wpnx1WzFCnr0V1KvqtHU9AB73eVntbjAD7ukQZqyEJJVcy
	 f2R/LlXH5kWxKqNVnNQQZl+1K89th9huoTkgFQ27FQ1S2RhaZS+eHKWmYOTbtJLqmG
	 T6Rq3fv0lTnq+/O92ySAMIJRCetpmTCFy6Nb45Ryb1gPF+0TLNxqUwg4bLRwqNcSrl
	 P3Rj1n3pCZO3Gb6Bkcxyt9MZHwat3h9knDrjIepOS/phnM+MLlWJ8bNL+CX0ZTsa3f
	 PCh5ncxdHQfXjJKTvCLnHTBO8uB0U7oyWXvgtVHm10o5IGfvkFSPn2MtOkJ/1Th4LZ
	 YeEZa5hWkEdqg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>
Subject: [PATCH v1 4/5] svcrdma: release a send context stranded by a partial post
Date: Mon, 21 Sep 2026 21:51:27 -0400
Message-ID: <20260922015128.240977-4-cel@kernel.org>
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
returns zero to say that a completion will clean up. The Write and
Reply chunk WRs in a reply's chain do carry completions, but those
only trace or close the transport. The Send at the chain's tail is
the one whose completion puts the send context, so a chain cut
before the Send leaves the context unreleased. svc_rdma_sendto()
reports success and never puts it either. No list the transport
destructor walks holds the context, so it leaks past teardown along
with the DMA mappings, page references, and rw contexts it owns.

The error path cannot release the context itself. The posted WRs
still reference its rw contexts and pages, and the HCA may still be
reading them. Nor can it drain the Send Queue to wait for them. A
drain needs a free SQ slot for its marker WR. A provider that
rejects a WR after accepting earlier ones has most likely diverged
from svcrdma's SQ accounting, so no slot svcrdma believes it holds
can be trusted.

Transfer the context to the transport instead. On a partial post,
svc_rdma_post_send() parks the context on a per-transport list and
reports success, the same ownership a fully posted chain has.
svc_rdma_free() releases the list after its own drain and before the
rw contexts are destroyed. The SQ reservation stays debited, since
the Send that refunds it never completes and the transport is
closing.

Reaching this path requires a provider to reject a WR after
accepting earlier ones in the same chain. That has not been
observed. The Fixes: tag names the commit that wrote the mistaken
contract. The chain became long enough to cut only with commit
10e6fc1054d9 ("svcrdma: Post the Reply chunk and Send WR together").

Fixes: 71b43531ee0b ("svcrdma: Post Send WR chain")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc_rdma.h          |  2 +
 net/sunrpc/xprtrdma/svc_rdma_rw.c        |  1 +
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    | 47 +++++++++++++++++++-----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  2 +
 4 files changed, 43 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 76aa5ec4ab40..b52f83f97d64 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -117,6 +117,7 @@ struct svcxprt_rdma {
 	struct llist_head    sc_recv_ctxts;
 
 	struct llist_head    sc_send_release_list;
+	struct llist_head    sc_send_stranded_ctxts;
 
 	atomic_t	     sc_completion_ids;
 };
@@ -300,6 +301,7 @@ extern int svc_rdma_process_read_list(struct svcxprt_rdma *rdma,
 /* svc_rdma_sendto.c */
 extern void svc_rdma_send_ctxts_destroy(struct svcxprt_rdma *rdma);
 extern void svc_rdma_send_ctxts_drain(struct svcxprt_rdma *rdma);
+extern void svc_rdma_send_ctxts_stranded_release(struct svcxprt_rdma *rdma);
 extern struct svc_rdma_send_ctxt *
 		svc_rdma_send_ctxt_get(struct svcxprt_rdma *rdma);
 extern void svc_rdma_send_ctxt_put(struct svcxprt_rdma *rdma,
diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
index 9aaaade99e6e..7b7879b2cc88 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -420,6 +420,7 @@ static int svc_rdma_post_chunk_ctxt(struct svcxprt_rdma *rdma,
 		return ret;
 
 	cc->cc_posttime = ktime_get();
+	bad_wr = first_wr;
 	ret = ib_post_send(rdma->sc_qp, first_wr, &bad_wr);
 	if (ret)
 		return svc_rdma_post_send_err(rdma, &cc->cc_cid, bad_wr,
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index c09659b17351..05dcdb6c007a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -292,6 +292,23 @@ void svc_rdma_send_ctxts_drain(struct svcxprt_rdma *rdma)
 		svc_rdma_send_ctxt_release(rdma, ctxt);
 }
 
+/**
+ * svc_rdma_send_ctxts_stranded_release - Release stranded send_ctxts
+ * @rdma: svcxprt_rdma being torn down
+ *
+ * Context: transport destructor only, after the QP has been drained
+ * and before its rw contexts are destroyed.
+ */
+void svc_rdma_send_ctxts_stranded_release(struct svcxprt_rdma *rdma)
+{
+	struct svc_rdma_send_ctxt *ctxt, *next;
+	struct llist_node *node;
+
+	node = llist_del_all(&rdma->sc_send_stranded_ctxts);
+	llist_for_each_entry_safe(ctxt, next, node, sc_node)
+		svc_rdma_send_ctxt_release(rdma, ctxt);
+}
+
 /**
  * svc_rdma_send_ctxt_put - Queue send_ctxt for deferred release
  * @rdma: controlling svcxprt_rdma
@@ -427,9 +444,15 @@ int svc_rdma_sq_wait(struct svcxprt_rdma *rdma,
  * @sqecount: number of SQ entries that were reserved
  * @ret: error code from ib_post_send
  *
+ * The transport is closing on return. Who owns the caller's context
+ * depends on how much of the chain was posted.
+ *
  * Return values:
- *   %0: At least one WR was posted; a completion handles cleanup
- *   %-ENOTCONN: No WRs were posted; SQ slots are released
+ *   %0: A prefix of the chain was posted. Its signaled tail was not,
+ *       so no completion will release the caller's context. The
+ *       caller keeps ownership. The SQ reservation stays debited.
+ *   %-ENOTCONN: No WR was posted; SQ slots are released and the
+ *       caller owns its context.
  */
 int svc_rdma_post_send_err(struct svcxprt_rdma *rdma,
 			   const struct rpc_rdma_cid *cid,
@@ -440,9 +463,6 @@ int svc_rdma_post_send_err(struct svcxprt_rdma *rdma,
 	trace_svcrdma_sq_post_err(rdma, cid, ret);
 	svc_rdma_xprt_deferred_close(rdma);
 
-	/* If even one WR was posted, a Send completion will
-	 * return the reserved SQ slots.
-	 */
 	if (bad_wr != first_wr)
 		return 0;
 
@@ -493,7 +513,8 @@ static void svc_rdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
  * In some error flow cases, svc_rdma_wc_send() releases @ctxt.
  *
  * Return values:
- *   %0: @ctxt's WR chain was posted successfully
+ *   %0: The transport owns @ctxt; a Send completion or the
+ *       transport destructor releases it
  *   %-ENOTCONN: The connection was lost
  */
 int svc_rdma_post_send(struct svcxprt_rdma *rdma,
@@ -519,9 +540,17 @@ int svc_rdma_post_send(struct svcxprt_rdma *rdma,
 
 	trace_svcrdma_post_send(ctxt);
 	ret = ib_post_send(rdma->sc_qp, first_wr, &bad_wr);
-	if (ret)
-		return svc_rdma_post_send_err(rdma, &cid, bad_wr,
-					      first_wr, sqecount, ret);
+	if (ret) {
+		ret = svc_rdma_post_send_err(rdma, &cid, bad_wr,
+					     first_wr, sqecount, ret);
+		if (ret)
+			return ret;
+
+		/* The posted prefix still references @ctxt. Only the
+		 * transport destructor may release it.
+		 */
+		llist_add(&ctxt->sc_node, &rdma->sc_send_stranded_ctxts);
+	}
 	return 0;
 }
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index f949601b2144..d449460e8f1e 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -197,6 +197,7 @@ static struct svcxprt_rdma *svc_rdma_create_xprt(struct svc_serv *serv,
 	init_llist_head(&cma_xprt->sc_recv_ctxts);
 	init_llist_head(&cma_xprt->sc_rw_ctxts);
 	init_llist_head(&cma_xprt->sc_send_release_list);
+	init_llist_head(&cma_xprt->sc_send_stranded_ctxts);
 	init_waitqueue_head(&cma_xprt->sc_send_wait);
 	init_waitqueue_head(&cma_xprt->sc_sq_ticket_wait);
 
@@ -673,6 +674,7 @@ static void svc_rdma_free(struct svc_xprt *xprt)
 	if (rdma->sc_qp && !IS_ERR(rdma->sc_qp))
 		ib_drain_qp(rdma->sc_qp);
 	svc_rdma_send_ctxts_drain(rdma);
+	svc_rdma_send_ctxts_stranded_release(rdma);
 
 	svc_rdma_flush_recv_queues(rdma);
 
-- 
2.55.0

