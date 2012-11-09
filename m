Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:43164 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755369Ab2KIUHD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Nov 2012 15:07:03 -0500
Received: by mail-vb0-f46.google.com with SMTP id ff1so4276477vbb.19
        for <linux-nfs@vger.kernel.org>; Fri, 09 Nov 2012 12:07:03 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC 7/7] nfsd: get rid of cl_recdir field
Date: Fri,  9 Nov 2012 15:06:44 -0500
Message-Id: <1352491604-21605-8-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352491604-21605-1-git-send-email-jlayton@redhat.com>
References: <1352491604-21605-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the cl_recdir field from the nfs4_client struct. Instead, just
compute it on the fly when and if it's needed, which is now only when
the legacy client tracking code is in effect.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c | 48 ++++++++++++++++++++++++++++++++----------------
 fs/nfsd/nfs4state.c   | 18 +++---------------
 fs/nfsd/state.h       |  2 --
 3 files changed, 35 insertions(+), 33 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index e010152..d8d3553 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -103,13 +103,13 @@ md5_to_hex(char *out, char *md5)
 	*out = '\0';
 }
 
-__be32
-nfs4_make_rec_clidname(char *dname, struct xdr_netobj *clname)
+static int
+nfs4_make_rec_clidname(char *dname, const struct xdr_netobj *clname)
 {
 	struct xdr_netobj cksum;
 	struct hash_desc desc;
 	struct scatterlist sg;
-	__be32 status = nfserr_jukebox;
+	int status = -EAGAIN;
 
 	dprintk("NFSD: nfs4_make_rec_clidname for %.*s\n",
 			clname->len, clname->data);
@@ -129,7 +129,7 @@ nfs4_make_rec_clidname(char *dname, struct xdr_netobj *clname)
 
 	md5_to_hex(dname, cksum.data);
 
-	status = nfs_ok;
+	status = 0;
 out:
 	kfree(cksum.data);
 	crypto_free_hash(desc.tfm);
@@ -141,7 +141,7 @@ static void
 nfsd4_create_clid_dir(struct nfs4_client *clp)
 {
 	const struct cred *original_cred;
-	char *dname = clp->cl_recdir;
+	char dname[HEXDIR_LEN];
 	struct dentry *dir, *dentry;
 	struct nfs4_client_reclaim *crp;
 	int status;
@@ -164,6 +164,7 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 	/* lock the parent */
 	mutex_lock(&dir->d_inode->i_mutex);
 
+	status = nfs4_make_rec_clidname(dname, &clp->cl_name);
 	dentry = lookup_one_len(dname, dir, HEXDIR_LEN-1);
 	if (IS_ERR(dentry)) {
 		status = PTR_ERR(dentry);
@@ -186,7 +187,7 @@ out_unlock:
 	mutex_unlock(&dir->d_inode->i_mutex);
 	if (status == 0) {
 		if (in_grace) {
-			crp = nfs4_client_to_reclaim(clp->cl_recdir);
+			crp = nfs4_client_to_reclaim(dname);
 			if (crp)
 				crp->cr_clp = clp;
 		}
@@ -298,6 +299,7 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
 {
 	const struct cred *original_cred;
 	struct nfs4_client_reclaim *crp;
+	char dname[HEXDIR_LEN];
 	int status;
 
 	if (!rec_file || !test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
@@ -312,13 +314,15 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
 	if (status < 0)
 		goto out;
 
-	status = nfsd4_unlink_clid_dir(clp->cl_recdir, HEXDIR_LEN-1);
+	status = nfs4_make_rec_clidname(dname, &clp->cl_name);
+	if (!status)
+		status = nfsd4_unlink_clid_dir(dname, HEXDIR_LEN-1);
 	nfs4_reset_creds(original_cred);
 	if (status == 0) {
 		vfs_fsync(rec_file, 0);
 		if (in_grace) {
 			/* remove reclaim record */
-			crp = nfsd4_find_reclaim_client(clp->cl_recdir);
+			crp = nfsd4_find_reclaim_client(dname);
 			if (crp)
 				nfs4_remove_reclaim_record(crp);
 		}
@@ -327,7 +331,7 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
 out:
 	if (status)
 		printk("NFSD: Failed to remove expired client state directory"
-				" %.*s\n", HEXDIR_LEN, clp->cl_recdir);
+				" %.*s\n", HEXDIR_LEN, dname);
 }
 
 static int
@@ -499,14 +503,20 @@ nfs4_recoverydir(void)
 static int
 nfsd4_check_legacy_client(struct nfs4_client *clp)
 {
+	int status;
+	char dname[HEXDIR_LEN];
 	struct nfs4_client_reclaim *crp;
 
 	/* did we already find that this client is stable? */
 	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
 		return 0;
 
+	status = nfs4_make_rec_clidname(dname, &clp->cl_name);
+	if (status)
+		return status;
+
 	/* look for it in the reclaim hashtable otherwise */
-	crp = nfsd4_find_reclaim_client(clp->cl_recdir);
+	crp = nfsd4_find_reclaim_client(dname);
 	if (crp) {
 		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
 		crp->cr_clp = clp;
@@ -992,7 +1002,7 @@ nfsd4_cltrack_legacy_topdir(void)
 }
 
 static char *
-nfsd4_cltrack_legacy_recdir(const char *recdir)
+nfsd4_cltrack_legacy_recdir(const struct xdr_netobj *name)
 {
 	int copied;
 	size_t len;
@@ -1009,10 +1019,16 @@ nfsd4_cltrack_legacy_recdir(const char *recdir)
 	if (!result)
 		return result;
 
-	copied = snprintf(result, len, LEGACY_RECDIR_ENV_PREFIX "%s/%s",
-				nfs4_recoverydir(), recdir);
-	if (copied >= len) {
-		/* just return nothing if output was truncated */
+	copied = snprintf(result, len, LEGACY_RECDIR_ENV_PREFIX "%s/",
+				nfs4_recoverydir());
+	if (copied >= (len - HEXDIR_LEN)) {
+		/* just return nothing if output will be truncated */
+		kfree(result);
+		return NULL;
+	}
+
+	copied = nfs4_make_rec_clidname(result + copied, name);
+	if (copied) {
 		kfree(result);
 		return NULL;
 	}
@@ -1125,7 +1141,7 @@ nfsd4_umh_cltrack_check(struct nfs4_client *clp)
 		dprintk("%s: can't allocate memory for upcall!\n", __func__);
 		return -ENOMEM;
 	}
-	legacy = nfsd4_cltrack_legacy_recdir(clp->cl_recdir);
+	legacy = nfsd4_cltrack_legacy_recdir(&clp->cl_name);
 	ret = nfsd4_umh_cltrack_upcall("check", hexid, legacy);
 	kfree(legacy);
 	kfree(hexid);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3894376..dad8e4e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1299,7 +1299,7 @@ static struct nfs4_stid *find_stateid_by_type(struct nfs4_client *cl, stateid_t
 	return NULL;
 }
 
-static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
+static struct nfs4_client *create_client(struct xdr_netobj name,
 		struct svc_rqst *rqstp, nfs4_verifier *verf)
 {
 	struct nfs4_client *clp;
@@ -1319,7 +1319,6 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 		return NULL;
 	}
 	idr_init(&clp->cl_stateids);
-	memcpy(clp->cl_recdir, recdir, HEXDIR_LEN);
 	atomic_set(&clp->cl_refcount, 0);
 	clp->cl_cb_state = NFSD4_CB_UNKNOWN;
 	INIT_LIST_HEAD(&clp->cl_idhash);
@@ -1616,7 +1615,6 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 {
 	struct nfs4_client *unconf, *conf, *new;
 	__be32 status;
-	char			dname[HEXDIR_LEN];
 	char			addr_str[INET6_ADDRSTRLEN];
 	nfs4_verifier		verf = exid->verifier;
 	struct sockaddr		*sa = svc_addr(rqstp);
@@ -1643,11 +1641,6 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		return nfserr_serverfault;	/* no excuse :-/ */
 	}
 
-	status = nfs4_make_rec_clidname(dname, &exid->clname);
-
-	if (status)
-		return status;
-
 	/* Cases below refer to rfc 5661 section 18.35.4: */
 	nfs4_lock_state();
 	conf = find_confirmed_client_by_name(&exid->clname);
@@ -1701,7 +1694,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
 	/* case 1 (normal case) */
 out_new:
-	new = create_client(exid->clname, dname, rqstp, &verf);
+	new = create_client(exid->clname, rqstp, &verf);
 	if (new == NULL) {
 		status = nfserr_jukebox;
 		goto out;
@@ -2222,12 +2215,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_verifier		clverifier = setclid->se_verf;
 	struct nfs4_client	*conf, *unconf, *new;
 	__be32 			status;
-	char                    dname[HEXDIR_LEN];
 	
-	status = nfs4_make_rec_clidname(dname, &clname);
-	if (status)
-		return status;
-
 	/* Cases below refer to rfc 3530 section 14.2.33: */
 	nfs4_lock_state();
 	conf = find_confirmed_client_by_name(&clname);
@@ -2249,7 +2237,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (unconf)
 		expire_client(unconf);
 	status = nfserr_jukebox;
-	new = create_client(clname, dname, rqstp, &clverifier);
+	new = create_client(clname, rqstp, &clverifier);
 	if (new == NULL)
 		goto out;
 	if (conf && same_verf(&conf->cl_verifier, &clverifier))
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 5ee88bf..c049039 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -227,7 +227,6 @@ struct nfs4_client {
 	struct list_head	cl_delegations;
 	struct list_head        cl_lru;         /* tail queue */
 	struct xdr_netobj	cl_name; 	/* id generated by client */
-	char                    cl_recdir[HEXDIR_LEN]; /* recovery dir */
 	nfs4_verifier		cl_verifier; 	/* generated by client */
 	time_t                  cl_time;        /* time of last lease renewal */
 	struct sockaddr_storage	cl_addr; 	/* client ipaddress */
@@ -470,7 +469,6 @@ extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
-extern __be32 nfs4_make_rec_clidname(char *clidname, struct xdr_netobj *clname);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name);
 extern bool nfs4_has_reclaimed_state(const char *name);
 extern void release_session_client(struct nfsd4_session *);
-- 
1.7.11.7

