Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53880 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751564Ab3GIDSW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jul 2013 23:18:22 -0400
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1UwORZ-0000zh-IK
	for linux-nfs@vger.kernel.org; Mon, 08 Jul 2013 23:18:21 -0400
Date: Mon, 8 Jul 2013 23:18:21 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: allow destroy_session over destroyed session
Message-ID: <20130709031821.GM29071@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

RFC 5661 allows a client to destroy a session using a compound
associated with the destroyed session, as long as the DESTROY_SESSION op
is the last op of the compound.

We attempt to allow this, but testing against a Solaris client (which
does destroy sessions in this way) showed that we were failing the
DESTROY_SESSION with NFS4ERR_DELAY, because we assumed the reference
count on the session (held by us) represented another rpc in progress
over this session.

Fix this by noting that in this case the expected reference count is 1,
not 0.

Also, note as long as the session holds a reference to the compound
we're destroying, we can't free it here--instead, delay the free till
the final put in nfs4svc_encode_compoundres.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   23 ++++++++++++++---------
 fs/nfsd/nfs4xdr.c   |    6 +++++-
 2 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d44a4bf..25ae6ce 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -97,19 +97,20 @@ nfs4_lock_state(void)
 
 static void free_session(struct nfsd4_session *);
 
-void nfsd4_put_session(struct nfsd4_session *ses)
+static bool is_session_dead(struct nfsd4_session *ses)
 {
-	atomic_dec(&ses->se_ref);
+	return ses->se_flags & NFS4_SESSION_DEAD;
 }
 
-static bool is_session_dead(struct nfsd4_session *ses)
+void nfsd4_put_session(struct nfsd4_session *ses)
 {
-	return ses->se_flags & NFS4_SESSION_DEAD;
+	if (atomic_dec_and_test(&ses->se_ref) && is_session_dead(ses))
+		free_session(ses);
 }
 
-static __be32 mark_session_dead_locked(struct nfsd4_session *ses)
+static __be32 mark_session_dead_locked(struct nfsd4_session *ses, int ref_held_by_me)
 {
-	if (atomic_read(&ses->se_ref))
+	if (atomic_read(&ses->se_ref) > ref_held_by_me)
 		return nfserr_jukebox;
 	ses->se_flags |= NFS4_SESSION_DEAD;
 	return nfs_ok;
@@ -2074,6 +2075,7 @@ nfsd4_destroy_session(struct svc_rqst *r,
 {
 	struct nfsd4_session *ses;
 	__be32 status;
+	int ref_held_by_me = 0;
 	struct nfsd_net *nn = net_generic(SVC_NET(r), nfsd_net_id);
 
 	nfs4_lock_state();
@@ -2081,6 +2083,7 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	if (nfsd4_compound_in_session(cstate->session, &sessionid->sessionid)) {
 		if (!nfsd4_last_compound_op(r))
 			goto out;
+		ref_held_by_me++;
 	}
 	dump_sessionid(__func__, &sessionid->sessionid);
 	spin_lock(&nn->client_lock);
@@ -2091,17 +2094,19 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	status = nfserr_wrong_cred;
 	if (!mach_creds_match(ses->se_client, r))
 		goto out_client_lock;
-	status = mark_session_dead_locked(ses);
+	nfsd4_get_session_locked(ses);
+	status = mark_session_dead_locked(ses, 1 + ref_held_by_me);
 	if (status)
-		goto out_client_lock;
+		goto out_put_session;
 	unhash_session(ses);
 	spin_unlock(&nn->client_lock);
 
 	nfsd4_probe_callback_sync(ses->se_client);
 
 	spin_lock(&nn->client_lock);
-	free_session(ses);
 	status = nfs_ok;
+out_put_session:
+	nfsd4_put_session(ses);
 out_client_lock:
 	spin_unlock(&nn->client_lock);
 out:
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c102d25..0c0f3ea9 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3760,13 +3760,17 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
 	BUG_ON(iov->iov_len > PAGE_SIZE);
 	if (nfsd4_has_session(cs)) {
+		struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+		struct nfs4_client *clp = cs->session->se_client;
 		if (cs->status != nfserr_replay_cache) {
 			nfsd4_store_cache_entry(resp);
 			cs->slot->sl_flags &= ~NFSD4_SLOT_INUSE;
 		}
 		/* Renew the clientid on success and on replay */
-		put_client_renew(cs->session->se_client);
+		spin_lock(&nn->client_lock);
 		nfsd4_put_session(cs->session);
+		spin_unlock(&nn->client_lock);
+		put_client_renew(clp);
 	}
 	return 1;
 }
-- 
1.7.9.5

