From: andros@netapp.com
Subject: [PATCH 17/29] nfsd41: remove unused nfsd4_cache_entry fields
Date: Thu, 23 Apr 2009 12:42:56 -0400
Message-ID: <1240504988-9572-18-git-send-email-andros@netapp.com>
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
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46174 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755881AbZDWQn0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 12:43:26 -0400
In-Reply-To: <1240504988-9572-17-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replacing page based drc cache with buffer based drc cache.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c        |   11 -----------
 include/linux/nfsd/state.h |    3 ---
 2 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1d7f2c0..5e2246c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1041,8 +1041,6 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	 */
 
 	if (nfsd4_not_cached(resp)) {
-		entry->ce_resused = 0;
-		entry->ce_rpchdrlen = 0;
 		entry->ce_datav.iov_len = 0;
 		dprintk("%s Just cache SEQUENCE. ce_cachethis %d\n", __func__,
 			resp->cstate.slot->sl_cache_entry.ce_cachethis);
@@ -1062,13 +1060,6 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	entry->ce_datav.iov_len = (char *)resp->p - (char *)resp->cstate.datap;
 	memcpy(entry->ce_datav.iov_base, resp->cstate.datap,
 	       entry->ce_datav.iov_len);
-
-	entry->ce_resused = rqstp->rq_resused;
-	if (entry->ce_resused > NFSD_PAGES_PER_SLOT + 1)
-		entry->ce_resused = NFSD_PAGES_PER_SLOT + 1;
-	/* Current request rpc header length*/
-	entry->ce_rpchdrlen = (char *)resp->cstate.statp -
-				(char *)page_address(rqstp->rq_respages[0]);
 	return 0;
 }
 
@@ -1104,9 +1095,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 	memcpy(resp->cstate.datap, entry->ce_datav.iov_base,
 	       entry->ce_datav.iov_len);
 
-	resp->rqstp->rq_resused = entry->ce_resused;
 	resp->opcnt = entry->ce_opcnt;
-	resp->cstate.iovlen = entry->ce_datav.iov_len + entry->ce_rpchdrlen;
 	status = entry->ce_status;
 
 	return status;
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index b8aa47a..29ed755 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -117,11 +117,8 @@ struct nfs4_callback {
 struct nfsd4_cache_entry {
 	__be32		ce_status;
 	struct kvec	ce_datav; /* encoded cached operations */
-	struct page	*ce_respages[NFSD_PAGES_PER_SLOT + 1];
 	int		ce_cachethis;
-	short		ce_resused;
 	int		ce_opcnt;
-	int		ce_rpchdrlen;
 };
 
 struct nfsd4_slot {
-- 
1.5.4.3

