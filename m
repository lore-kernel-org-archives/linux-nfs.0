Return-Path: <SRS0=RSPU=QN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5D3CC169C4
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 17:01:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A16A420823
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 17:01:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fOt2C9r3"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731441AbfBFRBB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Feb 2019 12:01:01 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:37118 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731439AbfBFRBB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2019 12:01:01 -0500
Received: by mail-it1-f196.google.com with SMTP id b5so7875110iti.2;
        Wed, 06 Feb 2019 09:01:00 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=kIriWFrndLdcRkaM+0K/Ws6OyDLWKyKbg6er7snJL3Y=;
        b=fOt2C9r360flc+PyZFRu35IYq4QgkGvVjMGzNxSmQOI32isfjr6dQLnVjvs6OBWw+x
         Va5cZGs/IYZ+Fn2zf1IokxWAFej+mWEcPpFAvVXP+0JuQ0s18wIyQPV1E1yNIewZV7FF
         JmhUCOJ1+7wmgr6ihb5XhB4Ssg6UytJnNZ47puVJLq3otuLAsKja1ReL0g0UxE5DGIPN
         pRe7XtskvhQcYOc9ZtMsKySeOppEtaOQpxlOefzsu+2QGVbVjtZuQzdPDVeili+Iwnhg
         Stn0+7S6ZqRqSAP3+A0lB2U3nnosyhRL0eleBVy1LiLW6TYXXvkYXAZrCthTD02bSiO6
         dafg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=kIriWFrndLdcRkaM+0K/Ws6OyDLWKyKbg6er7snJL3Y=;
        b=WcpzMabz+XGP66C65d0Ak8/nQbsSnWXsLhRdxgpig4+7WWdJDfNZKuiIB2DyufII19
         7nfhulE/NtBayIbP1+WROvlmMbZ1uS1xT5hU0LbowY1cXRjohkM5zX45E+LmDYVZJ8Up
         3PL02fopHJyi1a15U1OW6qWmjAGAvAul0y2wH1EuohDBbJn/jSPw8pAioC5rUzUnyNzs
         MITSxsoKJRz6orYKT3XR54IAL3wfAUFijAl1FACVfJaUvvLkhcZIuqERA9m58WQJj4he
         xTINwNPMFhlWZwqfKFIXrpbaki68UOiRIeeO0nleAn5GjUNXnuV9rZb06MrxNIZHg2d/
         A4AA==
X-Gm-Message-State: AHQUAuZQA1jdXG4wEIPaUWgrOQjZcHH5Ntewfr+pJrsNBv24gIAx/D0v
        Vqw+nxXsOv0sg9fJbMG7oxXwwnnn
X-Google-Smtp-Source: AHgI3IYRDl9Gj10sdUdsCyXG1BTw/E8OY+ItNgvl/81RHDBemUxPfA0T52AlSg1SPuzTgRh3pV4bvw==
X-Received: by 2002:a24:214a:: with SMTP id e71mr2911945ita.60.1549472459360;
        Wed, 06 Feb 2019 09:00:59 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id u19sm3114320iog.17.2019.02.06.09.00.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 09:00:58 -0800 (PST)
Received: from klimt.1015granger.net (klimt.1015granger.net [192.168.1.55])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x16H0v9a016045;
        Wed, 6 Feb 2019 17:00:57 GMT
Subject: [PATCH 1 2/2] svcrdma: Remove syslog warnings in work completion
 handlers
From:   Chuck Lever <chuck.lever@oracle.com>
To:     bfields@fieldses.org
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 06 Feb 2019 12:00:57 -0500
Message-ID: <20190206170057.27481.24007.stgit@klimt.1015granger.net>
In-Reply-To: <20190206170018.27481.32275.stgit@klimt.1015granger.net>
References: <20190206170018.27481.32275.stgit@klimt.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

These can result in a lot of log noise, and are able to be triggered
by client misbehavior. Since there are trace points in these
handlers now, there's no need to spam the log.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    9 +--------
 net/sunrpc/xprtrdma/svc_rdma_rw.c        |   11 +----------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    4 ----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 -----
 4 files changed, 2 insertions(+), 27 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 3ebb158..65e2fb9 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -272,11 +272,8 @@ bool svc_rdma_post_recvs(struct svcxprt_rdma *rdma)
 			return false;
 		ctxt->rc_temp = true;
 		ret = __svc_rdma_post_recv(rdma, ctxt);
-		if (ret) {
-			pr_err("svcrdma: failure posting recv buffers: %d\n",
-			       ret);
+		if (ret)
 			return false;
-		}
 	}
 	return true;
 }
@@ -322,10 +319,6 @@ static void svc_rdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
 	goto out;
 
 flushed:
-	if (wc->status != IB_WC_WR_FLUSH_ERR)
-		pr_err("svcrdma: Recv: %s (%u/0x%x)\n",
-		       ib_wc_status_msg(wc->status),
-		       wc->status, wc->vendor_err);
 post_err:
 	svc_rdma_recv_ctxt_put(rdma, ctxt);
 	set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
index c357536..4696da0 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -213,13 +213,8 @@ static void svc_rdma_write_done(struct ib_cq *cq, struct ib_wc *wc)
 	atomic_add(cc->cc_sqecount, &rdma->sc_sq_avail);
 	wake_up(&rdma->sc_send_wait);
 
-	if (unlikely(wc->status != IB_WC_SUCCESS)) {
+	if (unlikely(wc->status != IB_WC_SUCCESS))
 		set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
-		if (wc->status != IB_WC_WR_FLUSH_ERR)
-			pr_err("svcrdma: write ctx: %s (%u/0x%x)\n",
-			       ib_wc_status_msg(wc->status),
-			       wc->status, wc->vendor_err);
-	}
 
 	svc_rdma_write_info_free(info);
 }
@@ -278,10 +273,6 @@ static void svc_rdma_wc_read_done(struct ib_cq *cq, struct ib_wc *wc)
 
 	if (unlikely(wc->status != IB_WC_SUCCESS)) {
 		set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
-		if (wc->status != IB_WC_WR_FLUSH_ERR)
-			pr_err("svcrdma: read ctx: %s (%u/0x%x)\n",
-			       ib_wc_status_msg(wc->status),
-			       wc->status, wc->vendor_err);
 		svc_rdma_recv_ctxt_put(rdma, info->ri_readctxt);
 	} else {
 		spin_lock(&rdma->sc_rq_dto_lock);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index cf51b8f..6fb2dd8 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -272,10 +272,6 @@ static void svc_rdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
 	if (unlikely(wc->status != IB_WC_SUCCESS)) {
 		set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
 		svc_xprt_enqueue(&rdma->sc_xprt);
-		if (wc->status != IB_WC_WR_FLUSH_ERR)
-			pr_err("svcrdma: Send: %s (%u/0x%x)\n",
-			       ib_wc_status_msg(wc->status),
-			       wc->status, wc->vendor_err);
 	}
 
 	svc_xprt_put(&rdma->sc_xprt);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 4cbb37d..6f9f465 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -593,11 +593,6 @@ static void __svc_rdma_free(struct work_struct *work)
 	if (rdma->sc_qp && !IS_ERR(rdma->sc_qp))
 		ib_drain_qp(rdma->sc_qp);
 
-	/* We should only be called from kref_put */
-	if (kref_read(&xprt->xpt_ref) != 0)
-		pr_err("svcrdma: sc_xprt still in use? (%d)\n",
-		       kref_read(&xprt->xpt_ref));
-
 	svc_rdma_flush_recv_queues(rdma);
 
 	/* Final put of backchannel client transport */

