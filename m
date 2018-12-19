Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B54AC43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:00:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 08025217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:00:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AOJKLJlw"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729184AbeLSQAv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 11:00:51 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:36769 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728222AbeLSQAu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 11:00:50 -0500
Received: by mail-it1-f194.google.com with SMTP id c9so10064191itj.1;
        Wed, 19 Dec 2018 08:00:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=p6lkr/16ohwqBFo2MRfmrj0EAPREXCOKqFIKpKn96C8=;
        b=AOJKLJlwwC88ljQZwMp3y3VGhjNCqSSBH3zQMZRzrZ/bZlnhoTIyRPliiVBbLgN5M8
         EfljH4JcPwlw1AzxkPYLxZZiZtPda7nu58EoDK1pdxTAenXOufhnPljViGnaTSa0Y2fN
         2SfnJoGNNvHgrppiovBLuQWh9jhyqCJiKYbOEHU85YqmvMxtBlLG1maUh+JE/HFwOdYZ
         KCYA2dU7LcsG5cktIStFxAnrBiCLvinPLfzUoZuFetDosNnlB2AKJ+3ELUegpKjV+PxH
         L4xlpdSIdPv9uSCcJujLGeKH5iju1mQfXSRgequZjbdVLWd9lUcuRqwnLHVy4l9xYSip
         DLKA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=p6lkr/16ohwqBFo2MRfmrj0EAPREXCOKqFIKpKn96C8=;
        b=UT+5xOmKqBH00XZxs8hGb5wv2+E57u2SO2Vdi+HqVlqqjJZTbYqb/hjyS1dqltQ2gD
         eUF8AkyI+Lay0svdvr41GU66tGFfXxLlsvyYUX7MquCFaTvv1elnmzjC3iz5t6vx7eHp
         94AGFEU5kmCEJ6wkyAuCHn2/mfjwEebPlDvW0+sUKdMol0wMwl1f/NBDfAVH/FrrHpb9
         oHDPWOy2i1Bx7QqreCkJdkQxGO4WcQif1tN3Sph8CyNjqkaB8wxYYLvizDKPjnvl0pxE
         8zaPhuLyoqFaubcac3sWn8FVxJIWyy/YeRoRjkwFw8ZAwQd3o+MjJskP47pKJ/b3XUtv
         7/MA==
X-Gm-Message-State: AA+aEWbOxm4m2XkQRCn64Uk+iG9zSKY3ufs88D9JmCJ0zABaFiIktupE
        2NvgL/WdxNx8EyaIT0l4aL7aeMYR
X-Google-Smtp-Source: AFSGD/VUUgK/+75VvJD5sgKn5iR1ePaG1v2YGaNYd3yfkYhYMrNwX2cURmBOdNZlXGzKl/YjtgXCKw==
X-Received: by 2002:a24:80cc:: with SMTP id g195mr6693737itd.178.1545235249698;
        Wed, 19 Dec 2018 08:00:49 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id b5sm8707486ioc.21.2018.12.19.08.00.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 08:00:49 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJG0meB025856;
        Wed, 19 Dec 2018 16:00:48 GMT
Subject: [PATCH v5 30/30] xprtrdma: Don't leak freed MRs
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 11:00:48 -0500
Message-ID: <20181219160048.11602.91563.stgit@manet.1015granger.net>
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

