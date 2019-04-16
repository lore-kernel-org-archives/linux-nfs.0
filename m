Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6150EC10F14
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:38:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 31BB8217F9
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:38:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BYgmCZQu"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726215AbfDPNie (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 09:38:34 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:53680 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726751AbfDPNie (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2019 09:38:34 -0400
Received: by mail-it1-f196.google.com with SMTP id y204so33008066itf.3;
        Tue, 16 Apr 2019 06:38:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=XbA0YeHKcjeln+yWufNlUGVKirWee5UvaseV3tRtSzs=;
        b=BYgmCZQuh37VkjtzGAELwi0TcItzWHhoyjZFCrCdJswiz9E1GgioCV3bXihsrtQgPE
         l7u2vcPpCeRt5gBYTLrbS2SCP90cFJPzYixBPY8uYeJfcAJgWQshDzKOoLWpV6xb1/0O
         weqx+I6v7hgUqYddw+u9pxlYTaH+DjAENhQlk+f0xfzUOIYs0ASPG4LxFhsknJS+FHEm
         T+Tasw3vyxnU8S0NLuwwTyIHASLzOH7nqxg+vDdXF9ozwPx8lrxaIbAvihFZ/SvG4LOD
         DEHmDcwel+7jkOjDAoPAWfY/Btt3zCZWDyXrgb+31Xdv/ot+PDsCtggSwyUoEaM4q7A0
         52eA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=XbA0YeHKcjeln+yWufNlUGVKirWee5UvaseV3tRtSzs=;
        b=lvjSogxUMAsNbL01D6OAi+bhob8kwGivm/6XarY8ztuhBDszMBXc3jAlOruwS/4y98
         IDTyCLH1HYaPBFYHbY205BQWTq3CMzO7Z1ex1p9JWdHVWZsVo6WLrts1TxfgMZkd/zoG
         47XfvlXjekgbJ5VxYBJDEXJBiczu+7hfocDOk2qY/HatvT9vwObrs7180fYO6AbLqBWz
         j2UXHXEEwvLIiKKMQFWDRwpE0wdeNpeZIUEE+gAfxXNxZH/grpXDTlOAvmmR77j29Ju5
         HZ4BMnYpbqTL54F30ANxdUl1xCk/C/z0Ny8Wst1sI5O+bYBazMlWjQvO4r52UuddH7eu
         ixfg==
X-Gm-Message-State: APjAAAUi+r4k4po2Txsvi24tcZxEg9mBtzZwsVq1FnMNCkRBkbHediG2
        l80HoEzYyBgEKTd5wi6rETbBOoOW
X-Google-Smtp-Source: APXvYqxD4Loo9vAVWDde5cNkn7i1L+m9DzzKnHDAfAuvvnQlR+PtRM/MtrgX6/UObfGlYv8RdVLCIw==
X-Received: by 2002:a24:4290:: with SMTP id i138mr27645133itb.129.1555421913521;
        Tue, 16 Apr 2019 06:38:33 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id r184sm1453339ita.3.2019.04.16.06.38.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:38:33 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3GDcW1u021253;
        Tue, 16 Apr 2019 13:38:32 GMT
Subject: [PATCH v2 19/21] xprtrdma: Remove pr_err() call sites from
 completion handlers
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Tue, 16 Apr 2019 09:38:32 -0400
Message-ID: <20190416133832.23113.34456.stgit@manet.1015granger.net>
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

Clean up: rely on the trace points instead.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |   23 ++++-------------------
 net/sunrpc/xprtrdma/verbs.c    |    9 ---------
 2 files changed, 4 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 1d369b6..794ba4c 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -297,15 +297,6 @@ size_t frwr_maxpages(struct rpcrdma_xprt *r_xprt)
 		     (ia->ri_max_segs - 2) * ia->ri_max_frwr_depth);
 }
 
-static void
-__frwr_sendcompletion_flush(struct ib_wc *wc, const char *wr)
-{
-	if (wc->status != IB_WC_WR_FLUSH_ERR)
-		pr_err("rpcrdma: %s: %s (%u/0x%x)\n",
-		       wr, ib_wc_status_msg(wc->status),
-		       wc->status, wc->vendor_err);
-}
-
 /**
  * frwr_wc_fastreg - Invoked by RDMA provider for a flushed FastReg WC
  * @cq:	completion queue (ignored)
@@ -320,10 +311,8 @@ size_t frwr_maxpages(struct rpcrdma_xprt *r_xprt)
 			container_of(cqe, struct rpcrdma_frwr, fr_cqe);
 
 	/* WARNING: Only wr_cqe and status are reliable at this point */
-	if (wc->status != IB_WC_SUCCESS) {
+	if (wc->status != IB_WC_SUCCESS)
 		frwr->fr_state = FRWR_FLUSHED_FR;
-		__frwr_sendcompletion_flush(wc, "fastreg");
-	}
 	trace_xprtrdma_wc_fastreg(wc, frwr);
 }
 
@@ -341,10 +330,8 @@ size_t frwr_maxpages(struct rpcrdma_xprt *r_xprt)
 						 fr_cqe);
 
 	/* WARNING: Only wr_cqe and status are reliable at this point */
-	if (wc->status != IB_WC_SUCCESS) {
+	if (wc->status != IB_WC_SUCCESS)
 		frwr->fr_state = FRWR_FLUSHED_LI;
-		__frwr_sendcompletion_flush(wc, "localinv");
-	}
 	trace_xprtrdma_wc_li(wc, frwr);
 }
 
@@ -363,12 +350,10 @@ size_t frwr_maxpages(struct rpcrdma_xprt *r_xprt)
 						 fr_cqe);
 
 	/* WARNING: Only wr_cqe and status are reliable at this point */
-	if (wc->status != IB_WC_SUCCESS) {
+	if (wc->status != IB_WC_SUCCESS)
 		frwr->fr_state = FRWR_FLUSHED_LI;
-		__frwr_sendcompletion_flush(wc, "localinv");
-	}
-	complete(&frwr->fr_linv_done);
 	trace_xprtrdma_wc_li_wake(wc, frwr);
+	complete(&frwr->fr_linv_done);
 }
 
 /**
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 0d0c335..fcbcd4a 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -135,11 +135,6 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 
 	/* WARNING: Only wr_cqe and status are reliable at this point */
 	trace_xprtrdma_wc_send(sc, wc);
-	if (wc->status != IB_WC_SUCCESS && wc->status != IB_WC_WR_FLUSH_ERR)
-		pr_err("rpcrdma: Send: %s (%u/0x%x)\n",
-		       ib_wc_status_msg(wc->status),
-		       wc->status, wc->vendor_err);
-
 	rpcrdma_sendctx_put_locked(sc);
 }
 
@@ -177,10 +172,6 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	return;
 
 out_flushed:
-	if (wc->status != IB_WC_WR_FLUSH_ERR)
-		pr_err("rpcrdma: Recv: %s (%u/0x%x)\n",
-		       ib_wc_status_msg(wc->status),
-		       wc->status, wc->vendor_err);
 	rpcrdma_recv_buffer_put(rep);
 }
 

