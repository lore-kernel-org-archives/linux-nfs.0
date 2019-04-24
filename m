Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E723C10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D21D421773
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:39:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="U23VcLOl"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730464AbfDXNjk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:39:40 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:33671 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730419AbfDXNjk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:39:40 -0400
Received: by mail-it1-f195.google.com with SMTP id v8so5383697itf.0;
        Wed, 24 Apr 2019 06:39:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=tsK8SglLaKlUI+E/DrAQftq2FCq5FZbACg++NpQWxHs=;
        b=U23VcLOl2ogzPjHQ3amq+wzhuePXp+k7eJEBf5VQcC324Oe5M88tARZHwogzVuJOjy
         ro4ioI0llJ1rvTfRQqUcDNDhsvALu2V4hAua4c8y1C62Lzv94gNHQ5eQco539Tedte5k
         g0t6QdJAg7aMkKSs2bfbdxJRMoXMZJkkRBFG63XGkQ0tgyzWhKxL/ZE9z9gF5sUfrzi+
         PcCDiZu1/4ztMVmbJVdHjBL5BxG6chAqCOnV9qAgIdCRLGF49NGqOqrh8M+swFgUSW37
         NW8wls8Iv9p03Y/O8HP4LpFkmiVipCWKhKv/SzXAUExxwjotGhbsADFhqCw+2pouEluj
         fbUA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=tsK8SglLaKlUI+E/DrAQftq2FCq5FZbACg++NpQWxHs=;
        b=IJQs6un6p4CsBJTyhBLAXOHgwj1ts+35gl7UH5fHwu9zgScWGkMOjxSX401gBl2fKS
         ugWCMuFURNjNl5PCCs78LTiHrkBB/RBxAleSHgk3SL20XxMewXMMBvGe7Pajmmjhtw5z
         afdZOhaccy2tGf5t1/uR47GUBRIlf2TWVwgmc6p348jI8gsA7XxLMbY/TVpWk29lfhD8
         WBIMCF7BJRATMPqtx7+MAXU4nttb/BMNWEQI7X4BjoqjGnr/CU7UEp00XmOdAOhHDCMe
         9W6ww6L+XKJ9CSy/iLK+Ne/pZ10rED19xkufH2f9+bfkcBAx8iRumfNT0Vi2KTN9RpEh
         2ZKg==
X-Gm-Message-State: APjAAAXLQhqq6crt6u1wag1NvDUxA7ahg9dwQiO/uNK7PxwoOFzhQhvI
        kI/1rVfKcy4NUp9ofqLxvuM=
X-Google-Smtp-Source: APXvYqxI24jkUgDH26/1x1YN02ghsXAnOKSB+w9IDZNbzYNb8HVHPCEnwGP2fHf+g1FsUNGRoLOZMA==
X-Received: by 2002:a24:3602:: with SMTP id l2mr7266631itl.68.1556113178872;
        Wed, 24 Apr 2019 06:39:38 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id 125sm9294705itx.21.2019.04.24.06.39.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:39:38 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODdbEW011295;
        Wed, 24 Apr 2019 13:39:37 GMT
Subject: [PATCH v3 09/21] xprtrdma: Backchannel can use GFP_KERNEL
 allocations
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:39:37 -0400
Message-ID: <20190424133937.5077.86415.stgit@manet.1015granger.net>
In-Reply-To: <20190424133516.5077.67283.stgit@manet.1015granger.net>
References: <20190424133516.5077.67283.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The Receive handler runs in process context, thus can use on-demand
GFP_KERNEL allocations instead of pre-allocation.

This makes the xprtrdma backchannel independent of the number of
backchannel session slots provisioned by the Upper Layer protocol.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |  104 ++++++++++++++-----------------------
 1 file changed, 40 insertions(+), 64 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index e1a125a..ae51ef6 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -19,35 +19,6 @@
 
 #undef RPCRDMA_BACKCHANNEL_DEBUG
 
