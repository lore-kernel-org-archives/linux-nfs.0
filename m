Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.52
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793920922;
	b=24Ll2u8ZHZYfX2odBtDFwW5QiVFIeY12MQS9Dqto2hw2P4e2jLHHBQ6ax2c/iHQQPCCz
	 avKpxhOpjwonPu3F+r9euDeK/HdWGBfnFSz+zCWV8cckJ8ReI4FxPgW3MsZrQp9te5nZf
	 xIFpcynj9cxBK5vvrp3xX17fSi5yiitoaGYYb5Lt9/FRodY/yyg1IKgPpffEFQthYGTqJ
	 uUEXXu55C8yAix6lTeyTE2ZgzxAQrr5ZZoS1BZASfn/qzHUWCYyZVKnAIs+WEqnrqYis/
	 xl+znbjsnXN02eXgg8Hsh2VFZ88fNZ4UVKOQYZ5le5X2Ik4RHW8wYVsDTx4jEwa6aJQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793920922;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:
	 X-Google-Original-From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=y1zQ+4cFK5JvWjYX6XtFePLCtfXcVQN4627X0niiLQc=;
	b=kHfq6J9sWxlKOPeybZYC9Nb+vtpdBH3HmpH4y6H892kHfjpQ0zpM4kkLlUqjwxiuD9SD
	 cY9+GgnOBStp2Amp3pKA8QXNULJtfGaoybpNNBPQrETQ4yZFMVHNLVISqTIVmxohGCJKW
	 vuoSucdJrjS/NJaRPVdAcyB87zNE9x2PSmryxtbpXGx71kO7TU7XE+ybKiO4P/cNH1NT9
	 y+VR/k9x/Sb8rzwvsqS0MooYe8wO39UIyj0K6xkwUGBDGw4XG71zi+E8sQjRJlDPw6335
	 5RZ9zvDtVCvTDrTsapYpuKrHnvM6aDLm641a/708OFMN+vLRACJBn9hryiIuvm7sO6w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=cBYN+L7L;
	arc=none smtp.remote-ip=209.85.161.52
Received: from mail-oo1-f52.google.com (mail-oo1-f52.google.com [209.85.161.52])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 00CEB606A31B
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 23:22:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 00CEB606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=cBYN+L7L
Received: by mail-oo1-f52.google.com with SMTP id 006d021491bc7-6f5a0893610so82491eaf.1
        for <linux-nfs@vger.kernel.org>; Thu, 05 Nov 2026 15:22:01 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793920921; x=1794525721; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=y1zQ+4cFK5JvWjYX6XtFePLCtfXcVQN4627X0niiLQc=;
        b=cBYN+L7L3AoQKYdguR132jfd1Rg5lW9v2Wf+PDjVH0JBWnWNGL3jgdfLDPl6RlnU/f
         oFy6T/cYonMaBN8PXqka2zsJ6qNTD1/YEJdR1VAtmPvx6rtPHD2cj+Y32y4U92ZtrutU
         u+O8JAcbX1JpnY4ANt44UG19pDhXVHtCW/su6MDogTLP4Y0QKKZSEnVA3sg9Y13twUiI
         rR2QVY6eaSBLcuTShD1bNHX/BSaTB6NZsbQaxSDhE05vD/naG97QWmvmCQ8+HA/VnNhr
         ueya0twYQVvmr/dy9eaB6nUL9Z9emuGxeiB8iIQcEx4RWke4DREQ/OVoDBfSobx39ZgU
         x+AQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793920921; x=1794525721;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=y1zQ+4cFK5JvWjYX6XtFePLCtfXcVQN4627X0niiLQc=;
        b=l23Apjl4QRqjfz1/Eq01bVCob87ho4j38ls2+v3huoCGcc3mFZlrtZQZtnO5Zl7haU
         joAf7tfH+/MyTK5eIIGIbWFhLzMYyZomiLEmV93w07XBZuuvMjylX+EJSomm4NgaA3fu
         3ofE9DZ6vmkbkP7OdNFbwuCBmqyKfK1Lc2ZKokrPQOBuVlbfnigOxDfAuYQk1bw8vgFs
         /ek26absR/9wpEyEOZPs373SwnQOz9svqJWcLXBGhSWFGVd71wVFq/ES8VAaP/d5wNjR
         KQtUGw/rngoYQsmRv4UfpBUpcyem4DGI51DqGROk0JN/Tv8y/F7DFU7CjNHMZULDk3Gz
         8s8w==
