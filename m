Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43320 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751624Ab2JARnw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 13:43:52 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] nfsd4: enforce per-client sessions/no-sessions distinction
Date: Mon,  1 Oct 2012 13:43:48 -0400
Message-Id: <1349113428-30173-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1349113428-30173-1-git-send-email-bfields@redhat.com>
References: <1349113428-30173-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Something like creating a client with setclientid and then trying to
confirm it with create_session may not crash the server, but I'm not
completely positive of that, and in any case it's obviously bad client
behavior.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c  |    2 +-
 fs/nfsd/nfs4state.c |   49 +++++++++++++++++++++++++++++--------------------
 fs/nfsd/state.h     |    2 +-
 3 files changed, 31 insertions(+), 22 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index f2bb0ef..6c9a4b2 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -370,7 +370,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			break;
 		case NFS4_OPEN_CLAIM_PREVIOUS:
 			open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
-			status = nfs4_check_open_reclaim(&open->op_clientid);
+			status = nfs4_check_open_reclaim(&open->op_clientid, cstate->minorversion);
 			if (status)
 				goto out;
 		case NFS4_OPEN_CLAIM_FH:
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 73029cd..5507842 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1356,13 +1356,15 @@ move_to_confirmed(struct nfs4_client *clp)
 }
 
 static struct nfs4_client *
-find_confirmed_client(clientid_t *clid)
+find_confirmed_client(clientid_t *clid, bool sessions)
 {
 	struct nfs4_client *clp;
 	unsigned int idhashval = clientid_hashval(clid->cl_id);
 
 	list_for_each_entry(clp, &conf_id_hashtbl[idhashval], cl_idhash) {
 		if (same_clid(&clp->cl_clientid, clid)) {
+			if ((bool)clp->cl_minorversion != sessions)
+				return NULL;
 			renew_client(clp);
 			return clp;
 		}
@@ -1371,14 +1373,17 @@ find_confirmed_client(clientid_t *clid)
 }
 
 static struct nfs4_client *
-find_unconfirmed_client(clientid_t *clid)
+find_unconfirmed_client(clientid_t *clid, bool sessions)
 {
 	struct nfs4_client *clp;
 	unsigned int idhashval = clientid_hashval(clid->cl_id);
 
 	list_for_each_entry(clp, &unconf_id_hashtbl[idhashval], cl_idhash) {
-		if (same_clid(&clp->cl_clientid, clid))
+		if (same_clid(&clp->cl_clientid, clid)) {
+			if ((bool)clp->cl_minorversion != sessions)
+				return NULL;
 			return clp;
+		}
 	}
 	return NULL;
 }
@@ -1768,8 +1773,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		return nfserr_inval;
 
 	nfs4_lock_state();
-	unconf = find_unconfirmed_client(&cr_ses->clientid);
-	conf = find_confirmed_client(&cr_ses->clientid);
+	unconf = find_unconfirmed_client(&cr_ses->clientid, true);
+	conf = find_confirmed_client(&cr_ses->clientid, true);
 
 	if (conf) {
 		cs_slot = &conf->cl_cs_slot;
@@ -2096,8 +2101,8 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 	__be32 status = 0;
 
 	nfs4_lock_state();
-	unconf = find_unconfirmed_client(&dc->clientid);
-	conf = find_confirmed_client(&dc->clientid);
+	unconf = find_unconfirmed_client(&dc->clientid, true);
+	conf = find_confirmed_client(&dc->clientid, true);
 
 	if (conf) {
 		clp = conf;
@@ -2239,8 +2244,8 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		return nfserr_stale_clientid;
 	nfs4_lock_state();
 
-	conf = find_confirmed_client(clid);
-	unconf = find_unconfirmed_client(clid);
+	conf = find_confirmed_client(clid, false);
+	unconf = find_unconfirmed_client(clid, false);
 	/*
 	 * We try hard to give out unique clientid's, so if we get an
 	 * attempt to confirm the same clientid with a different cred,
@@ -2454,16 +2459,20 @@ same_owner_str(struct nfs4_stateowner *sop, struct xdr_netobj *owner,
 }
 
 static struct nfs4_openowner *
-find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open)
+find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open, bool sessions)
 {
 	struct nfs4_stateowner *so;
 	struct nfs4_openowner *oo;
+	struct nfs4_client *clp;
 
 	list_for_each_entry(so, &ownerstr_hashtbl[hashval], so_strhash) {
 		if (!so->so_is_open_owner)
 			continue;
 		if (same_owner_str(so, &open->op_owner, &open->op_clientid)) {
 			oo = openowner(so);
+			clp = oo->oo_owner.so_client;
+			if ((bool)clp->cl_minorversion != sessions)
+				return NULL;
 			renew_client(oo->oo_owner.so_client);
 			return oo;
 		}
@@ -2607,10 +2616,10 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 		return nfserr_jukebox;
 
 	strhashval = ownerstr_hashval(clientid->cl_id, &open->op_owner);
-	oo = find_openstateowner_str(strhashval, open);
+	oo = find_openstateowner_str(strhashval, open, cstate->minorversion);
 	open->op_openowner = oo;
 	if (!oo) {
-		clp = find_confirmed_client(clientid);
+		clp = find_confirmed_client(clientid, cstate->minorversion);
 		if (clp == NULL)
 			return nfserr_expired;
 		goto new_owner;
@@ -3107,7 +3116,7 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfserr_stale_clientid;
 	if (STALE_CLIENTID(clid, nn))
 		goto out;
-	clp = find_confirmed_client(clid);
+	clp = find_confirmed_client(clid, cstate->minorversion);
 	status = nfserr_expired;
 	if (clp == NULL) {
 		/* We assume the client took too long to RENEW. */
@@ -3375,7 +3384,7 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	return nfs_ok;
 }
 
-static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask, struct nfs4_stid **s)
+static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask, struct nfs4_stid **s, bool sessions)
 {
 	struct nfs4_client *cl;
 	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
@@ -3384,7 +3393,7 @@ static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask, s
 		return nfserr_bad_stateid;
 	if (STALE_STATEID(stateid, nn))
 		return nfserr_stale_stateid;
-	cl = find_confirmed_client(&stateid->si_opaque.so_clid);
+	cl = find_confirmed_client(&stateid->si_opaque.so_clid, sessions);
 	if (!cl)
 		return nfserr_expired;
 	*s = find_stateid_by_type(cl, stateid, typemask);
@@ -3417,7 +3426,7 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return check_special_stateids(net, current_fh, stateid, flags);
 
-	status = nfsd4_lookup_stateid(stateid, NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID, &s);
+	status = nfsd4_lookup_stateid(stateid, NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID, &s, cstate->minorversion);
 	if (status)
 		return status;
 	status = check_stateid_generation(stateid, &s->sc_stateid, nfsd4_has_session(cstate));
@@ -3567,7 +3576,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 		seqid, STATEID_VAL(stateid));
 
 	*stpp = NULL;
