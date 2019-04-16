Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3366FC10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:37:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ED0EF217F9
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:37:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="U4p1le2p"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728508AbfDPNhm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 09:37:42 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:40905 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728032AbfDPNhl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2019 09:37:41 -0400
Received: by mail-it1-f193.google.com with SMTP id k64so8894507itb.5;
        Tue, 16 Apr 2019 06:37:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=tsK8SglLaKlUI+E/DrAQftq2FCq5FZbACg++NpQWxHs=;
        b=U4p1le2ptb1f7GHpDBeNPYiG0o6u94Ij7+cGn+w8biZYna22cVmxxijpmEV5a3S9zl
         Iygxdr5QYOMKv7kf4l922opdCArjcKGciVL4fi4gFRGaOPZyuwBnL1MRzwhurlLB6kuh
         Md690G1nDx4/BrSX4KPVEhOQvjIbqJ4yxdweOXQ0XR5zJbck1ljfrPxzUrVeEL7WCUxE
         IlFEuurnLB5iJqBqFYrEwSsfbcEcfMyleE8WYIauFe/818g4zryBJuyWKFHjfGcrVpc4
         V7OAriv9YLeoz5/aLOa03kbx3Pos5LNwCDqAJk2q5+Z7dVhpHiz8r6AZC3E5DmfY6X3B
         7LGw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=tsK8SglLaKlUI+E/DrAQftq2FCq5FZbACg++NpQWxHs=;
        b=Nk7OHKB1b7Rq1eBamDa2oOq/mDieiQWKjHV96kE80MzezcRz8/5ffhkQiI7AH+3YOS
         g5HYhDxGbzJEWUSOCQ2C1KiyOhRRBOF8wwL0ZQ5rq3CyirPBnUA9djeTNbMy0Cq9xRbC
         WGOnrOwaC8umiSkaw5/A2m6HPYPLPKHmmGHR7eHCMkN55EGFS8fkmY5AkW7wBo0A3TiY
         LcnWvcAaLTkmxoMeImJdWKD2rGyh+a2ed9CDkSHNlmrx0KHbDaIQb9AciSmTKronH2gd
         Aq17x7GdEMQWMgT4ODO42PHjiQt8G35DyTfQ/ss22BtzHtbJUWnUF1SP4PyirC19YDsc
         fNmg==
X-Gm-Message-State: APjAAAXFe60PM3iUXnERrZSBc1Vv9/gq4SWNB9pDDHdrx5SNR1FHq5MV
        +VWYKwcOC/7HaL3wSeWoLJGcUAn1
X-Google-Smtp-Source: APXvYqzSXDtZV5n84tfbnHLBzjm0srcCxQdmTFX4xGbhWWJv3R2b6Iuh7na2sNAQHfkvaDeN7bQSqQ==
X-Received: by 2002:a24:3288:: with SMTP id j130mr3606965ita.104.1555421860024;
        Tue, 16 Apr 2019 06:37:40 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id 3sm1678465itk.1.2019.04.16.06.37.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:37:39 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3GDbcaE021223;
        Tue, 16 Apr 2019 13:37:38 GMT
Subject: [PATCH v2 09/21] xprtrdma: Backchannel can use GFP_KERNEL
 allocations
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Tue, 16 Apr 2019 09:37:38 -0400
Message-ID: <20190416133738.23113.25321.stgit@manet.1015granger.net>
In-Reply-To: <20190416133156.23113.91846.stgit@manet.1015granger.net>
References: <20190416133156.23113.91846.stgit@manet.1015granger.net>
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
 

