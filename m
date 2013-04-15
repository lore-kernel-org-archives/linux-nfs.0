Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40893 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932600Ab3DOCHK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Apr 2013 22:07:10 -0400
Date: Sun, 14 Apr 2013 22:07:09 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: finishing off 4.1 for 3.10...
Message-ID: <20130415020709.GB7081@fieldses.org>
References: <1365551896-6936-1-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1365551896-6936-1-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 09, 2013 at 07:58:05PM -0400, J. Bruce Fields wrote:
> The following close off 3 remaining 4.1 todo's and fix some
> miscellaneous bugs and ugliness along the way.
> 
> I had two more todo's in mind before considering 4.1 no longer
> experimental and turn it on by default:
> 
> 	- AUTH_GSS for the backchannel
> 	- SP4_MACH_CRED state protection
> 
> In theory they're both mandatory, but I think I may just go ahead
> without them, after making sure we return reasonable errors in both
> cases and so on.
> 
> The last patch (implementing SEQ4_STATUS_RECALLABLE_STATE_REVOKED)
> hasn't gotten any real testing--I need to write a pynfs test for the
> TEST_STATEID/FREE_STATEID behavior.  So that may still need some more
> revisions.

Sure enough.... A revised patch is appended.

I've also added a pynfs test, and pushed out the result to

	git://linux-nfs.org/~bfields/pynfs.git master

Along the way I noticed pynfs was using an out-of-date nfs4.x (which was
missing an error needed in this case) and had a crucial CB_SEQUENCE bug
(how did we not notice it was responding with the wrong sequence id?).
That (and another miscellaneous open/locking test) are included in the
above.

--b.

commit 4e05166c7148839be370ad8873d5835977c8f609
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Apr 9 17:02:51 2013 -0400

    nfsd4: implement SEQ4_STATUS_RECALLABLE_STATE_REVOKED
    
    A 4.1 server must notify a client that has had any state revoked using
    the SEQ4_STATUS_RECALLABLE_STATE_REVOKED flag.  The client can figure
    out exactly which state is the problem using CHECK_STATEID and then free
    it using FREE_STATEID.  The status flag will be unset once all such
    revoked stateids are freed.
    
    Our server's only recallable state is delegations.  So we keep with each
    4.1 client a list of delegations that have timed out and been recalled,
    but haven't yet been freed by FREE_STATEID.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 986114c..b45a978 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -445,7 +445,6 @@ static void unhash_stid(struct nfs4_stid *s)
 static void
 unhash_delegation(struct nfs4_delegation *dp)
 {
-	unhash_stid(&dp->dl_stid);
 	list_del_init(&dp->dl_perclnt);
 	spin_lock(&recall_lock);
 	list_del_init(&dp->dl_perfile);
@@ -454,10 +453,37 @@ unhash_delegation(struct nfs4_delegation *dp)
 	nfs4_put_deleg_lease(dp->dl_file);
 	put_nfs4_file(dp->dl_file);
 	dp->dl_file = NULL;
+}
+
+
+
+static void destroy_revoked_delegation(struct nfs4_delegation *dp)
+{
+	list_del_init(&dp->dl_recall_lru);
 	remove_stid(&dp->dl_stid);
 	nfs4_put_delegation(dp);
 }
 
+static void destroy_delegation(struct nfs4_delegation *dp)
+{
+	unhash_delegation(dp);
+	nfs4_put_delegation(dp);
+	remove_stid(&dp->dl_stid);
+}
+
+static void revoke_delegation(struct nfs4_delegation *dp)
+{
+	struct nfs4_client *clp = dp->dl_stid.sc_client;
+
+	if (clp->cl_minorversion == 0)
+		destroy_delegation(dp);
+	else {
+		unhash_delegation(dp);
+		dp->dl_stid.sc_type = NFS4_REVOKED_DELEG_STID;
+		list_add(&dp->dl_recall_lru, &clp->cl_revoked);
+	}
+}
+
 /* 
  * SETCLIENTID state 
  */
@@ -1113,7 +1139,7 @@ destroy_client(struct nfs4_client *clp)
 	spin_unlock(&recall_lock);
 	while (!list_empty(&reaplist)) {
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
-		unhash_delegation(dp);
+		destroy_delegation(dp);
 	}
 	while (!list_empty(&clp->cl_openowners)) {
 		oo = list_entry(clp->cl_openowners.next, struct nfs4_openowner, oo_perclient);
@@ -1309,6 +1335,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	INIT_LIST_HEAD(&clp->cl_delegations);
 	INIT_LIST_HEAD(&clp->cl_lru);
 	INIT_LIST_HEAD(&clp->cl_callbacks);
+	INIT_LIST_HEAD(&clp->cl_revoked);
 	spin_lock_init(&clp->cl_lock);
 	nfsd4_init_callback(&clp->cl_cb_null);
 	clp->cl_time = get_seconds();
@@ -2170,6 +2197,8 @@ out:
 	default:
 		seq->status_flags = 0;
 	}
