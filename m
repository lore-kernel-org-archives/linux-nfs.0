Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:45972 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754286Ab2KZNOO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 08:14:14 -0500
Subject: [PATCH 1/2] nfsd: recovery - make rec_file per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 26 Nov 2012 16:16:25 +0300
Message-ID: <20121126131625.8822.10895.stgit@localhost.localdomain>
In-Reply-To: <20121126131404.8822.65870.stgit@localhost.localdomain>
References: <20121126131404.8822.65870.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Opening and closing of this file is done in client tracking init and exit
operations.
Client tracking is done in network namespace context already. So let's make
this file opened and closed per network context - this will simlify it's
management.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h       |    2 +
 fs/nfsd/nfs4recover.c |   70 +++++++++++++++++++++++++------------------------
 2 files changed, 37 insertions(+), 35 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 08d5fa1..1305632 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -84,6 +84,8 @@ struct nfsd_net {
 
 	/* client_lock protects the client lru list and session hash table */
 	spinlock_t client_lock;
+
+	struct file *rec_file;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 651d513..3e76d28 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -62,7 +62,6 @@ struct nfsd4_client_tracking_ops {
 };
 
 /* Globals */
-static struct file *rec_file;
 static char user_recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
 static struct nfsd4_client_tracking_ops *client_tracking_ops;
 static bool in_grace;
@@ -182,7 +181,7 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 
 	if (test_and_set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
 		return;
-	if (!rec_file)
+	if (!nn->rec_file)
 		return;
 
 	status = nfs4_make_rec_clidname(dname, &clp->cl_name);
@@ -193,11 +192,11 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 	if (status < 0)
 		return;
 
-	status = mnt_want_write_file(rec_file);
+	status = mnt_want_write_file(nn->rec_file);
 	if (status)
 		return;
 
-	dir = rec_file->f_path.dentry;
+	dir = nn->rec_file->f_path.dentry;
 	/* lock the parent */
 	mutex_lock(&dir->d_inode->i_mutex);
 
@@ -227,14 +226,14 @@ out_unlock:
 			if (crp)
 				crp->cr_clp = clp;
 		}
-		vfs_fsync(rec_file, 0);
+		vfs_fsync(nn->rec_file, 0);
 	} else {
 		printk(KERN_ERR "NFSD: failed to write recovery record"
 				" (err %d); please check that %s exists"
 				" and is writeable", status,
 				user_recovery_dirname);
 	}
-	mnt_drop_write_file(rec_file);
+	mnt_drop_write_file(nn->rec_file);
 	nfs4_reset_creds(original_cred);
 }
 
