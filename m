From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 45/51] nfsd41: DRC save, restore, and clear functions
Date: Mon, 10 Nov 2008 22:56:09 +0200
Message-ID: <1226350569-11808-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57463 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836AbYKJU4W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:56:22 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Cache all the result pages, including the rpc header in rq_respages[0],
for a request in the slot table cache entry.

Cache the statp pointer from nfsd_dispatch which points into rq_respages[0]
just past the rpc header. When setting a cache entry, calculate and save the
length of the nfs data minus the rpc header for rq_respages[0].

When replaying a cache entry, replace the cached rpc header with the
replayed request rpc result header, unless there is not enough room in the
cached results first page. In that case, use the cached rpc header.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |  106 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfssvc.c           |    6 +++
 include/linux/nfsd/cache.h |    3 +
 include/linux/nfsd/state.h |   17 +++++--
 include/linux/nfsd/xdr4.h  |    7 +++
 5 files changed, 134 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ba6ab19..230ce1d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -412,6 +412,7 @@ alloc_init_session(struct nfs4_client *clp, struct nfsd4_create_session *cses)
 	for (i = 0; i < new->se_fnumslots; i++) {
 		new->se_slots[i].sl_session = new;
 		nfs41_set_slot_state(&new->se_slots[i], NFS4_SLOT_AVAILABLE);
+		spin_lock_init(&new->se_slots[i].sl_cache_entry.ce_lock);
 	}
 
 	new->se_client = clp;
@@ -997,6 +998,111 @@ nfsd4_clear_respages(struct page **respages, short resused)
 }
 
 #if defined(CONFIG_NFSD_V4_1)
+
+void
+nfsd41_set_statp(struct svc_rqst *rqstp, __be32 *statp)
+{
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
+
+	resp->statp = statp;
+}
+
+/*
+ * Cache the reply pages, clearing the previous pages.
+ * Store the base and length of the rq_req.head[0] page
+ * of the NFSv4.1 data, just past the rpc header.
+ */
+void
+nfsd41_set_cache_entry(struct nfsd4_compoundres *resp)
+{
+	struct nfs41_cache_entry *entry =
+		&resp->current_ses->cs_slot->sl_cache_entry;
+	struct svc_rqst *rqstp = resp->rqstp;
+	struct kvec *resv = &rqstp->rq_res.head[0];
+
+	dprintk("--> %s entry %p\n", __func__, entry);
+
+	/* Don't cache a failed OP_SEQUENCE */
+	if (resp->opcnt == 1 && resp->status)
+		return;
+	spin_lock(&entry->ce_lock);
+	nfsd4_clear_respages(entry->ce_respages, entry->ce_resused);
+	nfsd4_cache_rqst_pages(rqstp, entry->ce_respages, &entry->ce_resused);
+	entry->ce_status = resp->status;
+	entry->ce_datav.iov_base = resp->statp;
+	entry->ce_datav.iov_len = resv->iov_len - ((char *)resp->statp -
+				  (char *)page_address(rqstp->rq_respages[0]));
+	spin_unlock(&entry->ce_lock);
+}
+
+/*
+ * Copy the cached NFSv4.1 reply skipping the cached rpc header into the
+ * replay result res.head[0] past the rpc header to end up with replay
+ * rpc header and cached NFSv4.1 reply.
+ */
+static int
+nfsd41_copy_replay_data(struct nfsd4_compoundres *resp,
+			struct nfs41_cache_entry *entry)
+{
+	struct svc_rqst *rqstp = resp->rqstp;
+	struct kvec *resv = &resp->rqstp->rq_res.head[0];
+	int len;
+
+	/* Current request rpc header length*/
+	len = (char *)resp->statp - (char *)page_address(rqstp->rq_respages[0]);
+	if (entry->ce_datav.iov_len + len > PAGE_SIZE) {
+		dprintk("%s v41 cached reply too large (%Zd).\n", __func__,
+			entry->ce_datav.iov_len);
+		return 0;
+	}
+	/* copy the cached reply nfsd data past the current rpc header */
+	memcpy((char *)resv->iov_base + len, entry->ce_datav.iov_base,
+		entry->ce_datav.iov_len);
+	resv->iov_len = len + entry->ce_datav.iov_len;
+	return 1;
+}
+
+/*
+ * Keep the first page of the replay. Copy the NFSv4.1 data from the first
+ * cached page.  Replace any futher replay pages from the cache.
+ */
+__be32
+nfsd41_replay_cache_entry(struct nfsd4_compoundres *resp)
+{
+	struct nfs41_cache_entry *entry =
+		&resp->current_ses->cs_slot->sl_cache_entry;
+	__be32 status;
+
+	dprintk("--> %s entry %p\n", __func__, entry);
+
+	spin_lock(&entry->ce_lock);
+
+	if (!nfsd41_copy_replay_data(resp, entry)) {
+		/*
+		 * Not enough room to use the replay rpc header, send the
+		 * cached header. Release all the allocated result pages.
+		 */
+		svc_free_res_pages(resp->rqstp);
+		nfsd4_move_pages(resp->rqstp->rq_respages, entry->ce_respages,
+			entry->ce_resused);
+	} else {
+		/* Release all but the first allocatek result page */
+
+		resp->rqstp->rq_resused--;
+		svc_free_res_pages(resp->rqstp);
+
+		nfsd4_move_pages(&resp->rqstp->rq_respages[1],
+				 &entry->ce_respages[1],
+				 entry->ce_resused - 1);
+	}
+
+	resp->rqstp->rq_resused = entry->ce_resused;
+	status = entry->ce_status;
+	spin_unlock(&entry->ce_lock);
+
+	return status;
+}
+
 /*
  * Set the exchange_id flags returned by the server.
  */
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 07e4f5d..a9f90b6 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -543,6 +543,12 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 		+ rqstp->rq_res.head[0].iov_len;
 	rqstp->rq_res.head[0].iov_len += sizeof(__be32);
 
