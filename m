Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73C4DC169C4
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:23:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 44775218F0
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 16:23:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QagsoVhW"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728756AbfBKQXt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 11:23:49 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:37136 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726896AbfBKQXq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 11:23:46 -0500
Received: by mail-it1-f196.google.com with SMTP id b5so27654889iti.2;
        Mon, 11 Feb 2019 08:23:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=U4ZUHX4RZTzHr/pCFWygCgvoojqIJaWJXh208nHB5rw=;
        b=QagsoVhWSASzBtlwuvbPTjZ6u2v05f4hnTyeLeNVuCgf75UBRFhz+Aky72yFeENJxq
         Kr6l1HsSQOrG8gH3IQu/glx4PeS4s41H9z/7jKVDdcbZp4lfxXL+uxe/dQu1w+KOIqFp
         ZtZ7yNSOBxXd73Dd+rKsbEiih+g1BKZtH+3mSwhb52mvtr4vKpChFOTntwEHiSfOofM5
         uVScX8kg4oPqIZ7d2nz1vrHQoVUnkSvSQQoYC3VKiZbu/nbl1tFlRBFUxZN7m0dPIUn5
         1Ba/xOcr4nbacH/Bq43WDcsj4InBlK4osd/JlR96PlyAukomO0dOUNXZmUOrYe4AsMQd
         uxBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=U4ZUHX4RZTzHr/pCFWygCgvoojqIJaWJXh208nHB5rw=;
        b=HmYOCuecvPlYofo/ucrutmDwPhvGckuVWLkIwVH/j+PNeMiz+9q6PWDYNdghZzJRsq
         NasVqut7LMfBAQ3w5WKu+6gSmfMptMSs1n80wJdIc43vXvz7LyLSFvBVBWfkGbdchzY/
         ICFqTr9DCR0NtY2ObcJKjpPgyobAh4TaNLg98iIWEw1AlgBZfRTN9x+qzvaGBtsR1gwk
         /1EDK0APJatDALLCSPLesg24PSdZi3wICEwCtrxyJI5Sqn1Eh9UFCfjiwyY6LIkuehrF
         i+XyS7Z3zR8jY2CIDAwPbOk1tK4xA3Ygbik/+9lVOW9IS8zpNju1qSWCmxxVXAsP9QQB
         4bfA==
X-Gm-Message-State: AHQUAubQHqrJdzbiPo2g1skz4o6HOkvbMalNZZgy57qS9UmZVGgZGS5M
        qDcj0znWqQ8M1cY05M7iL6DDX2XV
X-Google-Smtp-Source: AHgI3IZpdReV9GZ4aitMscGWMr6C5zdnuYRPeOPOQZq7pYlaXUA9GNAdqAiGBvMLbnqZm+8yV9HJMA==
X-Received: by 2002:a6b:8bcd:: with SMTP id n196mr18428006iod.295.1549902225701;
        Mon, 11 Feb 2019 08:23:45 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id y38sm5338291ita.18.2019.02.11.08.23.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 08:23:45 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x1BGNigw029955;
        Mon, 11 Feb 2019 16:23:44 GMT
Subject: [PATCH v1 01/23] xprtrdma: Fix sparse warnings
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 11 Feb 2019 11:23:44 -0500
Message-ID: <20190211162344.2817.17679.stgit@manet.1015granger.net>
In-Reply-To: <20190211161920.2817.20881.stgit@manet.1015granger.net>
References: <20190211161920.2817.20881.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

linux/net/sunrpc/xprtrdma/rpc_rdma.c:375:63: warning: incorrect type in argument 5 (different base types)
linux/net/sunrpc/xprtrdma/rpc_rdma.c:375:63:    expected unsigned int [usertype] xid
linux/net/sunrpc/xprtrdma/rpc_rdma.c:375:63:    got restricted __be32 [usertype] rq_xid
linux/net/sunrpc/xprtrdma/rpc_rdma.c:432:62: warning: incorrect type in argument 5 (different base types)
linux/net/sunrpc/xprtrdma/rpc_rdma.c:432:62:    expected unsigned int [usertype] xid
linux/net/sunrpc/xprtrdma/rpc_rdma.c:432:62:    got restricted __be32 [usertype] rq_xid
linux/net/sunrpc/xprtrdma/rpc_rdma.c:489:62: warning: incorrect type in argument 5 (different base types)
linux/net/sunrpc/xprtrdma/rpc_rdma.c:489:62:    expected unsigned int [usertype] xid
linux/net/sunrpc/xprtrdma/rpc_rdma.c:489:62:    got restricted __be32 [usertype] rq_xid

Fixes: 0a93fbcb16e6 ("xprtrdma: Plant XID in on-the-wire RDMA ... ")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  |    4 ++--
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 6a56105..52cb6c1 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -391,7 +391,7 @@ size_t frwr_maxpages(struct rpcrdma_xprt *r_xprt)
  */
 struct rpcrdma_mr_seg *frwr_map(struct rpcrdma_xprt *r_xprt,
 				struct rpcrdma_mr_seg *seg,
-				int nsegs, bool writing, u32 xid,
+				int nsegs, bool writing, __be32 xid,
 				struct rpcrdma_mr **out)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
@@ -446,7 +446,7 @@ struct rpcrdma_mr_seg *frwr_map(struct rpcrdma_xprt *r_xprt,
 		goto out_mapmr_err;
 
 	ibmr->iova &= 0x00000000ffffffff;
-	ibmr->iova |= ((u64)cpu_to_be32(xid)) << 32;
+	ibmr->iova |= ((u64)be32_to_cpu(xid)) << 32;
 	key = (u8)(ibmr->rkey & 0x000000FF);
 	ib_update_fast_reg_key(ibmr, ++key);
 
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 5a18472..33db208 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -577,7 +577,7 @@ int frwr_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 size_t frwr_maxpages(struct rpcrdma_xprt *r_xprt);
 struct rpcrdma_mr_seg *frwr_map(struct rpcrdma_xprt *r_xprt,
 				struct rpcrdma_mr_seg *seg,
-				int nsegs, bool writing, u32 xid,
+				int nsegs, bool writing, __be32 xid,
 				struct rpcrdma_mr **mr);
 int frwr_send(struct rpcrdma_ia *ia, struct rpcrdma_req *req);
 void frwr_reminv(struct rpcrdma_rep *rep, struct list_head *mrs);

