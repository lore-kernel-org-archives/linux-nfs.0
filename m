Received: from mail-pf1-f227.google.com (mail-pf1-f227.google.com [209.85.210.227])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1E7C2471D0B
	for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2026 21:17:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.227
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787260629; cv=none; b=RSrHk8PuZ2kdjtxDnxY/t5gxQdojds4NetKBVYB3CmhBAsIXvApIhdNGXH5u1AhbnKj/vAE+MYMn6McfG/JWv/im+CeVzhJL1JXTzaTY3+T44qWQj3SsSzQyrOFawzawQ6HXSMJvd7Ul08pN7o4ZpzvCqd9JbcbTB/vGb412wIc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787260629; c=relaxed/simple;
	bh=fM1VQX/U55X1aVzVswulNNh878mZidiMhsqRuZ9brvI=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=RBegKipCsVbOgGwDvZE9kSPdrAIjgxNH6ihXYSxzFZpL2uPZ8HtCbwK5+YUDvk2lK0+XI6x5p9xwipAJ0iPbDUZc1o9B9xs9qVjZ67j2bxw6dbO5qmJU17pYZ/R1JuceJLx98eaUueLN4aUB74S5UObXrng9FO+nteiDKafzsIc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=everpuredata.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=bMj8K6TD; arc=none smtp.client-ip=209.85.210.227
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="bMj8K6TD"
Received: by mail-pf1-f227.google.com with SMTP id d2e1a72fcca58-848761b5897so114231b3a.3
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2026 14:17:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1787260623; x=1787865423; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=eTh8TrITayJyf7umhq1RHOex9ysjtdBnUrHh3RIQzLw=;
        b=bMj8K6TDKvDQnPrSI5bWKVmTr7pHxEtFhjyen2VZXWQFbpk2zWWiGbqD9ocqDj1jxy
         HBIRzRg5Vt3X58dNHfwjnUlF6IpGYQki+EgPQpZxwpkL9vtbWDOaiNaPK0kuKX3aSoEu
         DFarNnHIGRbxLO44/J/Vvfb8KOYDmWEtn5pn+ZiqSomKFsALalYTJxb1YBGu9zvWqakI
         KVvk1Uc+n4EFVIQBSnh/ekTNgZMYCOcPLlh/Rhn2FOvtfjE63wObt2BR6uqug80vD+La
         WxQhpsXvgMA5u22CX6QfBPRQiyccZ31GD9k1a0zuPuHWXGkNgNAwAlAFRqnHpwSL5inc
         G4Dg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787260623; x=1787865423;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=eTh8TrITayJyf7umhq1RHOex9ysjtdBnUrHh3RIQzLw=;
        b=fGBKjwia4YI3teUrnXPb5DCrVcpJ8kAjxbXP37cWF0MBNVNhDYVi3/h1tS7Mdeq/y0
         g7JAfFtiJN5efElH8V2ubfFClwDhMRkOQBO95LNkgjSf1JeNEAjYNtZlXBFCMo4uVrfB
         4GkSvxO9wekB+0tAV3weqVR2TIm+EJA2KdZfNqhm0W8OCTCXve3KSs+GKPzOuzC8+oTV
         DqG4sIhRg65Li2VtfHzGsAOCHzBfn48zhKdK+mnhwfNGZp9aCDxO4kS/X4Yu7Ag+QsRq
         9m1pRN+DG20gkED+BLXAbrHu8neLCa+XcFBCH2o9cW4TYmji7DanD9LGxdxSmuCfjLiB
         eTgQ==
X-Forwarded-Encrypted: i=1; AHgh+RpBnV6jIUS5k7EuJ3KaONi8w9wmh8rmLE2BcPC/5VWUvLyq+faaJFGejWN+amwm94LvwWCpQJav2xg=@vger.kernel.org
X-Gm-Message-State: AOJu0Ywd7Q/Spz9s1q2tkQ+J2aDzaKdCsWh/HvmKEEMRg1hL+C+CKJ83
	VvFjAoQ9y9ovXLxhEv0sfa2hO63cy4M06m7qGGgKc3sJWeZCTEmxaiitOydZr+Wnca4fU4hkzZt
	jWtL73dLydPCsGus994py5PbuPiA7QrjRlUp7ONIuDvq3qTo+u3iZ
