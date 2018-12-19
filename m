Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA387C43444
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:58:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6EC4B218D4
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:58:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mYHm5jRf"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729230AbeLSP62 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 10:58:28 -0500
Received: from mail-it1-f177.google.com ([209.85.166.177]:35076 "EHLO
        mail-it1-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728095AbeLSP61 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 10:58:27 -0500
Received: by mail-it1-f177.google.com with SMTP id p197so10063770itp.0;
        Wed, 19 Dec 2018 07:58:26 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=GYu0UsHQVtaKNGx1din9o11hbp64tcjGdgdTHECvmKg=;
        b=mYHm5jRfOziEi7n8YykibdSf35NlKB3z+dMTY5uR+/BYL0xpcW/5TVT2JIei5zRyHm
         8PSwuMQFf+YCc0QHD48wKEQUOwPWyNrupXgoFWC461U5BLCHcJWvA5nrfdV2uANM6OF3
         mdaSG67TeTw7UFYeFwedH40+9N92cNygCfw9dEGxitZgMAN04eFAZlCYD6INdxy8e1sC
         B7els4AWwHHiZ95mILk+UqdcUM1GMO11RR3PphFYScY32IkKu20Anhdqwvv8/9cc2EYD
         R9+Y3o6tVExN5fYL8w6CQh1gciHDfGiG0+NOjvNi8bn0TLwiFtuQFB17jllmhArJOc92
         SpAA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=GYu0UsHQVtaKNGx1din9o11hbp64tcjGdgdTHECvmKg=;
        b=oOYMEq3BQBTK/mIy/Wy9MxMYJtpUkZTKlrrvZHif8ZgrEtXOA8FYI0uw3Uat6Vl473
         ZKbpyrq08f4+L9jV2Uli8wUPBos/NEZ5I/rlO8ugbNpP1GFCcmVFt577k0nPVVKqhyYL
         8c+aySqsoz7fBfEtbmZgKE/BHTlt2NRa/swZruC41PvxpWXQPa5/YVbXmxG+l6yWad41
         6LfsDZ2rAJ7RilO6+zUl5trggMTPuyQ9gv1GRsi4osGmE3bV1+mHXv3ThQSGKiUt/eJl
         +S17NRwW+eORVGwRtHJ92hupbDirIQVIbNJaC0MS41BWgp3g53/IZ7DiYl5IcwfdE5SW
         SRRw==
X-Gm-Message-State: AA+aEWY77ITNZ/DBgiGY5vTfmR4V3CiDs3PhnzEMpZPu1CdCIQoI9p8b
        eEQYSmG8Yzi+hqaxbO9Vjow=
X-Google-Smtp-Source: AFSGD/WaZqdX0m/fkcYX2bWiULOlKlA2Hr3s+DWJsN2iqz8B6unJu7AV38dle6GCoRS6u1Go79Inwg==
X-Received: by 2002:a02:410e:: with SMTP id x14mr18986173jaa.36.1545235106200;
        Wed, 19 Dec 2018 07:58:26 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id q16sm7525759ioi.66.2018.12.19.07.58.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 07:58:25 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJFwONH025765;
        Wed, 19 Dec 2018 15:58:24 GMT
Subject: [PATCH v5 03/30] xprtrdma: Refactor Receive accounting
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 10:58:24 -0500
Message-ID: <20181219155824.11602.75211.stgit@manet.1015granger.net>
In-Reply-To: <20181219155152.11602.18605.stgit@manet.1015granger.net>
References: <20181219155152.11602.18605.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up: Divide the work cleanly:

- rpcrdma_wc_receive is responsible only for RDMA Receives
- rpcrdma_reply_handler is responsible only for RPC Replies
- the posted send and receive counts both belong in rpcrdma_ep

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h    |    2 +-
 net/sunrpc/xprtrdma/backchannel.c |    1 -
 net/sunrpc/xprtrdma/rpc_rdma.c    |   21 +++------------------
 net/sunrpc/xprtrdma/verbs.c       |   31 ++++++++++++++-----------------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    3 +--
 5 files changed, 19 insertions(+), 39 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index b093058..2efe2d7 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -570,7 +570,7 @@
 		__entry->r_xprt = r_xprt;
 		__entry->count = count;
 		__entry->status = status;
-		__entry->posted = r_xprt->rx_buf.rb_posted_receives;
+		__entry->posted = r_xprt->rx_ep.rep_receive_count;
 		__assign_str(addr, rpcrdma_addrstr(r_xprt));
 		__assign_str(port, rpcrdma_portstr(r_xprt));
 	),
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index e5b367a..2cb07a3 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -207,7 +207,6 @@ int xprt_rdma_bc_send_reply(struct rpc_rqst *rqst)
 	if (rc < 0)
 		goto failed_marshal;
 
