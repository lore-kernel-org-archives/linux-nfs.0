Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 949BBC43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 15:46:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 56F3520851
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 15:46:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ATOQe3cL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56F3520851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729854AbeKTCKH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Nov 2018 21:10:07 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:38181 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729762AbeKTCKH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Nov 2018 21:10:07 -0500
Received: by mail-it1-f196.google.com with SMTP id h65so4794132ith.3;
        Mon, 19 Nov 2018 07:46:08 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Hk5bOpTrFRIGEN/Gwgg2bCMEraAYYn8OVwOsUUCfuGw=;
        b=ATOQe3cLtkOxENsiWAezKHaz8bwmF0WUa6H45n3V2TBCnSowh3nISzGRLhItcZoxNM
         WmsdFMGjy+JRstIp2+8dG8+vcPH+/+E/m7wuOcmBmfxNfnzX9UuU4dB7dYX6SIclSVYu
         SQhf0vxYxHvx1pjZJifVzuJQnBg4neJ1YJxQ3lD57nsLCwMY3/ETtMU6q/6ksU9M9mdK
         bLpa3eSvsZ5kV24Oi9ZGP8/QcDjb2aWSPO/z9UafGHId6uOTZmblyiQ00f0UlIdZE1BA
         9mmXCkZc4z06Gb7AUhyRlaXcGah69rj3zMB3jrXeveOlcDdYwVTNTFhEk8pLJ/KOwCdi
         JIAg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Hk5bOpTrFRIGEN/Gwgg2bCMEraAYYn8OVwOsUUCfuGw=;
        b=F967hyDwNlrDe183tK/sclTi80NSInc2to82huztG61gMD+bdDN9PNrJw2G5gVP8V9
         Ycl/l/qlCLXwP9XxetLRGfCTOiGVnBQZ8C1jsDEswUenT9975mjc9j8wlxJ5ymt6RlwV
         Ei6IRnaSV0rjBU2waubBkXiE8aFa7M0yvoUuE8N43twziCSeC1fwfKpGLyM9GlKrNMrl
         fz2LrHHBDY0wZdoXcTFhPbGiQbNbf1EMr40k9GLCRwe1POVadTId8mcynaPzxjL+dSAA
         j4owvd5a0QRTogUvmWVA9WENKPkwkrwcoQmkWG2G8GfD+VQSZMViFmpwoBzWF/RKiOdA
         7L4w==
X-Gm-Message-State: AGRZ1gLxEAmLpLr4nGhJ7pbWCex3uNH4NYAZdshptJMZjmIoR5xK30f1
        7d+Xu6owSnLjlxBwoRL5DgOFX5Qy
X-Google-Smtp-Source: AFSGD/XoM0Vp/zwGhwwBkIC2oRI/xvz5Mt1llcfoLpAyUEaawGLYyAgm7TetWmIvhf0H7lpiXtC9lQ==
X-Received: by 2002:a24:2ed3:: with SMTP id i202mr8274840ita.89.1542642368303;
        Mon, 19 Nov 2018 07:46:08 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id i143-v6sm14948012itb.25.2018.11.19.07.46.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 07:46:07 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAJFk72j023008;
        Mon, 19 Nov 2018 15:46:07 GMT
Subject: [PATCH v1 4/4] xprtrdma: Plant XID in on-the-wire RDMA offset (FRWR)
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org
Cc:     linux-nfs@vger.kernel.org
Date:   Mon, 19 Nov 2018 10:46:07 -0500
Message-ID: <20181119154607.10832.92558.stgit@manet.1015granger.net>
In-Reply-To: <20181119153707.10832.42881.stgit@manet.1015granger.net>
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Place the associated RPC transaction's XID in the upper 32 bits of
each RDMA segment's rdma_offset field. These bits are currently
always zero.

There are two reasons to do this:

- The R_key only has 8 bits that are different from registration to
  registration. The XID adds more uniqueness to each RDMA segment to
  reduce the likelihood of a software bug on the server reading from
  or writing into memory it's not supposed to.

- On-the-wire RDMA Read and Write operations do not otherwise carry
  any identifier that matches them up to an RPC. The XID in the
  upper 32 bits will act as an eye-catcher in network captures.

Suggested-by: Tom Talpey <ttalpey@microsoft.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  |    3 ++-
 net/sunrpc/xprtrdma/rpc_rdma.c  |    6 +++---
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 49b314d..3b260d2 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -344,7 +344,7 @@
  */
 static struct rpcrdma_mr_seg *
 frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
-	    int nsegs, bool writing, struct rpcrdma_mr **out)
+	    int nsegs, bool writing, u32 xid, struct rpcrdma_mr **out)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	bool holes_ok = ia->ri_mrtype == IB_MR_TYPE_SG_GAPS;
@@ -398,6 +398,7 @@
 	if (unlikely(n != mr->mr_nents))
 		goto out_mapmr_err;
 
+	ibmr->iova |= ((u64)cpu_to_be32(xid)) << 32;
 	key = (u8)(ibmr->rkey & 0x000000FF);
 	ib_update_fast_reg_key(ibmr, ++key);
 
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 9f53e02..89a2db2 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -357,7 +357,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 	do {
 		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
-						   false, &mr);
+						   false, rqst->rq_xid, &mr);
 		if (IS_ERR(seg))
 			return PTR_ERR(seg);
 		rpcrdma_mr_push(mr, &req->rl_registered);
@@ -415,7 +415,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	nchunks = 0;
 	do {
 		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
-						   true, &mr);
+						   true, rqst->rq_xid, &mr);
 		if (IS_ERR(seg))
 			return PTR_ERR(seg);
 		rpcrdma_mr_push(mr, &req->rl_registered);
@@ -473,7 +473,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	nchunks = 0;
 	do {
 		seg = r_xprt->rx_ia.ri_ops->ro_map(r_xprt, seg, nsegs,
-						   true, &mr);
+						   true, rqst->rq_xid, &mr);
 		if (IS_ERR(seg))
 			return PTR_ERR(seg);
 		rpcrdma_mr_push(mr, &req->rl_registered);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index a13ccb6..2ae1ee2 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -472,7 +472,7 @@ struct rpcrdma_memreg_ops {
 	struct rpcrdma_mr_seg *
 			(*ro_map)(struct rpcrdma_xprt *,
 				  struct rpcrdma_mr_seg *, int, bool,
-				  struct rpcrdma_mr **);
+				  u32, struct rpcrdma_mr **);
 	int		(*ro_send)(struct rpcrdma_ia *ia,
 				   struct rpcrdma_req *req);
 	void		(*ro_reminv)(struct rpcrdma_rep *rep,

