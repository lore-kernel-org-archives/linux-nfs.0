From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 22/44] nfsd41: obliterate nfsd4_set_statp
Date: Tue, 16 Jun 2009 04:20:15 +0300
Message-ID: <1245115215-7526-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2668
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752523AbZFPBUP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:15 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replacing page based drc cache with buffer based drc cache.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c       |    8 --------
 fs/nfsd/nfssvc.c          |    4 ----
 include/linux/nfsd/xdr4.h |    1 -
 3 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 954ccda..c1fa96c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -994,14 +994,6 @@ out_err:
 	return;
 }
 
-void
-nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp)
-{
-	struct nfsd4_compoundres *resp = rqstp->rq_resp;
-
-	resp->cstate.statp = statp;
-}
-
 /*
  * Cache the reply pages up to NFSD_PAGES_PER_SLOT + 1, clearing the previous
  * pages. We add a page to NFSD_PAGES_PER_SLOT for the case where the total
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 37633f5..d14adea 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -572,10 +572,6 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 		+ rqstp->rq_res.head[0].iov_len;
 	rqstp->rq_res.head[0].iov_len += sizeof(__be32);
 
-	/* NFSv4.1 DRC requires statp */
-	if (rqstp->rq_vers == 4)
-		nfsd4_set_statp(rqstp, statp);
-
 	/* Now call the procedure handler, and encode NFS status. */
 	nfserr = proc->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
 	nfserr = map_new_errors(rqstp->rq_vers, nfserr);
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 76569d2..84ac4bb 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -51,7 +51,6 @@ struct nfsd4_compound_state {
 	/* For sessions DRC */
 	struct nfsd4_session	*session;
 	struct nfsd4_slot	*slot;
-	__be32			*statp;
 	__be32			*datap;
 	u32			minorversion;
 	u32			status;
-- 
1.6.3

