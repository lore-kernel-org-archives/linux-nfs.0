Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34851 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753280AbbHYQNf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 12:13:35 -0400
Received: by pacdd16 with SMTP id dd16so128495675pac.2
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 09:13:35 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 1/2] nfs42: decode_layoutstats does not need res parameter
Date: Wed, 26 Aug 2015 00:13:15 +0800
Message-Id: <1440519196-116456-2-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1440519196-116456-1-git-send-email-tao.peng@primarydata.com>
References: <1440519196-116456-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reviewed-by: Christoph Hellwig <hch@lst.de>
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

