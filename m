Return-Path: <SRS0=wtRa=SM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4224C10F14
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:07:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 86AB32075B
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:07:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OqgIUd6C"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726706AbfDJUH2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Apr 2019 16:07:28 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:39852 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726630AbfDJUH1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2019 16:07:27 -0400
Received: by mail-it1-f194.google.com with SMTP id 139so5615361ita.4;
        Wed, 10 Apr 2019 13:07:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=tsK8SglLaKlUI+E/DrAQftq2FCq5FZbACg++NpQWxHs=;
        b=OqgIUd6CK4l0+mmgS7biXdWm+tsyAn0YSCJZ62+2QgwH3L2aer3zaY7Abd0xx2KGys
         xDo+Q6sZpfvGklEEYDllJJL0R1xtqqN2Hn2ri6xiq/4GlScIWXPXHzQ1VlF3ibUnQm/q
         6hzjtI1mJZH/+gM2FcGI7oMEslEx0P2xMJRBlOy5mlTAPKZ1bzBdiFDMzFp5tNWkqkPF
         Hg/pjAqndMuTe7iK4RtXc+FYJhK1qI8nMCifK8fHnGxVeA0uvw5/HffQimB5IFpaqmfm
         D122UWf/1m02zFQsZz6jsbQ1rU0OaP+BQYRoqH+0CRhRxY9ie0kwqqLAKVbyC9z4Rfak
         vg6A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=tsK8SglLaKlUI+E/DrAQftq2FCq5FZbACg++NpQWxHs=;
        b=QFm+vCnshiBvaiJo0vcI6SJ1ENJK9mbE3VT8wS1i+YaklRpaya0xHkS1qYFy24+hLC
         67z9bnCzxLsAKz/ul5UuVsWhtlabLi2ArH2TEhaYxMBEIlq0KS4hHKAdOn7BXgRy3ITi
         PUOBT3O+y5tCRa8ZtinlbZnZhAoPPJlzGHQfunJBUDc7sFsGsFc6XJ4/eB4/9qYHFv4Z
         vzXDWp8o6A1idA1Lcd65laXty7eAoFbbPiivDFH5OB4X//V6kIHSIvSehwY4caoo4YVE
         0nhFhHQymYIbFRrq70QC8oCuW9AwXwUUtwOvxg9DrL4jv750k6lmNE8x4sY7ibaih3xu
         VzLQ==
X-Gm-Message-State: APjAAAUbCU+uKOuEEkeTNEJvTfwEY4u9u2ffe+y2WzBHJMnWPxUHRBt2
        PqapF4FmBcEWxiG4thGQIxMHmvAJ
X-Google-Smtp-Source: APXvYqzmrrRf6oe48kLanXFxiclJcQ5Y966181xPZRulI+hBYOu7lzodJKreKT3vagcPAdEkLABXEA==
X-Received: by 2002:a24:280e:: with SMTP id h14mr5535600ith.80.1554926845998;
        Wed, 10 Apr 2019 13:07:25 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id n184sm1284400itc.28.2019.04.10.13.07.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 13:07:25 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3AK7OfO004534;
        Wed, 10 Apr 2019 20:07:24 GMT
Subject: [PATCH v1 10/19] xprtrdma: Backchannel can use GFP_KERNEL
 allocations
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 10 Apr 2019 16:07:24 -0400
Message-ID: <20190410200724.11522.63068.stgit@manet.1015granger.net>
In-Reply-To: <20190410200446.11522.21145.stgit@manet.1015granger.net>
References: <20190410200446.11522.21145.stgit@manet.1015granger.net>
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
 