X-Gm-Gg: AR+sD110obyxyKTR+cmM98e4yTfv6f8rgI6Dhlsgh2B8L1WDyhY1HY5oR3tS4QmUQdO
	/EK/IIQv6x71oZ99JNuE0ktXrJzgPVB3Ozmrp0fz5mIujwYEvOyIJvqPQn60rxT/nom3Wz4R5VQ
	r6JFHJvN5m/Tna4Ra44pW1bXKcmtzk0Hw8afx5ixqGZBA34Y8hogp2Er8gbIRXLe/tirvthQgiT
	VnzJbr3FxVy2EXB6MtuMmrvjiRu22To9S+LawS0uE3/xFSj5Ww3ODQGcgaXYG2V9ziiKw1UA1FH
	UDnvSOVseIOmCZdyLkPt4+DQXtCbzsoR0u3F4R9zkoZYtk0OhSKZDSM2YIiXT/O5YX5OdZ7jc0x
	ySpWToyTmoNdpJyJI8AIfWbN0JX5luQ==
X-Received: by 2002:a05:6a00:4c98:b0:851:8baf:5b29 with SMTP id d2e1a72fcca58-851f9f7c38emr1513178b3a.10.1787260623356;
        Thu, 20 Aug 2026 14:17:03 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([2620:125:9008:8012:36:131:5:0])
        by smtp-relay.gmail.com with ESMTPS id 41be03b00d2f7-cc16882d0e9sm407241a12.2.2026.08.20.14.17.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 20 Aug 2026 14:17:03 -0700 (PDT)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 8993A3416E4;
	Thu, 20 Aug 2026 14:17:02 -0700 (PDT)
From: Tim Menninger <tmenninger@everpuredata.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: tom@talpey.com,
	cel@kernel.org,
	linux-nfs@vger.kernel.org,
	stable@vger.kernel.org,
	slingappa@everpuredata.com,
	ebadger@everpuredata.com,
	jcurley@everpuredata.com
Subject: [PATCH v2] xprtrdma: serialize unmap_sync with xprt_disconnect
Date: Thu, 20 Aug 2026 21:17:00 +0000
Message-Id: <20260820211700.318824-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20260818122825.2347594-1-tmenninger@purestorage.com>
References: <20260818122825.2347594-1-tmenninger@purestorage.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

frwr_unmap_sync() posts LOCAL_INV Work Requests to the QP and waits
for the matching CQE. This can race with rpcrdma_xprt_disconnect():

    1. frwr_unmap_sync() samples r_xprt->rx_ep
    2. rpcrdma_xprt_disconnect() drains the QP
    3. frwr_unmap_sync() posts LOCAL_INV WRs after the drain
    4. No CQE arrives, so wait_for_completion() blocks indefinitely

The hung task appears in the rpciod workqueue:

Workqueue: rpciod rpc_async_schedule [sunrpc]
    wait_for_completion()
    frwr_unmap_sync()
    xprt_rdma_free()
    xprt_release()

Serialize synchronous MR invalidation against QP teardown with
rx_unmap_rwsem. frwr_unmap_sync() holds the read side while it samples
rx_ep, builds the LOCAL_INV chain, and submits it. Disconnect holds the
write side across QP drain and resource teardown. Drop the read side
before waiting so disconnect can drain the submitted Work Requests and
deliver their CQEs.

Disconnect can reset a request while frwr_unmap_sync() waits for the
read side. Recheck rl_registered after acquiring the rwsem and return
without posting if the request has already been reset.

