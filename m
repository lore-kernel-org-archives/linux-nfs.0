From: andros@netapp.com
Subject: [PATCH 08/14] nfsd41: replace page based DRC with buffer based DRC
Date: Wed, 24 Jun 2009 15:37:52 -0400
Message-ID: <1245872278-18743-9-git-send-email-andros@netapp.com>
References: <>
 <1245872278-18743-1-git-send-email-andros@netapp.com>
 <1245872278-18743-2-git-send-email-andros@netapp.com>
 <1245872278-18743-3-git-send-email-andros@netapp.com>
 <1245872278-18743-4-git-send-email-andros@netapp.com>
 <1245872278-18743-5-git-send-email-andros@netapp.com>
 <1245872278-18743-6-git-send-email-andros@netapp.com>
 <1245872278-18743-7-git-send-email-andros@netapp.com>
 <1245872278-18743-8-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46578 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761012AbZFXTiD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2009 15:38:03 -0400
In-Reply-To: <1245872278-18743-8-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Use NFSD_SLOT_CACHE_SIZE size buffers for sessions DRC instead of holding nfsd
pages in cache.

Allocate memory for the session DRC in the CREATE_SESSION operation
because of the guarantee to the client that the memory resource is available
for caching responses.

Never cache the SEQUENCE operation, encode it from the session slot values.
Only cache the encoded results of operations past the SEQUENCE operation.

Remove struct nfsd4_cache_entry and helper functions for the old page-based
DRC.

The iov_len calculation in nfs4svc_encode_compoundres is now always
correct, clean up the nfs4svc_encode_compoundres session logic.

The nfsd4_compound_state statp pointer is also not used.
Remove nfsd4_set_statp().

Move useful nfsd4_cache_entry fields into nfsd4_slot.

