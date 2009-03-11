From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/30] NFSv4: Ignore errors on the post-op attributes in
 SETATTR calls
Date: Wed, 11 Mar 2009 14:41:06 -0400
Message-ID: <20090311184106.5578.3648.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24945 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754662AbZCKSoN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:13 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIi3rC021754
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:44:11 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is no need to fail or retry a SETATTR call just because the post-op
GETATTR failed.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4xdr.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)


diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d1e4c8f..5f0ee3e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4078,9 +4078,7 @@ static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp, __be32 *p, struct nfs_se
 	status = decode_setattr(&xdr, res);
 	if (status)
 		goto out;
-	status = decode_getfattr(&xdr, res->fattr, res->server);
-	if (status == NFS4ERR_DELAY)
-		status = 0;
+	decode_getfattr(&xdr, res->fattr, res->server);
 out:
 	return status;
 }

