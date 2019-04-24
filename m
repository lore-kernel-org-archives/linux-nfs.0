Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C476CC282CE
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:40:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9792D21773
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:40:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ijqLw09y"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727335AbfDXNkd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:40:33 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:51619 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730481AbfDXNkd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:40:33 -0400
Received: by mail-it1-f196.google.com with SMTP id s3so6378154itk.1;
        Wed, 24 Apr 2019 06:40:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=XbA0YeHKcjeln+yWufNlUGVKirWee5UvaseV3tRtSzs=;
        b=ijqLw09yaZArijz1veJg4B9/R4dWu+dha06VPgofgvco1Wzr2djbGIV9XXidWGlG1G
         8cBF9wU2hNxqyZ2TwKfp7wq9dApuPMMwwdXgZU/wivZvNH5Z4bpLYks0RsisJtVOYlGS
         aSFQ+XnDDHcAjKTBEbVH/ZGQHbWCKceAFGPE9xrh2NEsMMT5N4RJtEXs5n7OknscKl82
         T9QlMwSc1SG8dtkVquR5gH+Tq5/Cz6bvlHCK1F17xa8KWdqmSBpX0EkaLnP67lsUM0yC
         gXj9GoGqyZt77x/IYuQ6kTLgvClc4ibiwF8g2Lfi3jmG6R2BPTaAeSo1aa9X0WAH3hII
         Jqww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=XbA0YeHKcjeln+yWufNlUGVKirWee5UvaseV3tRtSzs=;
        b=XMuKc2fDXlUKn03ihFaStKPu5lXDxzrYIAK+fuRk/zN/mR0/LTGzOe2Ecd5ot6oJGm
         zWk3CQF0uetUmUrgX03ZI9VhoITmlCpweztD1hjBEbm40OVkAm5sd+8A06PkFPiLiAUQ
         3R3DUJ9WOv0+ZFDmKI8wp1BDkt2407/dkplscAGdrIcN90HWKebn+amLBO3oizN1vAlC
         HVw+ucCvWDeqZHZhqDmLUPHmnB7oP0jN8wNceym2YVyFzQHiCrGQrbw1im9/8XgWbFGm
         /RaAxExKH+rlN14bLwfvO5SRkmxnUq2UdxyiSwiEd9PGWY+tGhyboufSy32I1rKZ1Grx
         YNTQ==
X-Gm-Message-State: APjAAAXTd1CCwU3AfDmTgjdjhWHUXHMm28aoZNTWtI/pW1Q0Je6p5ewu
        85/VtwWFbyy6nuZ35brMViV07si8
X-Google-Smtp-Source: APXvYqwlwz3dLeJb5qhKyVVI0hrWmgLbJQKUUa2SPRaNWPq+LLHpxPrcbjEMz15DjjoxvuQd45D3IA==
X-Received: by 2002:a24:5ccf:: with SMTP id q198mr1140706itb.130.1556113232483;
        Wed, 24 Apr 2019 06:40:32 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id q2sm11188430ita.0.2019.04.24.06.40.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:40:32 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODeVMo011334;
        Wed, 24 Apr 2019 13:40:31 GMT
Subject: [PATCH v3 19/21] xprtrdma: Remove pr_err() call sites from
 completion handlers
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:40:31 -0400
Message-ID: <20190424134031.5077.82799.stgit@manet.1015granger.net>
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
 

