From: andros@netapp.com
Subject: [PATCH 14/30] nfsd41: nfsd41: replace ce_status with nfsd4_slot field
Date: Mon,  8 Jun 2009 14:20:55 -0400
Message-ID: <1244485271-7461-15-git-send-email-andros@netapp.com>
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
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38770 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753254AbZFHSV1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:27 -0400
In-Reply-To: <1244485271-7461-14-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

In preparation to remove struct nfsd4_cache_entry

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c        |    4 ++--
 include/linux/nfsd/state.h |    1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c5c372d..45cca94 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1063,7 +1063,7 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 
 	nfsd4_release_respages(entry->ce_respages, entry->ce_resused);
 	slot->sl_opcnt = resp->opcnt;
-	entry->ce_status = resp->cstate.status;
+	slot->sl_status = resp->cstate.status;
 
 	/*
 	 * Don't need a page to cache just the sequence operation - the slot
@@ -1177,7 +1177,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 	resp->rqstp->rq_resused = entry->ce_resused;
 	resp->opcnt = slot->sl_opcnt;
 	resp->cstate.iovlen = entry->ce_datav.iov_len + entry->ce_rpchdrlen;
-	status = entry->ce_status;
+	status = slot->sl_status;
 
 	return status;
 }
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index ceee37a..65f8fb6 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -122,6 +122,7 @@ struct nfsd4_slot {
 	u32				sl_seqid;
 	int				sl_cachethis;
 	int				sl_opcnt;
+	__be32				sl_status;
 	u32				sl_datalen;
 	char				sl_data[NFSD_SLOT_CACHE_SIZE];
 	struct nfsd4_cache_entry	sl_cache_entry;
-- 
1.5.4.3

