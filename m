Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:59742 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395Ab2KLUBV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2012 15:01:21 -0500
Received: by mail-vb0-f46.google.com with SMTP id ff1so6652181vbb.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Nov 2012 12:01:21 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 10/11] nfsd: get rid of cl_recdir field
Date: Mon, 12 Nov 2012 15:00:57 -0500
Message-Id: <1352750458-16857-11-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352750458-16857-1-git-send-email-jlayton@redhat.com>
References: <1352750458-16857-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the cl_recdir field from the nfs4_client struct. Instead, just
compute it on the fly when and if it's needed, which is now only when
the legacy client tracking code is in effect.

The error handling in the legacy client tracker is also changed to
handle the case where md5 is unavailable. In that case, we'll warn
the admin with a KERN_ERR message and disable the client tracking.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c | 93 ++++++++++++++++++++++++++++++++++++++++-----------
 fs/nfsd/nfs4state.c   | 18 ++--------
 fs/nfsd/state.h       |  2 --
 3 files changed, 77 insertions(+), 36 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 3048c01..80e77cc 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -103,33 +103,39 @@ md5_to_hex(char *out, char *md5)
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
+	int status;
 
 	dprintk("NFSD: nfs4_make_rec_clidname for %.*s\n",
 			clname->len, clname->data);
 	desc.flags = CRYPTO_TFM_REQ_MAY_SLEEP;
 	desc.tfm = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
-	if (IS_ERR(desc.tfm))
+	if (IS_ERR(desc.tfm)) {
+		status = PTR_ERR(desc.tfm);
 		goto out_no_tfm;
+	}
+
 	cksum.len = crypto_hash_digestsize(desc.tfm);
 	cksum.data = kmalloc(cksum.len, GFP_KERNEL);
-	if (cksum.data == NULL)
+	if (cksum.data == NULL) {
+		status = -ENOMEM;
  		goto out;
+	}
 
 	sg_init_one(&sg, clname->data, clname->len);
 
-	if (crypto_hash_digest(&desc, &sg, sg.length, cksum.data))
+	status = crypto_hash_digest(&desc, &sg, sg.length, cksum.data);
+	if (status)
 		goto out;
 
 	md5_to_hex(dname, cksum.data);
 
-	status = nfs_ok;
+	status = 0;
 out:
 	kfree(cksum.data);
 	crypto_free_hash(desc.tfm);
@@ -137,11 +143,36 @@ out_no_tfm:
 	return status;
 }
 