X-Gm-Message-State: APuU4Z/C/fUYHi6O4J8ozsNXEGx1IHM2x7ZwVMQ4zSC6vWYB8HD+cRlo
	q1dUu+P2xABvAEx5Q5iV9x2caVwP6jb504sIAtBStAnIcAajxFgQDmaGSLvojg==
X-Gm-Gg: AYBFou2SN+43R/oz0RFqlBKHw4LyzC82eCQCHVIxFUTGu9v0mbqDX9Cu7rjWpwT9QBV
	2s8d38YuyTluM65iZK2hNv8NImAmgsCIlzYsPO97cISfOb+TbY6YWTarbv/mUeMw7DRqQpUVBiY
	mCszRc2NxXqafQ2h9ytHB0/0POyLlePUYRI4JdPEYQnbK2bdu8+LovCOd0RYmlxrM/mRhc+eFCH
	PQd8808imUgIFtcWeGhYR/eSvpyJaWWRjribXi9dxQxjMFrVujLG4kw6KU+Q7G0C8xXdwmf2EWy
	FTfCmd8xC5j4z+MgrOyseA8Lf3Ii0mMJPICq/r78IajXZdnRf9O7WOnXpxsoapChkKDBejNcKaB
	fDa5rGTYStS0EMGdMiXn9eptqfERjezi9/NOZlKi0CfmsYSgrAlzIVWsLCVuby76hZNrVJjdIiD
	Y5VQFGujm1BRcWOkDir1kLIP39WN6bnSZtozFXRrMx9kkCun+5WrFqsEj2IUnWCIE1yz0CPc8L+
	0YpLtc4Ltq+pdJTu9tK6oV7B7Sxxv8Lz4QrKbd79mIzq5sWky8Hb+dEIyZWPvL4XPn4ULyFt6XT
	YHFO4cXiHhl5qV5ZW0qKz8z/DurWi4gmssBK
X-Received: by 2002:a05:6820:7612:b0:713:e433:f41a with SMTP id 006d021491bc7-716e7912e15mr624216eaf.25.1793920920825;
        Thu, 05 Nov 2026 15:22:00 -0800 (PST)
Received: from netapp30 ([192.63.62.92])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-716ea16753csm478202eaf.13.2026.11.05.15.21.59
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Nov 2026 15:22:00 -0800 (PST)
From: Jorge Mora <jmora1300@gmail.com>
X-Google-Original-From: Jorge Mora <mora@netapp.com>
To: linux-nfs@vger.kernel.org,
	cel@kernel.org
Cc: trondmy@kernel.org,
	anna@kernel.org,
	Rakesh.Bhargava@netapp.com,
	Mohit.Kumar@netapp.com
Subject: [PATCH v2] xprtrdma: fix race between frwr_unmap_sync() and transport disconnect
Date: Thu,  5 Nov 2026 16:21:37 -0700
Message-ID: <20261105232137.4706-1-mora@netapp.com>
X-Mailer: git-send-email 2.52.0
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

From: Rakesh Bhargava <Rakesh.Bhargava@netapp.com>

frwr_unmap_sync() is called from xprt_rdma_free() via ->buf_free, which
xprt_release() invokes without holding the transport send lock and
without XPRT_LOCKED. rpcrdma_xprt_disconnect() runs from xprt_autoclose()
under XPRT_LOCKED and, after draining the QP, resets every rpcrdma_req
(rpcrdma_reqs_reset) and destroys every MR (rpcrdma_mrs_destroy). Nothing
orders the two, so both can walk and list_del() the same req's
rl_registered list and the same MRs. Observed on RHEL 10.2
(6.12.0-211.7.3.el10_2) NFS/RDMA FlexFiles clients as:

  kernel BUG at lib/list_debug.c:65!
  frwr_unmap_sync+0x75 [rpcrdma]
  xprt_release+... [sunrpc]

