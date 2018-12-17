Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7DA2C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:39:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A7A072133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:39:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="O3JDD/6x"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388184AbeLQQjv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:39:51 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:54384 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727771AbeLQQju (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:39:50 -0500
Received: by mail-it1-f196.google.com with SMTP id i145so19459113ita.4;
        Mon, 17 Dec 2018 08:39:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=JrjAwoYZLatTrSpjWp1zdL2hQdofaBBegzEeSbKdEko=;
        b=O3JDD/6xlWimSEYIhZwyhswxm0oPgfkS56OJNAZ2cGmMv/t2Wj6LjRn3EFABiHjRpJ
         Xp3tM/6UiNdRbfsWvzLVd0U03SSsdk413bRFBE/xVy/jx6EO/WjAKdSXNtHk9TXZYrfp
         5sm5wE7HHwWiIbv63A01prsSH+QBPoUru7Yd8cl1Ma60hva60oyyClwrcQ8G5qPaEKCq
         a5fv31X6//a0kHtXNQD80G9eXSlBfQMjLZHQ1ZCfTDfkaAmhPIU/pgqNuonr3i4ASiAL
         W0qo+7EaMKWDnTEXyDT7JhzwyShZ9TDSbPOgy6SKRAsFlh3qSr03Ptus70qjZWocJydc
         lXIg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=JrjAwoYZLatTrSpjWp1zdL2hQdofaBBegzEeSbKdEko=;
        b=PQkR3YKW8JmYIbDCeENQU+SrF/lHVRyvCfZGraCYMpdShmEv4ws4S6bkq7aKnMlONZ
         QXpvrE7sMw8hSZx0eX1bGgY40cv+kQ56P+bPRSyKPgZkSl7/kmXATFWryBLtGRdWTP95
         MTK0bz3V09YMJDCT5zyF3mxlrWRjvip4y5uHdtbv2c8eBtGK+le8sf/GefPK3W6g/mXt
         OnJF2KmU6WM2tNavTy4inqsQsZW9l7VSkqKRJt13cwleX6C209QCPkccm/PJXpil/0vi
         wan9G0h+t7pZUI/OHQy9ffEH765KdRT3vPFlD8rm4rmxt34bQTr7eMTc8dp+K117fwL7
         h++g==
X-Gm-Message-State: AA+aEWZ/x90vbiX8wXKRNp9Z/QDsVOsGdtIEarDLoPDAftjzSFGFVtvf
        6mMWeqHofbhrD7c0GryNPNbrxY73
X-Google-Smtp-Source: AFSGD/VVhhJCaiT1uNGfozFftcn27cZ33d1FPDPLZtBgFtDjqxlSezq2YBDWv0zTzkJBDiT9CFaPpw==
X-Received: by 2002:a02:85ae:: with SMTP id d43mr613221jai.70.1545064789555;
        Mon, 17 Dec 2018 08:39:49 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id w8sm4193680iom.26.2018.12.17.08.39.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:39:49 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGdmnf018585;
        Mon, 17 Dec 2018 16:39:48 GMT
Subject: [PATCH v4 05/30] xprtrdma: No qp_event disconnect
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:39:48 -0500
Message-ID: <20181217163948.24133.60342.stgit@manet.1015granger.net>
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

After thinking about this more, and auditing other kernel ULP imple-
mentations, I believe that a DISCONNECT cm_event will occur after a
fatal QP event. If that's the case, there's no need for an explicit
disconnect in the QP event handler.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |   32 --------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 -
 2 files changed, 33 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index cff3a5d..9a0a765 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -100,25 +100,6 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 }
 
 /**
- * rpcrdma_disconnect_worker - Force a disconnect
- * @work: endpoint to be disconnected
- *
- * Provider callbacks can possibly run in an IRQ context. This function
- * is invoked in a worker thread to guarantee that disconnect wake-up
- * calls are always done in process context.
- */
-static void
-rpcrdma_disconnect_worker(struct work_struct *work)
-{
-	struct rpcrdma_ep *ep = container_of(work, struct rpcrdma_ep,
-					     rep_disconnect_worker.work);
-	struct rpcrdma_xprt *r_xprt =
-		container_of(ep, struct rpcrdma_xprt, rx_ep);
-
-	xprt_force_disconnect(&r_xprt->rx_xprt);
-}
-
-/**
  * rpcrdma_qp_event_handler - Handle one QP event (error notification)
  * @event: details of the event
  * @context: ep that owns QP where event occurred
@@ -134,15 +115,6 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 						   rx_ep);
 
 	trace_xprtrdma_qp_event(r_xprt, event);
-	pr_err("rpcrdma: %s on device %s connected to %s:%s\n",
-	       ib_event_msg(event->event), event->device->name,
-	       rpcrdma_addrstr(r_xprt), rpcrdma_portstr(r_xprt));
-
-	if (ep->rep_connected == 1) {
-		ep->rep_connected = -EIO;
-		schedule_delayed_work(&ep->rep_disconnect_worker, 0);
-		wake_up_all(&ep->rep_connect_wait);
-	}
 }
 
 /**
@@ -571,8 +543,6 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 				   cdata->max_requests >> 2);
 	ep->rep_send_count = ep->rep_send_batch;
 	init_waitqueue_head(&ep->rep_connect_wait);
-	INIT_DELAYED_WORK(&ep->rep_disconnect_worker,
-			  rpcrdma_disconnect_worker);
 	ep->rep_receive_count = 0;
 
 	sendcq = ib_alloc_cq(ia->ri_device, NULL,
@@ -646,8 +616,6 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 void
 rpcrdma_ep_destroy(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 {
-	cancel_delayed_work_sync(&ep->rep_disconnect_worker);
-
 	if (ia->ri_id && ia->ri_id->qp) {
 		rpcrdma_ep_disconnect(ep, ia);
 		rdma_destroy_qp(ia->ri_id);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 3f198cd..7c1b519 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -101,7 +101,6 @@ struct rpcrdma_ep {
 	wait_queue_head_t 	rep_connect_wait;
 	struct rpcrdma_connect_private	rep_cm_private;
 	struct rdma_conn_param	rep_remote_cma;
-	struct delayed_work	rep_disconnect_worker;
 	int			rep_receive_count;
 };
 

