Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DB11C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EAB05217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JMo2c2xx"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729385AbeLSP7K (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 10:59:10 -0500
Received: from mail-io1-f65.google.com ([209.85.166.65]:42903 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727829AbeLSP7K (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 10:59:10 -0500
Received: by mail-io1-f65.google.com with SMTP id x6so15959110ioa.9;
        Wed, 19 Dec 2018 07:59:09 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=tRIh6Vlmff0elQPQHQ6Kjc+t1Fp0s6+iXGm0s/cylgY=;
        b=JMo2c2xxpmS5vgqAzjn1Dm4cLsYfbzq5oSvgkBDHlHY16rcA2vwWLFGu76mUU61KZt
         PbxZm+1a2tcSw4deCHtiDW6zWMKvhaN9Aaxu5HHZiIz92hLQZGDQyjAS+IMTtqfeEgV9
         FaM4HeNUgztGAceFy+YA4iEBJRP+DQgbM43Pn2P5Bl2RTUEm5AqGfFNQdmra9su8GUeh
         g+0r57jaGrhlDMcQ9YSUAbdaEUoDZEAPet0wppnhqQx3y+cagkpQhBIDWVPdmlZWrlO0
         7lG04zcJujyXsDgz5gEcm12t9v/4eQft4cgEZFDXBP+hho91NvWpTT3Z0AB7nUCDVE9r
         sj4g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=tRIh6Vlmff0elQPQHQ6Kjc+t1Fp0s6+iXGm0s/cylgY=;
        b=RWbAB6Sw1cW6obEbDMkrfHtQB+B0TgJNotNkZsfzR2EypatxnuDvqJwTEQgS0v76yC
         pED+q2BNP7dut2GUuusRLhALXfo5SCr9thj17TLLlUTCdMbyLYyEH81XZgkDEqVnTaW5
         TY2Wb2JYiUmQ+nKtw4YxZfHq7k/WEI2oiOYxeYrzBAHzpT9kr1lGleGQcv8PNneE9wpk
         yW7DJjiUH6KBvTigKWrNvisP/mYi5HUTWhhH0l+HnfFuzO5LOlzinS7GuSzuP6qRXWMr
         +50o9mdlhnwcxywafjzeSLu35S2zPDekFdA2qvLmkXqdNxmJ6OhRSUT5VRWQqV1dMwsW
         AxbQ==
X-Gm-Message-State: AA+aEWbJ7zEuYKAoSi2DAn47NIDT8SqJmRKu2M7duT4cpyE148yGFfn2
        OvYuQ+GaF2OoJKakgi3DaHQ=
X-Google-Smtp-Source: AFSGD/Un9hvIh2GehMpHD3elQyTm1f61Knn+sjQQHLqoNbf+HWS+wmRTOIFNLUW0ikkinz3sm8RJxQ==
X-Received: by 2002:a5e:c00c:: with SMTP id u12mr17949413iol.152.1545235148615;
        Wed, 19 Dec 2018 07:59:08 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id h139sm3455355ith.24.2018.12.19.07.59.07
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 07:59:07 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJFx7fl025789;
        Wed, 19 Dec 2018 15:59:07 GMT
Subject: [PATCH v5 11/30] xprtrdma: Plant XID in on-the-wire RDMA offset
 (FRWR)
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 10:59:07 -0500
Message-ID: <20181219155906.11602.58244.stgit@manet.1015granger.net>
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
 net/sunrpc/xprtrdma/frwr_ops.c  |    5 ++++-
 net/sunrpc/xprtrdma/rpc_rdma.c  |    6 +++---
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 3 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index fb0944d..97f88bb 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -379,6 +379,7 @@ size_t frwr_maxpages(struct rpcrdma_xprt *r_xprt)
  * @seg: memory region co-ordinates
  * @nsegs: number of segments remaining
  * @writing: true when RDMA Write will be used
+ * @xid: XID of RPC using the registered memory
  * @out: initialized MR
  *
  * Prepare a REG_MR Work Request to register a memory region
@@ -389,7 +390,7 @@ size_t frwr_maxpages(struct rpcrdma_xprt *r_xprt)
  */
 struct rpcrdma_mr_seg *frwr_map(struct rpcrdma_xprt *r_xprt,
 				struct rpcrdma_mr_seg *seg,
-				int nsegs, bool writing,
+				int nsegs, bool writing, u32 xid,
 				struct rpcrdma_mr **out)
 {
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
@@ -444,6 +445,8 @@ struct rpcrdma_mr_seg *frwr_map(struct rpcrdma_xprt *r_xprt,
 	if (unlikely(n != mr->mr_nents))
 		goto out_mapmr_err;
 
+	ibmr->iova &= 0x00000000ffffffff;
+	ibmr->iova |= ((u64)cpu_to_be32(xid)) << 32;
 	key = (u8)(ibmr->rkey & 0x000000FF);
 	ib_update_fast_reg_key(ibmr, ++key);
 
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 2a2023d..3804fb3 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -356,7 +356,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		return nsegs;
 
 	do {
-		seg = frwr_map(r_xprt, seg, nsegs, false, &mr);
+		seg = frwr_map(r_xprt, seg, nsegs, false, rqst->rq_xid, &mr);
 		if (IS_ERR(seg))
 			return PTR_ERR(seg);
 		rpcrdma_mr_push(mr, &req->rl_registered);
@@ -413,7 +413,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 	nchunks = 0;
 	do {
-		seg = frwr_map(r_xprt, seg, nsegs, true, &mr);
+		seg = frwr_map(r_xprt, seg, nsegs, true, rqst->rq_xid, &mr);
 		if (IS_ERR(seg))
 			return PTR_ERR(seg);
 		rpcrdma_mr_push(mr, &req->rl_registered);
@@ -470,7 +470,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 
 	nchunks = 0;
 	do {
-		seg = frwr_map(r_xprt, seg, nsegs, true, &mr);
+		seg = frwr_map(r_xprt, seg, nsegs, true, rqst->rq_xid, &mr);
 		if (IS_ERR(seg))
 			return PTR_ERR(seg);
 		rpcrdma_mr_push(mr, &req->rl_registered);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index c42a003..ff4eab1 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -580,7 +580,7 @@ int frwr_open(struct rpcrdma_ia *ia, struct rpcrdma_ep *ep,
 size_t frwr_maxpages(struct rpcrdma_xprt *r_xprt);
 struct rpcrdma_mr_seg *frwr_map(struct rpcrdma_xprt *r_xprt,
 				struct rpcrdma_mr_seg *seg,
-				int nsegs, bool writing,
+				int nsegs, bool writing, u32 xid,
 				struct rpcrdma_mr **mr);
 int frwr_send(struct rpcrdma_ia *ia, struct rpcrdma_req *req);
 void frwr_reminv(struct rpcrdma_rep *rep, struct list_head *mrs);

