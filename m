From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 20/44] nfsd41: remove iovlen field from nfsd4_compound_state
Date: Tue, 16 Jun 2009 04:20:10 +0300
Message-ID: <1245115210-7460-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2715
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755793AbZFPBUJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:09 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Set resp->p in nfsd4_replay_cache_entry so that the nfs4svc_encode_compoundres
iov_len calculation is correct.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c       |    2 +-
 fs/nfsd/nfs4xdr.c         |    5 +----
 include/linux/nfsd/xdr4.h |    1 -
 3 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c975719..0f740c1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1092,7 +1092,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 
 	resp->rqstp->rq_resused = entry->ce_resused;
 	resp->opcnt = slot->sl_opcnt;
-	resp->cstate.iovlen = entry->ce_datav.iov_len + entry->ce_rpchdrlen;
+	resp->p = resp->cstate.datap + XDR_QUADLEN(slot->sl_datalen);
 	status = slot->sl_status;
 
 	return status;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5018483..cebde87 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3314,10 +3314,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
 	BUG_ON(iov->iov_len > PAGE_SIZE);
 	if (nfsd4_has_session(&resp->cstate)) {
-		if (resp->cstate.status == nfserr_replay_cache &&
-				!nfsd4_not_cached(resp)) {
-			iov->iov_len = resp->cstate.iovlen;
-		} else {
+		if (resp->cstate.status != nfserr_replay_cache) {
 			nfsd4_store_cache_entry(resp);
 			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
 			resp->cstate.slot->sl_inuse = 0;
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 6febc62..76569d2 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -53,7 +53,6 @@ struct nfsd4_compound_state {
 	struct nfsd4_slot	*slot;
 	__be32			*statp;
 	__be32			*datap;
-	size_t			iovlen;
 	u32			minorversion;
 	u32			status;
 };
-- 
1.6.3

