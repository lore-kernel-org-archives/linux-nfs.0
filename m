From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 20/47] nfsd41: DRC save, restore, and clear functions
Date: Fri, 27 Mar 2009 06:16:07 +0300
Message-ID: <1238123767-7577-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:21350 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755704AbZC0DQM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:16:12 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
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

The sessions fore channel maxresponse size cached is set to NFSD_PAGES_PER_SLOT
* PAGE_SIZE. For compounds we are cacheing with operations such as READDIR
that use the xdr_buf->pages to hold data, we choose to cache the extra page of
data rather than copying data from xdr_buf->pages into the xdr_buf->head page.

[nfsd41: limit cache to maxresponsesize_cached]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: mv nfsd4_set_statp under CONFIG_NFSD_V4_1]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |  142 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfssvc.c           |    4 +
 include/linux/nfsd/cache.h |    5 ++
 include/linux/nfsd/state.h |   13 ++++
 include/linux/nfsd/xdr4.h  |    4 +
 5 files changed, 168 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 10eb67b..f0ce639 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -860,6 +860,148 @@ out_err:
 }
 
 #if defined(CONFIG_NFSD_V4_1)
+void
+nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp)
+{
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
+
+	resp->cstate.statp = statp;
+}
+
+/*
+ * Dereference the result pages.
+ */
+static void
+nfsd4_release_respages(struct page **respages, short resused)
+{
+	int page_no;
+
+	dprintk("--> %s\n", __func__);
+	for (page_no = 0; page_no < resused; page_no++) {
+		if (!respages[page_no])
+			continue;
+		put_page(respages[page_no]);
+		respages[page_no] = NULL;
+	}
+}
+
+static void
+nfsd4_move_pages(struct page **topages, struct page **frompages, short count)
+{
+	int page_no;
+
+	for (page_no = 0; page_no < count; page_no++) {
+		topages[page_no] = frompages[page_no];
+		if (!topages[page_no])
+			continue;
+		get_page(topages[page_no]);
+	}
+}
+
+/*
+ * Cache the reply pages up to NFSD_PAGES_PER_SLOT + 1, clearing the previous
+ * pages. We add a page to NFSD_PAGES_PER_SLOT for the case where the total
+ * length of the XDR response is less than se_fmaxresp_cached
+ * (NFSD_PAGES_PER_SLOT * PAGE_SIZE) but the xdr_buf pages is used for a
+ * of the reply (e.g. readdir).
+ *
+ * Store the base and length of the rq_req.head[0] page
+ * of the NFSv4.1 data, just past the rpc header.
+ */
+void
+nfsd4_set_cache_entry(struct nfsd4_compoundres *resp)
+{
+	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
+	struct svc_rqst *rqstp = resp->rqstp;
+	struct kvec *resv = &rqstp->rq_res.head[0];
+
+	dprintk("--> %s entry %p\n", __func__, entry);
+
+	/* Don't cache a failed OP_SEQUENCE */
+	if (resp->opcnt == 1 && resp->cstate.status)
+		return;
+	nfsd4_release_respages(entry->ce_respages, entry->ce_resused);
+	entry->ce_resused = rqstp->rq_resused;
+	if (entry->ce_resused > NFSD_PAGES_PER_SLOT + 1)
+		entry->ce_resused = NFSD_PAGES_PER_SLOT + 1;
+	nfsd4_move_pages(entry->ce_respages, rqstp->rq_respages,
+			 entry->ce_resused);
+	entry->ce_status = resp->cstate.status;
+	entry->ce_datav.iov_base = resp->cstate.statp;
+	entry->ce_datav.iov_len = resv->iov_len - ((char *)resp->cstate.statp -
+				(char *)page_address(rqstp->rq_respages[0]));
+	entry->ce_opcnt = resp->opcnt;
+	/* Current request rpc header length*/
+	entry->ce_rpchdrlen = (char *)resp->cstate.statp -
+				(char *)page_address(rqstp->rq_respages[0]);
+}
+
+/*
+ * Copy the cached NFSv4.1 reply skipping the cached rpc header into the
+ * replay result res.head[0] past the rpc header to end up with replay
+ * rpc header and cached NFSv4.1 reply.
+ */
+static int
+nfsd41_copy_replay_data(struct nfsd4_compoundres *resp,
+			struct nfsd4_cache_entry *entry)
+{
+	struct svc_rqst *rqstp = resp->rqstp;
+	struct kvec *resv = &resp->rqstp->rq_res.head[0];
+	int len;
+
+	/* Current request rpc header length*/
+	len = (char *)resp->cstate.statp -
+			(char *)page_address(rqstp->rq_respages[0]);
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
+nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp)
+{
+	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
+	__be32 status;
+
+	dprintk("--> %s entry %p\n", __func__, entry);
+
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
+		/* Release all but the first allocated result page */
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
+
+	return status;
+}
+
 /*
  * Set the exchange_id flags returned by the server.
  */
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index ef0a368..b5168d1 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -515,6 +515,10 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 		+ rqstp->rq_res.head[0].iov_len;
 	rqstp->rq_res.head[0].iov_len += sizeof(__be32);
 