-	rpcrdma_post_recvs(r_xprt, true);
 	if (rpcrdma_ep_post(&r_xprt->rx_ia, &r_xprt->rx_ep, req))
 		goto drop_connection;
 	return 0;
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 9f53e02..dc23977 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1312,11 +1312,6 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	u32 credits;
 	__be32 *p;
 
-	--buf->rb_posted_receives;
-
-	if (rep->rr_hdrbuf.head[0].iov_len == 0)
-		goto out_badstatus;
-
 	/* Fixed transport header fields */
 	xdr_init_decode(&rep->rr_stream, &rep->rr_hdrbuf,
 			rep->rr_hdrbuf.head[0].iov_base);
@@ -1361,31 +1356,21 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	clear_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags);
 
 	trace_xprtrdma_reply(rqst->rq_task, rep, req, credits);
-
-	rpcrdma_post_recvs(r_xprt, false);
 	queue_work(rpcrdma_receive_wq, &rep->rr_work);
 	return;
 
 out_badversion:
 	trace_xprtrdma_reply_vers(rep);
-	goto repost;
+	goto out;
 
-/* The RPC transaction has already been terminated, or the header
- * is corrupt.
- */
 out_norqst:
 	spin_unlock(&xprt->queue_lock);
 	trace_xprtrdma_reply_rqst(rep);
-	goto repost;
+	goto out;
 
 out_shortreply:
 	trace_xprtrdma_reply_short(rep);
 
-/* If no pending RPC transaction was matched, post a replacement
- * receive buffer before returning.
- */
-repost:
-	rpcrdma_post_recvs(r_xprt, false);
-out_badstatus:
+out:
 	rpcrdma_recv_buffer_put(rep);
 }
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index b9bc7f9..e4461e7 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -78,6 +78,7 @@
 static void rpcrdma_mrs_destroy(struct rpcrdma_buffer *buf);
 static int rpcrdma_create_rep(struct rpcrdma_xprt *r_xprt, bool temp);
 static void rpcrdma_dma_unmap_regbuf(struct rpcrdma_regbuf *rb);
+static void rpcrdma_post_recvs(struct rpcrdma_xprt *r_xprt, bool temp);
 
 struct workqueue_struct *rpcrdma_receive_wq __read_mostly;
 
@@ -189,11 +190,13 @@
 	struct ib_cqe *cqe = wc->wr_cqe;
 	struct rpcrdma_rep *rep = container_of(cqe, struct rpcrdma_rep,
 					       rr_cqe);
+	struct rpcrdma_xprt *r_xprt = rep->rr_rxprt;
 
-	/* WARNING: Only wr_id and status are reliable at this point */
+	/* WARNING: Only wr_cqe and status are reliable at this point */
 	trace_xprtrdma_wc_receive(wc);
+	--r_xprt->rx_ep.rep_receive_count;
 	if (wc->status != IB_WC_SUCCESS)
-		goto out_fail;
+		goto out_flushed;
 
 	/* status == SUCCESS means all fields in wc are trustworthy */
 	rpcrdma_set_xdrlen(&rep->rr_hdrbuf, wc->byte_len);
