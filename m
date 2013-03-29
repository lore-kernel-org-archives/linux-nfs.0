Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:55084 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754552Ab3C2T5M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2013 15:57:12 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 29 Mar 2013 13:57:12 -0600
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 329206E803F
	for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2013 15:57:06 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2TJv8Ba326386
	for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2013 15:57:08 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2TJv8wU001094
	for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2013 15:57:08 -0400
Received: from malahal (malahal.austin.ibm.com [9.41.105.170])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id r2TJv7FS001056
	for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2013 15:57:07 -0400
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv3/v2: Fix data corruption with NFS short reads.
Date: Fri, 29 Mar 2013 14:57:06 -0500
Message-Id: <1364587026-7504-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This bug seems to be present in v2.6.37 or lower versions. The code was
re-organized in v2.6.38 that eliminated the bug. Current upstream code
doesn't have this bug. This may be applicable to some longterm releases!

Here are the bug details:

1. nfs_read_rpcsetup(), args.count and res.count are both set to the
   actual number of bytes to be read. Let us assume that the request is
   for 16K, so arg.count = res.count = 16K
2. nfs3_xdr_readres() conditionally sets res.count to to the actual
   number of bytes read. This condition is true for the first response
   as res.count was set to args.count before the first request. Let us
   say the server returned only 4K bytes. res.count=4K
3. Another read request is sent for the remaining data. Note that
   res.count is NOT updated. It is still set to the actual amount of
   bytes we got in the first response.  The client will send a READ
   request for the remaining 12K.
4. Assume that the server gave all 12K bytes. We still think we got ony
   4K bytes due to conditional update in nfs3_xdr_readres(). The client
   sends further requests, if not EOF! If this response includes EOF, it
   truncates pages beyond 4K+4K causing data corruption beyond 8K. The
   corrupted data is filled with zeros!

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 fs/nfs/nfs2xdr.c | 3 +--
 fs/nfs/nfs3xdr.c | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 5914a19..710ca56 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -287,8 +287,7 @@ nfs_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 	}
 
 	dprintk("RPC:      readres OK count %u\n", count);
-	if (count < res->count)
-		res->count = count;
+	res->count = count;
 
 	return count;
 }
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index f6cc60f..152a5e4 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -914,8 +914,7 @@ nfs3_xdr_readres(struct rpc_rqst *req, __be32 *p, struct nfs_readres *res)
 		res->eof = 0;
 	}
 
-	if (count < res->count)
-		res->count = count;
+	res->count = count;
 
 	return count;
 }
-- 
1.7.11.7

