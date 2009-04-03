From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 20/35] nfsd41: non-page DRC for solo sequence responses
Date: Fri,  3 Apr 2009 08:28:35 +0300
Message-ID: <1238736515-17703-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:28299 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755812AbZDCF2l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:28:41 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

A session inactivity time compound (lease renewal) or a compound where the
sequence operation has sa_cachethis set to FALSE do not require any pages
to be held in the v4.1 DRC. This is because struct nfsd4_slot is already
caching the session information.

Add logic to the nfs41 server to not cache response pages for solo sequence
responses.

Return nfserr_replay_uncached_rep on the operation following the sequence
operation when sa_cachethis is FALSE.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: use cstate session in nfsd4_replay_cache_entry]
[nfsd41: rename nfsd4_no_page_in_cache]
[nfsd41 rename nfsd4_enc_no_page_replay]
[nfsd41 nfsd4_is_solo_sequence]
[nfsd41 change nfsd4_not_cached return]
Signed-off-by: Andy Adamson <andros@netapp.com>
[changed return type to bool]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41 drop parens in nfsd4_is_solo_sequence call]
Signed-off-by: Andy Adamson <andros@netapp.com>
[changed "== 0" to "!"]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c         |   34 +++++++++++++++++++++++++++++-
 fs/nfsd/nfs4state.c        |   47 ++++++++++++++++++++++++++++++++++++++-----
 fs/nfsd/nfs4xdr.c          |    5 ++-
 include/linux/nfsd/state.h |    1 +
 include/linux/nfsd/xdr4.h  |   15 +++++++++++++-
 5 files changed, 91 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9e2ee75..ae21a4e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -828,6 +828,34 @@ static struct nfsd4_operation nfsd4_ops[];
 static const char *nfsd4_op_name(unsigned opnum);
 
 /*
+ * This is a replay of a compound for which no cache entry pages
+ * were used. Encode the sequence operation, and if cachethis is FALSE
+ * encode the uncache rep error on the next operation.
+ */
+static __be32
+nfsd4_enc_uncached_replay(struct nfsd4_compoundargs *args,
+			 struct nfsd4_compoundres *resp)
+{
+	struct nfsd4_op *op;
+
+	dprintk("--> %s resp->opcnt %d ce_cachethis %u \n", __func__,
+		resp->opcnt, resp->cstate.slot->sl_cache_entry.ce_cachethis);
+
+	/* Encode the replayed sequence operation */
+	BUG_ON(resp->opcnt != 1);
+	op = &args->ops[resp->opcnt - 1];
+	nfsd4_encode_operation(resp, op);
+
+	/*return nfserr_retry_uncached_rep in next operation. */
+	if (resp->cstate.slot->sl_cache_entry.ce_cachethis == 0) {
+		op = &args->ops[resp->opcnt++];
+		op->status = nfserr_retry_uncached_rep;
+		nfsd4_encode_operation(resp, op);
+	}
+	return op->status;
+}
+
+/*
  * Enforce NFSv4.1 COMPOUND ordering rules.
  *
  * TODO:
@@ -895,7 +923,6 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 		dprintk("nfsv4 compound op #%d/%d: %d (%s)\n",
 			resp->opcnt, args->opcnt, op->opnum,
 			nfsd4_op_name(op->opnum));
-
 		/*
 		 * The XDR decode routines may have pre-set op->status;
 		 * for example, if there is a miscellaneous XDR error
@@ -939,7 +966,10 @@ encode_op:
 		/* Only from SEQUENCE or CREATE_SESSION */
 		if (resp->cstate.status == nfserr_replay_cache) {
 			dprintk("%s NFS4.1 replay from cache\n", __func__);
-			status = op->status;
+			if (nfsd4_not_cached(resp))
+				status = nfsd4_enc_uncached_replay(args, resp);
+			else
+				status = op->status;
 			goto out;
 		}
 		if (op->status == nfserr_replay_me) {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 58f9797..04a395f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1049,17 +1049,31 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	/* Don't cache a failed OP_SEQUENCE. */
 	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
 		return;
+
 	nfsd4_release_respages(entry->ce_respages, entry->ce_resused);
+	entry->ce_opcnt = resp->opcnt;
+	entry->ce_status = resp->cstate.status;
+
+	/*
+	 * Don't need a page to cache just the sequence operation - the slot
+	 * does this for us!
+	 */
+
+	if (nfsd4_not_cached(resp)) {
+		entry->ce_resused = 0;
+		entry->ce_rpchdrlen = 0;
+		dprintk("%s Just cache SEQUENCE. ce_cachethis %d\n", __func__,
+			resp->cstate.slot->sl_cache_entry.ce_cachethis);
+		return;
+	}
 	entry->ce_resused = rqstp->rq_resused;
 	if (entry->ce_resused > NFSD_PAGES_PER_SLOT + 1)
 		entry->ce_resused = NFSD_PAGES_PER_SLOT + 1;
 	nfsd4_copy_pages(entry->ce_respages, rqstp->rq_respages,
 			 entry->ce_resused);
-	entry->ce_status = resp->cstate.status;
 	entry->ce_datav.iov_base = resp->cstate.statp;
 	entry->ce_datav.iov_len = resv->iov_len - ((char *)resp->cstate.statp -
 				(char *)page_address(rqstp->rq_respages[0]));
-	entry->ce_opcnt = resp->opcnt;
 	/* Current request rpc header length*/
 	entry->ce_rpchdrlen = (char *)resp->cstate.statp -
 				(char *)page_address(rqstp->rq_respages[0]);
@@ -1096,13 +1110,28 @@ nfsd41_copy_replay_data(struct nfsd4_compoundres *resp,
  * cached page.  Replace any futher replay pages from the cache.
  */
 __be32
-nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp)
+nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
+			 struct nfsd4_sequence *seq)
 {
 	struct nfsd4_cache_entry *entry = &resp->cstate.slot->sl_cache_entry;
 	__be32 status;
 
 	dprintk("--> %s entry %p\n", __func__, entry);
 
+	/*
+	 * If this is just the sequence operation, we did not keep
+	 * a page in the cache entry because we can just use the
+	 * slot info stored in struct nfsd4_sequence that was checked
+	 * against the slot in nfsd4_sequence().
+	 *
+	 * This occurs when seq->cachethis is FALSE, or when the client
+	 * session inactivity timer fires and a solo sequence operation
+	 * is sent (lease renewal).
+	 */
+	if (seq && nfsd4_not_cached(resp)) {
+		seq->maxslots = resp->cstate.session->se_fnumslots;
+		return nfs_ok;
+	}
 
 	if (!nfsd41_copy_replay_data(resp, entry)) {
 		/*
@@ -1330,7 +1359,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			cstate->slot = slot;
 			cstate->status = status;
 			/* Return the cached reply status */
-			status = nfsd4_replay_cache_entry(resp);
+			status = nfsd4_replay_cache_entry(resp, NULL);
 			goto out;
 		} else if (cr_ses->seqid != conf->cl_slot.sl_seqid + 1) {
 			status = nfserr_seq_misordered;
@@ -1380,6 +1409,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	slot->sl_inuse = true;
 	cstate->slot = slot;
+	/* Ensure a page is used for the cache */
+	slot->sl_cache_entry.ce_cachethis = 1;
 out:
 	nfs4_unlock_state();
 	dprintk("%s returns %d\n", __func__, ntohl(status));
@@ -1425,8 +1456,8 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 		cstate->slot = slot;
 		cstate->session = session;
 		/* Return the cached reply status and set cstate->status
-		 * for nfsd4_svc_encode_compoundres processing*/
-		status = nfsd4_replay_cache_entry(resp);
+		 * for nfsd4_svc_encode_compoundres processing */
+		status = nfsd4_replay_cache_entry(resp, seq);
 		cstate->status = nfserr_replay_cache;
 		goto replay_cache;
 	}
@@ -1436,6 +1467,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	/* Success! bump slot seqid */
 	slot->sl_inuse = true;
 	slot->sl_seqid = seq->seqid;
+	slot->sl_cache_entry.ce_cachethis = seq->cachethis;
+	/* Always set the cache entry cachethis for solo sequence */
+	if (nfsd4_is_solo_sequence(resp))
+		slot->sl_cache_entry.ce_cachethis = 1;
 
 	cstate->slot = slot;
 	cstate->session = session;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 671f9b9..64bc215 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2975,7 +2975,7 @@ nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, int nfserr,
 	return nfserr;
 }
 