+#ifdef CONFIG_NFSD_V4_1
+	/* NFSv4.1 DRC requires statp */
+	if (rqstp->rq_vers == 4)
+		nfsd41_set_statp(rqstp, statp);
+#endif /* CONFIG_NFSD_V4_1 */
+
 	/* Now call the procedure handler, and encode NFS status. */
 	nfserr = proc->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
 	nfserr = map_new_errors(rqstp->rq_vers, nfserr);
diff --git a/include/linux/nfsd/cache.h b/include/linux/nfsd/cache.h
index 04b355c..9315699 100644
--- a/include/linux/nfsd/cache.h
+++ b/include/linux/nfsd/cache.h
@@ -75,5 +75,8 @@ int	nfsd_reply_cache_init(void);
 void	nfsd_reply_cache_shutdown(void);
 int	nfsd_cache_lookup(struct svc_rqst *, int);
 void	nfsd_cache_update(struct svc_rqst *, int, __be32 *);
+#ifdef CONFIG_NFSD_V4_1
+void	nfsd41_set_statp(struct svc_rqst *, __be32*);
+#endif /* CONFIG_NFSD_V4_1 */
 
 #endif /* NFSCACHE_H */
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 4f37e2f..e4dc32f 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -125,15 +125,22 @@ enum {
 	NFS4_SLOT_INPROGRESS
 };
 
+struct nfs41_cache_entry {
+	spinlock_t	ce_lock;
+	__be32		ce_status;
+	struct kvec	ce_datav; /* encoded NFSv4.1 data in rq_res.head[0] */
+	struct page	*ce_respages[RPCSVC_MAXPAGES];
+	short		ce_resused;
+};
+
 /*
  * nfs41_slot
- *
- * for now, just slot sequence number - will hold DRC for this slot.
  */
 struct nfs41_slot {
-	atomic_t		sl_state;
-	struct nfs41_session	*sl_session;
-	u32			sl_seqid;
+	atomic_t			sl_state;
+	struct nfs41_session		*sl_session;
+	u32				sl_seqid;
+	struct nfs41_cache_entry	sl_cache_entry;
 };
 
 /*
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index fc42fba..554f2cd 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -491,6 +491,11 @@ struct nfsd4_compoundres {
 	u32				opcnt;
 	__be32 *			tagp; /* where to encode tag and  opcount */
 	u32				minorversion;
+#if defined(CONFIG_NFSD_V4_1)
+	__be32				*statp;
+	u32				status;
+	struct current_session		*current_ses;
+#endif /* CONFIG_NFSD_V4_1 */
 };
 
 #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)
@@ -534,6 +539,8 @@ extern __be32 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 #if defined(CONFIG_NFSD_V4_1)
 extern void nfsd41_current_session_free(struct current_session *cses);
 extern struct current_session *nfsd41_current_session_alloc(void);
+extern void nfsd41_set_cache_entry(struct nfsd4_compoundres *resp);
+extern __be32 nfsd41_replay_cache_entry(struct nfsd4_compoundres *resp);
 extern __be32 nfsd4_exchange_id(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_exchange_id *);
-- 
1.6.0.2

