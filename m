From: andros@netapp.com
Subject: [PATCH 4/4] nfsd41: replace page based DRC with buffer based DRC
Date: Fri, 28 Aug 2009 08:45:04 -0400
Message-ID: <1251463504-3376-5-git-send-email-andros@netapp.com>
References: <1251463504-3376-1-git-send-email-andros@netapp.com>
 <1251463504-3376-2-git-send-email-andros@netapp.com>
 <1251463504-3376-3-git-send-email-andros@netapp.com>
 <1251463504-3376-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33497 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752111AbZIAVCc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2009 17:02:32 -0400
In-Reply-To: <1251463504-3376-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Use NFSD_SLOT_CACHE_SIZE size buffers for sessions DRC instead of holding nfsd
pages in cache.

Connectathon testing has shown that 1024 bytes for encoded compound operation
responses past the sequence operation is sufficient, 512 bytes is a little too
small. Set NFSD_SLOT_CACHE_SIZE to 1024.

Allocate memory for the session DRC in the CREATE_SESSION operation
to guarantee that the memory resource is available for caching responses.
Allocate each slot individually in preparation for slot table size negotiation.

Remove struct nfsd4_cache_entry and helper functions for the old page-based
DRC.

The iov_len calculation in nfs4svc_encode_compoundres is now always
correct.  Replay is now done in nfsd4_sequence under the state lock, so
the session ref count is only bumped on non-replay. Clean up the
nfs4svc_encode_compoundres session logic.

The nfsd4_compound_state statp pointer is also not used.
Remove nfsd4_set_statp().

Move useful nfsd4_cache_entry fields into nfsd4_slot.

Signed-off-by: Andy Adamson <andros@netapp.com
---
 fs/nfsd/nfs4state.c        |  211 +++++++++++++-------------------------------
 fs/nfsd/nfs4xdr.c          |   17 ++--
 fs/nfsd/nfssvc.c           |    4 -
 include/linux/nfsd/state.h |   27 ++----
 include/linux/nfsd/xdr4.h  |    5 +-
 5 files changed, 79 insertions(+), 185 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c9a45f4..46e9ac5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -514,12 +514,23 @@ static int init_forechannel_attrs(struct svc_rqst *rqstp,
 	return status;
 }
 
+static void
+free_session_slots(struct nfsd4_session *ses)
+{
+	int i;
+
+	for (i = 0; i < ses->se_fchannel.maxreqs; i++)
+		kfree(ses->se_slots[i]);
+}
+
 static int
 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp,
 		   struct nfsd4_create_session *cses)
 {
 	struct nfsd4_session *new, tmp;
-	int idx, status = nfserr_serverfault, slotsize;
+	struct nfsd4_slot *sp;
+	int idx, slotsize, cachesize, i;
+	int status;
 
 	memset(&tmp, 0, sizeof(tmp));
 
@@ -530,14 +541,27 @@ alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp,
 	if (status)
 		goto out;
 
-	/* allocate struct nfsd4_session and slot table in one piece */
-	slotsize = tmp.se_fchannel.maxreqs * sizeof(struct nfsd4_slot);
+	BUILD_BUG_ON(NFSD_MAX_SLOTS_PER_SESSION * sizeof(struct nfsd4_slot)
+		     + sizeof(struct nfsd4_session) > PAGE_SIZE);
+
+	status = nfserr_serverfault;
+	/* allocate struct nfsd4_session and slot table pointers in one piece */
+	slotsize = tmp.se_fchannel.maxreqs * sizeof(struct nfsd4_slot *);
 	new = kzalloc(sizeof(*new) + slotsize, GFP_KERNEL);
 	if (!new)
 		goto out;
 
 	memcpy(new, &tmp, sizeof(*new));
 
+	/* allocate each struct nfsd4_slot and data cache in one piece */
+	cachesize = new->se_fchannel.maxresp_cached - NFSD_MIN_HDR_SEQ_SZ;
+	for (i = 0; i < new->se_fchannel.maxreqs; i++) {
+		sp = kzalloc(sizeof(*sp) + cachesize, GFP_KERNEL);
+		if (!sp)
+			goto out_free;
+		new->se_slots[i] = sp;
+	}
+
 	new->se_client = clp;
 	gen_sessionid(new);
 	idx = hash_sessionid(&new->se_sessionid);
@@ -554,6 +578,10 @@ alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp,
 	status = nfs_ok;
 out:
 	return status;
+out_free:
+	free_session_slots(new);
+	kfree(new);
+	goto out;
 }
 
 /* caller must hold sessionid_lock */
