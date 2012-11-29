Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61467 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932299Ab2K2DRv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 22:17:51 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] NFSD: Make DRC memory limits work with dynamic slot allocation
Date: Wed, 28 Nov 2012 22:17:41 -0500
Message-Id: <1354159063-17343-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1354159063-17343-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1354159063-17343-1-git-send-email-Trond.Myklebust@netapp.com>
 <1354159063-17343-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When growing the slot table, we always want to ensure that we're
not exceeding DRC size limits.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfsd/nfs4state.c | 56 ++++++++++++++++++++++++++---------------------------
 fs/nfsd/nfsd.h      |  4 ++--
 fs/nfsd/nfssvc.c    |  4 ++--
 fs/nfsd/state.h     |  1 +
 4 files changed, 33 insertions(+), 32 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5717ea1..9cb2450 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -704,15 +704,6 @@ gen_sessionid(struct nfsd4_session *ses)
  */
 #define NFSD_MIN_HDR_SEQ_SZ  (24 + 12 + 44)
 
-/*
- * We don't actually need to cache the rpc and session headers, so we
- * can allocate a little less for each slot:
- */
-static inline int slot_bytes(struct nfsd4_channel_attrs *ca)
-{
-	return ca->maxresp_cached - NFSD_MIN_HDR_SEQ_SZ;
-}
-
 static int nfsd4_sanitize_slot_size(u32 size)
 {
 	size -= NFSD_MIN_HDR_SEQ_SZ; /* We don't cache the rpc header */
@@ -726,27 +717,33 @@ static int nfsd4_sanitize_slot_size(u32 size)
  * re-negotiate active sessions and reduce their slot usage to make
  * room for new connections. For now we just fail the create session.
  */
-static int nfsd4_get_drc_mem(int slotsize, u32 num)
+static bool nfsd4_get_drc_mem(struct nfsd4_slot_table *tbl)
 {
-	int avail;
-
-	num = min_t(u32, num, NFSD_MAX_SLOTS_PER_SESSION);
+	unsigned long new_memused;
+	unsigned long avail;
+	bool ret = false;
 
+	new_memused = tbl->slt_memused + tbl->slt_slotsize;
+	if (new_memused > NFSD_MAX_MEM_PER_SESSION)
+		goto out;
 	spin_lock(&nfsd_drc_lock);
-	avail = min_t(int, NFSD_MAX_MEM_PER_SESSION,
-			nfsd_drc_max_mem - nfsd_drc_mem_used);
-	num = min_t(int, num, avail / slotsize);
-	nfsd_drc_mem_used += num * slotsize;
+	avail = nfsd_drc_max_mem - nfsd_drc_mem_used;
+	if (avail >= tbl->slt_slotsize) {
+		nfsd_drc_mem_used += tbl->slt_slotsize;
+		tbl->slt_memused = new_memused;
+		ret = true;
+	}
 	spin_unlock(&nfsd_drc_lock);
-
-	return num;
+out:
+	return ret;
 }
 
-static void nfsd4_put_drc_mem(int slotsize, int num)
+static void nfsd4_put_drc_mem(struct nfsd4_slot_table *tbl)
 {
 	spin_lock(&nfsd_drc_lock);
-	nfsd_drc_mem_used -= slotsize * num;
+	nfsd_drc_mem_used -= tbl->slt_slotsize;
 	spin_unlock(&nfsd_drc_lock);
+	tbl->slt_memused -= tbl->slt_slotsize;
 }
 
 static void nfsd4_free_slot(struct nfsd4_slot *slot)
@@ -795,16 +792,21 @@ static bool nfsd4_grow_slot_table_locked(struct nfsd4_slot_table *tbl,
 	struct nfsd4_slot *slot = NULL;
 	struct nfsd4_slot *prev;
 	u32 next_slotid;
+	bool ret;
 
 	for (;;) {
 		prev = nfsd4_find_last_slot_locked(tbl);
 		if (prev != NULL) {
+			ret = true;
 			if (prev->sl_slotid >= slotid)
 				break;
 			next_slotid = prev->sl_slotid + 1;
 		} else
 			next_slotid = 0;
+		ret = false;
 		if (slot != NULL){
+			if (!nfsd4_get_drc_mem(tbl))
+				break;
 			slot->sl_slotid = next_slotid;
 			list_add_tail(&slot->sl_list, &tbl->slt_head);
 		}
@@ -812,10 +814,10 @@ static bool nfsd4_grow_slot_table_locked(struct nfsd4_slot_table *tbl,
 		slot = nfsd4_new_slot(tbl->slt_slotsize, gfp_mask);
 		spin_lock(&tbl->slt_lock);
 		if (slot == NULL)
-			return false;
+			break;
 	}
 	nfsd4_free_slot(slot);
-	return true;
+	return ret;
 }
 
 static bool nfsd4_grow_slot_table(struct nfsd4_slot_table *tbl,
@@ -840,6 +842,7 @@ static void nfsd4_truncate_slot_table_locked(struct nfsd4_slot_table *tbl,
 			break;
 		list_del(&slot->sl_list);
 		nfsd4_free_slot(slot);
+		nfsd4_put_drc_mem(tbl);
 	}
 }
 
@@ -987,7 +990,6 @@ static void nfsd4_del_conns(struct nfsd4_session *s)
 
 static void __free_session(struct nfsd4_session *ses)
 {
-	nfsd4_put_drc_mem(slot_bytes(&ses->se_fchannel), ses->se_fchannel.maxreqs);
 	nfsd4_free_slot_table(&ses->se_slots);
 	kfree(ses);
 }
@@ -1021,15 +1023,13 @@ static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *fchan)
 	 * decrease number of slots instead of their size.
 	 */
 	slotsize = nfsd4_sanitize_slot_size(fchan->maxresp_cached);
-	numslots = nfsd4_get_drc_mem(slotsize, fchan->maxreqs);
+	numslots = min_t(u32, fchan->maxreqs, NFSD_MAX_SLOTS_PER_SESSION);
 	if (numslots < 1)
 		return NULL;
 
 	new = __alloc_session(slotsize, numslots - 1);
-	if (!new) {
-		nfsd4_put_drc_mem(slotsize, fchan->maxreqs);
+	if (!new)
 		return NULL;
-	}
 	init_forechannel_attrs(&new->se_fchannel, fchan, numslots, slotsize);
 	return new;
 }
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 80d5ce4..322eb93 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -57,8 +57,8 @@ extern u32			nfsd_supported_minorversion;
 extern struct mutex		nfsd_mutex;
 extern struct svc_serv		*nfsd_serv;
 extern spinlock_t		nfsd_drc_lock;
-extern unsigned int		nfsd_drc_max_mem;
-extern unsigned int		nfsd_drc_mem_used;
+extern unsigned long		nfsd_drc_max_mem;
+extern unsigned long		nfsd_drc_mem_used;
 
 extern const struct seq_operations nfs_exports_op;
 
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 2013aa00..180d205 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -61,8 +61,8 @@ struct svc_serv 		*nfsd_serv;
  * nfsd_drc_pages_used tracks the current version 4.1 DRC memory usage.
  */
 spinlock_t	nfsd_drc_lock;
-unsigned int	nfsd_drc_max_mem;
-unsigned int	nfsd_drc_mem_used;
+unsigned long	nfsd_drc_max_mem;
+unsigned long	nfsd_drc_mem_used;
 
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 static struct svc_stat	nfsd_acl_svcstats;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 7d319e9a..6bcc8a1 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -145,6 +145,7 @@ struct nfsd4_slot_table {
 	struct list_head	slt_head;
 	spinlock_t		slt_lock;
 	size_t			slt_slotsize;
+	unsigned long		slt_memused;
 };
 
 struct nfsd4_channel_attrs {
-- 
1.7.11.7

