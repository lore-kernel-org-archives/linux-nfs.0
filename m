Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57688 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751048Ab0JUQUd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 12:20:33 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 04/11] nfsd4: make backchannel sequence number per-session
Date: Thu, 21 Oct 2010 12:20:11 -0400
Message-Id: <1287678018-9266-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1287678018-9266-1-git-send-email-bfields@redhat.com>
References: <1287678018-9266-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

Currently we don't deal well with a client that has multiple sessions
associated with it (even simultaneously, or serially over the lifetime
of the client).

In particular, we don't attempt to keep the backchannel running after
the original session diseappears.

We will fix that soon.

Once we do that, we need the slot sequence number to be per-session;
otherwise, for example, we cannot correctly handle a case like this:

	- All session 1 connections are lost.
	- The client creates session 2.  We use it for the backchannel
	  (since it's the only working choice).
	- The client gives us a new connection to use with session 1.
	- The client destroys session 2.

At this point our only choice is to go back to using session 1.  When we
do so we must use the sequence number that is next for session 1.  We
therefore need to maintain multiple sequence number streams.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |    8 ++++----
 fs/nfsd/nfs4state.c    |   22 ++++++++++++----------
 fs/nfsd/state.h        |    2 +-
 3 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 78ac779..5df9dda 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -260,7 +260,7 @@ encode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_callback *cb,
 
 	WRITE32(OP_CB_SEQUENCE);
 	WRITEMEM(ses->se_sessionid.data, NFS4_MAX_SESSIONID_LEN);
-	WRITE32(cb->cb_clp->cl_cb_seq_nr);
+	WRITE32(ses->se_cb_seq_nr);
 	WRITE32(0);		/* slotid, always 0 */
 	WRITE32(0);		/* highest slotid always 0 */
 	WRITE32(0);		/* cachethis always 0 */
@@ -369,7 +369,7 @@ decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_callback *cb,
 		goto out;
 	}
 	READ32(dummy);
-	if (dummy != cb->cb_clp->cl_cb_seq_nr) {
+	if (dummy != ses->se_cb_seq_nr) {
 		dprintk("%s Invalid sequence number\n", __func__);
 		goto out;
 	}
@@ -643,11 +643,11 @@ static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 
 	if (clp->cl_cb_conn.cb_minorversion) {
 		/* No need for lock, access serialized in nfsd4_cb_prepare */
-		++clp->cl_cb_seq_nr;
+		++clp->cl_cb_session->se_cb_seq_nr;
 		clear_bit(0, &clp->cl_cb_slot_busy);
 		rpc_wake_up_next(&clp->cl_cb_waitq);
 		dprintk("%s: freed slot, new seqid=%d\n", __func__,
-			clp->cl_cb_seq_nr);
+			clp->cl_cb_session->se_cb_seq_nr);
 
 		/* We're done looking into the sequence information */
 		task->tk_msg.rpc_resp = NULL;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c942511..6367c44 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -725,8 +725,7 @@ void free_session(struct kref *kref)
 	kfree(ses);
 }
 
-
-static __be32 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp, struct nfsd4_create_session *cses)
+static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp, struct nfsd4_create_session *cses)
 {
 	struct nfsd4_session *new;
 	struct nfsd4_channel_attrs *fchan = &cses->fore_channel;
@@ -747,7 +746,7 @@ static __be32 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp
 	new = alloc_session(slotsize, numslots);
 	if (!new) {
 		nfsd4_put_drc_mem(slotsize, fchan->maxreqs);
-		return nfserr_jukebox;
+		return NULL;
 	}
 	init_forechannel_attrs(&new->se_fchannel, fchan, numslots, slotsize);
 
@@ -756,6 +755,7 @@ static __be32 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp
 
 	INIT_LIST_HEAD(&new->se_conns);
 
+	new->se_cb_seq_nr = 1;
 	new->se_flags = cses->flags;
 	kref_init(&new->se_ref);
 	idx = hash_sessionid(&new->se_sessionid);
@@ -765,9 +765,10 @@ static __be32 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp
 	spin_unlock(&client_lock);
 
 	status = nfsd4_new_conn(rqstp, new);
+	/* whoops: benny points out, status is ignored! (err, or bogus) */
 	if (status) {
 		free_session(&new->se_ref);
-		return nfserr_jukebox;
+		return NULL;
 	}
 	if (!clp->cl_cb_session && (cses->flags & SESSION4_BACK_CHAN)) {
 		struct sockaddr *sa = svc_addr(rqstp);
@@ -779,10 +780,9 @@ static __be32 alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp
 		clp->cl_cb_conn.cb_addrlen = svc_addr_len(sa);
 		clp->cl_cb_conn.cb_minorversion = 1;
 		clp->cl_cb_conn.cb_prog = cses->callback_prog;
-		clp->cl_cb_seq_nr = 1;
 		nfsd4_probe_callback(clp, &clp->cl_cb_conn);
 	}
-	return nfs_ok;
+	return new;
 }
 
 /* caller must hold client_lock */
@@ -1485,6 +1485,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 {
 	struct sockaddr *sa = svc_addr(rqstp);
 	struct nfs4_client *conf, *unconf;
+	struct nfsd4_session *new;
 	struct nfsd4_clid_slot *cs_slot = NULL;
 	int status = 0;
 
@@ -1538,11 +1539,12 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	cr_ses->flags &= ~SESSION4_PERSIST;
 	cr_ses->flags &= ~SESSION4_RDMA;
 
-	status = alloc_init_session(rqstp, conf, cr_ses);
-	if (status)
+	status = nfserr_jukebox;
+	new = alloc_init_session(rqstp, conf, cr_ses);
+	if (!new)
 		goto out;
-
-	memcpy(cr_ses->sessionid.data, conf->cl_cb_session->se_sessionid.data,
+	status = nfs_ok;
+	memcpy(cr_ses->sessionid.data, new->se_sessionid.data,
 	       NFS4_MAX_SESSIONID_LEN);
 	cr_ses->seqid = cs_slot->sl_seqid;
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index cdce26a..7f5b267 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -172,6 +172,7 @@ struct nfsd4_session {
 	struct nfsd4_channel_attrs se_fchannel;
 	struct nfsd4_channel_attrs se_bchannel;
 	struct list_head	se_conns;
+	u32			se_cb_seq_nr;
 	struct nfsd4_slot	*se_slots[];	/* forward channel slots */
 };
 
@@ -249,7 +250,6 @@ struct nfs4_client {
 	/* for nfs41 callbacks */
 	/* We currently support a single back channel with a single slot */
 	unsigned long		cl_cb_slot_busy;
-	u32			cl_cb_seq_nr;
 	struct rpc_wait_queue	cl_cb_waitq;	/* backchannel callers may */
 						/* wait here for slots */
 };
-- 
1.7.1