+	/* NFSv4.1 DRC requires statp */
+	if (rqstp->rq_vers == 4)
+		nfsd4_set_statp(rqstp, statp);
+
 	/* Now call the procedure handler, and encode NFS status. */
 	nfserr = proc->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
 	nfserr = map_new_errors(rqstp->rq_vers, nfserr);
diff --git a/include/linux/nfsd/cache.h b/include/linux/nfsd/cache.h
index 04b355c..57a83c7 100644
--- a/include/linux/nfsd/cache.h
+++ b/include/linux/nfsd/cache.h
@@ -75,5 +75,10 @@ int	nfsd_reply_cache_init(void);
 void	nfsd_reply_cache_shutdown(void);
 int	nfsd_cache_lookup(struct svc_rqst *, int);
 void	nfsd_cache_update(struct svc_rqst *, int, __be32 *);
+#ifdef CONFIG_NFSD_V4_1
+void	nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp);
+#else /* CONFIG_NFSD_V4_1 */
+static inline void nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp) {}
+#endif /* CONFIG_NFSD_V4_1 */
 
 #endif /* NFSCACHE_H */
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index feab6ec..8ca6a82 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -99,10 +99,23 @@ struct nfs4_callback {
 	struct rpc_clnt *       cb_client;
 };
 
+/* Maximum number of pages per slot cache entry */
+#define NFSD_PAGES_PER_SLOT	1
+
+struct nfsd4_cache_entry {
+	__be32		ce_status;
+	struct kvec	ce_datav; /* encoded NFSv4.1 data in rq_res.head[0] */
+	struct page	*ce_respages[NFSD_PAGES_PER_SLOT + 1];
+	short		ce_resused;
+	int		ce_opcnt;
+	int		ce_rpchdrlen;
+};
+
 struct nfsd4_slot {
 	bool				sl_inuse;
 	struct nfsd4_session		*sl_session;
 	u32				sl_seqid;
+	struct nfsd4_cache_entry	sl_cache_entry;
 };
 
 struct nfsd4_session {
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 9e4d8db..cde8947 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -50,6 +50,8 @@ struct nfsd4_compound_state {
 	struct nfs4_stateowner	*replay_owner;
 	/* For sessions DRC */
 	struct nfsd4_slot	*slot;
+	__be32			*statp;
+	u32			status;
 };
 
 struct nfsd4_change_info {
@@ -490,6 +492,8 @@ extern __be32 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid_confirm *setclientid_confirm);
 #if defined(CONFIG_NFSD_V4_1)
+extern void nfsd4_set_cache_entry(struct nfsd4_compoundres *resp);
+extern __be32 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp);
 extern __be32 nfsd4_exchange_id(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 struct nfsd4_exchange_id *);
-- 
1.6.2.1