@@ -204,17 +207,16 @@
 				   rdmab_addr(rep->rr_rdmabuf),
 				   wc->byte_len, DMA_FROM_DEVICE);
 
-out_schedule:
+	rpcrdma_post_recvs(r_xprt, false);
 	rpcrdma_reply_handler(rep);
 	return;
 
-out_fail:
+out_flushed:
 	if (wc->status != IB_WC_WR_FLUSH_ERR)
 		pr_err("rpcrdma: Recv: %s (%u/0x%x)\n",
 		       ib_wc_status_msg(wc->status),
 		       wc->status, wc->vendor_err);
-	rpcrdma_set_xdrlen(&rep->rr_hdrbuf, 0);
-	goto out_schedule;
+	rpcrdma_recv_buffer_put(rep);
 }
 
 static void
@@ -581,6 +583,7 @@
 	init_waitqueue_head(&ep->rep_connect_wait);
 	INIT_DELAYED_WORK(&ep->rep_disconnect_worker,
 			  rpcrdma_disconnect_worker);
+	ep->rep_receive_count = 0;
 
 	sendcq = ib_alloc_cq(ia->ri_device, NULL,
 			     ep->rep_attr.cap.max_send_wr + 1,
@@ -1174,7 +1177,6 @@ struct rpcrdma_req *
 	}
 
 	buf->rb_credits = 1;
-	buf->rb_posted_receives = 0;
 	INIT_LIST_HEAD(&buf->rb_recv_bufs);
 
 	rc = rpcrdma_sendctxs_create(r_xprt);
@@ -1511,25 +1513,20 @@ struct rpcrdma_regbuf *
 	return 0;
 }
 
-/**
- * rpcrdma_post_recvs - Maybe post some Receive buffers
- * @r_xprt: controlling transport
- * @temp: when true, allocate temp rpcrdma_rep objects
- *
- */
-void
+static void
 rpcrdma_post_recvs(struct rpcrdma_xprt *r_xprt, bool temp)
 {
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	struct rpcrdma_ep *ep = &r_xprt->rx_ep;
 	struct ib_recv_wr *wr, *bad_wr;
 	int needed, count, rc;
 
 	rc = 0;
 	count = 0;
 	needed = buf->rb_credits + (buf->rb_bc_srv_max_requests << 1);
-	if (buf->rb_posted_receives > needed)
+	if (ep->rep_receive_count > needed)
 		goto out;
-	needed -= buf->rb_posted_receives;
+	needed -= ep->rep_receive_count;
 
 	count = 0;
 	wr = NULL;
@@ -1577,7 +1574,7 @@ struct rpcrdma_regbuf *
 			--count;
 		}
 	}
-	buf->rb_posted_receives += count;
+	ep->rep_receive_count += count;
 out:
 	trace_xprtrdma_post_recvs(r_xprt, count, rc);
 }
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index a13ccb6..788124c 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -102,6 +102,7 @@ struct rpcrdma_ep {
 	struct rpcrdma_connect_private	rep_cm_private;
 	struct rdma_conn_param	rep_remote_cma;
 	struct delayed_work	rep_disconnect_worker;
+	int			rep_receive_count;
 };
 
 /* Pre-allocate extra Work Requests for handling backward receives
@@ -404,7 +405,6 @@ struct rpcrdma_buffer {
 	unsigned long		rb_flags;
 	u32			rb_max_requests;
 	u32			rb_credits;	/* most recent credit grant */
-	int			rb_posted_receives;
 
 	u32			rb_bc_srv_max_requests;
 	spinlock_t		rb_reqslock;	/* protect rb_allreqs */
@@ -560,7 +560,6 @@ int rpcrdma_ep_create(struct rpcrdma_ep *, struct rpcrdma_ia *,
 
 int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
 				struct rpcrdma_req *);
-void rpcrdma_post_recvs(struct rpcrdma_xprt *r_xprt, bool temp);
 
 /*
  * Buffer calls - xprtrdma/verbs.c

