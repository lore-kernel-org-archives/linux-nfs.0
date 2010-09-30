Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49131 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932217Ab0I3QTm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 12:19:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 10/16] nfsd4: clean up session allocation
Date: Thu, 30 Sep 2010 12:19:07 -0400
Message-Id: <1285863553-8945-11-git-send-email-bfields@redhat.com>
In-Reply-To: <1285863553-8945-1-git-send-email-bfields@redhat.com>
References: <1285863553-8945-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Changes:
	- make sure session memory reservation is released on failure
	  path.
	- use min_t()/min() for more compact code in several places.
	- break alloc_init_session into smaller pieces.
	- miscellaneous other cleanup.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |  211 +++++++++++++++++++++-----------------------------
 1 files changed, 89 insertions(+), 122 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ebddcc1..f86476c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -533,94 +533,6 @@ gen_sessionid(struct nfsd4_session *ses)
  */
 #define NFSD_MIN_HDR_SEQ_SZ  (24 + 12 + 44)
 
-/*
- * Give the client the number of ca_maxresponsesize_cached slots it
- * requests, of size bounded by NFSD_SLOT_CACHE_SIZE,
- * NFSD_MAX_MEM_PER_SESSION, and nfsd_drc_max_mem. Do not allow more
- * than NFSD_MAX_SLOTS_PER_SESSION.
- *
- * If we run out of reserved DRC memory we should (up to a point)
- * re-negotiate active sessions and reduce their slot usage to make
- * rooom for new connections. For now we just fail the create session.
- */
-static int set_forechannel_drc_size(struct nfsd4_channel_attrs *fchan)
-{
-	int mem, size = fchan->maxresp_cached;
-
-	if (fchan->maxreqs < 1)
-		return nfserr_inval;
-
-	if (size < NFSD_MIN_HDR_SEQ_SZ)
-		size = NFSD_MIN_HDR_SEQ_SZ;
-	size -= NFSD_MIN_HDR_SEQ_SZ;
-	if (size > NFSD_SLOT_CACHE_SIZE)
-		size = NFSD_SLOT_CACHE_SIZE;
-
-	/* bound the maxreqs by NFSD_MAX_MEM_PER_SESSION */
-	mem = fchan->maxreqs * size;
-	if (mem > NFSD_MAX_MEM_PER_SESSION) {
-		fchan->maxreqs = NFSD_MAX_MEM_PER_SESSION / size;
-		if (fchan->maxreqs > NFSD_MAX_SLOTS_PER_SESSION)
-			fchan->maxreqs = NFSD_MAX_SLOTS_PER_SESSION;
-		mem = fchan->maxreqs * size;
-	}
-
-	spin_lock(&nfsd_drc_lock);
-	/* bound the total session drc memory ussage */
-	if (mem + nfsd_drc_mem_used > nfsd_drc_max_mem) {
-		fchan->maxreqs = (nfsd_drc_max_mem - nfsd_drc_mem_used) / size;
-		mem = fchan->maxreqs * size;
-	}
-	nfsd_drc_mem_used += mem;
-	spin_unlock(&nfsd_drc_lock);
-
-	if (fchan->maxreqs == 0)
-		return nfserr_jukebox;
-
-	fchan->maxresp_cached = size + NFSD_MIN_HDR_SEQ_SZ;
-	return 0;
-}
-
-/*
- * fchan holds the client values on input, and the server values on output
- * sv_max_mesg is the maximum payload plus one page for overhead.
- */
-static int init_forechannel_attrs(struct svc_rqst *rqstp,
-				  struct nfsd4_channel_attrs *session_fchan,
-				  struct nfsd4_channel_attrs *fchan)
-{
-	int status = 0;
-	__u32   maxcount = nfsd_serv->sv_max_mesg;
-
-	/* headerpadsz set to zero in encode routine */
-
-	/* Use the client's max request and max response size if possible */
-	if (fchan->maxreq_sz > maxcount)
-		fchan->maxreq_sz = maxcount;
-	session_fchan->maxreq_sz = fchan->maxreq_sz;
-
-	if (fchan->maxresp_sz > maxcount)
-		fchan->maxresp_sz = maxcount;
-	session_fchan->maxresp_sz = fchan->maxresp_sz;
-
-	/* Use the client's maxops if possible */
-	if (fchan->maxops > NFSD_MAX_OPS_PER_COMPOUND)
-		fchan->maxops = NFSD_MAX_OPS_PER_COMPOUND;
-	session_fchan->maxops = fchan->maxops;
-
-	/* FIXME: Error means no more DRC pages so the server should
-	 * recover pages from existing sessions. For now fail session
-	 * creation.
-	 */
-	status = set_forechannel_drc_size(fchan);
-
-	session_fchan->maxresp_cached = fchan->maxresp_cached;
-	session_fchan->maxreqs = fchan->maxreqs;
-
-	dprintk("%s status %d\n", __func__, status);
-	return status;
-}
-
 static void
 free_session_slots(struct nfsd4_session *ses)
 {
@@ -639,63 +551,118 @@ static inline int slot_bytes(struct nfsd4_channel_attrs *ca)
 	return ca->maxresp_cached - NFSD_MIN_HDR_SEQ_SZ;
 }
 