In a vmcore, the panicking task was in frwr_unmap_sync() for r_xprt X
while another kworker was in xprt_autoclose -> rpcrdma_xprt_disconnect
-> rpcrdma_reqs_reset -> frwr_mr_release for the same r_xprt X. The
window was large because 256 transports were being torn down at once,
each blocked in mlx5_core_destroy_mkey waiting on firmware.

Fix it by making frwr_unmap_sync() and disconnect cooperate through
rb_lock:

 - frwr_unmap_sync() reads rx_ep, checks rb_closing and that
   rl_registered is non-empty, and claims all of the req's MRs under
   rb_lock. It bumps rb_unmap_users while it still references the MRs
   and the ep, and drops it (waking rb_unmap_wq) when done.
 - If rb_closing is set, frwr_unmap_sync() returns and leaves the MRs on
   rl_registered. rb_closing is only set after rdma_disconnect(), when
   the QP is in the error state and the peer cannot reach the MRs;
   rpcrdma_reqs_reset() then releases them.
 - rpcrdma_xprt_disconnect() sets rb_closing after rdma_disconnect(),
   waits for rb_unmap_users to reach zero after draining the QP and
   before releasing reps, reqs and MRs, and clears rx_ep and rb_closing
   together under rb_lock after dropping the ep reference.

Signed-off-by: Rakesh Bhargava <Rakesh.Bhargava@netapp.com>
Signed-off-by: Jorge Mora <mora@netapp.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  | 43 +++++++++++++++++++++++++++------
 net/sunrpc/xprtrdma/verbs.c     | 31 ++++++++++++++++++++++++
 net/sunrpc/xprtrdma/xprt_rdma.h | 14 +++++++++++
 3 files changed, 81 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index e83cef19e656..03e0e6c475b1 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -567,12 +567,33 @@ static void frwr_wc_localinv_wake(struct ib_cq *cq, struct ib_wc *wc)
  */
 void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 {
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 	struct ib_send_wr *first, **prev, *last;
-	struct rpcrdma_ep *ep = r_xprt->rx_ep;
 	const struct ib_send_wr *bad_wr;
+	struct rpcrdma_ep *ep;
 	struct rpcrdma_mr *mr;
 	int rc;
 
+	/* This function is invoked via ->buf_free, which does not
+	 * hold the transport send lock. It therefore races with
+	 * rpcrdma_xprt_disconnect(), which resets every req and
+	 * destroys every MR.
+	 *
+	 * Claim the req's MRs, and pin the transport's ep, under
+	 * rb_lock. If the disconnect path has already put the QP
+	 * into the error state, leave the MRs on rl_registered:
+	 * the peer can no longer reach them, and
+	 * rpcrdma_reqs_reset() releases them.
+	 */
+	spin_lock(&buf->rb_lock);
+	ep = r_xprt->rx_ep;
+	if (buf->rb_closing || !ep ||
+	    list_empty(&req->rl_registered)) {
+		spin_unlock(&buf->rb_lock);
+		return;
+	}
+	buf->rb_unmap_users++;
+
 	/* ORDER: Invalidate all of the MRs first
 	 *
 	 * Chain the LOCAL_INV Work Requests and post them with
@@ -598,6 +619,7 @@ void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 		*prev = last;
 		prev = &last->next;
 	} while ((mr = rpcrdma_mr_pop(&req->rl_registered)));
+	spin_unlock(&buf->rb_lock);
 
 	mr = container_of(last, struct rpcrdma_mr, mr_invwr);
 
@@ -621,15 +643,22 @@ void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	 */
 	if (bad_wr != first)
 		wait_for_completion(&mr->mr_linv_done);
-	if (!rc)
-		return;
+	if (rc) {
+		/* On error, the MRs get destroyed once the QP has drained. */
+		trace_xprtrdma_post_linv_err(req, rc);
 
-	/* On error, the MRs get destroyed once the QP has drained. */
-	trace_xprtrdma_post_linv_err(req, rc);
+		/* Force a connection loss to ensure complete recovery.
+		 */
+		rpcrdma_force_disconnect(ep);
+	}
 
-	/* Force a connection loss to ensure complete recovery.
+	/* The MRs and the ep are no longer referenced. Allow
+	 * rpcrdma_xprt_disconnect() to proceed.
 	 */
-	rpcrdma_force_disconnect(ep);
+	spin_lock(&buf->rb_lock);
+	if (!--buf->rb_unmap_users)
+		wake_up(&buf->rb_unmap_wq);
+	spin_unlock(&buf->rb_lock);
 }
 
 /**
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 54957295a631..b0c42cbe38ec 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -580,6 +580,7 @@ int rpcrdma_xprt_connect(struct rpcrdma_xprt *r_xprt)
  */
 void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)
 {
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 	struct rpcrdma_ep *ep = r_xprt->rx_ep;
 	struct rdma_cm_id *id;
 	int rc;
@@ -594,7 +595,27 @@ void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)
 	rc = rdma_disconnect(id);
 	trace_xprtrdma_disconnect(r_xprt, rc);
 
