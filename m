From: andros@netapp.com
Subject: [PATCH 15/31] nfsd41: nfsd41: replace ce_status with nfsd4_slot field
Date: Tue, 28 Apr 2009 12:59:49 -0400
Message-ID: <1240938005-23778-15-git-send-email-andros@netapp.com>
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
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50815 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757221AbZD1RAc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:00:32 -0400
In-Reply-To: <1240938005-23778-14-git-send-email-andros@netapp.com>
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
index d237e62..05083d3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1081,7 +1081,7 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 
 	nfsd4_release_respages(entry->ce_respages, entry->ce_resused);
 	slot->sl_opcnt = resp->opcnt;
-	entry->ce_status = resp->cstate.status;
+	slot->sl_status = resp->cstate.status;
 
 	/*
 	 * Don't need a page to cache just the sequence operation - the slot
@@ -1192,7 +1192,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 	resp->rqstp->rq_resused = entry->ce_resused;
 	resp->opcnt = slot->sl_opcnt;
 	resp->cstate.iovlen = entry->ce_datav.iov_len + entry->ce_rpchdrlen;
-	status = entry->ce_status;
+	status = slot->sl_status;
 
 	return status;
 }
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 46aabb1..8800e18 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -128,6 +128,7 @@ struct nfsd4_slot {
 	u32				sl_seqid;
 	int				sl_cachethis;
 	int				sl_opcnt;
+	__be32				sl_status;
 	u32				sl_datalen;
 	char				sl_data[NFSD_SLOT_CACHE_SIZE];
 	struct nfsd4_cache_entry	sl_cache_entry;
-- 
1.5.4.3

