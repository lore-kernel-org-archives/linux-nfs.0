From: andros@netapp.com
Subject: [PATCH 25/31] nfsd41: fix nfsd4_store_cache_entry comments
Date: Tue, 28 Apr 2009 12:59:59 -0400
Message-ID: <1240938005-23778-25-git-send-email-andros@netapp.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com>
 <1240938005-23778-2-git-send-email-andros@netapp.com>
 <1240938005-23778-3-git-send-email-andros@netapp.com>
 <1240938005-23778-4-git-send-email-andros@netapp.com>
 <1240938005-23778-5-git-send-email-andros@netapp.com>
 <1240938005-23778-6-git-send-email-andros@netapp.com>
 <1240938005-23778-7-git-send-email-andros@netapp.com>
 <1240938005-23778-8-git-send-email-andros@netapp.com>
 <1240938005-23778-9-git-send-email-andros@netapp.com>
 <1240938005-23778-10-git-send-email-andros@netapp.com>
 <1240938005-23778-11-git-send-email-andros@netapp.com>
 <1240938005-23778-12-git-send-email-andros@netapp.com>
 <1240938005-23778-13-git-send-email-andros@netapp.com>
 <1240938005-23778-14-git-send-email-andros@netapp.com>
 <1240938005-23778-15-git-send-email-andros@netapp.com>
 <1240938005-23778-16-git-send-email-andros@netapp.com>
 <1240938005-23778-17-git-send-email-andros@netapp.com>
 <1240938005-23778-18-git-send-email-andros@netapp.com>
 <1240938005-23778-19-git-send-email-andros@netapp.com>
 <1240938005-23778-20-git-send-email-andros@netapp.com>
 <1240938005-23778-21-git-send-email-andros@netapp.com>
 <1240938005-23778-22-git-send-email-andros@netapp.com>
 <1240938005-23778-23-git-send-email-andros@netapp.com>
 <1240938005-23778-24-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7762 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759369AbZD1RBI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:01:08 -0400
In-Reply-To: <1240938005-23778-24-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d38a48f..56114fd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1009,14 +1009,8 @@ out_err:
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
+ *  Copy all encoded operation responses past the sequence response into the
+ *  slot's cache.
  */
 void
 nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
@@ -1035,11 +1029,8 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	slot->sl_opcnt = resp->opcnt;
 	slot->sl_status = resp->cstate.status;
 
-	/*
-	 * Don't need a page to cache just the sequence operation - the slot
-	 * does this for us!
-	 */
 
+	/* Don't cache the sequence operation, use the slot values on replay */
 	if (nfsd4_not_cached(resp)) {
 		slot->sl_datalen = 0;
 		dprintk("%s Just cache SEQUENCE. cachethis %d\n", __func__,
-- 
1.5.4.3