@@ -596,22 +624,16 @@ release_session(struct nfsd4_session *ses)
 	nfsd4_put_session(ses);
 }
 
-static void nfsd4_release_respages(struct page **respages, short resused);
-
 void
 free_session(struct kref *kref)
 {
 	struct nfsd4_session *ses;
-	int i;
 
 	ses = container_of(kref, struct nfsd4_session, se_ref);
-	for (i = 0; i < ses->se_fchannel.maxreqs; i++) {
-		struct nfsd4_cache_entry *e = &ses->se_slots[i].sl_cache_entry;
-		nfsd4_release_respages(e->ce_respages, e->ce_resused);
-	}
 	spin_lock(&nfsd_drc_lock);
 	nfsd_drc_mem_used -= ses->se_fchannel.maxreqs * NFSD_SLOT_CACHE_SIZE;
 	spin_unlock(&nfsd_drc_lock);
+	free_session_slots(ses);
 	kfree(ses);
 }
 
@@ -968,116 +990,31 @@ out_err:
 	return;
 }
 
-void
-nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp)
-{
-	struct nfsd4_compoundres *resp = rqstp->rq_resp;
-
-	resp->cstate.statp = statp;
-}
-
-/*
- * Dereference the result pages.
- */
-static void
-nfsd4_release_respages(struct page **respages, short resused)
-{
-	int i;
-
-	dprintk("--> %s\n", __func__);
-	for (i = 0; i < resused; i++) {
-		if (!respages[i])
-			continue;
-		put_page(respages[i]);
-		respages[i] = NULL;
-	}
-}
-
-static void
-nfsd4_copy_pages(struct page **topages, struct page **frompages, short count)
-{
-	int i;
-
-	for (i = 0; i < count; i++) {
-		topages[i] = frompages[i];
-		if (!topages[i])
-			continue;
-		get_page(topages[i]);
-	}
-}
-
 /*
- * Cache the reply pages up to NFSD_PAGES_PER_SLOT + 1, clearing the previous
- * pages. We add a page to NFSD_PAGES_PER_SLOT for the case where the total
- * length of the XDR response is less than se_fmaxresp_cached
- * (NFSD_PAGES_PER_SLOT * PAGE_SIZE) but the xdr_buf pages is used for a
- * of the reply (e.g. readdir).
- *
- * Store the base and length of the rq_req.head[0] page
- * of the NFSv4.1 data, just past the rpc header.
+ * Cache a reply. nfsd4_check_drc_limit() has bounded the cache size.
  */
 void
 nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 {
-	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
-	struct svc_rqst *rqstp = resp->rqstp;
-	struct kvec *resv = &rqstp->rq_res.head[0];
-
-	dprintk("--> %s entry %p\n", __func__, entry);
+	struct nfsd4_slot *slot = resp->cstate.slot;
+	unsigned int base;
 
-	nfsd4_release_respages(entry->ce_respages, entry->ce_resused);
-	entry->ce_opcnt = resp->opcnt;
-	entry->ce_status = resp->cstate.status;
+	dprintk("--> %s slot %p\n", __func__, slot);
 
-	/*
-	 * Don't need a page to cache just the sequence operation - the slot
-	 * does this for us!
-	 */
+	slot->sl_opcnt = resp->opcnt;
+	slot->sl_status = resp->cstate.status;
 
 	if (nfsd4_not_cached(resp)) {
-		entry->ce_resused = 0;
-		entry->ce_rpchdrlen = 0;
-		dprintk("%s Just cache SEQUENCE. ce_cachethis %d\n", __func__,
-			resp->cstate.slot->sl_cache_entry.ce_cachethis);
+		slot->sl_datalen = 0;
 		return;
 	}
-	entry->ce_resused = rqstp->rq_resused;
-	if (entry->ce_resused > NFSD_PAGES_PER_SLOT + 1)
-		entry->ce_resused = NFSD_PAGES_PER_SLOT + 1;
-	nfsd4_copy_pages(entry->ce_respages, rqstp->rq_respages,
-			 entry->ce_resused);
-	entry->ce_datav.iov_base = resp->cstate.statp;
-	entry->ce_datav.iov_len = resv->iov_len - ((char *)resp->cstate.statp -
-				(char *)page_address(rqstp->rq_respages[0]));
-	/* Current request rpc header length*/
-	entry->ce_rpchdrlen = (char *)resp->cstate.statp -
-				(char *)page_address(rqstp->rq_respages[0]);
-}
-
-/*
- * We keep the rpc header, but take the nfs reply from the replycache.
- */
-static int
-nfsd41_copy_replay_data(struct nfsd4_compoundres *resp,
-			struct nfsd4_cache_entry *entry)
-{
-	struct svc_rqst *rqstp = resp->rqstp;
-	struct kvec *resv = &resp->rqstp->rq_res.head[0];
-	int len;
-
-	/* Current request rpc header length*/
-	len = (char *)resp->cstate.statp -
-			(char *)page_address(rqstp->rq_respages[0]);
-	if (entry->ce_datav.iov_len + len > PAGE_SIZE) {
-		dprintk("%s v41 cached reply too large (%Zd).\n", __func__,
-			entry->ce_datav.iov_len);
-		return 0;
-	}
-	/* copy the cached reply nfsd data past the current rpc header */
-	memcpy((char *)resv->iov_base + len, entry->ce_datav.iov_base,
-		entry->ce_datav.iov_len);
-	resv->iov_len = len + entry->ce_datav.iov_len;
-	return 1;
+	slot->sl_datalen = (char *)resp->p - (char *)resp->cstate.datap;
+	base = (char *)resp->cstate.datap -
+					(char *)resp->xbuf->head[0].iov_base;
+	if (read_bytes_from_xdr_buf(resp->xbuf, base, slot->sl_data,
+				    slot->sl_datalen))
+		WARN("%s: sessions DRC could not cache compound\n", __func__);
+	return;
 }
 
 /*
@@ -1095,14 +1032,14 @@ nfsd4_enc_sequence_replay(struct nfsd4_compoundargs *args,
 	struct nfsd4_slot *slot = resp->cstate.slot;
 
 	dprintk("--> %s resp->opcnt %d cachethis %u \n", __func__,
-		resp->opcnt, resp->cstate.slot->sl_cache_entry.ce_cachethis);
+		resp->opcnt, resp->cstate.slot->sl_cachethis);
 
 	/* Encode the replayed sequence operation */
 	op = &args->ops[resp->opcnt - 1];
 	nfsd4_encode_operation(resp, op);
 
 	/* Return nfserr_retry_uncached_rep in next operation. */