+	/* The QP is in the error state now, so the peer can no
+	 * longer access any registered MR. From here on, a
+	 * frwr_unmap_sync() caller that has not yet claimed a req's
+	 * MRs leaves them on rl_registered: rpcrdma_reqs_reset()
+	 * releases them below.
+	 */
+	spin_lock(&buf->rb_lock);
+	buf->rb_closing = true;
+	spin_unlock(&buf->rb_lock);
+
 	rpcrdma_xprt_drain(r_xprt);
+
+	/* frwr_unmap_sync() runs without the transport send lock.
+	 * Callers that claimed MRs before rb_closing was set may
+	 * still be posting or waiting on LOCAL_INV Work Requests.
+	 * Those complete (or flush) because the QP has been
+	 * drained, but the callers still reference the MRs and the
+	 * ep, so wait for them before anything is released.
+	 */
+	wait_event(buf->rb_unmap_wq, !READ_ONCE(buf->rb_unmap_users));
+
 	rpcrdma_reps_unmap(r_xprt);
 	rpcrdma_sendctxs_destroy(r_xprt);
 	rpcrdma_reqs_reset(r_xprt);
@@ -603,7 +624,14 @@ void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)
 	if (rpcrdma_ep_put(ep))
 		rdma_destroy_id(id);
 
+	/* rb_closing stays set until rx_ep is cleared, so a late
+	 * frwr_unmap_sync() caller returns before it can use a stale
+	 * rx_ep.
+	 */
+	spin_lock(&buf->rb_lock);
 	r_xprt->rx_ep = NULL;
+	buf->rb_closing = false;
+	spin_unlock(&buf->rb_lock);
 }
 
 /* Fixed-size circular FIFO queue. This implementation is wait-free and
@@ -1171,6 +1199,9 @@ int rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 
 	buf->rb_bc_srv_max_requests = 0;
 	spin_lock_init(&buf->rb_lock);
+	buf->rb_closing = false;
+	buf->rb_unmap_users = 0;
+	init_waitqueue_head(&buf->rb_unmap_wq);
 	INIT_LIST_HEAD(&buf->rb_mrs);
 	INIT_LIST_HEAD(&buf->rb_all_mrs);
 	INIT_WORK(&buf->rb_refresh_worker, rpcrdma_mr_refresh_worker);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 4cbc941e4a3e..0161317e4916 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -402,6 +402,20 @@ struct rpcrdma_buffer {
 	u32			rb_bc_max_requests;
 
 	struct work_struct	rb_refresh_worker;
+
+	/* Serializes frwr_unmap_sync(), which runs from ->buf_free
+	 * without holding the transport send lock, against
+	 * rpcrdma_xprt_disconnect(). Protected by rb_lock.
+	 *
+	 * rb_closing: the QP is in the error state and the disconnect
+	 *	path is about to reset all reqs and destroy all MRs.
+	 * rb_unmap_users: number of frwr_unmap_sync() callers that
+	 *	own MRs taken from a req's rl_registered list, or have
+	 *	LOCAL_INV Work Requests outstanding on the QP.
+	 */
+	bool			rb_closing;
+	unsigned int		rb_unmap_users;
+	wait_queue_head_t	rb_unmap_wq;
 };
 
 /*

base-commit: ef30b3efb7e8bae94d790a6503a595e1051323e7
-- 
2.52.0

