Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.217.102
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794335251;
	b=FrGmqmnt9zqSYbvwXaPS9ofr1UPw3BHoCIxPNjPBwaicTOv2Wjg/V+jpEk/GK2MBTqp3
	 asfiaPxcwsOCMjAgA5YhAFwDfWdOj6HI3A+KFOvDQjyApIslpcDhEOi5EMvHsdrshMfsP
	 bQn2PqEVdcpqFVcoZkAjqFIi9VaPDdTPYDVRp5YM0gpOvabw2nf8jvh66C6OM+X339dP4
	 HKM0YviXRfAwTwOBj/lv9j2E2Ocoxu3VW51dp+6CGOGsAq+6//HosdZm9hj++aUCG1P3+
	 VqpAO0LQarFkMwlR2mVQL5Lzj+amWkfPeGNtQxKvJKaTjDwXdve3u8apPrH7TD9FkqA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794335251;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=A9nW4gBRQ7p3qjyRgRM3UciraxXFsrpIYFBq4XXuWVU=;
	b=t02zXhbEOuXkAPrytLoKN8aKCxVOdobqtp8l1PZKRGbyYeRGRoACHx0qXeTQi1aJtxqm
	 IpjrnpVooeHE8gy69Hu9IenYTfGK0JbCUuiYZbhmIa77qDtxSEo+RWPv9KRuN5nyAEi2i
	 XVkn5Kr6GnX13jsfQDzRd5dhnCL+46OBShMQ/3tXOXdUQS2iA0hAN1fNejyob6HWtdROf
	 ALDsvWcdUc551NkbxqVmf8apKqonL47gqWocvMjByAsE2AQrFr2ytqDAOR5jFZT/IxG78
	 hKWexCqWQh1QSyMosvE7XLdTfw8RFL4DGEPU/7JJSWKI+7Dkav3Ss45Dv88snici5hA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=everpuredata.com;
	spf=pass smtp.mailfrom=everpuredata.com;
	dkim=pass header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=tWZQLAqw;
	arc=none smtp.remote-ip=209.85.217.102
Received: from mail-vs1-f102.google.com (mail-vs1-f102.google.com [209.85.217.102])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E8CE0606A31C
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 18:27:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E8CE0606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=tWZQLAqw
Received: by mail-vs1-f102.google.com with SMTP id ada2fe7eead31-7d2d95c5d81so1597554137.0
        for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 10:27:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1794335249; x=1794940049; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=A9nW4gBRQ7p3qjyRgRM3UciraxXFsrpIYFBq4XXuWVU=;
        b=tWZQLAqwvQHOVCGb59TnxeQlzI4KYVXkF/wDo12LF3Zg0bj352ut63TpfvDNfGiYRe
         uHbYNVx5dkVxVKngprSw3g0s6LVOHl1vUaOat/20jfjdZXKyXJg+WUN4TuBxetOBZWji
         FHkIywAWkrU4CD6geQdC4wOWLjf7pAiZ/bHvpGPn0Oj07CJW3Q2pNGZ1ep+DG0mE4hMg
         M7gDrU2iPV0SLCfBnr/3eKn2DoQB6EMKnuWikwKuIZEn7Nh26LNVOsaT+mSnmR6ElhLK
         AE53drtbELgLMZjhlSHV/25FrNcULRJ5K5OFOrvf265A0qT2saJkwNNOoQyLm+axQ7Rx
         fzBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794335249; x=1794940049;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=A9nW4gBRQ7p3qjyRgRM3UciraxXFsrpIYFBq4XXuWVU=;
        b=KLRgX7q0FaKgWmd8EVRjgnOmKmLL/pxwkXO6b6nrrnaouBGobKuswmPj7U4FYE9CxS
         QOfrKdWRMp3boogBm3XIuWXmURmeg+tSKHpQZNHxxw8BtqHEx67HtFuX1mQRESV7/4zt
         hb9oAWMBnzQ7Fr4YEhKs86+CcIij+e7eoX8GDBxyCKC5mL/GfiJGHaWiYA5f2mCiV5tr
         52Cu3+kD1VU21N3AAplh9t9TCgnKb0TKODT3zkE47zAhAtRS5o7L9Pyz6+FkcBZdJjLC
         SA1saplBXw/DbaVYjkaTXv5PfEMN04O12kUUJEkWCxnnqdzbVaKeNcNFA9KMkyUkoD/Z
         zuSg==
