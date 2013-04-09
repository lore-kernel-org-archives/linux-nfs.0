Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50139 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935407Ab3DIX6V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 19:58:21 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 07/10] nfsd4: fix forechannel attribute negotiation
Date: Tue,  9 Apr 2013 19:58:12 -0400
Message-Id: <1365551896-6936-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1365551896-6936-1-git-send-email-bfields@redhat.com>
References: <1365551896-6936-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Negotiation of the 4.1 session forechannel attributes is a mess.  Fix:

	- Move it all into check_forechannel_attrs instead of spreading
	  it between that, alloc_session, and init_forechannel_attrs.
	- set a minimum "slotsize" so that our drc memory limits apply
	  even for small maxresponsesize_cached.  This also fixes some
	  bugs when slotsize becomes <= 0.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |  116 ++++++++++++++++++++++-----------------------------
 1 file changed, 49 insertions(+), 67 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f1262f7..036d5f1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -776,17 +776,15 @@ free_session_slots(struct nfsd4_session *ses)
  * We don't actually need to cache the rpc and session headers, so we
  * can allocate a little less for each slot:
  */
-static inline int slot_bytes(struct nfsd4_channel_attrs *ca)
+static inline u32 slot_bytes(struct nfsd4_channel_attrs *ca)
 {
-	return ca->maxresp_cached - NFSD_MIN_HDR_SEQ_SZ;
-}
-
-static int nfsd4_sanitize_slot_size(u32 size)
-{
-	size -= NFSD_MIN_HDR_SEQ_SZ; /* We don't cache the rpc header */
-	size = min_t(u32, size, NFSD_SLOT_CACHE_SIZE);
+	u32 size;
 
-	return size;
+	if (ca->maxresp_cached < NFSD_MIN_HDR_SEQ_SZ)
+		size = 0;
+	else
+		size = ca->maxresp_cached - NFSD_MIN_HDR_SEQ_SZ;
+	return size + sizeof(struct nfsd4_slot);
 }
 
 /*
@@ -794,12 +792,12 @@ static int nfsd4_sanitize_slot_size(u32 size)
  * re-negotiate active sessions and reduce their slot usage to make
  * room for new connections. For now we just fail the create session.
  */
-static int nfsd4_get_drc_mem(int slotsize, u32 num)
+static u32 nfsd4_get_drc_mem(struct nfsd4_channel_attrs *ca)
 {
+	u32 slotsize = slot_bytes(ca);
+	u32 num = ca->maxreqs;
 	int avail;
 
-	num = min_t(u32, num, NFSD_MAX_SLOTS_PER_SESSION);
-
 	spin_lock(&nfsd_drc_lock);
 	avail = min((unsigned long)NFSD_MAX_MEM_PER_SESSION,
 		    nfsd_drc_max_mem - nfsd_drc_mem_used);
@@ -810,15 +808,19 @@ static int nfsd4_get_drc_mem(int slotsize, u32 num)
 	return num;
 }
 
-static void nfsd4_put_drc_mem(int slotsize, int num)
+static void nfsd4_put_drc_mem(struct nfsd4_channel_attrs *ca)
 {
+	int slotsize = slot_bytes(ca);
+
 	spin_lock(&nfsd_drc_lock);
-	nfsd_drc_mem_used -= slotsize * num;
+	nfsd_drc_mem_used -= slotsize * ca->maxreqs;
 	spin_unlock(&nfsd_drc_lock);
 }
 
-static struct nfsd4_session *__alloc_session(int slotsize, int numslots)
+static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *attrs)
 {
+	int numslots = attrs->maxreqs;
+	int slotsize = slot_bytes(attrs);
 	struct nfsd4_session *new;
 	int mem, i;
 
@@ -831,8 +833,7 @@ static struct nfsd4_session *__alloc_session(int slotsize, int numslots)
 		return NULL;
 	/* allocate each struct nfsd4_slot and data cache in one piece */
 	for (i = 0; i < numslots; i++) {
-		mem = sizeof(struct nfsd4_slot) + slotsize;
-		new->se_slots[i] = kzalloc(mem, GFP_KERNEL);
+		new->se_slots[i] = kzalloc(slotsize, GFP_KERNEL);
 		if (!new->se_slots[i])
 			goto out_free;
 	}
@@ -844,21 +845,6 @@ out_free:
 	return NULL;
 }
 
-static void init_forechannel_attrs(struct nfsd4_channel_attrs *new,
-				   struct nfsd4_channel_attrs *req,
-				   int numslots, int slotsize,
-				   struct nfsd_net *nn)
-{
-	u32 maxrpc = nn->nfsd_serv->sv_max_mesg;
-
-	new->maxreqs = numslots;
-	new->maxresp_cached = min_t(u32, req->maxresp_cached,
-					slotsize + NFSD_MIN_HDR_SEQ_SZ);
-	new->maxreq_sz = min_t(u32, req->maxreq_sz, maxrpc);
-	new->maxresp_sz = min_t(u32, req->maxresp_sz, maxrpc);
-	new->maxops = min_t(u32, req->maxops, NFSD_MAX_OPS_PER_COMPOUND);
-}
-
 static void free_conn(struct nfsd4_conn *c)
 {
 	svc_xprt_put(c->cn_xprt);
@@ -960,7 +946,6 @@ static void nfsd4_del_conns(struct nfsd4_session *s)
 
 static void __free_session(struct nfsd4_session *ses)
 {
-	nfsd4_put_drc_mem(slot_bytes(&ses->se_fchannel), ses->se_fchannel.maxreqs);
 	free_session_slots(ses);
 	kfree(ses);
 }
@@ -971,35 +956,10 @@ static void free_session(struct nfsd4_session *ses)
 
 	lockdep_assert_held(&nn->client_lock);
 	nfsd4_del_conns(ses);
+	nfsd4_put_drc_mem(&ses->se_fchannel);
 	__free_session(ses);
 }
 