-static int rpcrdma_bc_setup_reqs(struct rpcrdma_xprt *r_xprt,
-				 unsigned int count)
-{
-	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
-	struct rpcrdma_req *req;
-	struct rpc_rqst *rqst;
-	unsigned int i;
-
-	for (i = 0; i < (count << 1); i++) {
-		size_t size;
-
-		size = min_t(size_t, r_xprt->rx_data.inline_rsize, PAGE_SIZE);
-		req = rpcrdma_req_create(r_xprt, size, GFP_KERNEL);
-		if (!req)
-			return -ENOMEM;
-		rqst = &req->rl_slot;
-
-		rqst->rq_xprt = xprt;
-		INIT_LIST_HEAD(&rqst->rq_bc_list);
-		__set_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
-		spin_lock(&xprt->bc_pa_lock);
-		list_add(&rqst->rq_bc_pa_list, &xprt->bc_pa_list);
-		spin_unlock(&xprt->bc_pa_lock);
-		xdr_buf_init(&rqst->rq_snd_buf, rdmab_data(req->rl_sendbuf),
-			     size);
-	}
-	return 0;
-}
-
 /**
  * xprt_rdma_bc_setup - Pre-allocate resources for handling backchannel requests
  * @xprt: transport associated with these backchannel resources
@@ -58,34 +29,10 @@ static int rpcrdma_bc_setup_reqs(struct rpcrdma_xprt *r_xprt,
 int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
 {
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
-	int rc;
-
-	/* The backchannel reply path returns each rpc_rqst to the
-	 * bc_pa_list _after_ the reply is sent. If the server is
-	 * faster than the client, it can send another backward
-	 * direction request before the rpc_rqst is returned to the
-	 * list. The client rejects the request in this case.
-	 *
-	 * Twice as many rpc_rqsts are prepared to ensure there is
-	 * always an rpc_rqst available as soon as a reply is sent.
-	 */
-	if (reqs > RPCRDMA_BACKWARD_WRS >> 1)
-		goto out_err;
-
-	rc = rpcrdma_bc_setup_reqs(r_xprt, reqs);
-	if (rc)
-		goto out_free;
 
-	r_xprt->rx_buf.rb_bc_srv_max_requests = reqs;
+	r_xprt->rx_buf.rb_bc_srv_max_requests = RPCRDMA_BACKWARD_WRS >> 1;
 	trace_xprtrdma_cb_setup(r_xprt, reqs);
 	return 0;
-
-out_free:
-	xprt_rdma_bc_destroy(xprt, reqs);
-
-out_err:
-	pr_err("RPC:       %s: setup backchannel transport failed\n", __func__);
-	return -ENOMEM;
 }
 
 /**
@@ -213,6 +160,43 @@ void xprt_rdma_bc_free_rqst(struct rpc_rqst *rqst)
 	spin_unlock(&xprt->bc_pa_lock);
 }
 
+static struct rpc_rqst *rpcrdma_bc_rqst_get(struct rpcrdma_xprt *r_xprt)
+{
+	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
+	struct rpcrdma_req *req;
+	struct rpc_rqst *rqst;
+	size_t size;
+
+	spin_lock(&xprt->bc_pa_lock);
+	rqst = list_first_entry_or_null(&xprt->bc_pa_list, struct rpc_rqst,
+					rq_bc_pa_list);
+	if (!rqst)
+		goto create_req;
+	list_del(&rqst->rq_bc_pa_list);
+	spin_unlock(&xprt->bc_pa_lock);
+	return rqst;
+
+create_req:
+	spin_unlock(&xprt->bc_pa_lock);
+
+	/* Set a limit to prevent a remote from overrunning our resources.
+	 */
+	if (xprt->bc_alloc_count >= RPCRDMA_BACKWARD_WRS)
+		return NULL;
+
+	size = min_t(size_t, r_xprt->rx_data.inline_rsize, PAGE_SIZE);
+	req = rpcrdma_req_create(r_xprt, size, GFP_KERNEL);
+	if (!req)
+		return NULL;
+
+	xprt->bc_alloc_count++;
+	rqst = &req->rl_slot;
+	rqst->rq_xprt = xprt;
+	__set_bit(RPC_BC_PA_IN_USE, &rqst->rq_bc_pa_state);
+	xdr_buf_init(&rqst->rq_snd_buf, rdmab_data(req->rl_sendbuf), size);
+	return rqst;
+}
+
 /**
  * rpcrdma_bc_receive_call - Handle a backward direction call
  * @r_xprt: transport receiving the call
@@ -244,18 +228,10 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 	pr_info("RPC:       %s: %*ph\n", __func__, size, p);
 #endif
 
-	/* Grab a free bc rqst */
-	spin_lock(&xprt->bc_pa_lock);
-	if (list_empty(&xprt->bc_pa_list)) {
-		spin_unlock(&xprt->bc_pa_lock);
+	rqst = rpcrdma_bc_rqst_get(r_xprt);
+	if (!rqst)
 		goto out_overflow;
-	}
-	rqst = list_first_entry(&xprt->bc_pa_list,
-				struct rpc_rqst, rq_bc_pa_list);
-	list_del(&rqst->rq_bc_pa_list);
-	spin_unlock(&xprt->bc_pa_lock);
 
-	/* Prepare rqst */
 	rqst->rq_reply_bytes_recvd = 0;
 	rqst->rq_xid = *p;
 

