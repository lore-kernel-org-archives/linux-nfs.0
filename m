Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3642EC04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:29:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E485020821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:29:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TBWcQltP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E485020821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728304AbeLJQ3y (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:29:54 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:35878 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727705AbeLJQ3x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:29:53 -0500
Received: by mail-it1-f196.google.com with SMTP id c9so19108607itj.1;
        Mon, 10 Dec 2018 08:29:52 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=rYeueLnRQdXLLjELULVsntrpOQKiImvGwyFPIyuwErA=;
        b=TBWcQltPG/SHwvFuKgH0jwRjve0jL3XF+1z/fjU6BoS4SqNboGr8VSn9Aknog/exxG
         PmJj7/fYJry9opFZPTgxeVBH2t600g3ZH6VxsXw4z7wgh2QblvCyrOWF2Alnjx68k/3T
         RMtNfcyaFruGhXop7ZqjoEtbsrfUCiAZnm5I5s14yLEOxrjNm0Na/lEJb1kSgxQoubt5
         oLptrIjGF4kJ8m/GJJw8kCdR0YTGmZlbGc2xl7v6qTMSTdDorBy0iRKzlmF/IH+lVG13
         xE3h7bdb4/V0gboSfMX3jHLQ7oWtkwBkH8OAvcpC4ZY2RLw0wKPmgQzxxf6rIbOMQnCG
         BPKQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=rYeueLnRQdXLLjELULVsntrpOQKiImvGwyFPIyuwErA=;
        b=H2CCfulTmeyeVz+x5kSr5rJnkiVk9NhufbswjDZCD1SjlO63giUo6nXvphnZzFCRfC
         FU4JZsaGCb76S67OnKYv1HlAG0KW256btMEvYRqmTuMDP8qMg7s9k0VjuXPYn0JyBlAV
         XtFQBKYVH59iepftFFVxSPc0kAYFq2FintPtK4WR53RBYP6POLPOTRKMNkrILzTLeOot
         +B+S2eDCEs6/STCQWWlge7h6k8zm5a+DD30ft28wmq3WIk5SbWvaWgPIVUtBQELMV2dp
         sMIpIbSLMXJ+p7CO/42/HdJ5H7gHRL0Bs+p5mtnilSnja9WfXcc+0LXbcR4CykMkIo4P
         2/tg==
X-Gm-Message-State: AA+aEWZKeBoG1IZe/Q2MTy9k9h3xZk84J1hrIVXZdOrgUioSWjeiALzj
        NBn0be+1JNX49MjhgvAy388=
X-Google-Smtp-Source: AFSGD/WrlzdS+XpzUVSpiinBLf0a189g2koXpbddjKu+zlGKu46W2ed7bUyIcmWZI69q7Mk+6wKSEQ==
X-Received: by 2002:a05:660c:281:: with SMTP id s1mr5969878itl.36.1544459392181;
        Mon, 10 Dec 2018 08:29:52 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id x128sm6747024itb.8.2018.12.10.08.29.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:29:51 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGTpVc031030;
        Mon, 10 Dec 2018 16:29:51 GMT
Subject: [PATCH v3 06/24] xprtrdma: Plant XID in on-the-wire RDMA offset
 (FRWR)
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:29:51 -0500
Message-ID: <20181210162950.4198.65901.stgit@manet.1015granger.net>
In-Reply-To: <20181210161723.4198.51071.stgit@manet.1015granger.net>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Place the associated RPC transaction's XID in the upper 32 bits of
each RDMA segment's rdma_offset field. There are two reasons to do
this:

- The R_key only has 8 bits that are different from registration to
  registration. The XID adds more uniqueness to each RDMA segment to
  reduce the likelihood of a software bug on the server reading from
  or writing into memory it's not supposed to.

- On-the-wire RDMA Read and Write requests do not otherwise carry
  any identifier that matches them up to an RPC. The XID in the
  upper 32 bits will act as an eye-catcher in network captures.

Suggested-by: Tom Talpey <ttalpey@microsoft.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  |    4 +++-
 net/sunrpc/xprtrdma/rpc_rdma.c  |    6 +++---
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 72c6d32..e758c0d 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -347,7 +347,7 @@
  */
 static struct rpcrdma_mr_seg *
 frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
-	    int nsegs, bool writing, struct rpcrdma_mr **out)
+	    int nsegs, bool writing, u32 xid, struct rpcrdma_mr **out)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 	bool holes_ok = ia->ri_mrtype == IB_MR_TYPE_SG_GAPS;
@@ -401,6 +401,8 @@
 	if (unlikely(n != mr->mr_nents))
 		goto out_mapmr_err;
 
+	ibmr->iova &= 0x00000000ffffffff;
+	ibmr->iova |= ((u64)cpu_to_be32(xid)) << 32;
 	key = (u8)(ibmr->rkey & 0x000000FF);
 	ib_update_fast_reg_key(ibmr, ++key);
 
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index a2eb647..4cf0855 100644
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