Move the synchronous invalidation completion from the final MR to the
request, whose lifetime covers xprt_rdma_free(), and hold a reference
to the sampled endpoint through the completion wait and error path.
This allows disconnect to destroy MRs after draining the QP and drop
its endpoint reference without a separate active-unmap counter.

frwr_unmap_async() runs inline from Receive completion processing.
rpcrdma_xprt_drain() drains the Receive Queue before the Send Queue, so
asynchronous LOCAL_INV Work Requests are submitted before Send Queue
drain. frwr_unmap_sync(), however, runs from xprt_rdma_free() after the
transport send lock has been released, so it is not ordered against
disconnect.

Tested on v7.2-rc6 under pNFS load with repeated data server restarts
to provoke rapid QP disconnect/reconnect cycling. Without the fix, a
hung task in frwr_unmap_sync() reproduced twice in six attempts. With
the fix, no hang occurred across 200 cycles.

Also observed on v6.8 and v6.18.34.

Fixes: e28ce90083f0 ("xprtrdma: kmalloc rpcrdma_ep separate from rpcrdma_xprt")
Cc: stable@vger.kernel.org
Assisted-by: Claude:opus-4-7
Signed-off-by: Tim Menninger <tmenninger@everpuredata.com>
---
Changes since v1:

- Change the Fixes tag to e28ce90083f0, which made rx_ep a separately
  allocated, kref-managed pointer.
- Explain why Receive-before-Send Queue drain orders
  frwr_unmap_async(), but does not order frwr_unmap_sync().
- Move the synchronous LOCAL_INV completion from struct rpcrdma_mr to
  struct rpcrdma_req.
- Hold a reference to the sampled endpoint through the completion wait
  and error path.
- Remove rx_unmap_active and its disconnect-side wait.
- Recheck rl_registered after acquiring the rwsem in case disconnect
  reset the request while the reader was blocked.
- Update the transport-recovery comments, LOCAL_INV wake kernel-doc,
  frwr_unmap_sync() kernel-doc, and the QP-posting locking comment.
- Keep rx_unmap_rwsem in struct rpcrdma_xprt; an endpoint-resident lock
  cannot protect the initial rx_ep lookup.