-	if (args->opcnt > 1 && slot->sl_cache_entry.ce_cachethis == 0) {
+	if (args->opcnt > 1 && slot->sl_cachethis == 0) {
 		op = &args->ops[resp->opcnt++];
 		op->status = nfserr_retry_uncached_rep;
 		nfsd4_encode_operation(resp, op);
@@ -1111,57 +1048,29 @@ nfsd4_enc_sequence_replay(struct nfsd4_compoundargs *args,
 }
 
 /*
- * Keep the first page of the replay. Copy the NFSv4.1 data from the first
- * cached page.  Replace any futher replay pages from the cache.
+ * The sequence operation is not cached because we can use the slot and
+ * session values.
  */
 __be32
 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 			 struct nfsd4_sequence *seq)
 {
-	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
+	struct nfsd4_slot *slot = resp->cstate.slot;
 	__be32 status;
 
-	dprintk("--> %s entry %p\n", __func__, entry);
-
-	/*
-	 * If this is just the sequence operation, we did not keep
-	 * a page in the cache entry because we can just use the
-	 * slot info stored in struct nfsd4_sequence that was checked
-	 * against the slot in nfsd4_sequence().
-	 *
-	 * This occurs when seq->cachethis is FALSE, or when the client
-	 * session inactivity timer fires and a solo sequence operation
-	 * is sent (lease renewal).
-	 */
+	dprintk("--> %s slot %p\n", __func__, slot);
 
 	/* Either returns 0 or nfserr_retry_uncached */
 	status = nfsd4_enc_sequence_replay(resp->rqstp->rq_argp, resp);
 	if (status == nfserr_retry_uncached_rep)
 		return status;
 
-	if (!nfsd41_copy_replay_data(resp, entry)) {
-		/*
-		 * Not enough room to use the replay rpc header, send the
-		 * cached header. Release all the allocated result pages.
-		 */
-		svc_free_res_pages(resp->rqstp);
-		nfsd4_copy_pages(resp->rqstp->rq_respages, entry->ce_respages,
-			entry->ce_resused);
-	} else {
-		/* Release all but the first allocated result page */
-
-		resp->rqstp->rq_resused--;
-		svc_free_res_pages(resp->rqstp);
-
-		nfsd4_copy_pages(&resp->rqstp->rq_respages[1],
-				 &entry->ce_respages[1],
-				 entry->ce_resused - 1);
-	}
+	/* The sequence operation has been encoded, cstate->datap set. */
+	memcpy(resp->cstate.datap, slot->sl_data, slot->sl_datalen);
 
-	resp->rqstp->rq_resused = entry->ce_resused;
-	resp->opcnt = entry->ce_opcnt;
-	resp->cstate.iovlen = entry->ce_datav.iov_len + entry->ce_rpchdrlen;
-	status = entry->ce_status;
+	resp->opcnt = slot->sl_opcnt;
+	resp->p = resp->cstate.datap + XDR_QUADLEN(slot->sl_datalen);
+	status = slot->sl_status;
 
 	return status;
 }
@@ -1493,7 +1402,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	if (seq->slotid >= session->se_fchannel.maxreqs)
 		goto out;
 
-	slot = &session->se_slots[seq->slotid];
+	slot = session->se_slots[seq->slotid];
 	dprintk("%s: slotid %d\n", __func__, seq->slotid);
 
 	/* We do not negotiate the number of slots yet, so set the
@@ -1506,7 +1415,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 		cstate->slot = slot;
 		cstate->session = session;
 		/* Return the cached reply status and set cstate->status
-		 * for nfsd4_svc_encode_compoundres processing */
+		 * for nfsd4_proc_compound processing */
 		status = nfsd4_replay_cache_entry(resp, seq);
 		cstate->status = nfserr_replay_cache;
 		goto out;
@@ -1517,7 +1426,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	/* Success! bump slot seqid */
 	slot->sl_inuse = true;
 	slot->sl_seqid = seq->seqid;
-	slot->sl_cache_entry.ce_cachethis = seq->cachethis;
+	slot->sl_cachethis = seq->cachethis;
 
 	cstate->slot = slot;
 	cstate->session = session;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fdf632b..8fa38f5 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3064,6 +3064,7 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 	WRITE32(0);
 
 	ADJUST_ARGS();
+	resp->cstate.datap = p; /* DRC cache data pointer */
 	return 0;
 }
 
