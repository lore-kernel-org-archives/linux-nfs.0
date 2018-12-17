Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C0F4C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5A5A32133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HgSPVF3L"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388309AbeLQQlL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:41:11 -0500
Received: from mail-io1-f66.google.com ([209.85.166.66]:45515 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388011AbeLQQlL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:41:11 -0500
Received: by mail-io1-f66.google.com with SMTP id p7so2844910iog.12;
        Mon, 17 Dec 2018 08:41:09 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=dTTFxQBHqNac1U654cQS+n8MCI79WsiCTWna3Rmj/a4=;
        b=HgSPVF3LHf1Tw3DLhUzfIWtz+XSknqmnvQcGFHnL8kGyzzPP3dsZoPoY5X/ETcV+qk
         yCEZ7SQ1Hf6RKDe8QxWWjjKeKx/DHbzwbY0m2f1ap7PbEbMKJGTjEo9u+SWLYmHSjbwh
         BFr3D2u8DPOxxp3Kzqg1NrkpENcwCntX2OpqKM2vNkmvZ1dk4R/poUZp1qs3DUeZ7+1F
         3lN76airxu1u5D9bHRDsxTrcgkKSQfAnkYEGOnMRQkvGJuIyjEE0BKHGyxiCK+L/NrtR
         b3HswpMwTWcy4ghMLvBq7EJmAKX36gYbTXaXtewwAh9GEsI9Q81w4Jg9uuQbcCB//Pbw
         gZFA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=dTTFxQBHqNac1U654cQS+n8MCI79WsiCTWna3Rmj/a4=;
        b=kKLqD4BC5x9GWsVkaEWZuiqh7PMOj9LdUAovsrcW3Lb0ytHT1ldfZ/3dHUgj+Dq86J
         Eciuhu/FGHtc/DCARyA4EV0qDl6qKLYDWH5ejv8qkZRz4CGY43fFE+SN83ZhQ1iqcNYA
         tkmoFY7niSOUBTJskHQrMbgO4F5HlLdr4nzH1+vT9znaOjumEcHlUtgG9jrsyetaMjyg
         xAcp8C8ix2jwiiab9FniaokVue5+l/m41adz8umjQWsEsj+wUKVzywZJEyiIpzWkcCxc
         wbVY85+OLAC4DAQW3qVIJg7z5TSj+X+z9r8qMR5I2hpIFvev5zqXYye4RIpU/Vnz4mxU
         gqZg==
X-Gm-Message-State: AA+aEWaBrYNPwN/FXGK1uLu63UVq/Y26QFdixCHiIgOv+w6TarkffkVw
        JCBpGXB0RYn2XZ61YfcnPYgBgoWU
X-Google-Smtp-Source: AFSGD/USqtZI/g3f88Q4MvhCwmJZRrc/IZunthxLM4nRklUr5w3jdIAGwhxig2uQsjgGR/Ze8V6l1g==
X-Received: by 2002:a5e:a513:: with SMTP id 19mr11971392iog.151.1545064869409;
        Mon, 17 Dec 2018 08:41:09 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id s15sm6093300ioe.52.2018.12.17.08.41.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:41:08 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGf8xj018639;
        Mon, 17 Dec 2018 16:41:08 GMT
Subject: [PATCH v4 20/30] xprtrdma: Relocate the xprtrdma_mr_map trace points
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:41:08 -0500
Message-ID: <20181217164108.24133.31649.stgit@manet.1015granger.net>
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

