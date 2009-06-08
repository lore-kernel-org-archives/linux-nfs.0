From: andros@netapp.com
Subject: [PATCH 20/30] nfsd41: obliterate nfsd4_set_statp
Date: Mon,  8 Jun 2009 14:21:01 -0400
Message-ID: <1244485271-7461-21-git-send-email-andros@netapp.com>
References: <>
 <1244485271-7461-1-git-send-email-andros@netapp.com>
 <1244485271-7461-2-git-send-email-andros@netapp.com>
 <1244485271-7461-3-git-send-email-andros@netapp.com>
 <1244485271-7461-4-git-send-email-andros@netapp.com>
 <1244485271-7461-5-git-send-email-andros@netapp.com>
 <1244485271-7461-6-git-send-email-andros@netapp.com>
 <1244485271-7461-7-git-send-email-andros@netapp.com>
 <1244485271-7461-8-git-send-email-andros@netapp.com>
 <1244485271-7461-9-git-send-email-andros@netapp.com>
 <1244485271-7461-10-git-send-email-andros@netapp.com>
 <1244485271-7461-11-git-send-email-andros@netapp.com>
 <1244485271-7461-12-git-send-email-andros@netapp.com>
 <1244485271-7461-13-git-send-email-andros@netapp.com>
 <1244485271-7461-14-git-send-email-andros@netapp.com>
 <1244485271-7461-15-git-send-email-andros@netapp.com>
 <1244485271-7461-16-git-send-email-andros@netapp.com>
 <1244485271-7461-17-git-send-email-andros@netapp.com>
 <1244485271-7461-18-git-send-email-andros@netapp.com>
 <1244485271-7461-19-git-send-email-andros@netapp.com>
 <1244485271-7461-20-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38770 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753345AbZFHSVd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:33 -0400
In-Reply-To: <1244485271-7461-20-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replacing page based DRC cache with buffer based DRC cache, the cstate->statp
pointer is no longer necessary.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c       |    8 --------
 fs/nfsd/nfssvc.c          |    4 ----
 include/linux/nfsd/xdr4.h |    1 -
 3 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 55c7f3a..19f6064 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -990,14 +990,6 @@ out_err:
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
index 2ee9b1d..505e3e3 100644
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
1.5.4.3