Signed-off-by: Andy Adamson <andros@netapp.com
---
 fs/nfsd/nfs4proc.c         |    6 +-
 fs/nfsd/nfs4state.c        |  150 ++++++++------------------------------------
 fs/nfsd/nfs4xdr.c          |   13 ++--
 fs/nfsd/nfssvc.c           |    4 -
 include/linux/nfsd/state.h |   23 ++-----
 include/linux/nfsd/xdr4.h  |    4 +-
 6 files changed, 45 insertions(+), 155 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index b70a77d..6285106 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -957,8 +957,8 @@ nfsd4_enc_uncached_replay(struct nfsd4_compoundargs *args,
 {
 	struct nfsd4_op *op;
 
-	dprintk("--> %s resp->opcnt %d ce_cachethis %u \n", __func__,
-		resp->opcnt, resp->cstate.slot->sl_cache_entry.ce_cachethis);
+	dprintk("--> %s resp->opcnt %d sl_cachethis %u \n", __func__,
+		resp->opcnt, resp->cstate.slot->sl_cachethis);
 
 	/* Encode the replayed sequence operation */
 	BUG_ON(resp->opcnt != 1);
@@ -966,7 +966,7 @@ nfsd4_enc_uncached_replay(struct nfsd4_compoundargs *args,
 	nfsd4_encode_operation(resp, op);
 
 	/*return nfserr_retry_uncached_rep in next operation. */
-	if (resp->cstate.slot->sl_cache_entry.ce_cachethis == 0) {
+	if (resp->cstate.slot->sl_cachethis == 0) {
 		op = &args->ops[resp->opcnt++];
 		op->status = nfserr_retry_uncached_rep;
 		nfsd4_encode_operation(resp, op);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e646a83..2232b7b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -571,19 +571,12 @@ release_session(struct nfsd4_session *ses)
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
@@ -996,44 +989,6 @@ out_err:
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
  * Cache the reply pages up to NFSD_PAGES_PER_SLOT + 1, clearing the previous
  * pages. We add a page to NFSD_PAGES_PER_SLOT for the case where the total
@@ -1047,71 +1002,37 @@ nfsd4_copy_pages(struct page **topages, struct page **frompages, short count)
 void
 nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 {
-	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
+	struct nfsd4_slot *slot = resp->cstate.slot;
 	struct svc_rqst *rqstp = resp->rqstp;
 	struct nfsd4_compoundargs *args = rqstp->rq_argp;
 	struct nfsd4_op *op = &args->ops[resp->opcnt];
-	struct kvec *resv = &rqstp->rq_res.head[0];
+	unsigned int base;
 
-	dprintk("--> %s entry %p\n", __func__, entry);
+	dprintk("--> %s slot %p\n", __func__, slot);
 
 	/* Don't cache a failed OP_SEQUENCE. */
 	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
 		return;
 
-	nfsd4_release_respages(entry->ce_respages, entry->ce_resused);
-	entry->ce_opcnt = resp->opcnt;
-	entry->ce_status = resp->cstate.status;
-
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
+	base = (char *)resp->cstate.datap -
+					(char *)resp->xbuf->head[0].iov_base;
+	slot->sl_datalen = (char *)resp->p - (char *)resp->cstate.datap;
+	if (slot->sl_datalen > NFSD_SLOT_CACHE_SIZE || slot->sl_datalen <= 0)
+		goto out_warn;
+	if (read_bytes_from_xdr_buf(resp->xbuf, base, slot->sl_data,
+				    slot->sl_datalen))
+		goto out_warn;
+	return;
 
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
+out_warn:
+	printk(KERN_WARNING "nfsd: sessions DRC could not cache compound\n");
 }
 
 /*
@@ -1122,10 +1043,10 @@ __be32
 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 			 struct nfsd4_sequence *seq)
 {
-	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
+	struct nfsd4_slot *slot = resp->cstate.slot;
 	__be32 status;
 
-	dprintk("--> %s entry %p\n", __func__, entry);
+	dprintk("--> %s slot %p\n", __func__, slot);
 
 	/*
 	 * If this is just the sequence operation, we did not keep
@@ -1142,29 +1063,12 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 		return nfs_ok;
 	}
 
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
@@ -1502,7 +1406,7 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 		cstate->slot = slot;
 		cstate->session = session;
 		/* Return the cached reply status and set cstate->status
-		 * for nfsd4_svc_encode_compoundres processing */
+		 * for nfsd4_proc_compound processing */
 		status = nfsd4_replay_cache_entry(resp, seq);
 		cstate->status = nfserr_replay_cache;
 		goto replay_cache;
@@ -1513,10 +1417,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	/* Success! bump slot seqid */
 	slot->sl_inuse = true;
 	slot->sl_seqid = seq->seqid;
-	slot->sl_cache_entry.ce_cachethis = seq->cachethis;
+	slot->sl_cachethis = seq->cachethis;
 	/* Always set the cache entry cachethis for solo sequence */
 	if (nfsd4_is_solo_sequence(resp))
-		slot->sl_cache_entry.ce_cachethis = 1;
+		slot->sl_cachethis = 1;
 
 	cstate->slot = slot;
 	cstate->session = session;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fdf632b..49824ea 100644
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
@@ -3304,14 +3306,11 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 		iov = &rqstp->rq_res.head[0];
 	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
 	BUG_ON(iov->iov_len > PAGE_SIZE);
-	if (nfsd4_has_session(&resp->cstate)) {
-		if (resp->cstate.status == nfserr_replay_cache &&
-				!nfsd4_not_cached(resp)) {
-			iov->iov_len = resp->cstate.iovlen;
-		} else {
+	if (nfsd4_has_session(cs)) {
+		if (cs->status != nfserr_replay_cache) {
 			nfsd4_store_cache_entry(resp);
 			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
-			resp->cstate.slot->sl_inuse = 0;
+			resp->cstate.slot->sl_inuse = false;
 		}
 		nfsd4_put_session(resp->cstate.session);
 	}
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 1793dba..f0ef241 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -580,10 +580,6 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
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
index c45a7bd..09592db 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -95,26 +95,17 @@ struct nfs4_cb_conn {
 
 /* Maximum number of slots per session. 128 is useful for long haul TCP */
 #define NFSD_MAX_SLOTS_PER_SESSION	128
-/* Maximum number of pages per slot cache entry */
-#define NFSD_PAGES_PER_SLOT	1
-/* Maximum number of operations per session compound */
 #define NFSD_SLOT_CACHE_SIZE		512
 #define NFSD_MAX_OPS_PER_COMPOUND	16
 
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
+	u32	sl_seqid;
+	int	sl_cachethis;
+	int	sl_opcnt;
+	__be32	sl_status;
+	u32	sl_datalen;
+	char	sl_data[NFSD_SLOT_CACHE_SIZE];
 };
 
 struct nfsd4_channel_attrs {
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 5e4beb0..ae325ad 100644
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
@@ -472,7 +472,7 @@ static inline bool nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
 
 static inline bool nfsd4_not_cached(struct nfsd4_compoundres *resp)
 {
-	return !resp->cstate.slot->sl_cache_entry.ce_cachethis ||
+	return !resp->cstate.slot->sl_cachethis ||
 			nfsd4_is_solo_sequence(resp);
 }
 
-- 
1.5.4.3

