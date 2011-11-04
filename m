Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42705 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755845Ab1KDQEl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 12:04:41 -0400
Date: Fri, 4 Nov 2011 12:04:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: stable@kernel.org
Cc: linux-nfs@vger.kernel.org, bharrosh@panasas.com
Subject: Re: nfsd (and lock) changes for 3.2
Message-ID: <20111104160439.GA32756@fieldses.org>
References: <20111025121924.GA15662@fieldses.org>
 <4EA77B78.6080706@panasas.com>
 <20111027203412.GB31669@fieldses.org>
 <4EA9F5E8.6060900@panasas.com>
 <20111028144252.GB5798@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111028144252.GB5798@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz points out that I forgot to add stable cc's to two commits:

	48483bf23a568f3ef4cc7ad2c8f1a082f10ad0e7 "nfsd4: simplify recovery dir setting"
	6577aac01f00636c16cd583c30bd4dedf18475d5 "nfsd4: fix failure to
	end nfsd4 grace period"

which fix a regression introduced by
ab1350b2b3c1dd2e465a6abdda608d8c44facfb8 "nfsd41: Deny new lock before
RECLAIM_COMPLETE done" (first included in v3.1-rc1).

Included below for reference, but I assume simplest for you will be to
cherry-pick the above two sha1's.

Thanks!

--b.

commit 6577aac01f00636c16cd583c30bd4dedf18475d5
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Fri Aug 12 17:30:12 2011 -0700

    nfsd4: fix failure to end nfsd4 grace period
    
    Even if we fail to write a recovery record, we should still mark the
    client as having acquired its first state.  Otherwise we leave 4.1
    clients with indefinite ERR_GRACE returns.
    
    However, an inability to write stable storage records may cause failures
    of reboot recovery, and the problem should still be brought to the
    server administrator's attention.
    
    So, make sure the error is logged.
    
    These errors shouldn't normally be triggered on a corectly functioning
    server--this isn't a case where a misconfigured client could spam the
    logs.
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index c346661..493851b 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -130,6 +130,7 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 	if (!rec_file || clp->cl_firststate)
 		return 0;
 
+	clp->cl_firststate = 1;
 	status = nfs4_save_creds(&original_cred);
 	if (status < 0)
 		return status;
@@ -144,10 +145,8 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 		goto out_unlock;
 	}
 	status = -EEXIST;
-	if (dentry->d_inode) {
-		dprintk("NFSD: nfsd4_create_clid_dir: DIRECTORY EXISTS\n");
+	if (dentry->d_inode)
 		goto out_put;
-	}
 	status = mnt_want_write(rec_file->f_path.mnt);
 	if (status)
 		goto out_put;
@@ -157,12 +156,14 @@ out_put:
 	dput(dentry);
 out_unlock:
 	mutex_unlock(&dir->d_inode->i_mutex);
-	if (status == 0) {
-		clp->cl_firststate = 1;
+	if (status == 0)
 		vfs_fsync(rec_file, 0);
-	}
+	else
+		printk(KERN_ERR "NFSD: failed to write recovery record"
+				" (err %d); please check that %s exists"
+				" and is writeable", status,
+				user_recovery_dirname);
 	nfs4_reset_creds(original_cred);
-	dprintk("NFSD: nfsd4_create_clid_dir returns %d\n", status);
 	return status;
 }
 

commit 48483bf23a568f3ef4cc7ad2c8f1a082f10ad0e7
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Aug 26 20:40:28 2011 -0400

    nfsd4: simplify recovery dir setting
    
    Move around some of this code, simplify a bit.
    
    Reviewed-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 29d77f6..c346661 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -45,6 +45,7 @@
 
 /* Globals */
 static struct file *rec_file;
+static char user_recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
 
 static int
 nfs4_save_creds(const struct cred **original_creds)
