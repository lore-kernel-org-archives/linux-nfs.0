Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A94BC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D089C2133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZSapJvtW"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388307AbeLQQk4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:40:56 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:55527 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388281AbeLQQk4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:40:56 -0500
Received: by mail-it1-f196.google.com with SMTP id o19so19440924itg.5;
        Mon, 17 Dec 2018 08:40:54 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=6klOv+StCAdLA/KPQDlr1jm2BnrTiFkKbZbPVE6T44Y=;
        b=ZSapJvtWQ2lUiNfBytYwsNM58FgVXVGJFHXjSvHa7pXk59iclWI8TA1GM1Qe4eUqmz
         ZCgzCD0jfYQMQf3NU82YzYa3/JMyvo3AVv3Rir9HjUYzhdl42L75VV8xKKVrC7N4GqSb
         Y2kQTqZbJjvOuZVCQJdPoiL67H9XeeBJlwl8V8CcwCDpS0Z2FHyGzbRgh9goZobaGtI0
         EAIn/dekQbEfW4rDxmECjumnSBcdvovov23e7e5w7c0wbqJ2F/D7OHEm+x3H6cwilTMx
         S305ahhWg4bk741q6VyFP7lAO5v2DW91OJOVa6olZ1W1j6Y77iQOy4LTz0bWLFk6wesF
         cGbg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=6klOv+StCAdLA/KPQDlr1jm2BnrTiFkKbZbPVE6T44Y=;
        b=nZarN8KsCCSp+I3ki2Y4bUktWNdWKYoHFd7GVM66AHom5ea9nRBnGxJgcqUsRw6qRQ
         IkQWEHfNK/f19VWYnG7nxlk5Bgrvcu/i817jyFOO550ZQdVmtRZw71XcPFmQESNl511x
         C4ZK0fCySmwrPDMdKKcdEtNG3y0AyWB7aDsLrpEyH+4p+Fqyxyjr90kd4A447kJHYc/X
         UkUNkcQd4Fb98rONSpk1+2tHGDQyCdTjPDzCpZLhsio1zvQ/uZWiimqCbQ8kz/Gj88a4
         sGFVFU82Aarod19yP0ZTSJRHpEQjuRPZZpSu1uM+FuN7V0srK3Gra354BSyuyNSNDlov
         0b/w==
X-Gm-Message-State: AA+aEWbib20MoAqrFECxfZxWuwZPMYb/t7F2poI7JBvA6kgmrkAPkimv
        Z8+EfNeOe1ydYZiRrOr8h/+B+C4p
X-Google-Smtp-Source: AFSGD/VUcyVRNTF1o0lbOdjfRajLSKag2ecJ/LjBvn96srEnrmCNpsph4E3yer2/ltm0n32pErLQjg==
X-Received: by 2002:a02:b4d1:: with SMTP id a17mr13106259jak.27.1545064853607;
        Mon, 17 Dec 2018 08:40:53 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id u20sm3683028ioc.44.2018.12.17.08.40.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:40:53 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGeqbZ018629;
        Mon, 17 Dec 2018 16:40:52 GMT
Subject: [PATCH v4 17/30] xprtrdma: Cull dprintk() call sites
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:40:52 -0500
Message-ID: <20181217164052.24133.20895.stgit@manet.1015granger.net>
In-Reply-To: <20181217162406.24133.27356.stgit@manet.1015granger.net>
References: <20181217162406.24133.27356.stgit@manet.1015granger.net>
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
 net/sunrpc/xprtrdma/transport.c   |   33 ++++-----------------------------
 net/sunrpc/xprtrdma/verbs.c       |   34 +++++-----------------------------
 4 files changed, 19 insertions(+), 68 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index af8249b..64e1708 100644
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
index 8de0b9f..5a58769 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1186,17 +1186,20 @@ static int decode_reply_chunk(struct xdr_stream *xdr, u32 *length)
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
index f824892..41e4347 100644
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
@@ -446,8 +441,6 @@
 
 	might_sleep();
 
-	dprintk("RPC:       %s: closing xprt %p\n", __func__, xprt);
-
 	/* Prevent marshaling and sending of new requests */
 	xprt_clear_connected(xprt);
 
@@ -854,24 +847,15 @@ void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 
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
 
-	rc = xprt_unregister_transport(&xprt_rdma_bc);
-	if (rc)
-		dprintk("RPC:       %s: xprt_unregister(bc) returned %i\n",
-			__func__, rc);
+	xprt_unregister_transport(&xprt_rdma);
+	xprt_unregister_transport(&xprt_rdma_bc);
 }
 
 int xprt_rdma_init(void)
@@ -888,15 +872,6 @@ int xprt_rdma_init(void)
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
index a6ab216..64672d0 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -309,22 +309,15 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 
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
@@ -337,11 +330,8 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 
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
@@ -540,8 +530,6 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 			     1, IB_POLL_WORKQUEUE);
 	if (IS_ERR(sendcq)) {
 		rc = PTR_ERR(sendcq);
-		dprintk("RPC:       %s: failed to create send CQ: %i\n",
-			__func__, rc);
 		goto out1;
 	}
 
@@ -550,8 +538,6 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 			     0, IB_POLL_WORKQUEUE);
 	if (IS_ERR(recvcq)) {
 		rc = PTR_ERR(recvcq);
-		dprintk("RPC:       %s: failed to create recv CQ: %i\n",
-			__func__, rc);
 		goto out2;
 	}
 
@@ -691,11 +677,8 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
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
@@ -726,8 +709,6 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 		dprintk("RPC:       %s: connecting...\n", __func__);
 		rc = rdma_create_qp(ia->ri_id, ia->ri_pd, &ep->rep_attr);
 		if (rc) {
-			dprintk("RPC:       %s: rdma_create_qp failed %i\n",
-				__func__, rc);
 			rc = -ENETUNREACH;
 			goto out_noupdate;
 		}
@@ -749,11 +730,8 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
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
@@ -1088,8 +1066,6 @@ struct rpcrdma_req *
 out_free:
 	kfree(rep);
 out:
-	dprintk("RPC:       %s: reply buffer %d alloc failed\n",
-		__func__, rc);
 	return rc;
 }
 

