Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD071C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:07:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 765E6205C9
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:07:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HD2Gl6xD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 765E6205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726414AbeK0HCP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 02:02:15 -0500
Received: from mail-io1-f66.google.com ([209.85.166.66]:39292 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726296AbeK0HCP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2018 02:02:15 -0500
Received: by mail-io1-f66.google.com with SMTP id k7so5156325iob.6;
        Mon, 26 Nov 2018 12:07:00 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=7skte31iUDuXNUaXXBGsmJB1N8WStTli/vQHdTmez+k=;
        b=HD2Gl6xDnFpYfxKY44sykymPJQdAV7Coiq2AGm7ShWIAVH9pp8bpNG8WKMgdZPpKcD
         uKw9Pjcy1+3SmScBD3jgTpj6Dc9lymEXRDSYSEasIl7TmqHEMUOnG8q/eYQMv7hW+gEh
         LEOBx3hqQgehGrsUHc6WJM0q4HNnHVMnSgtTDPrUb+hZP6X5Q4L7ZO2gFejbKO6BQfuw
         npv+7gMwwZxxbJFpT6JbsHCMfyWhJvo7XdW1rbhAzhyIogX0tJ/AOAHH+80WTxA3baHK
         eMgdP3EetC47OF7reyrdKtSMUqZNVc1UW7Yo32lcUWYZLXXSqDvgN9qFwYpKLsgIC1Pn
         Z/ag==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=7skte31iUDuXNUaXXBGsmJB1N8WStTli/vQHdTmez+k=;
        b=ueu9gur9s+7Mf6jaUCDwKg19q4Jn10tachL0ed1THrFoE+RRGKXIdbNIWuDQf/6Spb
         feJOIVCTZYm2rRm0R69KYev8UBi+OWj48WnD5n1S2ya4Yvoc4qOLLLu3plFTc62k8yBg
         mECWKg+h3xhc1VAu5/ka7nIk6liL0TwKxh44SQn0kVbgAueN5fZEKwpMCTd75DKxfdLy
         m7AISjTwwAM+X5khR5hLhkF0MDiwaJ/buCK+f27LW4Pxl7Z6sDlw4gYJEpYZzFGfbx5P
         mm2mTjCuwOqF6FbPt/CMqJuP4qLPrLcC0iY6eOeAFf1WsKRLYyLLEtMWJ+FoRueUhjWY
         8Mug==
X-Gm-Message-State: AA+aEWZkqpbQO6D/Z2HK5L01czwCnri1QW/t0GPFUGTT/dpP/1xWp74d
        ymMUtoeoQTH2vWk0CdQ1KcAbNWH6
X-Google-Smtp-Source: AFSGD/WIsESnFZN3Cz68DyxwuroQXH0e/g/CO32RP0542OQzyhk2yjzM6zC2ljXRwCVTvNNC4aybug==
X-Received: by 2002:a5e:da48:: with SMTP id o8mr24835482iop.165.1543262819285;
        Mon, 26 Nov 2018 12:06:59 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id l11sm474515iob.24.2018.11.26.12.06.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 12:06:57 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAQK6uDo010681;
        Mon, 26 Nov 2018 20:06:56 GMT
Subject: [PATCH v2 13/20] xprtrdma: Cull dprintk() call sites
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 26 Nov 2018 15:06:56 -0500
Message-ID: <20181126200656.10321.66947.stgit@manet.1015granger.net>
In-Reply-To: <20181126194611.10321.71714.stgit@manet.1015granger.net>
References: <20181126194611.10321.71714.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up: Remove dprintk() call sites that report rare or impossible
errors. Leave a few that display high-value low noise status
information.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    3 ---
 net/sunrpc/xprtrdma/rpc_rdma.c    |   17 ++++++++++-------
 net/sunrpc/xprtrdma/transport.c   |   34 ++++------------------------------
 net/sunrpc/xprtrdma/verbs.c       |   34 +++++-----------------------------
 4 files changed, 19 insertions(+), 69 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index c8a3d45..556975f 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -235,9 +235,6 @@ void xprt_rdma_bc_free_rqst(struct rpc_rqst *rqst)
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
 	struct rpc_xprt *xprt = rqst->rq_xprt;
 
-	dprintk("RPC:       %s: freeing rqst %p (req %p)\n",
-		__func__, rqst, req);
-
 	rpcrdma_recv_buffer_put(req->rl_reply);
 	req->rl_reply = NULL;
 
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 9993654..89c10f2 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1189,17 +1189,20 @@ static int decode_reply_chunk(struct xdr_stream *xdr, u32 *length)
 		p = xdr_inline_decode(xdr, 2 * sizeof(*p));
 		if (!p)
 			break;
-		dprintk("RPC: %5u: %s: server reports version error (%u-%u)\n",
-			rqst->rq_task->tk_pid, __func__,
-			be32_to_cpup(p), be32_to_cpu(*(p + 1)));
+		dprintk("RPC:       %s: server reports "
+			"version error (%u-%u), xid %08x\n", __func__,
+			be32_to_cpup(p), be32_to_cpu(*(p + 1)),
+			be32_to_cpu(rep->rr_xid));
 		break;
 	case err_chunk:
-		dprintk("RPC: %5u: %s: server reports header decoding error\n",
-			rqst->rq_task->tk_pid, __func__);
+		dprintk("RPC:       %s: server reports "
+			"header decoding error, xid %08x\n", __func__,
+			be32_to_cpu(rep->rr_xid));
 		break;
 	default:
-		dprintk("RPC: %5u: %s: server reports unrecognized error %d\n",
-			rqst->rq_task->tk_pid, __func__, be32_to_cpup(p));
+		dprintk("RPC:       %s: server reports "
+			"unrecognized error %d, xid %08x\n", __func__,
+			be32_to_cpup(p), be32_to_cpu(rep->rr_xid));
 	}
 
 	r_xprt->rx_stats.bad_reply_count++;
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 254cb8c..45b2f53 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -318,17 +318,12 @@
 	struct sockaddr *sap;
 	int rc;
 