@@ -354,13 +355,13 @@ nfsd4_recdir_load(void) {
  */
 
 void
-nfsd4_init_recdir(char *rec_dirname)
+nfsd4_init_recdir()
 {
 	const struct cred *original_cred;
 	int status;
 
 	printk("NFSD: Using %s as the NFSv4 state recovery directory\n",
-			rec_dirname);
+			user_recovery_dirname);
 
 	BUG_ON(rec_file);
 
@@ -372,10 +373,10 @@ nfsd4_init_recdir(char *rec_dirname)
 		return;
 	}
 
-	rec_file = filp_open(rec_dirname, O_RDONLY | O_DIRECTORY, 0);
+	rec_file = filp_open(user_recovery_dirname, O_RDONLY | O_DIRECTORY, 0);
 	if (IS_ERR(rec_file)) {
 		printk("NFSD: unable to find recovery directory %s\n",
-				rec_dirname);
+				user_recovery_dirname);
 		rec_file = NULL;
 	}
 
@@ -390,3 +391,30 @@ nfsd4_shutdown_recdir(void)
 	fput(rec_file);
 	rec_file = NULL;
 }
+
+/*
+ * Change the NFSv4 recovery directory to recdir.
+ */
+int
+nfs4_reset_recoverydir(char *recdir)
+{
+	int status;
+	struct path path;
+
+	status = kern_path(recdir, LOOKUP_FOLLOW, &path);
+	if (status)
+		return status;
+	status = -ENOTDIR;
+	if (S_ISDIR(path.dentry->d_inode->i_mode)) {
+		strcpy(user_recovery_dirname, recdir);
+		status = 0;
+	}
+	path_put(&path);
+	return status;
+}
+
+char *
+nfs4_recoverydir(void)
+{
+	return user_recovery_dirname;
+}
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index aa0a36e..36d0beb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -64,8 +64,6 @@ static struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
 static struct nfs4_stateid * search_for_stateid(stateid_t *stid);
 static struct nfs4_delegation * search_for_delegation(stateid_t *stid);
 static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
-static char user_recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
-static void nfs4_set_recdir(char *recdir);
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_stateowner *lowner);
 
 /* Locking: */
@@ -4523,7 +4521,7 @@ nfsd4_load_reboot_recovery_data(void)
 	int status;
 
 	nfs4_lock_state();
-	nfsd4_init_recdir(user_recovery_dirname);
+	nfsd4_init_recdir();
 	status = nfsd4_recdir_load();
 	nfs4_unlock_state();
 	if (status)
@@ -4632,40 +4630,3 @@ nfs4_state_shutdown(void)
 	nfs4_unlock_state();
 	nfsd4_destroy_callback_queue();
 }
-
-/*
- * user_recovery_dirname is protected by the nfsd_mutex since it's only
- * accessed when nfsd is starting.
- */
-static void
-nfs4_set_recdir(char *recdir)
-{
-	strcpy(user_recovery_dirname, recdir);
-}
-
-/*
- * Change the NFSv4 recovery directory to recdir.
- */
-int
-nfs4_reset_recoverydir(char *recdir)
-{
-	int status;
-	struct path path;
-
-	status = kern_path(recdir, LOOKUP_FOLLOW, &path);
-	if (status)
-		return status;
-	status = -ENOTDIR;
-	if (S_ISDIR(path.dentry->d_inode->i_mode)) {
-		nfs4_set_recdir(recdir);
-		status = 0;
-	}
-	path_put(&path);
-	return status;
-}
-
-char *
-nfs4_recoverydir(void)
-{
-	return user_recovery_dirname;
-}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 5cfebe5..12c1b1e 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -467,7 +467,7 @@ extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern __be32 nfs4_make_rec_clidname(char *clidname, struct xdr_netobj *clname);
-extern void nfsd4_init_recdir(char *recdir_name);
+extern void nfsd4_init_recdir(void);
 extern int nfsd4_recdir_load(void);
 extern void nfsd4_shutdown_recdir(void);
 extern int nfs4_client_to_reclaim(const char *name);
