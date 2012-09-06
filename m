Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:23903 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756667Ab2IFTyc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Sep 2012 15:54:32 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>,
        stable@vger.kernel.org
Subject: [PATCH 1/2] NFS: return error from decode_getfh in decode open
Date: Thu,  6 Sep 2012 15:54:27 -0400
Message-Id: <1346961268-15864-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If decode_getfh failed, nfs4_xdr_dec_open would return 0 since the last
decode_* call must have succeeded.

Cc: stable@vger.kernel.org
Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4xdr.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 1bfbd67..f505726 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6229,7 +6229,8 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
 	status = decode_open(xdr, res);
 	if (status)
 		goto out;
-	if (decode_getfh(xdr, &res->fh) != 0)
+	status = decode_getfh(xdr, &res->fh);
+	if (status)
 		goto out;
 	decode_getfattr(xdr, res->f_attr, res->server);
 out:
-- 
1.7.9.6 (Apple Git-31.1)

