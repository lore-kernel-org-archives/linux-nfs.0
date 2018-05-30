Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:39191 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753563AbeE3SGT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:19 -0400
Received: by mail-io0-f174.google.com with SMTP id 200-v6so21679227ioz.6
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:18 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.17
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:17 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/19] pnfs: Store return value of decode_layoutget for later processing
Date: Wed, 30 May 2018 14:05:36 -0400
Message-Id: <20180530180553.38769-3-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-2-trond.myklebust@hammerspace.com>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
 <20180530180553.38769-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <fred.isaman@gmail.com>

This will be needed to seperate return value of OPEN and LAYOUTGET
when they are combined into a single RPC.

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4xdr.c        | 15 ++++++++++-----
 include/linux/nfs_xdr.h |  1 +
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 9b7392032321..6024980dfc9e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6024,7 +6024,7 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 
 	status = decode_op_hdr(xdr, OP_LAYOUTGET);
 	if (status)
-		return status;
+		goto out;
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
@@ -6037,7 +6037,8 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 	if (!layout_count) {
 		dprintk("%s: server responded with empty layout array\n",
 			__func__);
-		return -EINVAL;
+		status = -EINVAL;
+		goto out;
 	}
 
 	p = xdr_inline_decode(xdr, 28);
@@ -6062,7 +6063,8 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 		dprintk("NFS: server cheating in layoutget reply: "
 				"layout len %u > recvd %u\n",
 				res->layoutp->len, recvd);
-		return -EINVAL;
+		status = -EINVAL;
+		goto out;
 	}
 
 	if (layout_count > 1) {
@@ -6075,10 +6077,13 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
 			__func__, layout_count);
 	}
 
-	return 0;
+out:
+	res->status = status;
+	return status;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
-	return -EIO;
+	status = -EIO;
+	goto out;
 }
 
 static int decode_layoutreturn(struct xdr_stream *xdr,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 52b481dfd61e..dee11a9e91e8 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -259,6 +259,7 @@ struct nfs4_layoutget_args {
 
 struct nfs4_layoutget_res {
 	struct nfs4_sequence_res seq_res;
+	int status;
 	__u32 return_on_close;
 	struct pnfs_layout_range range;
 	__u32 type;
-- 
2.17.0

