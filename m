Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.101
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793974876;
	b=jUFj4KmbCod49WJC5msPji3l6DRLHEIfgzcJ6rEOzKZeFHydM/6F4SeEQSSrjjqM4hMe
	 2Oshmb1dv0SWu9htlEpmjQ2Cc3BEpem9V22OCv1/sEHFR0lJhb3Z/yVwFjpQO9rvqfLQW
	 goTu4juq5KKJm4k49g+ihvuSqvxjBMWZOR+YN+Zns/WisDMTQZUlKv+gEyVIAkBVXKm8J
	 +H6ShA6a+M0cpWocMqwEFCQldJ+O2xlq58nhT1jE0wpa/Ya0kJ7mmMe6lxCWkEk/jedWR
	 5IGkqQviJecBPjt3rVFx/SBCw9XyHeulI1XhFIVgU9NsjoKOrrS185tuKFtY/chVD+A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793974876;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=nGOR4tDkLacm4ZLrXHP/oAENb1HqDMQ1DZAzDXXud+k=;
	b=Ph+EYPYgdDlgMtMYdhgoXxs8k5n06sQk/0YKX4KyVWjFm+yMybO3jrMvfn0SELm2IfyG
	 BPVBh26QbZ4PXDcFDv2NDbaeBFIrJ70q3kvWFfULnJ8j9Gec4MoxDWRX9LMLlaFeLMlzL
	 LY7Vlww2FDRBW55yTd1vs3LWp0fQ5PLWD6OJP4djr7tvx3zxiB63AzWTihHMTqSq/E1vG
	 LmmOPN/fF4muUcO8zpleX8LYwsQ7Wi2P986685NB3BNSKnghJU91I0PxmP7V0FVwRwSGS
	 FVvPuTELbDxg2VPtXgnXrMIV6Q2J/0cz4sR2LnXDwB0PReADw7XjTCbby7PiDdDi+QQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=everpuredata.com;
	spf=pass smtp.mailfrom=everpuredata.com;
	dkim=pass header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=0Jc8amRn;
	arc=none smtp.remote-ip=209.85.128.101
Received: from mail-wm1-f101.google.com (mail-wm1-f101.google.com [209.85.128.101])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EFB9F606A329
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 14:21:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EFB9F606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=0Jc8amRn
Received: by mail-wm1-f101.google.com with SMTP id 5b1f17b1804b1-4a9a8d6cea8so6460065e9.1
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2026 06:21:14 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1793974873; x=1794579673; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=nGOR4tDkLacm4ZLrXHP/oAENb1HqDMQ1DZAzDXXud+k=;
        b=0Jc8amRnrlbSUFL7YLN1ZK0uiHpcC4jCvCpM+CIZlVTX13Qe8MheQ8fu33Lr02rNEM
         WLF0lUOyF6Sd9Z4OojxzfTRSVStZP9RvBGgZvEjFttNmjioHSfl6ZuCL3RmpbC048RFZ
         qxtO8rgzh0tcsIsYjR7fFkvOtJlEga+gJqVK3Gy7PU+f3rE9a/QInLjinktH64bEXoxt
         sE7H24AjOp/mPjbA3p4PYtrZIKLdLLYBQwtY+b2AnGIg9GpOXlU921TNeWiqM+lH6/hO
         dU5nfBN742hGH/yng4a1wZ/O1N3hAge8tDHmG51bShrVjkwylz4Dxu/u15IrncZG7NiM
         2Izg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793974873; x=1794579673;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=nGOR4tDkLacm4ZLrXHP/oAENb1HqDMQ1DZAzDXXud+k=;
        b=NGDWyg0w4VPvaaI0hc8x5+Nx2L7+kc+dGomK6uFsCUy/cQMVf7k1P0lyfKq4hpNVxw
         gNuuZjTF7v3GWxkSLFAFnstmjXJ+0onBV8dbjGExQ7FCtqdDZgSImugZRW/Kh4D5+ZTP
         hAR7saap5ovcUoVDTpSN6B1rC7TzscS95ZYO7guYL176HpowVSe78I81IU9w5H6RwJtT
         9RmZgx8PGvbs4NVn8s6fDTIjbsu5Zcds8JEb0dhQ39k0LifY/fooa/XrNEsQ0J7uELrN
         KcsNkV4u5tFzX9Zwnvmw/thZLQjZwe25874fuwB2LqxuOkv1Yz894YgWK1H3FtlUgFks
         un8w==
X-Forwarded-Encrypted: i=1; AKwUvBzzlXDOw2IcTVNq7dsP6nPZvoDJ+h5nwXP34REiBz/SKzW1LR0rppmID+LhOlU7mwbThrBX2IeWU08=@vger.kernel.org
X-Gm-Message-State: APuU4Z/GO98WPFoZE73OoEEknAsZDxdMHUZoOEZ6no9cjlEIU3WR6bO1
	kOXAQ1qkFrs4ZLEPmoBuEd+mfWSEO9xm3Fzv5wYNk5uvQRow9VmEcy6OAueGxFRCAEyyOwVRa78
	RXehWcYr2NdnuOOugyERHAxAh4MpH5Tzk6enN
