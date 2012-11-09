Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:49177 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755367Ab2KIUHA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Nov 2012 15:07:00 -0500
Received: by mail-yh0-f46.google.com with SMTP id m54so889382yhm.19
        for <linux-nfs@vger.kernel.org>; Fri, 09 Nov 2012 12:06:59 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC 5/7] nfsd: don't search for client by hash on legacy reboot recovery gracedone
Date: Fri,  9 Nov 2012 15:06:42 -0500
Message-Id: <1352491604-21605-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352491604-21605-1-git-send-email-jlayton@redhat.com>
References: <1352491604-21605-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When nfsd starts, the legacy reboot recovery code creates a tracking
struct for each directory in the v4recoverydir. When the grace period
ends, it basically does a "readdir" on the directory again, and matches
each dentry in there to an existing client id to see if it should be
removed or not. If the matching client doesn't exist, or hasn't
reclaimed its state then it will remove that dentry.

This is pretty inefficient since it involves doing a lot of hash-bucket
searching. It also means that we have to keep relying on being able to
search for a nfs4_client by md5 hashed cl_recdir name.

Instead, add a pointer to the nfs4_client that indicates the association
between the nfs4_client_reclaim and nfs4_client. When a reclaim operation
comes in, we set the pointer to make that association. On gracedone, the
legacy client tracker will keep the recdir around iff:

1/ there is a reclaim record for the directory

...and...

2/ there's an association between the reclaim record and a client record
-- that is, a create or check operation was performed on the client that
matches that directory.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c | 31 +++++++++++++++++++++++++++----
 fs/nfsd/nfs4state.c   | 12 +++++-------
 fs/nfsd/state.h       |  4 ++--
 3 files changed, 34 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index df582fa..e010152 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -65,6 +65,7 @@ struct nfsd4_client_tracking_ops {
 static struct file *rec_file;
 static char user_recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
 static struct nfsd4_client_tracking_ops *client_tracking_ops;
+static bool in_grace;
 
 static int
 nfs4_save_creds(const struct cred **original_creds)
@@ -142,6 +143,7 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 	const struct cred *original_cred;
 	char *dname = clp->cl_recdir;
 	struct dentry *dir, *dentry;
+	struct nfs4_client_reclaim *crp;
 	int status;
 
 	dprintk("NFSD: nfsd4_create_clid_dir for \"%s\"\n", dname);
@@ -182,13 +184,19 @@ out_put:
 	dput(dentry);
 out_unlock:
 	mutex_unlock(&dir->d_inode->i_mutex);
-	if (status == 0)
+	if (status == 0) {
+		if (in_grace) {
+			crp = nfs4_client_to_reclaim(clp->cl_recdir);
+			if (crp)
+				crp->cr_clp = clp;
+		}
 		vfs_fsync(rec_file, 0);
-	else
+	} else {
 		printk(KERN_ERR "NFSD: failed to write recovery record"
 				" (err %d); please check that %s exists"
 				" and is writeable", status,
 				user_recovery_dirname);
+	}
 	mnt_drop_write_file(rec_file);
 	nfs4_reset_creds(original_cred);
 }
@@ -289,6 +297,7 @@ static void
 nfsd4_remove_clid_dir(struct nfs4_client *clp)
 {
 	const struct cred *original_cred;
+	struct nfs4_client_reclaim *crp;
 	int status;
 
 	if (!rec_file || !test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
@@ -305,8 +314,15 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
 
 	status = nfsd4_unlink_clid_dir(clp->cl_recdir, HEXDIR_LEN-1);
 	nfs4_reset_creds(original_cred);
-	if (status == 0)
+	if (status == 0) {
 		vfs_fsync(rec_file, 0);
+		if (in_grace) {
+			/* remove reclaim record */
+			crp = nfsd4_find_reclaim_client(clp->cl_recdir);
+			if (crp)
+				nfs4_remove_reclaim_record(crp);
+		}
+	}
 	mnt_drop_write_file(rec_file);
 out:
 	if (status)
@@ -409,6 +425,8 @@ nfsd4_init_recdir(void)
 	}
 
 	nfs4_reset_creds(original_cred);
+	if (!status)
+		in_grace = true;
 	return status;
 }
 
@@ -446,6 +464,7 @@ nfsd4_shutdown_recdir(void)
 static void
 nfsd4_legacy_tracking_exit(struct net *net)
 {
+	in_grace = false;
 	nfs4_release_reclaim();
 	nfsd4_shutdown_recdir();
 }
@@ -480,13 +499,17 @@ nfs4_recoverydir(void)
 static int
 nfsd4_check_legacy_client(struct nfs4_client *clp)
 {
+	struct nfs4_client_reclaim *crp;
+
 	/* did we already find that this client is stable? */
 	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
 		return 0;
 
 	/* look for it in the reclaim hashtable otherwise */
-	if (nfsd4_find_reclaim_client(clp->cl_recdir)) {
+	crp = nfsd4_find_reclaim_client(clp->cl_recdir);
+	if (crp) {
 		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
+		crp->cr_clp = clp;
 		return 0;
 	}
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 23947b3..f26a7e6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4464,16 +4464,13 @@ alloc_reclaim(void)
 	return kmalloc(sizeof(struct nfs4_client_reclaim), GFP_KERNEL);
 }
 
-int
+bool
 nfs4_has_reclaimed_state(const char *name)
 {
-	unsigned int strhashval = clientstr_hashval(name);
-	struct nfs4_client *clp;
+	struct nfs4_client_reclaim *crp;
 
-	clp = find_confirmed_client_by_str(name, strhashval);
-	if (!clp)
-		return 0;
-	return test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
+	crp = nfsd4_find_reclaim_client(name);
+	return (crp && crp->cr_clp);
 }
 
 /*
@@ -4494,6 +4491,7 @@ nfs4_client_to_reclaim(const char *name)
 	list_add(&crp->cr_strhash, &reclaim_str_hashtbl[strhashval]);
 	memcpy(crp->cr_recdir, name, HEXDIR_LEN);
 	reclaim_str_hashtbl_size++;
+	crp->cr_clp = NULL;
 	return crp;
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 7b9e656..e1b39b9 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -292,6 +292,7 @@ is_client_expired(struct nfs4_client *clp)
  */
 struct nfs4_client_reclaim {
 	struct list_head	cr_strhash;	/* hash by cr_name */
+	struct nfs4_client	*cr_clp;	/* pointer to associated clp */
 	char			cr_recdir[HEXDIR_LEN]; /* recover dir */
 };
 
@@ -452,7 +453,6 @@ extern __be32 nfs4_preprocess_stateid_op(struct net *net,
 		stateid_t *stateid, int flags, struct file **filp);
 extern void nfs4_lock_state(void);
 extern void nfs4_unlock_state(void);
-extern int nfs4_in_grace(void);
 void nfs4_remove_reclaim_record(struct nfs4_client_reclaim *);
 extern void nfs4_release_reclaim(void);
 extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir);
@@ -471,7 +471,7 @@ extern void nfsd4_shutdown_callback(struct nfs4_client *);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern __be32 nfs4_make_rec_clidname(char *clidname, struct xdr_netobj *clname);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name);
-extern int nfs4_has_reclaimed_state(const char *name);
+extern bool nfs4_has_reclaimed_state(const char *name);
 extern void release_session_client(struct nfsd4_session *);
 extern void nfsd4_purge_closed_stateid(struct nfs4_stateowner *);
 
-- 
1.7.11.7