+	if (!list_empty(&clp->cl_revoked))
+		seq->status_flags |= SEQ4_STATUS_RECALLABLE_STATE_REVOKED;
 out_no_session:
 	kfree(conn);
 	spin_unlock(&nn->client_lock);
@@ -3296,7 +3325,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 	spin_unlock(&recall_lock);
 	list_for_each_safe(pos, next, &reaplist) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
-		unhash_delegation(dp);
+		revoke_delegation(dp);
 	}
 	test_val = nn->nfsd4_lease;
 	list_for_each_safe(pos, next, &nn->close_lru) {
@@ -3458,6 +3487,8 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	switch (s->sc_type) {
 	case NFS4_DELEG_STID:
 		return nfs_ok;
+	case NFS4_REVOKED_DELEG_STID:
+		return nfserr_deleg_revoked;
 	case NFS4_OPEN_STID:
 	case NFS4_LOCK_STID:
 		ols = openlockstateid(s);
@@ -3601,6 +3632,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	stateid_t *stateid = &free_stateid->fr_stateid;
 	struct nfs4_stid *s;
+	struct nfs4_delegation *dp;
 	struct nfs4_client *cl = cstate->session->se_client;
 	__be32 ret = nfserr_bad_stateid;
 
@@ -3622,6 +3654,11 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		else
 			ret = nfserr_locks_held;
 		break;
+	case NFS4_REVOKED_DELEG_STID:
+		dp = delegstateid(s);
+		destroy_revoked_delegation(dp);
+		ret = nfs_ok;
+		break;
 	default:
 		ret = nfserr_bad_stateid;
 	}
@@ -3646,10 +3683,12 @@ static __be32 nfs4_seqid_op_checks(struct nfsd4_compound_state *cstate, stateid_
 	status = nfsd4_check_seqid(cstate, sop, seqid);
 	if (status)
 		return status;
-	if (stp->st_stid.sc_type == NFS4_CLOSED_STID)
+	if (stp->st_stid.sc_type == NFS4_CLOSED_STID
+		|| stp->st_stid.sc_type == NFS4_REVOKED_DELEG_STID)
 		/*
 		 * "Closed" stateid's exist *only* to return
-		 * nfserr_replay_me from the previous step.
+		 * nfserr_replay_me from the previous step, and
+		 * revoked delegations are kept only for free_stateid.
 		 */
 		return nfserr_bad_stateid;
 	status = check_stateid_generation(stateid, &stp->st_stid.sc_stateid, nfsd4_has_session(cstate));
@@ -3912,7 +3951,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		goto out;
 
-	unhash_delegation(dp);
+	destroy_delegation(dp);
 out:
 	nfs4_unlock_state();
 
@@ -4762,7 +4801,7 @@ u64 nfsd_forget_client_delegations(struct nfs4_client *clp, u64 max)
 	spin_unlock(&recall_lock);
 
 	list_for_each_entry_safe(dp, next, &victims, dl_recall_lru)
-		unhash_delegation(dp);
+		revoke_delegation(dp);
 
 	return count;
 }
@@ -5017,7 +5056,7 @@ nfs4_state_shutdown_net(struct net *net)
 	spin_unlock(&recall_lock);
 	list_for_each_safe(pos, next, &reaplist) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
-		unhash_delegation(dp);
+		destroy_delegation(dp);
 	}
 
 	nfsd4_client_tracking_exit(net);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 13ec485..274e2a1 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -79,6 +79,8 @@ struct nfs4_stid {
 #define NFS4_DELEG_STID 4
 /* For an open stateid kept around *only* to process close replays: */
 #define NFS4_CLOSED_STID 8
+/* For a deleg stateid kept around only to process free_stateid's: */
+#define NFS4_REVOKED_DELEG_STID 16
 	unsigned char sc_type;
 	stateid_t sc_stateid;
 	struct nfs4_client *sc_client;
@@ -238,6 +240,7 @@ struct nfs4_client {
 	struct list_head	cl_openowners;
 	struct idr		cl_stateids;	/* stateid lookup */
 	struct list_head	cl_delegations;
+	struct list_head	cl_revoked;	/* unacknowledged, revoked 4.1 state */
 	struct list_head        cl_lru;         /* tail queue */
 	struct xdr_netobj	cl_name; 	/* id generated by client */
 	nfs4_verifier		cl_verifier; 	/* generated by client */
