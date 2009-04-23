From: andros@netapp.com
Subject: [PATCH 23/29] nfsd41: fix nfsd4_store_cache_entry comments
Date: Thu, 23 Apr 2009 12:43:02 -0400
Message-ID: <1240504988-9572-24-git-send-email-andros@netapp.com>
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
 <1240504988-9572-22-git-send-email-andros@netapp.com>
 <1240504988-9572-23-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46174 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756832AbZDWQnc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 12:43:32 -0400
In-Reply-To: <1240504988-9572-23-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   16 +++-------------
 1 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index efc9374..1e995ec 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1001,14 +1001,8 @@ out_err:
 }
 
 /*
- * Cache the reply pages up to NFSD_PAGES_PER_SLOT + 1, clearing the previous
- * pages. We add a page to NFSD_PAGES_PER_SLOT for the case where the total
- * length of the XDR response is less than se_fmaxresp_cached
- * (NFSD_PAGES_PER_SLOT * PAGE_SIZE) but the xdr_buf pages is used for a
- * of the reply (e.g. readdir).
- *
- * Store the base and length of the rq_req.head[0] page
- * of the NFSv4.1 data, just past the rpc header.
+ * Copy all encoded operation responses past the sequence response into the
+ * slot's cache.
  */
 __be32
 nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
@@ -1027,11 +1021,7 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	entry->ce_opcnt = resp->opcnt;
 	entry->ce_status = resp->cstate.status;
 
-	/*
-	 * Don't need a page to cache just the sequence operation - the slot
-	 * does this for us!
-	 */
-
+	/* Don't cache the sequence operation, use the slot values on replay. */
 	if (nfsd4_not_cached(resp)) {
 		entry->ce_datav.iov_len = 0;
 		dprintk("%s Just cache SEQUENCE. ce_cachethis %d\n", __func__,
-- 
1.5.4.3

