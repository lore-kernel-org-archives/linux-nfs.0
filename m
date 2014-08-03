Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:58935 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923AbaHCRGO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 13:06:14 -0400
Received: by mail-qg0-f51.google.com with SMTP id a108so7849708qge.24
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 10:06:13 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] nfsd: Reorder nfsd_cache_match to check more powerful discriminators first
Date: Sun,  3 Aug 2014 13:06:04 -0400
Message-Id: <1407085564-3227-7-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1407085564-3227-6-git-send-email-trond.myklebust@primarydata.com>
References: <1407085564-3227-1-git-send-email-trond.myklebust@primarydata.com>
 <1407085564-3227-2-git-send-email-trond.myklebust@primarydata.com>
 <1407085564-3227-3-git-send-email-trond.myklebust@primarydata.com>
 <1407085564-3227-4-git-send-email-trond.myklebust@primarydata.com>
 <1407085564-3227-5-git-send-email-trond.myklebust@primarydata.com>
 <1407085564-3227-6-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We would normally expect the xid and the checksum to be the best
discriminators. Check them before looking at the procedure number,
etc.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfscache.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 74603654b7f9..122f69185ef5 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -338,20 +338,24 @@ nfsd_cache_csum(struct svc_rqst *rqstp)
 static bool
 nfsd_cache_match(struct svc_rqst *rqstp, __wsum csum, struct svc_cacherep *rp)
 {
-	/* Check RPC header info first */
-	if (rqstp->rq_xid != rp->c_xid || rqstp->rq_proc != rp->c_proc ||
-	    rqstp->rq_prot != rp->c_prot || rqstp->rq_vers != rp->c_vers ||
-	    rqstp->rq_arg.len != rp->c_len ||
-	    !rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) ||
-	    rpc_get_port(svc_addr(rqstp)) != rpc_get_port((struct sockaddr *)&rp->c_addr))
+	/* Check RPC XID first */
+	if (rqstp->rq_xid != rp->c_xid)
 		return false;
-
 	/* compare checksum of NFS data */
 	if (csum != rp->c_csum) {
 		++payload_misses;
 		return false;
 	}
 
+	/* Other discriminators */
+	if (rqstp->rq_proc != rp->c_proc ||
+	    rqstp->rq_prot != rp->c_prot ||
+	    rqstp->rq_vers != rp->c_vers ||
+	    rqstp->rq_arg.len != rp->c_len ||
+	    !rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) ||
+	    rpc_get_port(svc_addr(rqstp)) != rpc_get_port((struct sockaddr *)&rp->c_addr))
+		return false;
+
 	return true;
 }
 
-- 
1.9.3

