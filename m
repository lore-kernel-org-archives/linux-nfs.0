Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D361C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EF36B2133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PskoHHGb"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388262AbeLQQkX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:40:23 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:55428 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388257AbeLQQkX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:40:23 -0500
Received: by mail-it1-f196.google.com with SMTP id o19so19438193itg.5;
        Mon, 17 Dec 2018 08:40:22 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=ty1oGOtNt9biJZaf/kjTjU9tLsvdxKC6SZs1D4odKpI=;
        b=PskoHHGbN8GgPWk/kMfPyO6sWlOkONEYpw5lYvVP9bshPM2/gUgIXsoKXNb/0HcKbq
         bCEXywwfeRt3cGohvkp7q0Kaex2pF2dQWzNiF69WigVQxt2DPX19J1NaBS/R/5wmAXXp
         B1icXQc5cFYh1O65Df/07WWRgp8Us6MuPFGuJ1DX+FXBNIH2SujBIEPqfNMRMe0P36pG
         pFRJo0QSStisASs+cBa9qVuFzzgsyHC0TXSsq8X1Hms+IOPxco0A9jl05tA/sjW15jhY
         mUud2yE6m7neEdIOz9ux/vxbWgycp+YBs1FcQxyDFu74eOuPgf2dOzXMCZQTxcuVXCK9
         70Jw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=ty1oGOtNt9biJZaf/kjTjU9tLsvdxKC6SZs1D4odKpI=;
        b=Cs3rYe9IyZ95yA1EkMVGAdci8RMa8Wx0/fdz61uOSu4EMdwhdbONgY3dbQlq54gpnM
         QdnoqTvNjmE4niAL6C5wV5GS+WW/MTW0Zj5/tFz1mcNGH9GuW3V+wscDEZ4mL8hvqFfH
         tmgcYpbgoHts59ZY2+XfxbSaKzsjXwY0UvJfoil1UXhx9AMGa3+zaJh42mE40TZr7VVz
         +1od/O0FWwLNVo0tYmyO2JlEEJHJCKoEvumE7qS9XhIle9DjoZjP8gq/bXFk7SRQeGr2
         AQ5InI2hK8ECfAghnd/NDeLeFou5uRsllqQVJbySFFoLafcXb24B03Ig/JGwaMyVOHaa
         sq4A==
X-Gm-Message-State: AA+aEWb0a8Q8w8QrJFxNXE7uPztRvCx+2mpHg/FZ0pj2MFvqbvvviKHP
        5GGmdZl/r3kjL5tpjZB3Qu6ThZOX
X-Google-Smtp-Source: AFSGD/WlZTD/xBckq3tBhokjP14UGxMyhxOcERY4OWRFwnNtcJ+4+Qiae7DaLmMkKFzCWD/0oMinXQ==
X-Received: by 2002:a24:7609:: with SMTP id z9mr13860403itb.66.1545064821873;
        Mon, 17 Dec 2018 08:40:21 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id y76sm7827351ita.18.2018.12.17.08.40.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:40:21 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGeKGw018611;
        Mon, 17 Dec 2018 16:40:20 GMT
Subject: [PATCH v4 11/30] xprtrdma: Plant XID in on-the-wire RDMA offset
 (FRWR)
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:40:20 -0500
Message-ID: <20181217164020.24133.66234.stgit@manet.1015granger.net>
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
index eccb930..56b299f 100644
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

