Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02974C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C3A5F217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lBM/BI0G"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728067AbeLSP76 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 10:59:58 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:51765 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727847AbeLSP76 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 10:59:58 -0500
Received: by mail-it1-f194.google.com with SMTP id w18so10060124ite.1;
        Wed, 19 Dec 2018 07:59:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=dTTFxQBHqNac1U654cQS+n8MCI79WsiCTWna3Rmj/a4=;
        b=lBM/BI0GMQ8MpGxxKyXkPi3Cvs6acPc3ZV5zxKTG1Pj0jAFgKIyKCD5/97USTUwrLI
         V56a+y9SYj/GsL+JjzqwZXmD12LzFvKFQLNJd3p3VZRFqEzWt5y7yDKJGPtn+A1wT93b
         e8o3oYEM03r5Zu5P6fgvjppDXbbOJIfDqucBcQ6F/oxosMJBlRkB1P07nxdZR7Hq3CGe
         Rx2OBeZXybQcf7mlXni+vB59XgLi0XbBiB7mriX8VlzAEESHm8nWAYkjmuzOuQ60oGzT
         6YQKuXEFxVbqEBuYDONxOgGtypSmZsAZNx8fIlk/VyZhgNSdCNcMIw0l5NEX+xicLiDV
         UWiA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=dTTFxQBHqNac1U654cQS+n8MCI79WsiCTWna3Rmj/a4=;
        b=hYvVICu1zZU1eacDb4y/4uHXEmdNisBvedQExFXK0CnA1CVui1F+/LAuEmoabKzr5z
         dc/sUjq/pgDPKKx8pDobFJB3rq5bl+rM4HKIlOsTh7cHWtnqLohdSE9vQCD85sNS4Vy6
         1g1FpjIlR0JztsvO8xCYHc6bn8SQG8X5aYW622D+sFj8SoF71x6rjBTPdGgCC7rB553a
         H3JpbTscOj4EBdxCe87PKLLHHkvMF9VZo2ksanxRma7eKwAGx2OqUxgYvAgpYlI3hGTJ
         29ydQt+Zj1P9CRsvc/QQTEudb8ivlLWOxWMbKAI3Tjs1q6jyeQmOzAM4UZCCl6CeYBUO
         k17A==
X-Gm-Message-State: AA+aEWaLm0PP5dkyYLwoKPMZxD7etQYi/ggWxfNc2u4+pvYlmhn95gRj
        eE8cYguj8EoQpM9BwY6XO1o=
X-Google-Smtp-Source: AFSGD/WmX03Eb361gaDucfcqfCCfXlhPJyD13b/g3aSTe8rLNU6+Uo4CKRr7dqXQLZpcSgJxEjlJwg==
X-Received: by 2002:a24:6115:: with SMTP id s21mr7428968itc.62.1545235196584;
        Wed, 19 Dec 2018 07:59:56 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id r63sm3791061ita.2.2018.12.19.07.59.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 07:59:56 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJFxt01025816;
        Wed, 19 Dec 2018 15:59:55 GMT
Subject: [PATCH v5 20/30] xprtrdma: Relocate the xprtrdma_mr_map trace points
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 10:59:55 -0500
Message-ID: <20181219155955.11602.19265.stgit@manet.1015granger.net>
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

The mr_map trace points were capturing information about the previous
use of the MR rather than about the segment that was just mapped.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 97f88bb..1f508f4 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -438,7 +438,6 @@ struct rpcrdma_mr_seg *frwr_map(struct rpcrdma_xprt *r_xprt,
 	mr->mr_nents = ib_dma_map_sg(ia->ri_device, mr->mr_sg, i, mr->mr_dir);
 	if (!mr->mr_nents)
 		goto out_dmamap_err;
-	trace_xprtrdma_mr_map(mr);
 
 	ibmr = frwr->fr_mr;
 	n = ib_map_mr_sg(ibmr, mr->mr_sg, mr->mr_nents, NULL, PAGE_SIZE);
@@ -460,6 +459,7 @@ struct rpcrdma_mr_seg *frwr_map(struct rpcrdma_xprt *r_xprt,
 	mr->mr_handle = ibmr->rkey;
 	mr->mr_length = ibmr->length;
 	mr->mr_offset = ibmr->iova;
+	trace_xprtrdma_mr_map(mr);
 
 	*out = mr;
 	return seg;

