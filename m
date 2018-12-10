Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7612C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 78D502086D
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WEIWH+9x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78D502086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728438AbeLJQaW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:30:22 -0500
Received: from mail-io1-f66.google.com ([209.85.166.66]:39981 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728363AbeLJQaV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:30:21 -0500
Received: by mail-io1-f66.google.com with SMTP id n9so9210796ioh.7;
        Mon, 10 Dec 2018 08:30:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=zuUPDlNLR26O0ox2kJlkS3DrYPEoii53Zedb5tb9G2s=;
        b=WEIWH+9xnXGECYetCJWJfJtwET9NvlpmTen62YZHZ3us1qKwfOkDq8j/OvzXuFwDoX
         BTUxa5j7f4QvrBbFMjeuDqBcKskKV1hwsmuqvZIQwyDtGRL2Fr1kArYQoaoXjbOs8Bnm
         KuFDiDj6wkP+sLAwxPrQbrHu7hJQ8BKlThWXM6FsYinwtTP8m4nVgxPjNGvdk39fexm0
         tY/aNT108bRbMCRoQdWsIHGHVxMQZN9guFIQMWhWHiRxc94OhJSezb739euIJveyVfNA
         sgGNmJ9yFh63w3NsJG4Q8XqgjYLLQGsqbcuf17qjdkjLwCtAfIAiq9rI6TnvAbE0W0cq
         NogQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=zuUPDlNLR26O0ox2kJlkS3DrYPEoii53Zedb5tb9G2s=;
        b=REaXfsV5cRz3WVwH+KRmmdfY+bkQa+1awv+C9r9BfZKv49VJiG/O+rTVQUAprl/M4q
         ezMzbxbOzE9nskovF8HFHEsoXIFFhoTsl5kPjyjw0MUGnjnm0k2fH0GVhcYZvtVcmwRE
         GHTG70cWtX6lmRBN0CWITiFNrNq97+VQmc2DaiDyO1JziK09ni/8mIX0l0wTobAfH8vs
         KD9iff6dvm04R9m/sY4TUREX4uWiwGSmhDLX1b80c1odIQKcEByMnsGfr2I8vZj1F0Yo
         2C3zaa1GjFLaMXqE/qOFhqjq8Lne8zwlldAdDA8kdcme8VKZqrLxX34+VVWJdr+okzkI
         wjVQ==
X-Gm-Message-State: AA+aEWZUrT0Ch9Ktd0AP+V+Ju4SgNUQZUjt5xcVPG+skpLNp9MA0h30C
        RoLLLRwxsUX42FBnDAToQ2M=
X-Google-Smtp-Source: AFSGD/VYjTCm/5K2SHsECgiTUnIj/+vaWJsffDPDujWJbw/FR5OxOxUt9SFOVSLU00y/BLoufhh4Cg==
X-Received: by 2002:a6b:7303:: with SMTP id e3mr9643839ioh.264.1544459419605;
        Mon, 10 Dec 2018 08:30:19 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id w16sm6481375ita.38.2018.12.10.08.30.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:30:19 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGUHpq031055;
        Mon, 10 Dec 2018 16:30:17 GMT
Subject: [PATCH v3 11/24] xprtrdma: Cull dprintk() call sites
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:30:17 -0500
Message-ID: <20181210163017.4198.5921.stgit@manet.1015granger.net>
In-Reply-To: <20181210161723.4198.51071.stgit@manet.1015granger.net>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
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
index 41d263c..2353a9e 100644
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
index 2bb9052..636e0f1 100644
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
index 2ba8be1..5d6c3b3 100644
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
 	if (test_and_clear_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags)) {
 		xprt_clear_connected(xprt);
 		rpcrdma_ia_remove(ia);
@@ -846,26 +839,16 @@ void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 
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
@@ -889,15 +872,6 @@ int xprt_rdma_init(void)
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
index bd6bc45..4afed9f 100644
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
@@ -581,8 +571,6 @@
 			     1, IB_POLL_WORKQUEUE);
 	if (IS_ERR(sendcq)) {
 		rc = PTR_ERR(sendcq);
-		dprintk("RPC:       %s: failed to create send CQ: %i\n",
-			__func__, rc);
 		goto out1;
 	}
 
@@ -591,8 +579,6 @@
 			     0, IB_POLL_WORKQUEUE);
 	if (IS_ERR(recvcq)) {
 		rc = PTR_ERR(recvcq);
-		dprintk("RPC:       %s: failed to create recv CQ: %i\n",
-			__func__, rc);
 		goto out2;
 	}
 
@@ -734,11 +720,8 @@
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
@@ -769,8 +752,6 @@
 		dprintk("RPC:       %s: connecting...\n", __func__);
 		rc = rdma_create_qp(ia->ri_id, ia->ri_pd, &ep->rep_attr);
 		if (rc) {
-			dprintk("RPC:       %s: rdma_create_qp failed %i\n",
-				__func__, rc);
 			rc = -ENETUNREACH;
 			goto out_noupdate;
 		}
@@ -792,11 +773,8 @@
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
@@ -1128,8 +1106,6 @@ struct rpcrdma_req *
 out_free:
 	kfree(rep);
 out:
-	dprintk("RPC:       %s: reply buffer %d alloc failed\n",
-		__func__, rc);
 	return rc;
 }
 

