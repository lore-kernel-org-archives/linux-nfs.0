From: andros@netapp.com
Subject: [PATCH 24/30] nfsd41: fix nfsd4_store_cache_entry comments
Date: Mon,  8 Jun 2009 14:21:05 -0400
Message-ID: <1244485271-7461-25-git-send-email-andros@netapp.com>
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
 <1244485271-7461-21-git-send-email-andros@netapp.com>
 <1244485271-7461-22-git-send-email-andros@netapp.com>
 <1244485271-7461-23-git-send-email-andros@netapp.com>
 <1244485271-7461-24-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38770 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753428AbZFHSVh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:37 -0400
In-Reply-To: <1244485271-7461-24-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 694cfb7..05b0190 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -991,14 +991,8 @@ out_err:
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
@@ -1017,11 +1011,8 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
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

