Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39437C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F04B820672
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="D+RBMfSA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F04B820672
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727131AbeK0HBb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 02:01:31 -0500
Received: from mail-io1-f68.google.com ([209.85.166.68]:38043 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726296AbeK0HBb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2018 02:01:31 -0500
Received: by mail-io1-f68.google.com with SMTP id l14so14879104ioj.5;
        Mon, 26 Nov 2018 12:06:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=r5ygAM681JsqssJ4hf6Fh9W4EaTbQDpvms7g5AbWWQI=;
        b=D+RBMfSAXPhxLLUMdblgm2e9XErl9M8ws2Y+r2Imk4hOnspUWGKaiHAFdcMW5My8qf
         mQbJhSt+UEiWHTKxwLr9NbpcfFkTsFzGh7iNNpl3HmyfQ/QjkhPp7saHbRNL3jC6mGOn
         TjZbjZqt7Q9BQ2VOGmlw5y0fXu7E4Eilc+4pdvqECWcnY/YbMwhe3CJloEpBWEv/D2HD
         0HvS+djJJRqhh+SfTi1TXrbrONFt/chqRm1wcmwmp2KWj4hiXjVW1ZLEDzWE5DmM7YpV
         iLcRVZiis0GLKAiijOxjkVDwB8aK66KEXhIX/oyhvukRjcaTrDF6NiydvumA4EdAW3j7
         OTTA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=r5ygAM681JsqssJ4hf6Fh9W4EaTbQDpvms7g5AbWWQI=;
        b=OBQ2xJgvjwUFQRKxWP0doGbWknJc8XOMfJ3IWKUkPXR15EZ/q5fQW2NjXbOir7+gIP
         DdZxhqPFG005YOkww78pZL8rP3P28LYddJQL2CZi2oZ0LaBLFEyJafYiSLRQRRHpkMRX
         V52qjK1UCP1Ionsy7jt87ZhYEAPlWmuM1p55raVWI4e7jBj9Z8RsXsi8pIGM7AL8yDUt
         r3DrNZGe/eL7F4jPO2KAc3Hf9MmiEdgjAUPJ9W8SVr+l1qiKqxJnlMItQtCbWJJXlwLX
         jFywBBII9kw9O6BRbenPG5e9eLw9jUAauD4WpxVoKofiSKpzLCICMUV7XoGv1A/pCs7o
         iysQ==
X-Gm-Message-State: AA+aEWbWJMCkOrIBtY3NvhWGP76mfTwqfSxHN7TjUar/5TeCuJkgsQcv
        f6Al1SEda0QwTeo9F82Iku1oDPFN
X-Google-Smtp-Source: AFSGD/V0V7C3WBvvFhnV/JfVoOCSx0wCGLy+Mg9khCLSdnZE9ZX1FIofgsgrq3+cI+Y50tqS50iEIA==
X-Received: by 2002:a5e:834d:: with SMTP id y13mr23611308iom.298.1543262776561;
        Mon, 26 Nov 2018 12:06:16 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id v24sm460437ioj.78.2018.11.26.12.06.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 12:06:15 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAQK6EOT010657;
        Mon, 26 Nov 2018 20:06:14 GMT
Subject: [PATCH v2 05/20] xprtrdma: Plant XID in on-the-wire RDMA offset
 (FRWR)
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 26 Nov 2018 15:06:14 -0500
Message-ID: <20181126200614.10321.58476.stgit@manet.1015granger.net>
In-Reply-To: <20181126194611.10321.71714.stgit@manet.1015granger.net>
References: <20181126194611.10321.71714.stgit@manet.1015granger.net>
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

