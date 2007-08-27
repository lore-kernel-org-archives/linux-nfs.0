From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 05/15] knfsd: cleanup of nfsd4 cmp_* functions
Date: Mon, 27 Aug 2007 16:22:46 -0400
Message-ID: <11882461771774-git-send-email-bfields@fieldses.org>
References: <11882461763072-git-send-email-bfields@fieldses.org>
	<1188246176681-git-send-email-bfields@fieldses.org>
	<1188246176897-git-send-email-bfields@fieldses.org>
	<1188246177833-git-send-email-bfields@fieldses.org>
	<11882461773576-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>, nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPl6z-0004hQ-KW
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:01 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPl71-0003NB-I5
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:05 -0700
In-Reply-To: <11882461773576-git-send-email-bfields@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: J. Bruce Fields <bfields@citi.umich.edu>

Benny Halevy suggested renaming cmp_* to same_* to make the meaning of
the return value clearer.

Fix some nearby style deviations while we're at it, including a small
swath of creative indentation in nfs4_preprocess_seqid_op().

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |   91 ++++++++++++++++++++++++++------------------------
 1 files changed, 47 insertions(+), 44 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3f55970..578d809 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -462,26 +462,28 @@ copy_cred(struct svc_cred *target, struct svc_cred *source) {
 }
 
 static inline int