-	status = nfsd4_lookup_stateid(stateid, typemask, &s);
+	status = nfsd4_lookup_stateid(stateid, typemask, &s, cstate->minorversion);
 	if (status)
 		return status;
 	*stpp = openlockstateid(s);
@@ -3805,7 +3814,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	inode = cstate->current_fh.fh_dentry->d_inode;
 
 	nfs4_lock_state();
-	status = nfsd4_lookup_stateid(stateid, NFS4_DELEG_STID, &s);
+	status = nfsd4_lookup_stateid(stateid, NFS4_DELEG_STID, &s, cstate->minorversion);
 	if (status)
 		goto out;
 	dp = delegstateid(s);
@@ -4533,12 +4542,12 @@ nfsd4_find_reclaim_client(struct nfs4_client *clp)
 * Called from OPEN. Look for clientid in reclaim list.
 */
 __be32
-nfs4_check_open_reclaim(clientid_t *clid)
+nfs4_check_open_reclaim(clientid_t *clid, bool sessions)
 {
 	struct nfs4_client *clp;
 
 	/* find clientid in conf_id_hashtbl */
-	clp = find_confirmed_client(clid);
+	clp = find_confirmed_client(clid, sessions);
 	if (clp == NULL)
 		return nfserr_reclaim_bad;
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index ec513fd..e036894 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -455,7 +455,7 @@ extern void nfs4_unlock_state(void);
 extern int nfs4_in_grace(void);
 extern void nfs4_release_reclaim(void);
 extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(struct nfs4_client *crp);
-extern __be32 nfs4_check_open_reclaim(clientid_t *clid);
+extern __be32 nfs4_check_open_reclaim(clientid_t *clid, bool sessions);
 extern void nfs4_free_openowner(struct nfs4_openowner *);
 extern void nfs4_free_lockowner(struct nfs4_lockowner *);
 extern int set_callback_cred(void);
-- 
1.7.9.5

