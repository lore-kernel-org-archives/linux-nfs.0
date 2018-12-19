Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC115C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7B68B217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LZcL8/Fc"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729139AbeLSP7a (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 10:59:30 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:37563 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727829AbeLSP7a (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 10:59:30 -0500
Received: by mail-it1-f196.google.com with SMTP id b5so10052733iti.2;
        Wed, 19 Dec 2018 07:59:30 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=PXLIaALci2knYQ1gMtWCij3L4mHSL0l8lqusuVMPb0k=;
        b=LZcL8/FcSvKaLacf4DyLOT0t+5qtExUBt833v8FgKzezP+caGNLHy1s7jVgZzvTIqr
         wRbcL7IvNz4hzwPO/9LUj2y/rkzTTueUHC2IUeZVjaWwINWXRiY/KFq+Miaivu1lX/bR
         /Bfa8I14vJm0BxFm3X88C6OszOEgo/GWJgr3aDbMZS5mPVADnAZmgWuOSZg/RQYWZAyk
         /E6dgL5QV/XZG1p79URp7fD3GnxMEBxmSeJX8hR0+3d2jW9H+nV/ih65G/KkDIuoKyhb
         I6u7MA9Acx/e1fsk66gaUpMgIWU17oCpdt95FwIl8oY32H5lqwLkvXvczmPvaAns/kOn
         uUvQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=PXLIaALci2knYQ1gMtWCij3L4mHSL0l8lqusuVMPb0k=;
        b=RLcTFx8Z9/PMtBZ0uS1Y3vL31yCCfb7Bo0gDl+C2RUSOfWIOlGrD1vJZbDRoLF40eJ
         145abzAVq5k6au3+nbuK4RvJMf95RBJmyHEKXVvnOiZHn1AXASxxLbiWo8cgLfDg6W2a
         VfaNuVMo9lgBbTGTQQqUprUojOpHHj5y3nM0z8kY6d3T743SYjoDGxJW784pr/q7at+0
         x75MambuMWZ8k4I70NF83MWb7QswpJ2GTg04hXAP62UfLUYi/60QLerCwvEUWL9BDnMW
         hPVA1befXj8kk9F2IdWdTAZrjuTXXudfhXg+1DjiCZLGwLBKoH8KThdwuXh7pTe72WnT
         sS3Q==
X-Gm-Message-State: AA+aEWYyPUa4nQ9i7/exASS0UetBrrr+jfPwGwnpzRG2SLIjo/8n8YgC
        MXNA3JI+KW7EO8ICTriE79/O/RMU
X-Google-Smtp-Source: AFSGD/WaT4QvtwP68PG+NDpyakmuKJCsgfqQNSIkvHbkbmxwhaWMkZ8j4QXVccJDmpxKBMbl6vPkGA==
X-Received: by 2002:a02:97fd:: with SMTP id v58mr20818481jaj.115.1545235169858;
        Wed, 19 Dec 2018 07:59:29 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id d128sm9372345iof.37.2018.12.19.07.59.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 07:59:29 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJFxSH7025801;
        Wed, 19 Dec 2018 15:59:28 GMT
Subject: [PATCH v5 15/30] xprtrdma: Expose transport header errors
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 10:59:28 -0500
Message-ID: <20181219155928.11602.65722.stgit@manet.1015granger.net>
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

For better observability of parsing errors, return the error code
generated in the decoders to the upper layer consumer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 939f84a..8de0b9f 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1246,7 +1246,6 @@ void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
 out_badheader:
 	trace_xprtrdma_reply_hdr(rep);
 	r_xprt->rx_stats.bad_reply_count++;
-	status = -EIO;
 	goto out;
 }
 

