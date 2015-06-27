Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:34288 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbbF0PwS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Jun 2015 11:52:18 -0400
Received: by iebmu5 with SMTP id mu5so92133856ieb.1
        for <linux-nfs@vger.kernel.org>; Sat, 27 Jun 2015 08:52:17 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4.2: Fix up a decoding error in layoutstats
Date: Sat, 27 Jun 2015 11:52:13 -0400
Message-Id: <1435420334-12967-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to the spec, the server is only returning the status,
which we decode in the op header.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs42xdr.c | 18 +-----------------
 1 file changed, 1 insertion(+), 17 deletions(-)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 9aae0205ef11..a6bd27da6286 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -241,23 +241,7 @@ out_overflow:
 static int decode_layoutstats(struct xdr_stream *xdr,
 			      struct nfs42_layoutstat_res *res)
 {
-	int status;
-	__be32 *p;
-
-	status = decode_op_hdr(xdr, OP_LAYOUTSTATS);
-	if (status)
-		return status;
-
-	p = xdr_inline_decode(xdr, 4);
-	if (unlikely(!p))
-		goto out_overflow;
-
-	res->rpc_status = be32_to_cpup(p++);
-	return 0;
-
-out_overflow:
-	print_overflow_msg(__func__, xdr);
-	return -EIO;
+	return decode_op_hdr(xdr, OP_LAYOUTSTATS);
 }
 
 /*
-- 
2.4.3

