Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792860403;
	b=pm3hQ4Ln5FiFpVczBEi38FToYQT6lVxx5RiJHyU34JOe6enxTuvBVxQn4puhd0YJ9A5X
	 rulJjjniU7IKHXRsZLPorMzvSmH3DVKmnUvY//Wpo+Vd0rdjz4f9WIsbGW+m1ED+61c9i
	 qr88CYJDoXN5v/iHPKBDuZ/+JI8gvJBJ7vd30PldqdKFDMP5eywnyq6vIa4Ks+0cyzwv0
	 fwh0j2j+NG6emc/3QG4j3D49RWaIuUJaO0ElfCWam8AMSg4U7m7NRr+scMDm5OYbVDATv
	 N9hZUjJA87oTaHr1Tq0AnvsxJdLCOI3rPyrRjBAuW6TUzqiMX6BczciyZwdFxA1x2QQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792860403;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:
	 X-Google-Original-From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=hVMPTqE+AvdxWQmhKptXflgDLkzfz95f7AxrV7OxPJw=;
	b=QecJk2QY3qbyEODkk+eCADKnCL4H71zFdNl7xJEXPRppfQqc1oUCLB1dE3Z7WR+ckJLa
	 CZr5IcdefEPCw/MAuvQB/Yf2POsauNRMm27Cq8sAT//U+HhjZNSpf2dFR5XSvYKmnIWg0
	 xMiu50WqQSQTaD/o6Tn8jGjj4htr1B5jKQqNXtT/iTOdIQKlPYUhas2FWvsAhpe15Msxz
	 bjx0LpcH70OuajYlrLOJcyklG+ybzHdVriD85w9u2ypMMsA1xClTmqSrTgPX8bQS5FmmN
	 pzN4Wc4z2YFvReF2FTZLg/6aGDBPtmoF0teo+IdgE4uC/3CA7aKtUpWEzPoFHIBi5tg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=JNYG1Zcm;
	arc=none smtp.remote-ip=209.85.210.51
