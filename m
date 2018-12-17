Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77F70C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:39:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 474E62133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:39:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="N3ZkeNBB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387981AbeLQQj3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:39:29 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:38295 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2387737AbeLQQj3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:39:29 -0500
Received: by mail-it1-f194.google.com with SMTP id h65so20898547ith.3;
        Mon, 17 Dec 2018 08:39:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=YnmL2QcytZ7nDWQP0b2qARfKenfoawrMQNmn+bhvVt8=;
        b=N3ZkeNBBhiaYv1gQ/+IR2BmE6eYN0wdBNvtzKlaXTr9gWsjLolAj3AMFdcuOxMdX79
         SXoIN1K8DVwgGGXoRp4BYXj8D6iNf63OEePvXqzoeaUj9Mu8eSrWFvoF3d+YWGulzO6U
         4fAuUuxU6r4KeuThjFrYx+9RMf79SM97jhiiXd6OCjWsQxdWg4HbvWwjLaFwHicpdpC6
         p4YDxCy83s+4tJN2heCePs/lFGOMUvJcdQ0hMjCQ72rrR2O0lX4USBZhy9QmU0Y96EgV
         9bTDcBXrWCpQsL+HATstiLtBMnyzWCfxNpY4V/GdMemI3Ez5Sx2PTaj/pMNb2C9Aj5oI
         JzGw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=YnmL2QcytZ7nDWQP0b2qARfKenfoawrMQNmn+bhvVt8=;
        b=EaKEoPhfIQE4i1YFHdrX4FsRX4UoE5Ovaqapvh9EXpnbpiMrZfl/As+WEjBLxLLGJY
         uIZWr/2yClGxRmhTJ0seXoVIfxSmx0bB7h+H5cinY6eAv5V9ergnKbCBhIGGKlUp0AIp
         JhVwvRRXR+y9feK25jRe1IQGH4ve7xU2id32uHTA0IgQlMtGuK4AisF/v/xoQPOmLBCJ
         QLabOC84dVdLByCD/qIjY2i+gH2b2SQ77y/msv+2xY1OtcEpMn77tJ4AISesQPDy3u7c
         ifkSVu+tc/qtTwZRPau4BBJfyZ36V7o/dFjx133y7dtUUTjQmvbXYQcSFCe2+Hrdt2Kt
         3ojQ==
X-Gm-Message-State: AA+aEWZzStczlN86DV15J06QtNp/0BaNZGnw0D150izQFd/Gy7Tvz+tI
        q2DNSylENqSxzUnOs8iCuk6xJlis
X-Google-Smtp-Source: AFSGD/WcSY+x9u+0qS5TUlWzaQjykI+ezOYQ74A0MpziArE/Dm9bd/b5hhCQpYzSw9Mm75VIDsRShg==
X-Received: by 2002:a24:8a44:: with SMTP id v65mr12430160itd.67.1545064767874;
        Mon, 17 Dec 2018 08:39:27 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id k64sm9754861itb.7.2018.12.17.08.39.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:39:27 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGdQtA018573;
        Mon, 17 Dec 2018 16:39:26 GMT
Subject: [PATCH v4 01/30] xprtrdma: Yet another double DMA-unmap
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:39:26 -0500
Message-ID: <20181217163926.24133.67489.stgit@manet.1015granger.net>
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

While chasing yet another set of DMAR fault reports, I noticed that
the frwr recycler conflates whether or not an MR has been DMA
unmapped with frwr->fr_state. Actually the two have only an indirect
relationship. It's in fact impossible to guess reliably whether the
MR has been DMA unmapped based on its fr_state field, especially as
the surrounding code and its assumptions have changed over time.

A better approach is to track the DMA mapping status explicitly so
that the recycler is less brittle to unexpected situations, and
attempts to DMA-unmap a second time are prevented.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@vger.kernel.org # v4.20
---
 net/sunrpc/xprtrdma/frwr_ops.c |    6 ++++--
 net/sunrpc/xprtrdma/verbs.c    |    9 ++++++---
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index fc6378cc..20ced24 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -117,15 +117,15 @@
 frwr_mr_recycle_worker(struct work_struct *work)
 {
 	struct rpcrdma_mr *mr = container_of(work, struct rpcrdma_mr, mr_recycle);
-	enum rpcrdma_frwr_state state = mr->frwr.fr_state;
 	struct rpcrdma_xprt *r_xprt = mr->mr_xprt;
 
 	trace_xprtrdma_mr_recycle(mr);
 
-	if (state != FRWR_FLUSHED_LI) {
+	if (mr->mr_dir != DMA_NONE) {
 		trace_xprtrdma_mr_unmap(mr);
 		ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
 				mr->mr_sg, mr->mr_nents, mr->mr_dir);
+		mr->mr_dir = DMA_NONE;
 	}
 
 	spin_lock(&r_xprt->rx_buf.rb_mrlock);
@@ -150,6 +150,8 @@
 	if (!mr->mr_sg)
 		goto out_list_err;
 
+	frwr->fr_state = FRWR_IS_INVALID;
+	mr->mr_dir = DMA_NONE;
 	INIT_LIST_HEAD(&mr->mr_list);
 	INIT_WORK(&mr->mr_recycle, frwr_mr_recycle_worker);
 	sg_init_table(mr->mr_sg, depth);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 3ddba94..b9bc7f9 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1329,9 +1329,12 @@ struct rpcrdma_mr *
 {
 	struct rpcrdma_xprt *r_xprt = mr->mr_xprt;
 
-	trace_xprtrdma_mr_unmap(mr);
-	ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
-			mr->mr_sg, mr->mr_nents, mr->mr_dir);
+	if (mr->mr_dir != DMA_NONE) {
+		trace_xprtrdma_mr_unmap(mr);
+		ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
+				mr->mr_sg, mr->mr_nents, mr->mr_dir);
+		mr->mr_dir = DMA_NONE;
+	}
 	__rpcrdma_mr_put(&r_xprt->rx_buf, mr);
 }
 

