Received: from mail-pj1-f99.google.com (mail-pj1-f99.google.com [209.85.216.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B3DC12459EA
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 13:46:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.99
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787492814; cv=none; b=Ksi5AJT7P+zSTmU3cewfoV9Z1neTBi4Kh8aD7ue2SHuGs9dE7XgEFLvS4WaQHN4+nOMqIJmAroq9IpUSk8hpkGKsm2WCsZobxzni3hfiamgY+aMToi/OVq3Jv2xcXA09P25/C0b6yQZB7DFcRnRs8cBc/KV+NPaLA4DLtccO9JQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787492814; c=relaxed/simple;
	bh=4Fla8+j8Eg7YX/6CzswFoBmhtQ/nFpsG9jj/Ojj+Amg=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=XFXU0+x1E9ff3eiHRy6sYqzVPdqlXb5Z4xErPFvSFMhfkMe9EZKIlbWbGIW5dRCXHH8dzQ7BH9ja+U7BwOv/Ytl6q3Ppr32BEc9CKV6Olvd9nRNq/w1nflU/6Pv5vQ+wcI6qjZKssl8g6xVHR/r9mfi2PF0969s2KGA5/mqNkfY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=everpuredata.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=jJDViUx/; arc=none smtp.client-ip=209.85.216.99
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="jJDViUx/"
Received: by mail-pj1-f99.google.com with SMTP id 98e67ed59e1d1-381c51fde6bso2918884a91.2
        for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 06:46:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1787492810; x=1788097610; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=7DAgqpl1PMI6iUbvX3pPVIfxWLemP/Z9+LL3nU21f7E=;
        b=jJDViUx/wVhEZogZetwdCII+ztB3DZvH4CtrYB4UHe0m+LDZtkuUki1TsPZX3JHYxC
         4T8puxFk7ed0wUr0gKww6rcJMeF2B+Ny8/WRtLoG7iVy8cM41NPohk13hNZ8V8QAcQE9
         /yypmu7T2mvbK4QHL65Ffr5LPxsS6T5zGAMKV7w7ckkWx7zSc8aAxChVSTT2iz4Qrqxm
         ZWqKaX4i3jkwKDM6OWfu62CIdUxCxenrXQV+1OSInhGEUlznDrDBmvSEdG6vTqld/WfY
         9Np6SBtxCIgyIC5psHC4VJVczbSPye5tQKSZ+SAmGkK/D4jofrD749gDZMMHiFki+hc4
         lBwA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787492810; x=1788097610;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=7DAgqpl1PMI6iUbvX3pPVIfxWLemP/Z9+LL3nU21f7E=;
        b=pKKYg2ccmjNaKgMDYSeYpkYERgukWp0F27pYNFmmGKnI+0gwCzfXW0y3CzkQEMfzMw
         1IPJuD4TBPFz5h2D3csrXJX/j9t78TdXUcUuvWv+PT6QMjAPNNeAFL3/jzbFLGcUCdHl
         eSDNUh7YcXQOvjXRU2jzZAz7RDmbkyIwLF0JkBcqkVJjOzlZ6LyogNxh6oGyNE/xufK4
         IYocqK98HpFOgZs2czQ4YRgBDcuL8/TX/99nNrrUPrtSB970LGaT2dvAHr3b5oEjPokW
         99tJWQ8KlFBhAiboSRbKXj0nShM2tWTtWNdfBizqyjC0tSr+Ol7jJLkXZ7ys7k4n5fs/
         cvzQ==
X-Forwarded-Encrypted: i=1; AHgh+RoVuzXlfFQdq9av8+oVAt5bOk1KZ03SkjlwPjpRnm3tgbDRISFFLm8EwBFE+Rki3RroWNVWssDkOIA=@vger.kernel.org
X-Gm-Message-State: AFuF++lwBd2qp4ZrSZK1KPJMUd5Dy5fwYwwKF2FSEnQGjs36Om0yW2FG
	gZ4MZFLCaPPSUaPahIrYFWg1KUl+htZOFcBE2Gt1Af/D8mSYaSIaHijzjui1bmsIUNs4SydXbND
	TPYFlwupOwQqGdL3aimCB1qzxxlBseFLuGBpU
X-Gm-Gg: AR+sD11Bgd5K2mr6Jk7350uQ9RIznmo4O1PsBEKOUMjXBeswuPeMRWUtLea0XSS1crm
	miFEimUxFg2hYD/oAupqZlzITQ5YuDtkKfnGb1vAZxhnw4m53gkxZ8eRoY0d0O00KMm2BdqHUsD
	DXLd0H+l8bcvmGl5rJZeJfTvtDRrLz1h0qP4iX92e911SQmESTUoIGZeqwH5xWH7g8uAmxVSPyJ
	uV7Bbxuta02aYc16JCSev5bxvUgsHsNFTG3b3iR+fd8M4qQa3nryvZkeskfXw+gM2xUGN3v8CQS
	YV29cb+W/Ay6tJ389YEW686ErZH38jW9Z1VG+PpIfFc4J3lJZCq/LaORK5wepebfu+w91VVobtk
	4xrP/7Se8u7zfcjH0Uht5mQk+Puwa3y6sglTMteo=
X-Received: by 2002:a17:90b:1801:b0:38d:b36e:9813 with SMTP id 98e67ed59e1d1-395df25998dmr18340424a91.11.1787492809919;
        Sun, 23 Aug 2026 06:46:49 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id 98e67ed59e1d1-395e4a2db46sm2662561a91.12.2026.08.23.06.46.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 23 Aug 2026 06:46:49 -0700 (PDT)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 5AA57340166;
	Sun, 23 Aug 2026 06:46:49 -0700 (PDT)
From: Tim Menninger <tmenninger@everpuredata.com>
To: Chuck Lever <cel@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	slingappa@everpuredata.com,
	ebadger@everpuredata.com,
	jcurley@everpuredata.com,
	Tim Menninger <tmenninger@purestorage.com>,
	Tim Menninger <tmenninger@everpuredata.com>,
	stable@vger.kernel.org
Subject: [PATCH v4] xprtrdma: serialize unmap_sync with xprt_disconnect
Date: Sun, 23 Aug 2026 13:46:40 +0000
Message-Id: <20260823134640.3083136-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <9b573eb8-ea13-47bb-a06a-db70d57fc20e@app.fastmail.com>
References: <9b573eb8-ea13-47bb-a06a-db70d57fc20e@app.fastmail.com>
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
rx_unmap_rwsem. frwr_unmap_sync() holds the read side while it builds
and submits the LOCAL_INV chain. Disconnect holds the write side across
QP drain and resource teardown. Drop the read side before waiting so
disconnect can drain the submitted Work Requests and deliver their CQEs.

Disconnect can reset a request while frwr_unmap_sync() waits for the
read side. Recheck rl_registered after acquiring the rwsem and return
without posting if the request has already been reset.

Move the synchronous invalidation completion from the final MR to the
request, whose lifetime covers xprt_rdma_free(), and hold a reference
to the sampled endpoint through the completion wait and error path.
This allows disconnect to destroy MRs after draining the QP and release
the transport-owned endpoint reference without a separate active-unmap
counter.

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
Reviewed-by: Chuck Lever <cel@kernel.org>
Signed-off-by: Tim Menninger <tmenninger@everpuredata.com>
---
Changes in v4:
- Add kernel-doc comments for rpcrdma_ep_get() and
  rpcrdma_ep_release().
- Convert the rpcrdma_ep_put() comment to ordinary comment style.

v3: https://lore.kernel.org/all/20260821234827.1560856-1-tmenninger@purestorage.com/

Changes in v3:
- Document the sleepable rx_unmap_rwsem locking context in
  frwr_unmap_sync() and rpcrdma_xprt_disconnect().
- Add rpcrdma_ep_release() so CM ID destruction remains encapsulated
  in verbs.c; export the endpoint get/release pair instead of get/put.
- Use ep->re_id->qp directly while frwr_unmap_sync() holds the rwsem
  read side.
- Correct rpcrdma_xprt_disconnect() documentation to account for
  endpoint resources that can outlive the disconnect operation.
- Narrow the rx_unmap_rwsem comment to describe the LOCAL_INV versus
  QP-drain ordering it provides.

v2: https://lore.kernel.org/all/20260820211700.318824-1-tmenninger@everpuredata.com/

Changes in v2:
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
- Keep rx_unmap_rwsem in struct rpcrdma_xprt so the reader can
  synchronize with disconnect before retaining the current endpoint.

v1: https://lore.kernel.org/all/20260818122825.2347594-1-tmenninger@purestorage.com/

 net/sunrpc/xprtrdma/frwr_ops.c  | 97 ++++++++++++++++++++++-----------
 net/sunrpc/xprtrdma/transport.c |  2 +
 net/sunrpc/xprtrdma/verbs.c     | 52 ++++++++++++++----
 net/sunrpc/xprtrdma/xprt_rdma.h | 12 +++-
 4 files changed, 118 insertions(+), 45 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index e5c71cf705a3..cfe6339577fe 100644
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
@@ -538,40 +541,64 @@ static void frwr_wc_localinv(struct ib_cq *cq, struct ib_wc *wc)
  * @cq: completion queue
  * @wc: WCE for a completed LocalInv WR
  *
- * Awaken anyone waiting for an MR to finish being fenced.
+ * Wake frwr_unmap_sync() after the final LOCAL_INV completion.
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
+ * final completion. On successful completion, this fences the mapped
+ * regions from remote access and preserves Send Queue flow control.
+ *
+ * A concurrent disconnect can reset @req while this function waits for
+ * the read side. In that case the MRs have already been released and no
+ * LOCAL_INV Work Requests are posted.
+ *
+ * Context: Process context. Takes and releases
+ *	    @r_xprt->rx_unmap_rwsem for read. May sleep.
  */
 void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 {
 	struct ib_send_wr *first, **prev, *last;
-	struct rpcrdma_ep *ep = r_xprt->rx_ep;
 	const struct ib_send_wr *bad_wr;
+	struct rpcrdma_ep *ep;
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
+	/*
+	 * Hold an endpoint reference so ep, its QP, and its CM ID remain
+	 * valid after the rwsem is dropped and through the completion wait.
+	 */
+	rpcrdma_ep_get(ep);
+
 	/* ORDER: Invalidate all of the MRs first
 	 *
 	 * Chain the LOCAL_INV Work Requests and post them with
@@ -598,37 +625,43 @@ void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
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
 	rc = ib_post_send(ep->re_id->qp, first, &bad_wr);
 
+	up_read(&r_xprt->rx_unmap_rwsem);
+
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
+	rpcrdma_ep_release(ep);
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
index 04b286223b24..b9f7fbc67b74 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -74,7 +74,6 @@ static void rpcrdma_reqs_reset(struct rpcrdma_xprt *r_xprt);
 static void rpcrdma_reps_unmap(struct rpcrdma_xprt *r_xprt);
 static void rpcrdma_mrs_create(struct rpcrdma_xprt *r_xprt);
 static void rpcrdma_mrs_destroy(struct rpcrdma_xprt *r_xprt);
-static void rpcrdma_ep_get(struct rpcrdma_ep *ep);
 static int rpcrdma_ep_put(struct rpcrdma_ep *ep);
 static struct rpcrdma_regbuf *
 rpcrdma_regbuf_alloc_node(size_t size, enum dma_data_direction direction,
@@ -374,20 +373,39 @@ static void rpcrdma_ep_destroy(struct kref *kref)
 	module_put(THIS_MODULE);
 }
 
-static noinline void rpcrdma_ep_get(struct rpcrdma_ep *ep)
+/**
+ * rpcrdma_ep_get - Acquire an endpoint reference
+ * @ep: RPC/RDMA endpoint to retain
+ *
+ * Context: Any context.
+ */
+noinline void rpcrdma_ep_get(struct rpcrdma_ep *ep)
 {
 	kref_get(&ep->re_kref);
 }
 
-/* Returns:
- *     %0 if @ep still has a positive kref count, or
- *     %1 if @ep was destroyed successfully.
- */
+/* Return 1 if ep was destroyed, otherwise 0. */
 static noinline int rpcrdma_ep_put(struct rpcrdma_ep *ep)
 {
 	return kref_put(&ep->re_kref, rpcrdma_ep_destroy);
 }
 
+/**
+ * rpcrdma_ep_release - Release an endpoint reference
+ * @ep: RPC/RDMA endpoint to release
+ *
+ * The final release destroys @ep and its RDMA CM ID.
+ *
+ * Context: Process context. May sleep.
+ */
+void rpcrdma_ep_release(struct rpcrdma_ep *ep)
+{
+	struct rdma_cm_id *id = ep->re_id;
+
+	if (rpcrdma_ep_put(ep))
+		rdma_destroy_id(id);
+}
+
 static int rpcrdma_ep_create(struct rpcrdma_xprt *r_xprt)
 {
 	struct rpcrdma_connect_private *pmsg;
@@ -572,26 +590,32 @@ int rpcrdma_xprt_connect(struct rpcrdma_xprt *r_xprt)
  * rpcrdma_xprt_disconnect - Disconnect underlying transport
  * @r_xprt: controlling transport instance
  *
- * Caller serializes. Either the transport send lock is held,
- * or we're being called to destroy the transport.
+ * Context: Caller serializes. Either the transport send lock is held,
+ *	    or the transport is being destroyed. Takes and releases
+ *	    @r_xprt->rx_unmap_rwsem for write. May sleep.
  *
- * On return, @r_xprt is completely divested of all hardware
- * resources and prepared for the next ->connect operation.
+ * On return, @r_xprt is prepared for the next ->connect operation.
+ * The detached endpoint and its resources can outlive this function
+ * until the final endpoint reference is released.
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
@@ -601,6 +625,9 @@ void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)
 		rdma_destroy_id(id);
 
 	r_xprt->rx_ep = NULL;
+
+out_unlock:
+	up_write(&r_xprt->rx_unmap_rwsem);
 }
 
 /* Fixed-size circular FIFO queue. This implementation is wait-free and
@@ -924,6 +951,7 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt,
 
 	INIT_LIST_HEAD(&req->rl_free_mrs);
 	INIT_LIST_HEAD(&req->rl_registered);
+	init_completion(&req->rl_linv_done);
 	spin_lock(&buffer->rb_lock);
 	list_add(&req->rl_all, &buffer->rb_allreqs);
 	spin_unlock(&buffer->rb_lock);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 4cbc941e4a3e..08dfe9414657 100644
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
@@ -449,6 +450,13 @@ struct rpcrdma_xprt {
 	struct delayed_work	rx_connect_worker;
 	struct rpc_timeout	rx_timeout;
 	struct rpcrdma_stats	rx_stats;
+
+	/*
+	 * Orders frwr_unmap_sync()'s LOCAL_INV submission ahead of the
+	 * QP drain. Disconnect holds the write side across the drain
+	 * and resource teardown.
+	 */
+	struct rw_semaphore	rx_unmap_rwsem;
 };
 
 #define rpcx_to_rdmax(x) container_of(x, struct rpcrdma_xprt, rx_xprt)
@@ -479,6 +487,8 @@ extern unsigned int xprt_rdma_memreg_strategy;
  * Endpoint calls - xprtrdma/verbs.c
  */
 void rpcrdma_force_disconnect(struct rpcrdma_ep *ep);
+void rpcrdma_ep_get(struct rpcrdma_ep *ep);
+void rpcrdma_ep_release(struct rpcrdma_ep *ep);
 void rpcrdma_flush_disconnect(struct rpcrdma_xprt *r_xprt, struct ib_wc *wc);
 int rpcrdma_xprt_connect(struct rpcrdma_xprt *r_xprt);
 void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt);
-- 
2.34.1