X-Forwarded-Encrypted: i=1; AL+hErGFf3mBQue5CK8on9eKys3s10wJ3EPFTxOva6Fvvw1zTwW1DQ+jhGjyiWRZdai/0ZmOnJ08xnaakc4=@vger.kernel.org
X-Gm-Message-State: APuU4Z+vpTPW0FQQR7C0Fi8OL7DphKdnf0ycIKP2sqlC5MJTJudrV71Z
	AIO2KmKSEMN5AWqwCqvL3V+OVn8KUfIy6SShINaIk6E2CANEGDbj5aGVwFf56lpHgOGh1KVv1rT
	FT0JWdZ06zsr97lTWw7Pvg1agDvpAMCG/8Cf6
X-Gm-Gg: AYBFou0XHJeys9QN3uXFHDwmZFnC08lrIBEvQ7qYooz1vU+YOyFqVzzcdUwIAosczkk
	r5USjJj5AgZ5lST845NqdNkGtMmudlFk0hwqL7i/6BMlNZ3dUqbR3qCA1eohqE3vcS8/7XIq4ob
	QDl+LkmqpM0KV/Lz6WFmqc150pSVeYH7EcpBOhrMbEmpDR3GDmJX2AJBCYOd0ms5sSMA1DyY7u5
	WXg0gqyKVvcok0OpBWfEQAF2W5bQg5docr00vd2zKUJBrTNIW8166LA3vQNOJlYYdQfgi5oSaNd
	9Xschb6Q++pDY3EknCGQScgWLpHaoff9ElHSrF3jPk3d4u2zYEVNdTu7R+b9YGarvGogyTnQt3e
	anUkSzCfLuL4IeBSSuTI1ibbFILgBELTjpb7ym4M=
X-Received: by 2002:a05:6102:f0a:b0:7d2:d209:7af8 with SMTP id ada2fe7eead31-7d494e6c4femr144451137.19.1794335248751;
        Tue, 10 Nov 2026 10:27:28 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id ada2fe7eead31-7d302339075sm25359137.5.2026.11.10.10.27.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 10 Nov 2026 10:27:28 -0800 (PST)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id DB7CF34039E;
	Tue, 10 Nov 2026 10:27:27 -0800 (PST)
From: Tim Menninger <tmenninger@everpuredata.com>
To: anna@kernel.org,
	trondmy@kernel.org
Cc: cel@kernel.org,
	Rakesh.Bhargava@netapp.com,
	ebadger@everpuredata.com,
	jcurley@everpuredata.com,
	linux-nfs@vger.kernel.org,
	mora@netapp.com,
	slingappa@everpuredata.com,
	stable@vger.kernel.org,
	tmenninger@everpuredata.com,
	tom@talpey.com
Subject: [PATCH v6] xprtrdma: serialize unmap_sync with xprt_disconnect
Date: Tue, 10 Nov 2026 18:27:27 +0000
Message-ID: <20261110182727.1739245-1-tmenninger@everpuredata.com>
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
request, whose lifetime covers xprt_rdma_free(). This allows disconnect
to destroy MRs after draining the QP while frwr_unmap_sync() is still
waiting. On a post failure, call rpcrdma_force_disconnect() before
dropping the read side so the endpoint is not dereferenced after
disconnect can run.

frwr_unmap_async() runs inline from Receive completion processing.
rpcrdma_xprt_drain() drains the Receive Queue before the Send Queue, so
asynchronous LOCAL_INV Work Requests are submitted before Send Queue
drain. frwr_unmap_sync(), however, runs from xprt_rdma_free() after the
transport send lock has been released, so it is not ordered against
disconnect.

Tested on v7.4-rc1 under pNFS load with repeated data server restarts
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
Changes in v6:
- Call rpcrdma_force_disconnect() before dropping the rx_unmap_rwsem
  read side so @ep is not used after the rwsem is released, and drop
  the endpoint reference that frwr_unmap_sync() held across the
  completion wait.