-static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *fchan,
-					   struct nfsd_net *nn)
-{
-	struct nfsd4_session *new;
-	int numslots, slotsize;
-	/*
-	 * Note decreasing slot size below client's request may
-	 * make it difficult for client to function correctly, whereas
-	 * decreasing the number of slots will (just?) affect
-	 * performance.  When short on memory we therefore prefer to
-	 * decrease number of slots instead of their size.
-	 */
-	slotsize = nfsd4_sanitize_slot_size(fchan->maxresp_cached);
-	numslots = nfsd4_get_drc_mem(slotsize, fchan->maxreqs);
-	if (numslots < 1)
-		return NULL;
-
-	new = __alloc_session(slotsize, numslots);
-	if (!new) {
-		nfsd4_put_drc_mem(slotsize, numslots);
-		return NULL;
-	}
-	init_forechannel_attrs(&new->se_fchannel, fchan, numslots, slotsize, nn);
-	return new;
-}
-
 static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, struct nfs4_client *clp, struct nfsd4_create_session *cses)
 {
 	int idx;
@@ -1022,7 +982,8 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
 	list_add(&new->se_perclnt, &clp->cl_sessions);
 	spin_unlock(&clp->cl_lock);
 	spin_unlock(&nn->client_lock);
-
+	memcpy(&new->se_fchannel, &cses->fore_channel,
+			sizeof(struct nfsd4_channel_attrs));
 	if (cses->flags & SESSION4_BACK_CHAN) {
 		struct sockaddr *sa = svc_addr(rqstp);
 		/*
@@ -1803,12 +1764,33 @@ nfsd4_replay_create_session(struct nfsd4_create_session *cr_ses,
 				/* seqid, slotID, slotID, slotID, status */ \
 			5 ) * sizeof(__be32))
 
-static __be32 check_forechannel_attrs(struct nfsd4_channel_attrs *ca)
+static __be32 check_forechannel_attrs(struct nfsd4_channel_attrs *ca, struct nfsd_net *nn)
 {
+	u32 maxrpc = nn->nfsd_serv->sv_max_mesg;
+
 	if (ca->maxreq_sz < NFSD_MIN_REQ_HDR_SEQ_SZ)
 		return nfserr_toosmall;
 	if (ca->maxresp_sz < NFSD_MIN_RESP_HDR_SEQ_SZ)
 		return nfserr_toosmall;
+	ca->headerpadsz = 0;
+	ca->maxreq_sz = min_t(u32, ca->maxreq_sz, maxrpc);
+	ca->maxresp_sz = min_t(u32, ca->maxresp_sz, maxrpc);
+	ca->maxops = min_t(u32, ca->maxops, NFSD_MAX_OPS_PER_COMPOUND);
+	ca->maxresp_cached = min_t(u32, ca->maxresp_cached,
+			NFSD_SLOT_CACHE_SIZE + NFSD_MIN_HDR_SEQ_SZ);
+	ca->maxreqs = min_t(u32, ca->maxreqs, NFSD_MAX_SLOTS_PER_SESSION);
+	/*
+	 * Note decreasing slot size below client's request may make it
+	 * difficult for client to function correctly, whereas
+	 * decreasing the number of slots will (just?) affect
+	 * performance.  When short on memory we therefore prefer to
+	 * decrease number of slots instead of their size.  Clients that
+	 * request larger slots than they need will get poor results:
+	 */
+	ca->maxreqs = nfsd4_get_drc_mem(ca);
+	if (!ca->maxreqs)
+		return nfserr_jukebox;
+
 	return nfs_ok;
 }
 
@@ -1827,13 +1809,13 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	if (cr_ses->flags & ~SESSION4_FLAG_MASK_A)
 		return nfserr_inval;
-	status = check_forechannel_attrs(&cr_ses->fore_channel);
+	status = check_forechannel_attrs(&cr_ses->fore_channel, nn);
 	if (status)
 		return status;
-	new = alloc_session(&cr_ses->fore_channel, nn);
-	if (!new)
-		return nfserr_jukebox;
 	status = nfserr_jukebox;
+	new = alloc_session(&cr_ses->fore_channel);
+	if (!new)
+		goto out_release_drc_mem;
 	conn = alloc_conn_from_crses(rqstp, cr_ses);
 	if (!conn)
 		goto out_free_session;
@@ -1892,8 +1874,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	memcpy(cr_ses->sessionid.data, new->se_sessionid.data,
 	       NFS4_MAX_SESSIONID_LEN);
-	memcpy(&cr_ses->fore_channel, &new->se_fchannel,
-		sizeof(struct nfsd4_channel_attrs));
 	cs_slot->sl_seqid++;
 	cr_ses->seqid = cs_slot->sl_seqid;
 
@@ -1906,6 +1886,8 @@ out_free_conn:
 	free_conn(conn);
 out_free_session:
 	__free_session(new);
+out_release_drc_mem:
+	nfsd4_put_drc_mem(&cr_ses->fore_channel);
 	return status;
 }
 
-- 
1.7.9.5

