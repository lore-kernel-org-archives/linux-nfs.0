Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BFF8C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:42:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E08592133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:42:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sBCjh2KK"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388334AbeLQQmE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:42:04 -0500
Received: from mail-io1-f65.google.com ([209.85.166.65]:38630 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388011AbeLQQmE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:42:04 -0500
Received: by mail-io1-f65.google.com with SMTP id l14so10471549ioj.5;
        Mon, 17 Dec 2018 08:42:03 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=p6lkr/16ohwqBFo2MRfmrj0EAPREXCOKqFIKpKn96C8=;
        b=sBCjh2KK6Ku9KrJWvfE6qDN9tz6XCq/Qn+JWd2LJ1LUFeWunlgBQ8spCTLyuwsBg5d
         3RG0itlPbUAS/mRVV4XPnJOOX0KywOGJo4AG4WY/PCkQYoJAOeC12Ix5oDvIvjVRvmDK
         L8a3vCu8iaq4RDVoGqaVI4RsxH1NlA68d4tNa0NXm8Vx/b372jnKPLGb6ZLYVDCQFQvd
         C0zVFW5tPI7UArd3P8dBhJaOAVFV+d9DIYlBwApbD7E0alhfvyv1jdYytgY9PAe14jND
         TCqZU+tnuW85WFWQsGScP/8LcCATZF+dFLJrtrVBKAyEe6y2JCugEt7FoCe5C4cK1G2l
         R5XQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=p6lkr/16ohwqBFo2MRfmrj0EAPREXCOKqFIKpKn96C8=;
        b=aCbTU3mRV00KFr3Ny3cko+fs6mqkZsK9M0XftRafsY8/qYdwx/NfktFbC/9F2pHbZy
         SeeVRuqVN+tjwWHSbeH8OPUMkx0Ec9+5bX3ZXWB43Dar8zHb0/DJUq5S6b9uNL5ym0uo
         Cft0wOKDIKhxALxMaK7j5NJh0yHnT4HGpofKWfu8L+TMO7aFH+egC5N7lFW9BBf4Nb/r
         O7k3ctR5yggOPQJU3Vg/I4ez6ZGpnF7XBrLOte2I14Lo3MruYTqgtPM0B1MMHIC+iBlK
         UkzX48VhrcVvVsTzCZ8vAKq3ApALLkH88JgMhwI6kAy5hLoCf6VerbPHiJKWNZempdmi
         TJuw==
X-Gm-Message-State: AA+aEWZRXY95MjOtTnWpuJ98k32xQ/1v5RQtH8nPY0aa5/ZQ4XsmbWf1
        tYArJxr0sSYLTHR683MOOBGC049W
X-Google-Smtp-Source: AFSGD/WfmpaFlrZpKI2pgejl2Qnir7qjW5+CRlM3B1VrNchKI9hS4+hvhLugRtj1Bysfz1m+jY2q9Q==
X-Received: by 2002:a6b:3f06:: with SMTP id m6mr11097430ioa.117.1545064922786;
        Mon, 17 Dec 2018 08:42:02 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id f10sm7233182itf.41.2018.12.17.08.42.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:42:02 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGg1JE018669;
        Mon, 17 Dec 2018 16:42:01 GMT
Subject: [PATCH v4 30/30] xprtrdma: Don't leak freed MRs
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:42:01 -0500
Message-ID: <20181217164201.24133.618.stgit@manet.1015granger.net>
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

Defensive clean up. Don't set frwr->fr_mr until we know that the
scatterlist allocation has succeeded.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |   27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 35c8f62..6a56105 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -155,36 +155,39 @@ void frwr_release_mr(struct rpcrdma_mr *mr)
 int frwr_init_mr(struct rpcrdma_ia *ia, struct rpcrdma_mr *mr)
 {
 	unsigned int depth = ia->ri_max_frwr_depth;
-	struct rpcrdma_frwr *frwr = &mr->frwr;
+	struct scatterlist *sg;
+	struct ib_mr *frmr;
 	int rc;
 
-	frwr->fr_mr = ib_alloc_mr(ia->ri_pd, ia->ri_mrtype, depth);
-	if (IS_ERR(frwr->fr_mr))
+	frmr = ib_alloc_mr(ia->ri_pd, ia->ri_mrtype, depth);
+	if (IS_ERR(frmr))
 		goto out_mr_err;
 
-	mr->mr_sg = kcalloc(depth, sizeof(*mr->mr_sg), GFP_KERNEL);
-	if (!mr->mr_sg)
+	sg = kcalloc(depth, sizeof(*sg), GFP_KERNEL);
+	if (!sg)
 		goto out_list_err;
 
-	frwr->fr_state = FRWR_IS_INVALID;
+	mr->frwr.fr_mr = frmr;
+	mr->frwr.fr_state = FRWR_IS_INVALID;
 	mr->mr_dir = DMA_NONE;
 	INIT_LIST_HEAD(&mr->mr_list);
 	INIT_WORK(&mr->mr_recycle, frwr_mr_recycle_worker);
-	sg_init_table(mr->mr_sg, depth);
-	init_completion(&frwr->fr_linv_done);
+	init_completion(&mr->frwr.fr_linv_done);
+
+	sg_init_table(sg, depth);
+	mr->mr_sg = sg;
 	return 0;
 
 out_mr_err:
-	rc = PTR_ERR(frwr->fr_mr);
+	rc = PTR_ERR(frmr);
 	trace_xprtrdma_frwr_alloc(mr, rc);
 	return rc;
 
 out_list_err:
-	rc = -ENOMEM;
 	dprintk("RPC:       %s: sg allocation failure\n",
 		__func__);
-	ib_dereg_mr(frwr->fr_mr);
-	return rc;
+	ib_dereg_mr(frmr);
+	return -ENOMEM;
 }
 
 /**