-	if (args->addrlen > sizeof(xprt->addr)) {
-		dprintk("RPC:       %s: address too large\n", __func__);
+	if (args->addrlen > sizeof(xprt->addr))
 		return ERR_PTR(-EBADF);
-	}
 
 	xprt = xprt_alloc(args->net, sizeof(struct rpcrdma_xprt), 0, 0);
-	if (xprt == NULL) {
-		dprintk("RPC:       %s: couldn't allocate rpcrdma_xprt\n",
-			__func__);
+	if (!xprt)
 		return ERR_PTR(-ENOMEM);
-	}
 
 	/* 60 second timeout, no retries */
 	xprt->timeout = &xprt_rdma_default_timeout;
@@ -444,8 +439,6 @@
 	struct rpcrdma_ep *ep = &r_xprt->rx_ep;
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 
-	dprintk("RPC:       %s: closing xprt %p\n", __func__, xprt);
-
 	if (test_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags)) {
 		xprt_clear_connected(xprt);
 		rpcrdma_ia_remove(ia);
@@ -848,26 +841,16 @@ void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 
 void xprt_rdma_cleanup(void)
 {
-	int rc;
-
-	dprintk("RPCRDMA Module Removed, deregister RPC RDMA transport\n");
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 	if (sunrpc_table_header) {
 		unregister_sysctl_table(sunrpc_table_header);
 		sunrpc_table_header = NULL;
 	}
 #endif
-	rc = xprt_unregister_transport(&xprt_rdma);
-	if (rc)
-		dprintk("RPC:       %s: xprt_unregister returned %i\n",
-			__func__, rc);
 
+	xprt_unregister_transport(&xprt_rdma);
 	rpcrdma_destroy_wq();
-
-	rc = xprt_unregister_transport(&xprt_rdma_bc);
-	if (rc)
-		dprintk("RPC:       %s: xprt_unregister(bc) returned %i\n",
-			__func__, rc);
+	xprt_unregister_transport(&xprt_rdma_bc);
 }
 
 int xprt_rdma_init(void)
@@ -891,15 +874,6 @@ int xprt_rdma_init(void)
 		return rc;
 	}
 