- Remove rpcrdma_ep_release(), the rpcrdma_ep_get() export, and their
  kernel-doc and restore the original rpcrdma_ep_get()/rpcrdma_ep_put()
  definitions and comments.
- Restore the original "On return" paragraph in the
  rpcrdma_xprt_disconnect() kernel-doc.
- Update the commit message to match.

v5: https://lore.kernel.org/all/20261106142039.1066437-1-tmenninger@everpuredata.com/

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

 net/sunrpc/xprtrdma/frwr_ops.c  | 89 ++++++++++++++++++++-------------
 net/sunrpc/xprtrdma/transport.c |  2 +
 net/sunrpc/xprtrdma/verbs.c     | 16 ++++--
 net/sunrpc/xprtrdma/xprt_rdma.h | 10 +++-
 4 files changed, 78 insertions(+), 39 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index e83cef19e6569..97034a3b5141d 100644
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
@@ -539,40 +542,60 @@ static void frwr_wc_localinv(struct ib_cq *cq, struct ib_wc *wc)
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
+	if (!ep || list_empty(&req->rl_registered)) {
+		up_read(&r_xprt->rx_unmap_rwsem);
+		return;
+	}
+
 	/* ORDER: Invalidate all of the MRs first
 	 *
 	 * Chain the LOCAL_INV Work Requests and post them with
@@ -599,37 +622,35 @@ void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
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
+	if (rc) {
+		/* On error, the MRs get destroyed once the QP has drained. */
+		trace_xprtrdma_post_linv_err(req, rc);
+
+		/* Force a connection loss to ensure complete recovery.
+		 */
+		rpcrdma_force_disconnect(ep);
+	}
+	up_read(&r_xprt->rx_unmap_rwsem);
 
 	/* The final LOCAL_INV WR in the chain is supposed to
 	 * do the wake. If it was never posted, the wake will
 	 * not happen, so don't wait in that case.
 	 */
 	if (bad_wr != first)
-		wait_for_completion(&mr->mr_linv_done);
-	if (!rc)
-		return;
-
-	/* On error, the MRs get destroyed once the QP has drained. */
-	trace_xprtrdma_post_linv_err(req, rc);
-
-	/* Force a connection loss to ensure complete recovery.
-	 */
-	rpcrdma_force_disconnect(ep);
+		wait_for_completion(&req->rl_linv_done);
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
index 54957295a6310..620afff79effa 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -572,20 +572,24 @@ int rpcrdma_xprt_connect(struct rpcrdma_xprt *r_xprt)
  * rpcrdma_xprt_disconnect - Disconnect underlying transport
  * @r_xprt: controlling transport instance
  *
- * Caller serializes. Either the transport send lock is held,
- * or we're being called to destroy the transport.
+ * Context: Caller serializes. Either the transport send lock is held,
+ *	    or the transport is being destroyed. Takes and releases
+ *	    @r_xprt->rx_unmap_rwsem for write. May sleep.
  *
  * On return, @r_xprt is completely divested of all hardware
  * resources and prepared for the next ->connect operation.
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
@@ -604,6 +608,9 @@ void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)
 		rdma_destroy_id(id);
 
 	r_xprt->rx_ep = NULL;
+
+out_unlock:
+	up_write(&r_xprt->rx_unmap_rwsem);
 }
 
 /* Fixed-size circular FIFO queue. This implementation is wait-free and
@@ -927,6 +934,7 @@ struct rpcrdma_req *rpcrdma_req_create(struct rpcrdma_xprt *r_xprt,
 
 	INIT_LIST_HEAD(&req->rl_free_mrs);
 	INIT_LIST_HEAD(&req->rl_registered);
+	init_completion(&req->rl_linv_done);
 	spin_lock(&buffer->rb_lock);
 	list_add(&req->rl_all, &buffer->rb_allreqs);
 	spin_unlock(&buffer->rb_lock);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 4cbc941e4a3eb..b3016e1eb1723 100644
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

base-commit: 6628e7d4c6b25c8d18f1345e3a20d21829aae7e4
-- 
2.53.0

