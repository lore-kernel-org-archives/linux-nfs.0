Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34219 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932609AbbHYPfI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 11:35:08 -0400
Received: by pabzx8 with SMTP id zx8so36944771pab.1
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 08:35:08 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, bfields@fieldses.org,
        Jeff Layton <jeff.layton@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH RFC 03/11] nfs42: decode_layoutstats does not need res parameter
Date: Tue, 25 Aug 2015 23:33:41 +0800
Message-Id: <1440516829-116041-4-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
References: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
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