v1: https://lore.kernel.org/all/20260818122825.2347594-1-tmenninger@purestorage.com/

 net/sunrpc/xprtrdma/frwr_ops.c  | 98 ++++++++++++++++++++++-----------
 net/sunrpc/xprtrdma/transport.c |  2 +
 net/sunrpc/xprtrdma/verbs.c     | 18 ++++--
 net/sunrpc/xprtrdma/xprt_rdma.h | 11 +++-
 4 files changed, 89 insertions(+), 40 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index e5c71cf705a3..77aff9c0533a 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -27,13 +27,17 @@
 
 /* Transport recovery
  *
- * frwr_map and frwr_unmap_* cannot run at the same time the transport
- * connect worker is running. The connect worker holds the transport
- * send lock, just as ->send_request does. This prevents frwr_map and
- * the connect worker from running concurrently. When a connection is
- * closed, the Receive completion queue is drained before the allowing
- * the connect worker to get control. This prevents frwr_unmap and the
- * connect worker from running concurrently.
+ * frwr_map() is serialized with the connect worker by the transport
+ * send lock.
+ *
+ * frwr_unmap_async() runs from Receive completion processing.
+ * rpcrdma_xprt_drain() drains the Receive Queue before the Send Queue,
+ * so asynchronous LOCAL_INV Work Requests are submitted before Send
+ * Queue drain.
+ *
+ * frwr_unmap_sync() runs after the transport send lock is released.
+ * rx_unmap_rwsem orders its LOCAL_INV submission before disconnect
+ * drains the QP.
  *
  * When the underlying transport disconnects, MRs that are in flight
  * are flushed and are likely unusable. Thus all MRs are destroyed.
@@ -139,7 +143,6 @@ int frwr_mr_init(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr *mr)
 	mr->mr_ibmr = frmr;
 	mr->mr_device = NULL;
 	INIT_LIST_HEAD(&mr->mr_list);
-	init_completion(&mr->mr_linv_done);
 	frwr_cid_init(ep, mr);
 
 	sg_init_table(sg, depth);
@@ -538,40 +541,62 @@ static void frwr_wc_localinv(struct ib_cq *cq, struct ib_wc *wc)
  * @cq: completion queue
  * @wc: WCE for a completed LocalInv WR
  *
- * Awaken anyone waiting for an MR to finish being fenced.
+ * Wake the request waiting for the final LOCAL_INV completion.
  */
 static void frwr_wc_localinv_wake(struct ib_cq *cq, struct ib_wc *wc)
 {
 	struct ib_cqe *cqe = wc->wr_cqe;
 	struct rpcrdma_mr *mr = container_of(cqe, struct rpcrdma_mr, mr_cqe);
+	struct rpcrdma_req *req = mr->mr_req;
 
 	/* WARNING: Only wr_cqe and status are reliable at this point */
 	trace_xprtrdma_wc_li_wake(wc, &mr->mr_cid);
 	frwr_mr_done(wc, mr);
-	complete(&mr->mr_linv_done);
+	complete(&req->rl_linv_done);
 
 	rpcrdma_flush_disconnect(cq->cq_context, wc);
 }
 
 /**
- * frwr_unmap_sync - invalidate memory regions that were registered for @req
+ * frwr_unmap_sync - synchronously invalidate MRs registered for @req
  * @r_xprt: controlling transport instance
- * @req: rpcrdma_req with a non-empty list of MRs to process
+ * @req: request whose registered MRs are to be invalidated
  *
- * Sleeps until it is safe for the host CPU to access the previously mapped
- * memory regions. This guarantees that registered MRs are properly fenced
- * from the server before the RPC consumer accesses the data in them. It
- * also ensures proper Send flow control: waking the next RPC waits until
- * this RPC has relinquished all its Send Queue entries.
+ * If @req still owns registered MRs after synchronizing with transport
+ * disconnect, post a chain of LOCAL_INV Work Requests and wait for the
+ * final completion. This fences the mapped regions from remote access
+ * and preserves Send Queue flow control.
+ *
+ * A concurrent disconnect can reset @req while this function waits for
+ * the read side. In that case the MRs have already been released and no
+ * LOCAL_INV Work Requests are posted.
  */
 void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 {
 	struct ib_send_wr *first, **prev, *last;
-	struct rpcrdma_ep *ep = r_xprt->rx_ep;
 	const struct ib_send_wr *bad_wr;
+	struct rpcrdma_ep *ep;
+	struct rdma_cm_id *id;
 	struct rpcrdma_mr *mr;
 	int rc;
 
+	/* serialize against rpcrdma_xprt_disconnect() */
+	down_read(&r_xprt->rx_unmap_rwsem);
+
+	/*
+	 * Disconnect can reset this request while we wait for the read side.
+	 * Recheck rl_registered in case rx_ep now refers to a new connection.
+	 */
+	ep = r_xprt->rx_ep;
+	if (!ep || list_empty(&req->rl_registered))
+		goto out_unlock;
+
+	/* Hold an endpoint reference so ep and its CM ID remain valid
+	 * after we drop the rwsem and while we wait for completion.
+	 */
+	rpcrdma_ep_get(ep);
+	id = ep->re_id;
+
 	/* ORDER: Invalidate all of the MRs first
 	 *
 	 * Chain the LOCAL_INV Work Requests and post them with
@@ -598,37 +623,44 @@ void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 		prev = &last->next;
 	} while ((mr = rpcrdma_mr_pop(&req->rl_registered)));
 
-	mr = container_of(last, struct rpcrdma_mr, mr_invwr);
-
 	/* Strong send queue ordering guarantees that when the
 	 * last WR in the chain completes, all WRs in the chain
 	 * are complete.
 	 */
 	last->wr_cqe->done = frwr_wc_localinv_wake;
-	reinit_completion(&mr->mr_linv_done);
+	reinit_completion(&req->rl_linv_done);
 
-	/* Transport disconnect drains the receive CQ before it
-	 * replaces the QP. The RPC reply handler won't call us
-	 * unless re_id->qp is a valid pointer.
+	/*
+	 * The read side prevents disconnect from draining this QP until the
+	 * LOCAL_INV chain has been submitted.
 	 */
 	bad_wr = NULL;
-	rc = ib_post_send(ep->re_id->qp, first, &bad_wr);
+	rc = ib_post_send(id->qp, first, &bad_wr);
+
+	up_read(&r_xprt->rx_unmap_rwsem);
 
 	/* The final LOCAL_INV WR in the chain is supposed to
 	 * do the wake. If it was never posted, the wake will
 	 * not happen, so don't wait in that case.
 	 */
 	if (bad_wr != first)
-		wait_for_completion(&mr->mr_linv_done);
-	if (!rc)
-		return;
+		wait_for_completion(&req->rl_linv_done);
 
-	/* On error, the MRs get destroyed once the QP has drained. */
-	trace_xprtrdma_post_linv_err(req, rc);
+	if (rc) {
+		/* On error, the MRs get destroyed once the QP has drained. */
+		trace_xprtrdma_post_linv_err(req, rc);
 
-	/* Force a connection loss to ensure complete recovery.
-	 */
-	rpcrdma_force_disconnect(ep);
+		/* Force a connection loss to ensure complete recovery.
+		 */
+		rpcrdma_force_disconnect(ep);
+	}
+
+	if (rpcrdma_ep_put(ep))
+		rdma_destroy_id(id);
+	return;
+
+out_unlock:
+	up_read(&r_xprt->rx_unmap_rwsem);
 }
 
 /**
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index d4e6746d8ecd..e38637c2ec78 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -364,6 +364,8 @@ xprt_setup_rdma(struct xprt_create *args)
 	INIT_DELAYED_WORK(&new_xprt->rx_connect_worker,
 			  xprt_rdma_connect_worker);
 
+	init_rwsem(&new_xprt->rx_unmap_rwsem);
+
 	xprt->max_payload = RPCRDMA_MAX_DATA_SEGS << PAGE_SHIFT;
 
 	return xprt;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 04b286223b24..193a90c97f7a 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -74,8 +74,6 @@ static void rpcrdma_reqs_reset(struct rpcrdma_xprt *r_xprt);
 static void rpcrdma_reps_unmap(struct rpcrdma_xprt *r_xprt);
 static void rpcrdma_mrs_create(struct rpcrdma_xprt *r_xprt);
 static void rpcrdma_mrs_destroy(struct rpcrdma_xprt *r_xprt);
-static void rpcrdma_ep_get(struct rpcrdma_ep *ep);
-static int rpcrdma_ep_put(struct rpcrdma_ep *ep);
 static struct rpcrdma_regbuf *
 rpcrdma_regbuf_alloc_node(size_t size, enum dma_data_direction direction,
 			  int node);
@@ -374,7 +372,7 @@ static void rpcrdma_ep_destroy(struct kref *kref)
 	module_put(THIS_MODULE);
 }
 
-static noinline void rpcrdma_ep_get(struct rpcrdma_ep *ep)
+noinline void rpcrdma_ep_get(struct rpcrdma_ep *ep)
 {
 	kref_get(&ep->re_kref);
 }
@@ -383,7 +381,7 @@ static noinline void rpcrdma_ep_get(struct rpcrdma_ep *ep)
  *     %0 if @ep still has a positive kref count, or
  *     %1 if @ep was destroyed successfully.
  */