-static __be32
+__be32
 nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 		      struct nfsd4_sequence *seq)
 {
@@ -3192,7 +3192,8 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
 	BUG_ON(iov->iov_len > PAGE_SIZE);
 	if (resp->cstate.slot != NULL) {
-		if (resp->cstate.status == nfserr_replay_cache) {
+		if (resp->cstate.status == nfserr_replay_cache &&
+				!nfsd4_not_cached(resp)) {
 			iov->iov_len = resp->cstate.iovlen;
 		} else {
 			nfsd4_store_cache_entry(resp);
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index f063df7..18dcffa 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -110,6 +110,7 @@ struct nfsd4_cache_entry {
 	__be32		ce_status;
 	struct kvec	ce_datav; /* encoded NFSv4.1 data in rq_res.head[0] */
 	struct page	*ce_respages[NFSD_PAGES_PER_SLOT + 1];
+	int		ce_cachethis;
 	short		ce_resused;
 	int		ce_opcnt;
 	int		ce_rpchdrlen;
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 9468829..4861888 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -480,6 +480,18 @@ struct nfsd4_compoundres {
 	struct nfsd4_compound_state	cstate;
 };
 
+static inline bool nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
+{
+	struct nfsd4_compoundargs *args = resp->rqstp->rq_argp;
+	return args->opcnt == 1;
+}
+
+static inline bool nfsd4_not_cached(struct nfsd4_compoundres *resp)
+{
+	return !resp->cstate.slot->sl_cache_entry.ce_cachethis ||
+			nfsd4_is_solo_sequence(resp);
+}
+
 #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)
 
 static inline void
@@ -510,7 +522,8 @@ extern __be32 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid_confirm *setclientid_confirm);
 extern void nfsd4_store_cache_entry(struct nfsd4_compoundres *resp);
-extern __be32 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp);
+extern __be32 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
+		struct nfsd4_sequence *seq);
 extern __be32 nfsd4_exchange_id(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 struct nfsd4_exchange_id *);
-- 
1.6.2.1

