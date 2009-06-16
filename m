From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 16/44] nfsd41: nfsd41: replace ce_status with nfsd4_slot field
Date: Tue, 16 Jun 2009 04:19:58 +0300
Message-ID: <1245115198-7328-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2547
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754889AbZFPBT6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:19:58 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

In preparation to remove struct nfsd4_cache_entry

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |    4 ++--
 include/linux/nfsd/state.h |    1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 826c265..58f4308 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1067,7 +1067,7 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 
 	nfsd4_release_respages(entry->ce_respages, entry->ce_resused);
 	slot->sl_opcnt = resp->opcnt;
-	entry->ce_status = resp->cstate.status;
+	slot->sl_status = resp->cstate.status;
 
 	/*
 	 * Don't need a page to cache just the sequence operation - the slot
@@ -1178,7 +1178,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 	resp->rqstp->rq_resused = entry->ce_resused;
 	resp->opcnt = slot->sl_opcnt;
 	resp->cstate.iovlen = entry->ce_datav.iov_len + entry->ce_rpchdrlen;
-	status = entry->ce_status;
+	status = slot->sl_status;
 
 	return status;
 }
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 9de02b6..4003afc 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -115,6 +115,7 @@ struct nfsd4_slot {
 	u32				sl_seqid;
 	int				sl_cachethis;
 	int				sl_opcnt;
+	__be32				sl_status;
 	u32				sl_datalen;
 	char				sl_data[NFSD_SLOT_CACHE_SIZE];
 	struct nfsd4_cache_entry	sl_cache_entry;
-- 
1.6.3