@@ -267,7 +266,7 @@ static int
 nfsd4_list_rec_dir(recdir_func *f, struct nfsd_net *nn)
 {
 	const struct cred *original_cred;
-	struct dentry *dir = rec_file->f_path.dentry;
+	struct dentry *dir = nn->rec_file->f_path.dentry;
 	LIST_HEAD(names);
 	int status;
 
@@ -275,13 +274,13 @@ nfsd4_list_rec_dir(recdir_func *f, struct nfsd_net *nn)
 	if (status < 0)
 		return status;
 
-	status = vfs_llseek(rec_file, 0, SEEK_SET);
+	status = vfs_llseek(nn->rec_file, 0, SEEK_SET);
 	if (status < 0) {
 		nfs4_reset_creds(original_cred);
 		return status;
 	}
 
-	status = vfs_readdir(rec_file, nfsd4_build_namelist, &names);
+	status = vfs_readdir(nn->rec_file, nfsd4_build_namelist, &names);
 	mutex_lock_nested(&dir->d_inode->i_mutex, I_MUTEX_PARENT);
 	while (!list_empty(&names)) {
 		struct name_list *entry;
@@ -305,14 +304,14 @@ nfsd4_list_rec_dir(recdir_func *f, struct nfsd_net *nn)
 }
 
 static int
-nfsd4_unlink_clid_dir(char *name, int namlen)
+nfsd4_unlink_clid_dir(char *name, int namlen, struct nfsd_net *nn)
 {
 	struct dentry *dir, *dentry;
 	int status;
 
 	dprintk("NFSD: nfsd4_unlink_clid_dir. name %.*s\n", namlen, name);
 
-	dir = rec_file->f_path.dentry;
+	dir = nn->rec_file->f_path.dentry;
 	mutex_lock_nested(&dir->d_inode->i_mutex, I_MUTEX_PARENT);
 	dentry = lookup_one_len(name, dir, namlen);
 	if (IS_ERR(dentry)) {
@@ -339,14 +338,14 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
 	int status;
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
-	if (!rec_file || !test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
+	if (!nn->rec_file || !test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
 		return;
 
 	status = nfs4_make_rec_clidname(dname, &clp->cl_name);
 	if (status)
 		return legacy_recdir_name_error(status);
 
-	status = mnt_want_write_file(rec_file);
+	status = mnt_want_write_file(nn->rec_file);
 	if (status)
 		goto out;
 	clear_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
@@ -355,10 +354,10 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
 	if (status < 0)
 		goto out_drop_write;
 
-	status = nfsd4_unlink_clid_dir(dname, HEXDIR_LEN-1);
+	status = nfsd4_unlink_clid_dir(dname, HEXDIR_LEN-1, nn);
 	nfs4_reset_creds(original_cred);
 	if (status == 0) {
-		vfs_fsync(rec_file, 0);
+		vfs_fsync(nn->rec_file, 0);
 		if (in_grace) {
 			/* remove reclaim record */
 			crp = nfsd4_find_reclaim_client(dname, nn);
@@ -367,7 +366,7 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
 		}
 	}
 out_drop_write:
-	mnt_drop_write_file(rec_file);
+	mnt_drop_write_file(nn->rec_file);
 out:
 	if (status)
 		printk("NFSD: Failed to remove expired client state directory"
@@ -396,20 +395,20 @@ nfsd4_recdir_purge_old(struct nfsd_net *nn, time_t boot_time)
 	int status;
 
 	in_grace = false;
-	if (!rec_file)
+	if (!nn->rec_file)
 		return;
-	status = mnt_want_write_file(rec_file);
+	status = mnt_want_write_file(nn->rec_file);
 	if (status)
 		goto out;
 	status = nfsd4_list_rec_dir(purge_old, nn);
 	if (status == 0)
-		vfs_fsync(rec_file, 0);
-	mnt_drop_write_file(rec_file);
+		vfs_fsync(nn->rec_file, 0);
+	mnt_drop_write_file(nn->rec_file);
 out:
 	nfs4_release_reclaim(nn);
 	if (status)
 		printk("nfsd4: failed to purge old clients from recovery"
-			" directory %s\n", rec_file->f_path.dentry->d_name.name);
+			" directory %s\n", nn->rec_file->f_path.dentry->d_name.name);
 }
 
 static int
@@ -430,13 +429,13 @@ nfsd4_recdir_load(struct net *net) {
 	int status;
 	struct nfsd_net *nn =  net_generic(net, nfsd_net_id);
 
-	if (!rec_file)
+	if (!nn->rec_file)
 		return 0;
 
 	status = nfsd4_list_rec_dir(load_recdir, nn);
 	if (status)
 		printk("nfsd4: failed loading clients from recovery"
-			" directory %s\n", rec_file->f_path.dentry->d_name.name);
+			" directory %s\n", nn->rec_file->f_path.dentry->d_name.name);
 	return status;
 }
 
@@ -445,15 +444,16 @@ nfsd4_recdir_load(struct net *net) {
  */
 
 static int
-nfsd4_init_recdir(void)
+nfsd4_init_recdir(struct net *net)
 {
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	const struct cred *original_cred;
 	int status;
 
 	printk("NFSD: Using %s as the NFSv4 state recovery directory\n",
 			user_recovery_dirname);
 
-	BUG_ON(rec_file);
+	BUG_ON(nn->rec_file);
 
 	status = nfs4_save_creds(&original_cred);
 	if (status < 0) {
@@ -463,12 +463,12 @@ nfsd4_init_recdir(void)
 		return status;
 	}
 
-	rec_file = filp_open(user_recovery_dirname, O_RDONLY | O_DIRECTORY, 0);
-	if (IS_ERR(rec_file)) {
+	nn->rec_file = filp_open(user_recovery_dirname, O_RDONLY | O_DIRECTORY, 0);
+	if (IS_ERR(nn->rec_file)) {
 		printk("NFSD: unable to find recovery directory %s\n",
 				user_recovery_dirname);
-		status = PTR_ERR(rec_file);
-		rec_file = NULL;
+		status = PTR_ERR(nn->rec_file);
+		nn->rec_file = NULL;
 	}
 
 	nfs4_reset_creds(original_cred);
@@ -509,7 +509,7 @@ nfsd4_load_reboot_recovery_data(struct net *net)
 {
 	int status;
 
-	status = nfsd4_init_recdir();
+	status = nfsd4_init_recdir(net);
 	if (!status)
 		status = nfsd4_recdir_load(net);
 	if (status)
@@ -544,12 +544,12 @@ err:
 }
 
 static void
-nfsd4_shutdown_recdir(void)
+nfsd4_shutdown_recdir(struct nfsd_net *nn)
 {
-	if (!rec_file)
+	if (!nn->rec_file)
 		return;
-	fput(rec_file);
-	rec_file = NULL;
+	fput(nn->rec_file);
+	nn->rec_file = NULL;
 }
 
 static void
@@ -558,7 +558,7 @@ nfsd4_legacy_tracking_exit(struct net *net)
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	nfs4_release_reclaim(nn);
-	nfsd4_shutdown_recdir();
+	nfsd4_shutdown_recdir(nn);
 	nfs4_legacy_state_shutdown(net);
 }
 