-static noinline int rpcrdma_ep_put(struct rpcrdma_ep *ep)
+noinline int rpcrdma_ep_put(struct rpcrdma_ep *ep)
 {
 	return kref_put(&ep->re_kref, rpcrdma_ep_destroy);
 }
@@ -580,18 +578,22 @@ int rpcrdma_xprt_connect(struct rpcrdma_xprt *r_xprt)
  */
 void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)
 {
-	struct rpcrdma_ep *ep = r_xprt->rx_ep;
+	struct rpcrdma_ep *ep;
 	struct rdma_cm_id *id;
 	int rc;
 
+	down_write(&r_xprt->rx_unmap_rwsem);
+
+	ep = r_xprt->rx_ep;
 	if (!ep)
-		return;
+		goto out_unlock;
 
 	id = ep->re_id;
 	rc = rdma_disconnect(id);
 	trace_xprtrdma_disconnect(r_xprt, rc);
 
 	rpcrdma_xprt_drain(r_xprt);
+
 	rpcrdma_reps_unmap(r_xprt);
 	rpcrdma_sendctxs_destroy(r_xprt);
 	rpcrdma_reqs_reset(r_xprt);
@@ -601,6 +603,9 @@ void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)
 		rdma_destroy_id(id);
 
 	r_xprt->rx_ep = NULL;