Received: from mail-ot1-f51.google.com (mail-ot1-f51.google.com [209.85.210.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 97BC0606A31A
	for <linux-nfs@vger.kernel.org>; Sat, 24 Oct 2026 16:46:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 97BC0606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=JNYG1Zcm
Received: by mail-ot1-f51.google.com with SMTP id 46e09a7af769-846566246e8so1525412a34.1
        for <linux-nfs@vger.kernel.org>; Sat, 24 Oct 2026 09:46:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792860401; x=1793465201; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=hVMPTqE+AvdxWQmhKptXflgDLkzfz95f7AxrV7OxPJw=;
        b=JNYG1ZcmWejtdvNxcuHGLvxjhmdi3qvmfALDE3DUAGSgNHT5KYvt0VQWkCdcAZy2xz
         oV6rYZtH2N98/NFLn0NmeRotOoW9tgUcSAyIAEd6+HYAWu5uf9abkkxRN/nMMkODobT+
         5MSTMymm/BADPVrO1VvCp6XmeCHrjirsY60W8OMmt8jdT94OUiFzJ64QW/nZWDYnBly8
         lUucZ5rLzIOM+KRiSPFy61N9UZkGqO64viz06AavxBNoDXHiRLzOevpd6kTqoFbesl4P
         Xnpuk/RhukyRVNXRZBDWjCtpcilEvDwR6OkujMRZcvi0m//Mtrp+iaDR8K6g71W2b1no
         bSOg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792860401; x=1793465201;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=hVMPTqE+AvdxWQmhKptXflgDLkzfz95f7AxrV7OxPJw=;
        b=hL8soRXbr0k9SWf2DCD6uZdcERZ2zz0p/cxqM7iqG6o4UclakJqVhE8BafxX2ys0y4
         c6Os7oWMBmMuESqAPvjoq0mfSiEMF3QMl6sqK2DN8VbYWtE6PbF0GViVq8+Jpbz+kCDM
         iOvLDvo4vFrso5aRBHOiLzQcCmEe1fa9z2F+RG9QIGUpj/kfESGYlkesWKpgB+dJSlM9
         1xUhG2g2E9wiv0+ekRRr5SqLASM7vic4YT2eKorIfbKYUSUuL8eWuZQ3vVcPAqlknC9Y
         ndBcRa8qNeqMlOqJ5XXCnX/qBzL2RCYa4B3C5agKYM79tm7g6FAiSUkzUopzwazTRsbz
         /mqg==
X-Gm-Message-State: AFq9FYKhxHQdigfzijTL8vnQHhM/mBZgTLwGgdAlAaPLUivK7yKWA2T4
	pP0EJdgeLkGAP2NJq4YM5OSioYOrnz0llBg/OkKMYC5q4UV8+/qHgcW5dNrUWA==
X-Gm-Gg: AYBFou3Z9T/ZiOefqrmkC9YOtRmAtaWBrQLjfpv/NqBB5ZPhg+cDSBrq+uuxJSwc0WL
	cs8oiye74875NgWbe2xs5hZUP5Q6tbKixUK1wOl09ibbuiYDBzOEdLhyJpdYbGzcksOfBaaaJBF
	POAWWxxx3x0P3wdQL/M1yq6cdeXtfIPzzUyxHioKDdjk/LpRcRQDM24eMlxiQohORUJ/WB+p5GM
	yb2phxYTRvpSfR5vBDVLgMg14fnC3pR1An3OBMnzDd7YXgx5ZqDo/gHNBPc58sCxWlu17ttjNr8
	nsiVVZDLb8EA0Q/az8SOFJSuWcv6Fb+zcxCefj+NFumJbWyE8T8TyrtQrswYQlgeZfYdtV9N5zX
	5MFfUR7rb4hg3j4T3ZFKudAh5M6yGG+0RK2c9SkWIzfg/AnhpXVeCmbfWODjwVUl+xrBucLX7ZM
	g/CmSnYl4fts4HPF7tlILmxXElHgSx/mUe3KAcF+vmtkiOAtrK1ltXk/7tWiPJb77sn2nmboF80
	e8IlbSa3m00VJbU1VVgYMbVE/9V180DpBloAPCOV2by03HW25PKGnMJD+N/i/QuhcIY3YZY4ZiX
	FVShEyk=
X-Received: by 2002:a05:6830:3489:b0:81b:9104:5ad0 with SMTP id 46e09a7af769-850f8b303b5mr1479928a34.0.1792860401432;
        Sat, 24 Oct 2026 09:46:41 -0700 (PDT)
Received: from localhost.localdomain ([192.63.62.92])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-850fb0749dcsm2587443a34.11.2026.10.24.09.46.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 24 Oct 2026 09:46:41 -0700 (PDT)
From: Jorge Mora <jmora1300@gmail.com>
X-Google-Original-From: Jorge Mora <mora@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: trondmy@kernel.org,
	anna@kernel.org,
	Rakesh.Bhargava@netapp.com,
	Mohit.Kumar@netapp.com,
	mora@netapp.com
Subject: [PATCH] xprtrdma: fix race between frwr_unmap_sync() and transport disconnect
Date: Sat, 24 Oct 2026 10:46:33 -0600
Message-ID: <20261024164633.256458-1-mora@netapp.com>
X-Mailer: git-send-email 2.47.3
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

Other consequences of the same race are a use of ep after
rpcrdma_ep_put() frees it, and rpcrdma_flush_disconnect() dereferencing
r_xprt->rx_ep after disconnect cleared it.

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
   under rb_lock before dropping the ep reference.
 - rpcrdma_flush_disconnect() tolerates a NULL rx_ep.

Signed-off-by: Rakesh Bhargava <Rakesh.Bhargava@netapp.com>
Signed-off-by: Jorge Mora <mora@netapp.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  | 43 ++++++++++++++++++++++++++------
 net/sunrpc/xprtrdma/verbs.c     | 44 ++++++++++++++++++++++++++++++---
 net/sunrpc/xprtrdma/xprt_rdma.h | 14 +++++++++++
 3 files changed, 90 insertions(+), 11 deletions(-)

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
index be335eed329d..8848cebc42b2 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -133,8 +133,14 @@ void rpcrdma_force_disconnect(struct rpcrdma_ep *ep)
  */
 void rpcrdma_flush_disconnect(struct rpcrdma_xprt *r_xprt, struct ib_wc *wc)
 {
-	if (wc->status != IB_WC_SUCCESS)
-		rpcrdma_force_disconnect(r_xprt->rx_ep);
+	struct rpcrdma_ep *ep = READ_ONCE(r_xprt->rx_ep);
+
+	/* A flushed completion can be processed after the disconnect
+	 * path has already divested the transport of its endpoint.
+	 * In that case the connection is already gone.
+	 */
+	if (wc->status != IB_WC_SUCCESS && ep)
+		rpcrdma_force_disconnect(ep);
 }
 
 /**
@@ -580,6 +586,7 @@ int rpcrdma_xprt_connect(struct rpcrdma_xprt *r_xprt)
  */
 void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)
 {
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 	struct rpcrdma_ep *ep = r_xprt->rx_ep;
 	struct rdma_cm_id *id;
 	int rc;
@@ -591,16 +598,42 @@ void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)
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
 	rpcrdma_mrs_destroy(r_xprt);
 
+	/* Unpublish the ep before dropping the last reference to it
+	 * so that frwr_unmap_sync() never picks up a stale pointer.
+	 */
+	spin_lock(&buf->rb_lock);
+	r_xprt->rx_ep = NULL;
+	buf->rb_closing = false;
+	spin_unlock(&buf->rb_lock);
+
 	if (rpcrdma_ep_put(ep))
 		rdma_destroy_id(id);
-
-	r_xprt->rx_ep = NULL;
 }
 
 /* Fixed-size circular FIFO queue. This implementation is wait-free and
@@ -1168,6 +1201,9 @@ int rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 
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

base-commit: 18a80121193c6d19519e218434c9acf90e8d0e5c
-- 
2.47.3

