Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35977 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752920Ab1H0ArL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 20:47:11 -0400
Date: Fri, 26 Aug 2011 20:47:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] nfsd4: simplify recovery dir setting ++
Message-ID: <20110827004708.GA19967@fieldses.org>
References: <4E45C594.1030609@panasas.com>
 <20110826201910.GB17196@fieldses.org>
 <4E5838E0.4090703@panasas.com>
 <20110827004618.GG18699@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110827004618.GG18699@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

Move around some of this code, simplify a bit.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4recover.c |   36 ++++++++++++++++++++++++++++++++----
 fs/nfsd/nfs4state.c   |   41 +----------------------------------------
 fs/nfsd/state.h       |    2 +-
 3 files changed, 34 insertions(+), 45 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 02eb38e..3e6ebcf 100644
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
index f71d73c..05e3f85 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -63,8 +63,6 @@ static u64 current_sessionid = 1;
 static struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
 static struct nfs4_delegation * search_for_delegation(stateid_t *stid);
 static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
-static char user_recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
-static void nfs4_set_recdir(char *recdir);
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
 
 /* Locking: */
@@ -4475,7 +4473,7 @@ nfsd4_load_reboot_recovery_data(void)
 	int status;
 
 	nfs4_lock_state();
-	nfsd4_init_recdir(user_recovery_dirname);
+	nfsd4_init_recdir();
 	status = nfsd4_recdir_load();
 	nfs4_unlock_state();
 	if (status)
@@ -4584,40 +4582,3 @@ nfs4_state_shutdown(void)
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
index 1f90cab..66179ac 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -493,7 +493,7 @@ extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern __be32 nfs4_make_rec_clidname(char *clidname, struct xdr_netobj *clname);
-extern void nfsd4_init_recdir(char *recdir_name);
+extern void nfsd4_init_recdir(void);
 extern int nfsd4_recdir_load(void);
 extern void nfsd4_shutdown_recdir(void);
 extern int nfs4_client_to_reclaim(const char *name);
-- 
1.7.4.1