-same_name(const char *n1, const char *n2) {
+same_name(const char *n1, const char *n2)
+{
 	return 0 == memcmp(n1, n2, HEXDIR_LEN);
 }
 
 static int
-cmp_verf(nfs4_verifier *v1, nfs4_verifier *v2) {
-	return(!memcmp(v1->data,v2->data,sizeof(v1->data)));
+same_verf(nfs4_verifier *v1, nfs4_verifier *v2)
+{
+	return 0 == memcmp(v1->data, v2->data, sizeof(v1->data));
 }
 
 static int
-cmp_clid(clientid_t * cl1, clientid_t * cl2) {
-	return((cl1->cl_boot == cl2->cl_boot) &&
-	   	(cl1->cl_id == cl2->cl_id));
+same_clid(clientid_t *cl1, clientid_t *cl2)
+{
+	return (cl1->cl_boot == cl2->cl_boot) && (cl1->cl_id == cl2->cl_id);
 }
 
 /* XXX what about NGROUP */
 static int
-cmp_creds(struct svc_cred *cr1, struct svc_cred *cr2){
-	return(cr1->cr_uid == cr2->cr_uid);
-
+same_creds(struct svc_cred *cr1, struct svc_cred *cr2)
+{
+	return cr1->cr_uid == cr2->cr_uid;
 }
 
 static void
@@ -546,7 +548,7 @@ find_confirmed_client(clientid_t *clid)
 	unsigned int idhashval = clientid_hashval(clid->cl_id);
 
 	list_for_each_entry(clp, &conf_id_hashtbl[idhashval], cl_idhash) {
-		if (cmp_clid(&clp->cl_clientid, clid))
+		if (same_clid(&clp->cl_clientid, clid))
 			return clp;
 	}
 	return NULL;
@@ -559,7 +561,7 @@ find_unconfirmed_client(clientid_t *clid)
 	unsigned int idhashval = clientid_hashval(clid->cl_id);
 
 	list_for_each_entry(clp, &unconf_id_hashtbl[idhashval], cl_idhash) {
-		if (cmp_clid(&clp->cl_clientid, clid))
+		if (same_clid(&clp->cl_clientid, clid))
 			return clp;
 	}
 	return NULL;
@@ -753,7 +755,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		 * or different ip_address
 		 */
 		status = nfserr_clid_inuse;
-		if (!cmp_creds(&conf->cl_cred, &rqstp->rq_cred)
+		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)
 				|| conf->cl_addr != sin->sin_addr.s_addr) {
 			dprintk("NFSD: setclientid: string in use by client"
 				"at %u.%u.%u.%u\n", NIPQUAD(conf->cl_addr));
@@ -779,7 +781,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		gen_confirm(new);
 		gen_callback(new, setclid);
 		add_to_unconfirmed(new, strhashval);
-	} else if (cmp_verf(&conf->cl_verifier, &clverifier)) {
+	} else if (same_verf(&conf->cl_verifier, &clverifier)) {
 		/*
 		 * CASE 1:
 		 * cl_name match, confirmed, principal match
@@ -830,7 +832,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		gen_confirm(new);
 		gen_callback(new, setclid);
 		add_to_unconfirmed(new, strhashval);
-	} else if (!cmp_verf(&conf->cl_confirm, &unconf->cl_confirm)) {
+	} else if (!same_verf(&conf->cl_confirm, &unconf->cl_confirm)) {
 		/*	
 		 * CASE3:
 		 * confirmed found (name, principal match)
@@ -910,16 +912,16 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		goto out;
 
 	if ((conf && unconf) && 
-	    (cmp_verf(&unconf->cl_confirm, &confirm)) &&
-	    (cmp_verf(&conf->cl_verifier, &unconf->cl_verifier)) &&
+	    (same_verf(&unconf->cl_confirm, &confirm)) &&
+	    (same_verf(&conf->cl_verifier, &unconf->cl_verifier)) &&
 	    (same_name(conf->cl_recdir,unconf->cl_recdir))  &&
-	    (!cmp_verf(&conf->cl_confirm, &unconf->cl_confirm))) {
+	    (!same_verf(&conf->cl_confirm, &unconf->cl_confirm))) {
 		/* CASE 1:
 		* unconf record that matches input clientid and input confirm.
 		* conf record that matches input clientid.
 		* conf and unconf records match names, verifiers
 		*/
-		if (!cmp_creds(&conf->cl_cred, &unconf->cl_cred)) 
+		if (!same_creds(&conf->cl_cred, &unconf->cl_cred))
 			status = nfserr_clid_inuse;
 		else {
 			/* XXX: We just turn off callbacks until we can handle
@@ -933,7 +935,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		}
 	} else if ((conf && !unconf) ||
 	    ((conf && unconf) && 
-	     (!cmp_verf(&conf->cl_verifier, &unconf->cl_verifier) ||
+	     (!same_verf(&conf->cl_verifier, &unconf->cl_verifier) ||
 	      !same_name(conf->cl_recdir, unconf->cl_recdir)))) {
 		/* CASE 2:
 		 * conf record that matches input clientid.
@@ -941,18 +943,18 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		 * unconf->cl_name or unconf->cl_verifier don't match the
 		 * conf record.
 		 */
-		if (!cmp_creds(&conf->cl_cred,&rqstp->rq_cred))
+		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred))
 			status = nfserr_clid_inuse;
 		else
 			status = nfs_ok;
 	} else if (!conf && unconf
-			&& cmp_verf(&unconf->cl_confirm, &confirm)) {
+			&& same_verf(&unconf->cl_confirm, &confirm)) {
 		/* CASE 3:
 		 * conf record not found.
 		 * unconf record found.
 		 * unconf->cl_confirm matches input confirm
 		 */
-		if (!cmp_creds(&unconf->cl_cred, &rqstp->rq_cred)) {
+		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred)) {
 			status = nfserr_clid_inuse;
 		} else {
 			unsigned int hash =
@@ -967,8 +969,8 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			conf = unconf;
 			status = nfs_ok;
 		}
-	} else if ((!conf || (conf && !cmp_verf(&conf->cl_confirm, &confirm)))
-	    && (!unconf || (unconf && !cmp_verf(&unconf->cl_confirm,
+	} else if ((!conf || (conf && !same_verf(&conf->cl_confirm, &confirm)))
+	    && (!unconf || (unconf && !same_verf(&unconf->cl_confirm,
 				    				&confirm)))) {
 		/* CASE 4:
 		 * conf record not found, or if conf, conf->cl_confirm does not
@@ -1207,10 +1209,12 @@ move_to_close_lru(struct nfs4_stateowner *sop)
 }
 
 static int
-cmp_owner_str(struct nfs4_stateowner *sop, struct xdr_netobj *owner, clientid_t *clid) {
-	return ((sop->so_owner.len == owner->len) && 
-	 !memcmp(sop->so_owner.data, owner->data, owner->len) && 
-	  (sop->so_client->cl_clientid.cl_id == clid->cl_id));
+same_owner_str(struct nfs4_stateowner *sop, struct xdr_netobj *owner,
+							clientid_t *clid)
+{
+	return (sop->so_owner.len == owner->len) &&
+		0 == memcmp(sop->so_owner.data, owner->data, owner->len) &&
+		(sop->so_client->cl_clientid.cl_id == clid->cl_id);
 }
 
 static struct nfs4_stateowner *
@@ -1219,7 +1223,7 @@ find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open)
 	struct nfs4_stateowner *so = NULL;
 
 	list_for_each_entry(so, &ownerstr_hashtbl[hashval], so_strhash) {
-		if (cmp_owner_str(so, &open->op_owner, &open->op_clientid))
+		if (same_owner_str(so, &open->op_owner, &open->op_clientid))
 			return so;
 	}
 	return NULL;
@@ -2181,21 +2185,20 @@ nfs4_preprocess_seqid_op(struct svc_fh *current_fh, u32 seqid, stateid_t *statei
 		lkflg = setlkflg(lock->lk_type);
 
 		if (lock->lk_is_new) {
-                       if (!sop->so_is_open_owner)
-			       return nfserr_bad_stateid;
-                       if (!cmp_clid(&clp->cl_clientid, lockclid))
+			if (!sop->so_is_open_owner)
+				return nfserr_bad_stateid;
+			if (!same_clid(&clp->cl_clientid, lockclid))
 			       return nfserr_bad_stateid;
-                       /* stp is the open stateid */
-                       status = nfs4_check_openmode(stp, lkflg);
-                       if (status)
-			       return status;
-               } else {
-                       /* stp is the lock stateid */
-                       status = nfs4_check_openmode(stp->st_openstp, lkflg);
-                       if (status)
-			       return status;
+			/* stp is the open stateid */
+			status = nfs4_check_openmode(stp, lkflg);
+			if (status)
+				return status;
+		} else {
+			/* stp is the lock stateid */
+			status = nfs4_check_openmode(stp->st_openstp, lkflg);
+			if (status)
+				return status;
                }
-
 	}
 
 	if ((flags & CHECK_FH) && nfs4_check_fh(current_fh, stp)) {
@@ -2561,7 +2564,7 @@ find_lockstateowner_str(struct inode *inode, clientid_t *clid,
 	struct nfs4_stateowner *op;
 
 	list_for_each_entry(op, &lock_ownerstr_hashtbl[hashval], so_strhash) {
-		if (cmp_owner_str(op, owner, clid))
+		if (same_owner_str(op, owner, clid))
 			return op;
 	}
 	return NULL;
@@ -3025,7 +3028,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	INIT_LIST_HEAD(&matches);
 	for (i = 0; i < LOCK_HASH_SIZE; i++) {
 		list_for_each_entry(sop, &lock_ownerid_hashtbl[i], so_idhash) {
-			if (!cmp_owner_str(sop, owner, clid))
+			if (!same_owner_str(sop, owner, clid))
 				continue;
 			list_for_each_entry(stp, &sop->so_stateids,
 					st_perstateowner) {
-- 
1.5.3.rc5.19.g0734d


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