-	dprintk("RPCRDMA Module Init, register RPC RDMA transport\n");
-
-	dprintk("Defaults:\n");
-	dprintk("\tSlots %d\n"
-		"\tMaxInlineRead %d\n\tMaxInlineWrite %d\n",
-		xprt_rdma_slot_table_entries,
-		xprt_rdma_max_inline_read, xprt_rdma_max_inline_write);
-	dprintk("\tPadding 0\n\tMemreg %d\n", xprt_rdma_memreg_strategy);
-
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 	if (!sunrpc_table_header)
 		sunrpc_table_header = register_sysctl_table(sunrpc_table);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 73d5247..1a1402f 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -347,22 +347,15 @@
 
 	id = rdma_create_id(xprt->rx_xprt.xprt_net, rpcrdma_cm_event_handler,
 			    xprt, RDMA_PS_TCP, IB_QPT_RC);
-	if (IS_ERR(id)) {
-		rc = PTR_ERR(id);
-		dprintk("RPC:       %s: rdma_create_id() failed %i\n",
-			__func__, rc);
+	if (IS_ERR(id))
 		return id;
-	}
 
 	ia->ri_async_rc = -ETIMEDOUT;
 	rc = rdma_resolve_addr(id, NULL,
 			       (struct sockaddr *)&xprt->rx_xprt.addr,
 			       RDMA_RESOLVE_TIMEOUT);
-	if (rc) {
-		dprintk("RPC:       %s: rdma_resolve_addr() failed %i\n",
-			__func__, rc);
+	if (rc)
 		goto out;
-	}
 	rc = wait_for_completion_interruptible_timeout(&ia->ri_done, wtimeout);
 	if (rc < 0) {
 		trace_xprtrdma_conn_tout(xprt);
@@ -375,11 +368,8 @@
 
 	ia->ri_async_rc = -ETIMEDOUT;
 	rc = rdma_resolve_route(id, RDMA_RESOLVE_TIMEOUT);
-	if (rc) {
-		dprintk("RPC:       %s: rdma_resolve_route() failed %i\n",
-			__func__, rc);
+	if (rc)
 		goto out;
-	}
 	rc = wait_for_completion_interruptible_timeout(&ia->ri_done, wtimeout);
 	if (rc < 0) {
 		trace_xprtrdma_conn_tout(xprt);
@@ -587,8 +577,6 @@
 			     1, IB_POLL_WORKQUEUE);
 	if (IS_ERR(sendcq)) {
 		rc = PTR_ERR(sendcq);
-		dprintk("RPC:       %s: failed to create send CQ: %i\n",
-			__func__, rc);
 		goto out1;
 	}
 
@@ -597,8 +585,6 @@
 			     0, IB_POLL_WORKQUEUE);
 	if (IS_ERR(recvcq)) {
 		rc = PTR_ERR(recvcq);
-		dprintk("RPC:       %s: failed to create recv CQ: %i\n",
-			__func__, rc);
 		goto out2;
 	}
 
@@ -740,11 +726,8 @@
 	}
 
 	err = rdma_create_qp(id, ia->ri_pd, &ep->rep_attr);
-	if (err) {
-		dprintk("RPC:       %s: rdma_create_qp returned %d\n",
-			__func__, err);
+	if (err)
 		goto out_destroy;
-	}
 
 	/* Atomically replace the transport's ID and QP. */
 	rc = 0;
@@ -775,8 +758,6 @@
 		dprintk("RPC:       %s: connecting...\n", __func__);
 		rc = rdma_create_qp(ia->ri_id, ia->ri_pd, &ep->rep_attr);
 		if (rc) {
-			dprintk("RPC:       %s: rdma_create_qp failed %i\n",
-				__func__, rc);
 			rc = -ENETUNREACH;
 			goto out_noupdate;
 		}
@@ -798,11 +779,8 @@
 	rpcrdma_post_recvs(r_xprt, true);
 
 	rc = rdma_connect(ia->ri_id, &ep->rep_remote_cma);
-	if (rc) {
-		dprintk("RPC:       %s: rdma_connect() failed with %i\n",
-				__func__, rc);
+	if (rc)
 		goto out;
-	}
 
 	wait_event_interruptible(ep->rep_connect_wait, ep->rep_connected != 0);
 	if (ep->rep_connected <= 0) {
@@ -1144,8 +1122,6 @@ struct rpcrdma_req *
 out_free:
 	kfree(rep);
 out:
-	dprintk("RPC:       %s: reply buffer %d alloc failed\n",
-		__func__, rc);
 	return rc;
 }
 