-static __be32 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp, struct nfsd4_create_session *cses)
+static int nfsd4_sanitize_slot_size(u32 size)
 {
-	struct nfsd4_session *new, tmp;
-	struct nfsd4_slot *sp;
-	int idx, slotsize, cachesize, i;
-	int status;
+	size -= NFSD_MIN_HDR_SEQ_SZ; /* We don't cache the rpc header */
+	size = min_t(u32, size, NFSD_SLOT_CACHE_SIZE);
 
-	memset(&tmp, 0, sizeof(tmp));
+	return size;
+}
 
-	/* FIXME: For now, we just accept the client back channel attributes. */
-	tmp.se_bchannel = cses->back_channel;
-	status = init_forechannel_attrs(rqstp, &tmp.se_fchannel,
-					&cses->fore_channel);
-	if (status)
-		goto out;
+/*
+ * XXX: If we run out of reserved DRC memory we could (up to a point)
+ * re-negotiate active sessions and reduce their slot usage to make
+ * rooom for new connections. For now we just fail the create session.
+ */
+static int nfsd4_get_drc_mem(int slotsize, u32 num)
+{
+	int avail;
 
-	BUILD_BUG_ON(NFSD_MAX_SLOTS_PER_SESSION * sizeof(struct nfsd4_slot *)
-		     + sizeof(struct nfsd4_session) > PAGE_SIZE);
+	num = min_t(u32, num, NFSD_MAX_SLOTS_PER_SESSION);
 
-	status = nfserr_jukebox;
-	/* allocate struct nfsd4_session and slot table pointers in one piece */
-	slotsize = tmp.se_fchannel.maxreqs * sizeof(struct nfsd4_slot *);
-	new = kzalloc(sizeof(*new) + slotsize, GFP_KERNEL);
-	if (!new)
-		goto out;
+	spin_lock(&nfsd_drc_lock);
+	avail = min_t(int, NFSD_MAX_MEM_PER_SESSION,
+			nfsd_drc_max_mem - nfsd_drc_mem_used);
+	num = min_t(int, num, avail / slotsize);
+	nfsd_drc_mem_used += num * slotsize;
+	spin_unlock(&nfsd_drc_lock);
+
+	return num;
+}
+
+static void nfsd4_put_drc_mem(int slotsize, int num)
+{
+	spin_lock(&nfsd_drc_lock);
+	nfsd_drc_mem_used -= slotsize * num;
+	spin_unlock(&nfsd_drc_lock);
+}
+
+static struct nfsd4_session *alloc_session(int slotsize, int numslots)
+{
+	struct nfsd4_session *new;
+	int mem, i;
 
-	memcpy(new, &tmp, sizeof(*new));
+	BUILD_BUG_ON(NFSD_MAX_SLOTS_PER_SESSION * sizeof(struct nfsd4_slot *)
+			+ sizeof(struct nfsd4_session) > PAGE_SIZE);
+	mem = numslots * sizeof(struct nfsd4_slot *);
 
+	new = kzalloc(sizeof(*new) + mem, GFP_KERNEL);
+	if (!new)
+		return NULL;
 	/* allocate each struct nfsd4_slot and data cache in one piece */
-	cachesize = slot_bytes(&new->se_fchannel);
-	for (i = 0; i < new->se_fchannel.maxreqs; i++) {
-		sp = kzalloc(sizeof(*sp) + cachesize, GFP_KERNEL);
-		if (!sp)
+	for (i = 0; i < numslots; i++) {
+		mem = sizeof(struct nfsd4_slot) + slotsize;
+		new->se_slots[i] = kzalloc(mem, GFP_KERNEL);
+		if (!new->se_slots[i])
 			goto out_free;
-		new->se_slots[i] = sp;
 	}
+	return new;
+out_free:
+	while (i--)
+		kfree(new->se_slots[i]);
+	kfree(new);
+	return NULL;
+}
+
+static void init_forechannel_attrs(struct nfsd4_channel_attrs *new, struct nfsd4_channel_attrs *req, int numslots, int slotsize)
+{
+	u32 maxrpc = nfsd_serv->sv_max_mesg;
+
+	new->maxreqs = numslots;
+	new->maxresp_cached = slotsize + NFSD_MIN_HDR_SEQ_SZ;
+	new->maxreq_sz = min_t(u32, req->maxreq_sz, maxrpc);
+	new->maxresp_sz = min_t(u32, req->maxresp_sz, maxrpc);
+	new->maxops = min_t(u32, req->maxops, NFSD_MAX_OPS_PER_COMPOUND);
+}
+
+static __be32 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp, struct nfsd4_create_session *cses)
+{
+	struct nfsd4_session *new;
+	struct nfsd4_channel_attrs *fchan = &cses->fore_channel;
+	int numslots, slotsize;
+	int idx;
+
+	/*
+	 * Note decreasing slot size below client's request may
+	 * make it difficult for client to function correctly, whereas
+	 * decreasing the number of slots will (just?) affect
+	 * performance.  When short on memory we therefore prefer to
+	 * decrease number of slots instead of their size.
+	 */
+	slotsize = nfsd4_sanitize_slot_size(fchan->maxresp_cached);
+	numslots = nfsd4_get_drc_mem(slotsize, fchan->maxreqs);
+
+	new = alloc_session(slotsize, numslots);
+	if (!new) {
+		nfsd4_put_drc_mem(slotsize, fchan->maxreqs);
+		return nfserr_jukebox;
+	}
+	init_forechannel_attrs(&new->se_fchannel, fchan, numslots, slotsize);
 
 	new->se_client = clp;
 	gen_sessionid(new);
-	idx = hash_sessionid(&new->se_sessionid);
 	memcpy(clp->cl_sessionid.data, new->se_sessionid.data,
 	       NFS4_MAX_SESSIONID_LEN);
 
 	new->se_flags = cses->flags;
 	kref_init(&new->se_ref);
+	idx = hash_sessionid(&new->se_sessionid);
 	spin_lock(&client_lock);
 	list_add(&new->se_hash, &sessionid_hashtbl[idx]);
 	list_add(&new->se_perclnt, &clp->cl_sessions);
 	spin_unlock(&client_lock);
 
-	status = nfs_ok;
-out:
-	return status;
-out_free:
-	free_session_slots(new);
-	kfree(new);
-	goto out;
+	return nfs_ok;
 }
 
 /* caller must hold client_lock */
-- 
1.7.0.4