+/*
+ * If we had an error generating the recdir name for the legacy tracker
+ * then warn the admin. If the error doesn't appear to be transient,
+ * then disable recovery tracking.
+ */
+static void
+legacy_recdir_name_error(int error)
+{
+	printk(KERN_ERR "NFSD: unable to generate recoverydir "
+			"name (%d).\n", error);
+
+	/*
+	 * if the algorithm just doesn't exist, then disable the recovery
+	 * tracker altogether. The crypto libs will generally return this if
+	 * FIPS is enabled as well.
+	 */
+	if (error == -ENOENT) {
+		printk(KERN_ERR "NFSD: disabling legacy clientid tracking. "
+			"Reboot recovery will not function correctly!\n");
+
+		/* the argument is ignored by the legacy exit function */
+		nfsd4_client_tracking_exit(NULL);
+	}
+}
+
 static void
 nfsd4_create_clid_dir(struct nfs4_client *clp)
 {
 	const struct cred *original_cred;
-	char *dname = clp->cl_recdir;
+	char dname[HEXDIR_LEN];
 	struct dentry *dir, *dentry;
 	struct nfs4_client_reclaim *crp;
 	int status;
@@ -152,6 +183,11 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 		return;
 	if (!rec_file)
 		return;
+
+	status = nfs4_make_rec_clidname(dname, &clp->cl_name);
+	if (status)
+		return legacy_recdir_name_error(status);
+
 	status = nfs4_save_creds(&original_cred);
 	if (status < 0)
 		return;
@@ -186,7 +222,7 @@ out_unlock:
 	mutex_unlock(&dir->d_inode->i_mutex);
 	if (status == 0) {
 		if (in_grace) {
-			crp = nfs4_client_to_reclaim(clp->cl_recdir);
+			crp = nfs4_client_to_reclaim(dname);
 			if (crp)
 				crp->cr_clp = clp;
 		}
@@ -298,11 +334,16 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
 {
 	const struct cred *original_cred;
 	struct nfs4_client_reclaim *crp;
+	char dname[HEXDIR_LEN];
 	int status;
 
 	if (!rec_file || !test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
 		return;
 
+	status = nfs4_make_rec_clidname(dname, &clp->cl_name);
+	if (status)
+		return legacy_recdir_name_error(status);
+
 	status = mnt_want_write_file(rec_file);
 	if (status)
 		goto out;
@@ -312,13 +353,13 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
 	if (status < 0)
 		goto out_drop_write;
 
-	status = nfsd4_unlink_clid_dir(clp->cl_recdir, HEXDIR_LEN-1);
+	status = nfsd4_unlink_clid_dir(dname, HEXDIR_LEN-1);
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
@@ -328,7 +369,7 @@ out_drop_write:
 out:
 	if (status)
 		printk("NFSD: Failed to remove expired client state directory"
-				" %.*s\n", HEXDIR_LEN, clp->cl_recdir);
+				" %.*s\n", HEXDIR_LEN, dname);
 }
 
 static int
@@ -500,14 +541,22 @@ nfs4_recoverydir(void)
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
+	if (status) {
+		legacy_recdir_name_error(status);
+		return status;
+	}
+
 	/* look for it in the reclaim hashtable otherwise */
-	crp = nfsd4_find_reclaim_client(clp->cl_recdir);
+	crp = nfsd4_find_reclaim_client(dname);
 	if (crp) {
 		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
 		crp->cr_clp = clp;
@@ -993,7 +1042,7 @@ nfsd4_cltrack_legacy_topdir(void)
 }
 
 static char *
-nfsd4_cltrack_legacy_recdir(const char *recdir)
+nfsd4_cltrack_legacy_recdir(const struct xdr_netobj *name)
 {
 	int copied;
 	size_t len;
@@ -1010,10 +1059,16 @@ nfsd4_cltrack_legacy_recdir(const char *recdir)
 	if (!result)
 		return result;
 
-	copied = snprintf(result, len, LEGACY_RECDIR_ENV_PREFIX "%s/%s",
-				nfs4_recoverydir(), recdir);
-	if (copied >= len) {
-		/* just return nothing if output was truncated */
+	copied = snprintf(result, len, LEGACY_RECDIR_ENV_PREFIX "%s/",
+				nfs4_recoverydir());
+	if (copied > (len - HEXDIR_LEN)) {
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
@@ -1126,7 +1181,7 @@ nfsd4_umh_cltrack_check(struct nfs4_client *clp)
 		dprintk("%s: can't allocate memory for upcall!\n", __func__);
 		return -ENOMEM;
 	}
-	legacy = nfsd4_cltrack_legacy_recdir(clp->cl_recdir);
+	legacy = nfsd4_cltrack_legacy_recdir(&clp->cl_name);
 	ret = nfsd4_umh_cltrack_upcall("check", hexid, legacy);
 	kfree(legacy);
 	kfree(hexid);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 99998a1..37b19f7 100644
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
@@ -2236,12 +2229,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
@@ -2263,7 +2251,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (unconf)
 		expire_client(unconf);
 	status = nfserr_jukebox;
-	new = create_client(clname, dname, rqstp, &clverifier);
+	new = create_client(clname, rqstp, &clverifier);
 	if (new == NULL)
 		goto out;
 	if (conf && same_verf(&conf->cl_verifier, &clverifier))
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 6c342bd..029217a 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -238,7 +238,6 @@ struct nfs4_client {
 	struct list_head	cl_delegations;
 	struct list_head        cl_lru;         /* tail queue */
 	struct xdr_netobj	cl_name; 	/* id generated by client */
-	char                    cl_recdir[HEXDIR_LEN]; /* recovery dir */
 	nfs4_verifier		cl_verifier; 	/* generated by client */
 	time_t                  cl_time;        /* time of last lease renewal */
 	struct sockaddr_storage	cl_addr; 	/* client ipaddress */
@@ -482,7 +481,6 @@ extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
-extern __be32 nfs4_make_rec_clidname(char *clidname, struct xdr_netobj *clname);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name);
 extern bool nfs4_has_reclaimed_state(const char *name);
 extern void release_session_client(struct nfsd4_session *);
-- 
1.7.11.7