X-Gm-Gg: AYBFou1rpXa8WDZffeSRZ4WRaeK78whKTyLUeECtYqP3zvwRQCxcAgDhH0C8ontzIJ3
	mC8d0OZQZOBBaYMJQ2opOs81px1SnIVa9SWgtn0pZHLPXdTjchXvXQdHOHNDXyV85kBjA/GCbgd
	RXEFysK0cCNEPel9dnwoMhgWqyOMJ186rDYY0EpdgmMNrZ6vaqHtxO3cOYw1osiksfjV82QP2nR
	MCV9+CSRgB1n5IVpfvlP3BbWHcUqchaYoURCNsoI0LDCCwGVj2JhvrGU1L0ogEAS59TcmNkEE17
	h9koGt6ah+hKeEo6CS3C3Wc/2hZJ9F4N2e0n7bahk2mgT/kgKAMKeks9V3ZiYkqsT+8I+BmuaO/
	GCvy0dS6nkwxS06Fxrqd/cgVHaZiJkxW9nRjLSQo=
X-Received: by 2002:a05:600c:8b05:b0:4a1:efbe:529c with SMTP id 5b1f17b1804b1-4b6dff855a6mr50997395e9.12.1793974872118;
        Fri, 06 Nov 2026 06:21:12 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.128])
        by smtp-relay.gmail.com with ESMTPS id 5b1f17b1804b1-4b56d6337f3sm12140885e9.0.2026.11.06.06.21.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 06 Nov 2026 06:21:12 -0800 (PST)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 1590A3404E1;
	Fri,  6 Nov 2026 06:20:40 -0800 (PST)
From: Tim Menninger <tmenninger@everpuredata.com>
To: anna@kernel.org,
	trondmy@kernel.org
Cc: cel@kernel.org,
	ebadger@everpuredata.com,
	jcurley@everpuredata.com,
	linux-nfs@vger.kernel.org,
	slingappa@everpuredata.com,
	stable@vger.kernel.org,
	tom@talpey.com
Subject: [PATCH v5] xprtrdma: serialize unmap_sync with xprt_disconnect
Date: Fri,  6 Nov 2026 14:20:39 +0000
Message-ID: <20261106142039.1066437-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.53.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
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
Changes in v5:
- Rebase onto v7.4-rc1. Resolve context conflict with commit
  0b5bb4e586f7b ("xprtrdma: prevent disconnect feedback during
  endpoint teardown") in rpcrdma_xprt_disconnect(). No functional
  changes.

v4: https://lore.kernel.org/all/20260823134640.3083136-1-tmenninger@everpuredata.com/

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
index e83cef19e6569..6a5d243167145 100644
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
@@ -539,40 +542,64 @@ static void frwr_wc_localinv(struct ib_cq *cq, struct ib_wc *wc)
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
@@ -599,37 +626,43 @@ void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
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
index d4e6746d8ecd3..e38637c2ec787 100644
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
index 54957295a6310..1e109600031c6 100644
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
@@ -572,20 +590,25 @@ int rpcrdma_xprt_connect(struct rpcrdma_xprt *r_xprt)
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
 
 	/* Prevent teardown-generated events from requesting another close. */
 	atomic_xchg(&ep->re_force_disconnect, 1);
@@ -595,6 +618,7 @@ void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)
 	trace_xprtrdma_disconnect(r_xprt, rc);
 
 	rpcrdma_xprt_drain(r_xprt);
+
 	rpcrdma_reps_unmap(r_xprt);
 	rpcrdma_sendctxs_destroy(r_xprt);
 	rpcrdma_reqs_reset(r_xprt);
@@ -604,6 +628,9 @@ void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)
 		rdma_destroy_id(id);
 
 	r_xprt->rx_ep = NULL;
+
+out_unlock:
+	up_write(&r_xprt->rx_unmap_rwsem);
 }
 
 /* Fixed-size circular FIFO queue. This implementation is wait-free and
@@ -927,6 +954,7 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt,
 
 	INIT_LIST_HEAD(&req->rl_free_mrs);
 	INIT_LIST_HEAD(&req->rl_registered);
+	init_completion(&req->rl_linv_done);
 	spin_lock(&buffer->rb_lock);
 	list_add(&req->rl_all, &buffer->rb_allreqs);
 	spin_unlock(&buffer->rb_lock);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 4cbc941e4a3eb..08dfe9414657c 100644
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

base-commit: 6628e7d4c6b25c8d18f1345e3a20d21829aae7e4
-- 
2.53.0

