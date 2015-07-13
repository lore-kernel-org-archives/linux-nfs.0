Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34017 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbbGMFvX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 01:51:23 -0400
Received: by pacan13 with SMTP id an13so9835041pac.1
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2015 22:51:22 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 1/7] nfs42: decode_layoutstats does not need res parameter
Date: Mon, 13 Jul 2015 13:50:49 +0800
Message-Id: <1436766655-10696-2-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com>
References: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs42xdr.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index a6bd27d..0eb29e1 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -238,8 +238,7 @@ out_overflow:
 	return -EIO;
 }
 
-static int decode_layoutstats(struct xdr_stream *xdr,
-			      struct nfs42_layoutstat_res *res)
+static int decode_layoutstats(struct xdr_stream *xdr)
 {
 	return decode_op_hdr(xdr, OP_LAYOUTSTATS);
 }
@@ -343,7 +342,7 @@ static int nfs4_xdr_dec_layoutstats(struct rpc_rqst *rqstp,
 		goto out;
 	WARN_ON(res->num_dev > PNFS_LAYOUTSTATS_MAXDEV);
 	for (i = 0; i < res->num_dev; i++) {
-		status = decode_layoutstats(xdr, res);
+		status = decode_layoutstats(xdr);
 		if (status)
 			goto out;
 	}
-- 
1.8.3.1

