From: andros@netapp.com
Subject: [PATCH 21/29] nfsd41: remove iovlen field from nfsd4_compound_state
Date: Thu, 23 Apr 2009 12:43:00 -0400
Message-ID: <1240504988-9572-22-git-send-email-andros@netapp.com>
References: <>
 <1240504988-9572-1-git-send-email-andros@netapp.com>
 <1240504988-9572-2-git-send-email-andros@netapp.com>
 <1240504988-9572-3-git-send-email-andros@netapp.com>
 <1240504988-9572-4-git-send-email-andros@netapp.com>
 <1240504988-9572-5-git-send-email-andros@netapp.com>
 <1240504988-9572-6-git-send-email-andros@netapp.com>
 <1240504988-9572-7-git-send-email-andros@netapp.com>
 <1240504988-9572-8-git-send-email-andros@netapp.com>
 <1240504988-9572-9-git-send-email-andros@netapp.com>
 <1240504988-9572-10-git-send-email-andros@netapp.com>
 <1240504988-9572-11-git-send-email-andros@netapp.com>
 <1240504988-9572-12-git-send-email-andros@netapp.com>
 <1240504988-9572-13-git-send-email-andros@netapp.com>
 <1240504988-9572-14-git-send-email-andros@netapp.com>
 <1240504988-9572-15-git-send-email-andros@netapp.com>
 <1240504988-9572-16-git-send-email-andros@netapp.com>
 <1240504988-9572-17-git-send-email-andros@netapp.com>
 <1240504988-9572-18-git-send-email-andros@netapp.com>
 <1240504988-9572-19-git-send-email-andros@netapp.com>
 <1240504988-9572-20-git-send-email-andros@netapp.com>
 <1240504988-9572-21-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46174 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757389AbZDWQna (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 12:43:30 -0400
In-Reply-To: <1240504988-9572-21-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Set resp->p in nfsd4_replay_cache_entry so that the nfs4svc_encode_compoundres
iov_len calculation is correct.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c       |    1 +
 fs/nfsd/nfs4xdr.c         |    5 +----
 include/linux/nfsd/xdr4.h |    1 -
 3 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8c96451..1affb0a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1120,6 +1120,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 	       entry->ce_datav.iov_len);
 
 	resp->opcnt = entry->ce_opcnt;
+	resp->p = resp->cstate.datap + XDR_QUADLEN(entry->ce_datav.iov_len);
 	status = entry->ce_status;
 
 	return status;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f4bba66..1e46525 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3359,10 +3359,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
 	BUG_ON(iov->iov_len > PAGE_SIZE);
 	if (nfsd4_has_session(&resp->cstate)) {
-		if (resp->cstate.status == nfserr_replay_cache &&
-				!nfsd4_not_cached(resp)) {
-			iov->iov_len = resp->cstate.iovlen;
-		} else {
+		if (resp->cstate.status != nfserr_replay_cache) {
 			/* FIXME: return ignored for now. Can have -ENOMEM */
 			nfsd4_store_cache_entry(resp);
 			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 97f5cee..45ccbc3 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -52,7 +52,6 @@ struct nfsd4_compound_state {
 	struct nfsd4_session	*session;
 	struct nfsd4_slot	*slot;
 	__be32			*datap;
-	size_t			iovlen;
 	u32			minorversion;
 	u32			status;
 };
-- 
1.5.4.3

