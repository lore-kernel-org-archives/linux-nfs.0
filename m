Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44755 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754477Ab1JQV4X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Oct 2011 17:56:23 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/8] nfsd4: centralize renew_client() calls
Date: Mon, 17 Oct 2011 17:55:50 -0400
Message-Id: <1318888557-14719-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1318888557-14719-1-git-send-email-bfields@redhat.com>
References: <1318888557-14719-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

There doesn't seem to be any harm to renewing the client a bit earlier,
when it is looked up.  That saves us from having to sprinkle
renew_client calls over quite so many places.

Also remove a redundant comment and do a little cleanup.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   23 ++++++++++-------------
 1 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2042805..d90461e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -931,9 +931,6 @@ renew_client_locked(struct nfs4_client *clp)
 		return;
 	}
 
-	/*
-	* Move client to the end to the LRU list.
-	*/
 	dprintk("renewing client (clientid %08x/%08x)\n", 
 			clp->cl_clientid.cl_boot, 
 			clp->cl_clientid.cl_id);
@@ -1220,8 +1217,10 @@ find_confirmed_client(clientid_t *clid)
 	unsigned int idhashval = clientid_hashval(clid->cl_id);
 
 	list_for_each_entry(clp, &conf_id_hashtbl[idhashval], cl_idhash) {
-		if (same_clid(&clp->cl_clientid, clid))
+		if (same_clid(&clp->cl_clientid, clid)) {
+			renew_client(clp);
 			return clp;
+		}
 	}
 	return NULL;
 }
@@ -2372,11 +2371,15 @@ same_owner_str(struct nfs4_stateowner *sop, struct xdr_netobj *owner,
 static struct nfs4_openowner *
 find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open)
 {
-	struct nfs4_stateowner *so = NULL;
+	struct nfs4_stateowner *so;
+	struct nfs4_openowner *oo;
 
 	list_for_each_entry(so, &open_ownerstr_hashtbl[hashval], so_strhash) {
-		if (same_owner_str(so, &open->op_owner, &open->op_clientid))
-			return container_of(so, struct nfs4_openowner, oo_owner);
+		if (same_owner_str(so, &open->op_owner, &open->op_clientid)) {
+			oo = openowner(so);
+			renew_client(oo->oo_owner.so_client);
+			return oo;
+		}
 	}
 	return NULL;
 }
@@ -2536,7 +2539,6 @@ renew:
 		open->op_openowner = oo;
 	}
 	list_del_init(&oo->oo_close_lru);
-	renew_client(oo->oo_owner.so_client);
 	return nfs_ok;
 }
 
@@ -2970,7 +2972,6 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		dprintk("nfsd4_renew: clientid not found!\n");
 		goto out;
 	}
-	renew_client(clp);
 	status = nfserr_cb_path_down;
 	if (!list_empty(&clp->cl_delegations)
 			&& clp->cl_cb_state != NFSD4_CB_UP)
@@ -3275,7 +3276,6 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 		status = nfs4_check_delegmode(dp, flags);
 		if (status)
 			goto out;
-		renew_client(dp->dl_stid.sc_client);
 		if (filpp) {
 			*filpp = dp->dl_file->fi_deleg_file;
 			BUG_ON(!*filpp);
@@ -3293,7 +3293,6 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 		status = nfs4_check_openmode(stp, flags);
 		if (status)
 			goto out;
-		renew_client(stp->st_stateowner->so_client);
 		if (filpp) {
 			if (flags & RD_STATE)
 				*filpp = find_readable_file(stp->st_file);
@@ -3412,7 +3411,6 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 		return status;
 	*stpp = openlockstateid(s);
 	cstate->replay_owner = (*stpp)->st_stateowner;
-	renew_client((*stpp)->st_stateowner->so_client);
 
 	return nfs4_seqid_op_checks(cstate, stateid, seqid, *stpp);
 }
@@ -3643,7 +3641,6 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = check_stateid_generation(stateid, &dp->dl_stid.sc_stateid, nfsd4_has_session(cstate));
 	if (status)
 		goto out;
-	renew_client(dp->dl_stid.sc_client);
 
 	unhash_delegation(dp);
 out:
-- 
1.7.5.4

