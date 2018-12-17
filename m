Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 221E2C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:39:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E68D22133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:39:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dZ1j9Gy+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387995AbeLQQje (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:39:34 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:56298 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727771AbeLQQje (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:39:34 -0500
Received: by mail-it1-f196.google.com with SMTP id o19so19433635itg.5;
        Mon, 17 Dec 2018 08:39:33 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=nqihSE1hg4o1H0UcWmtuHnYhVxMpkCBQQUarfYAvFW0=;
        b=dZ1j9Gy+8gVRrAamlgY0DVOq9cQRyUm6b37cshOhNQ0MV6VwuHl9ttUc1DQ/yoVUuQ
         EBY6W+lVwcK4Mcs28/p1tfekencvxR6Qd1HVP8UvVUr/xnQAd9Fsl3Ipx9wbPlEmstXk
         1zQGJBV8xFHEIK5Fcc8iqMhqwykBpTN3WYSLP3PCS/LszTrLqvcC5r1gdYMhLUDFCUuR
         6XeyMuAd9euKyIkfxraxBsgciGz7Qb8aFTxJttHCssUHyWFOo9QcC8KATazxDBVE8n7x
         A/7Z1MMXWc58HKrgkbrpU90PXhXCCka4necFIoGARgIyXckky9A77jbJsLXqL3OPEWvr
         hYxw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=nqihSE1hg4o1H0UcWmtuHnYhVxMpkCBQQUarfYAvFW0=;
        b=dRCGadXLHZhWp771gkmn3+djF3STxPbdY2o7FF3FHPlAyXsyLb7OTnVQBfbi+31QHn
         ksCuLJY4FlKPPNKhLrHxpMqYWKYoIZmB2QXk4HTpNpQI2d05GJxNHhitwRjg//7Kp9v8
         4IdEjAvJ97IgBY/6DCxpw4cxsIbL3Sw/E121dXn6ejGiihTL0qy4tKt52Ar0fMwD84V+
         YW5KbvEy8Rw/012qTb9+BXXqFHPbTbWyH5ZRwva5B36yPAyYa6Gbipdc55r3uf9zAz6b
         MeFAQonvRA9/oOSml3rq/6go70fF/bBmLcLWPAnsN+LP7Jl6ch/WsS6VbI3xVFe2T0Oc
         KYHw==
X-Gm-Message-State: AA+aEWam9ozPVlaTWGEbpf9mQN9WSzS/elY8b3StxvAYaghgLZbuCgY3
        aiqk2Ke2ieul4A2Rpu0yWAaiLGl6
X-Google-Smtp-Source: AFSGD/WzjiNiRlKpkLkl9I7Paii9UQUeW3i0ey9YzUh9MqnNJn3z+UyYnR8Xg3JUYKeXUnHulkd5Ow==
X-Received: by 2002:a24:69cd:: with SMTP id e196mr13353012itc.161.1545064773223;
        Mon, 17 Dec 2018 08:39:33 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id g12sm5637162iok.38.2018.12.17.08.39.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:39:32 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGdV6s018576;
        Mon, 17 Dec 2018 16:39:31 GMT
Subject: [PATCH v4 02/30] xprtrdma: Ensure MRs are DMA-unmapped when posting
 LOCAL_INV fails
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:39:31 -0500
Message-ID: <20181217163931.24133.44118.stgit@manet.1015granger.net>
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

The recovery case in frwr_op_unmap_sync needs to DMA unmap each MR.
frwr_release_mr does not DMA-unmap, but the recycle worker does.

Fixes: 61da886bf74e ("xprtrdma: Explicitly resetting MRs is ... ")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 20ced24..27222c0 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -563,8 +563,8 @@
 		mr = container_of(frwr, struct rpcrdma_mr, frwr);
 		bad_wr = bad_wr->next;
 
-		list_del(&mr->mr_list);
-		frwr_op_release_mr(mr);
+		list_del_init(&mr->mr_list);
+		rpcrdma_mr_recycle(mr);
 	}
 }
 