@@ -3166,7 +3167,7 @@ static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
 		return status;
 
 	session = resp->cstate.session;
-	if (session == NULL || slot->sl_cache_entry.ce_cachethis == 0)
+	if (session == NULL || slot->sl_cachethis == 0)
 		return status;
 
 	if (resp->opcnt >= args->opcnt)
@@ -3291,6 +3292,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 	/*
 	 * All that remains is to write the tag and operation count...
 	 */
+	struct nfsd4_compound_state *cs = &resp->cstate;
 	struct kvec *iov;
 	p = resp->tagp;
 	*p++ = htonl(resp->taglen);
@@ -3304,15 +3306,10 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 		iov = &rqstp->rq_res.head[0];
 	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
 	BUG_ON(iov->iov_len > PAGE_SIZE);
-	if (nfsd4_has_session(&resp->cstate)) {
-		if (resp->cstate.status == nfserr_replay_cache &&
-				!nfsd4_not_cached(resp)) {
-			iov->iov_len = resp->cstate.iovlen;
-		} else {
-			nfsd4_store_cache_entry(resp);
-			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
-			resp->cstate.slot->sl_inuse = 0;
-		}
+	if (nfsd4_has_session(cs) && cs->status != nfserr_replay_cache) {
+		nfsd4_store_cache_entry(resp);
+		dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
+		resp->cstate.slot->sl_inuse = false;
 		nfsd4_put_session(resp->cstate.session);
 	}
 	return 1;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 675d395..4472449 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -577,10 +577,6 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 		+ rqstp->rq_res.head[0].iov_len;
 	rqstp->rq_res.head[0].iov_len += sizeof(__be32);
 
-	/* NFSv4.1 DRC requires statp */
-	if (rqstp->rq_vers == 4)
-		nfsd4_set_statp(rqstp, statp);
-
 	/* Now call the procedure handler, and encode NFS status. */
 	nfserr = proc->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
 	nfserr = map_new_errors(rqstp->rq_vers, nfserr);
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index ff0b771..70ef5f4 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -94,30 +94,23 @@ struct nfs4_cb_conn {
 
 /* Maximum number of slots per session. 160 is useful for long haul TCP */
 #define NFSD_MAX_SLOTS_PER_SESSION     160
-/* Maximum number of pages per slot cache entry */
-#define NFSD_PAGES_PER_SLOT	1
-#define NFSD_SLOT_CACHE_SIZE		PAGE_SIZE
 /* Maximum number of operations per session compound */
 #define NFSD_MAX_OPS_PER_COMPOUND	16
+/* Maximum  session per slot cache size */
+#define NFSD_SLOT_CACHE_SIZE		1024
 /* Maximum number of NFSD_SLOT_CACHE_SIZE slots per session */
 #define NFSD_CACHE_SIZE_SLOTS_PER_SESSION	32
 #define NFSD_MAX_MEM_PER_SESSION  \
 		(NFSD_CACHE_SIZE_SLOTS_PER_SESSION * NFSD_SLOT_CACHE_SIZE)
 
-struct nfsd4_cache_entry {
-	__be32		ce_status;
-	struct kvec	ce_datav; /* encoded NFSv4.1 data in rq_res.head[0] */
-	struct page	*ce_respages[NFSD_PAGES_PER_SLOT + 1];
-	int		ce_cachethis;
-	short		ce_resused;
-	int		ce_opcnt;
-	int		ce_rpchdrlen;
-};
-
 struct nfsd4_slot {
-	bool				sl_inuse;
-	u32				sl_seqid;
-	struct nfsd4_cache_entry	sl_cache_entry;
+	bool	sl_inuse;
+	bool	sl_cachethis;
+	u16	sl_opcnt;
+	u32	sl_seqid;
+	__be32	sl_status;
+	u32	sl_datalen;
+	char	sl_data[];
 };
 
 struct nfsd4_channel_attrs {
@@ -159,7 +152,7 @@ struct nfsd4_session {
 	struct nfs4_sessionid	se_sessionid;
 	struct nfsd4_channel_attrs se_fchannel;
 	struct nfsd4_channel_attrs se_bchannel;
-	struct nfsd4_slot	se_slots[];	/* forward channel slots */
+	struct nfsd4_slot	*se_slots[];	/* forward channel slots */
 };
 
 static inline void
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 3f71660..73164c2 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -51,7 +51,7 @@ struct nfsd4_compound_state {
 	/* For sessions DRC */
 	struct nfsd4_session	*session;
 	struct nfsd4_slot	*slot;
-	__be32			*statp;
+	__be32			*datap;
 	size_t			iovlen;
 	u32			minorversion;
 	u32			status;
@@ -472,8 +472,7 @@ static inline bool nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
 
 static inline bool nfsd4_not_cached(struct nfsd4_compoundres *resp)
 {
-	return !resp->cstate.slot->sl_cache_entry.ce_cachethis ||
-			nfsd4_is_solo_sequence(resp);
+	return !resp->cstate.slot->sl_cachethis || nfsd4_is_solo_sequence(resp);
 }
 
 #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)
-- 
1.6.2.5