+
+out_unlock:
+	up_write(&r_xprt->rx_unmap_rwsem);
 }
 
 /* Fixed-size circular FIFO queue. This implementation is wait-free and
@@ -924,6 +929,7 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt,
 
 	INIT_LIST_HEAD(&req->rl_free_mrs);
 	INIT_LIST_HEAD(&req->rl_registered);
+	init_completion(&req->rl_linv_done);
 	spin_lock(&buffer->rb_lock);
 	list_add(&req->rl_all, &buffer->rb_allreqs);
 	spin_unlock(&buffer->rb_lock);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 4cbc941e4a3e..e50b0af5adf8 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -46,6 +46,7 @@
 #include <linux/spinlock.h> 		/* spinlock_t, etc */
 #include <linux/atomic.h>		/* atomic_t, etc */
 #include <linux/kref.h>			/* struct kref */
+#include <linux/rwsem.h>		/* struct rw_semaphore */
 #include <linux/workqueue.h>		/* struct work_struct */
 #include <linux/llist.h>
 
@@ -249,7 +250,6 @@ struct rpcrdma_mr {
 	int			mr_nents;
 	enum dma_data_direction	mr_dir;
 	struct ib_cqe		mr_cqe;
-	struct completion	mr_linv_done;
 	union {
 		struct ib_reg_wr	mr_regwr;
 		struct ib_send_wr	mr_invwr;
@@ -348,6 +348,7 @@ struct rpcrdma_req {
 
 	struct list_head	rl_free_mrs;
 	struct list_head	rl_registered;
+	struct completion	rl_linv_done;
 };
 
 static inline struct rpcrdma_req *
@@ -449,6 +450,12 @@ struct rpcrdma_xprt {
 	struct delayed_work	rx_connect_worker;
 	struct rpc_timeout	rx_timeout;
 	struct rpcrdma_stats	rx_stats;
+
+	/*
+	 * Read side protects sampling rx_ep and posting synchronous LOCAL_INV
+	 * WRs; disconnect holds the write side across QP drain and teardown.
+	 */
+	struct rw_semaphore	rx_unmap_rwsem;
 };
 
 #define rpcx_to_rdmax(x) container_of(x, struct rpcrdma_xprt, rx_xprt)
@@ -479,6 +486,8 @@ extern unsigned int xprt_rdma_memreg_strategy;
  * Endpoint calls - xprtrdma/verbs.c
  */
 void rpcrdma_force_disconnect(struct rpcrdma_ep *ep);
+void rpcrdma_ep_get(struct rpcrdma_ep *ep);
+int rpcrdma_ep_put(struct rpcrdma_ep *ep);
 void rpcrdma_flush_disconnect(struct rpcrdma_xprt *r_xprt, struct ib_wc *wc);
 int rpcrdma_xprt_connect(struct rpcrdma_xprt *r_xprt);
 void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt);
-- 
2.34.1

