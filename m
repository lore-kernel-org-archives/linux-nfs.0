Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:25745 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964821Ab2KNPSm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Nov 2012 10:18:42 -0500
Subject: [PATCH v2 03/15] nfsd: make reclaim_str_hashtbl allocated per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Wed, 14 Nov 2012 18:21:16 +0300
Message-ID: <20121114152116.4708.81886.stgit@localhost.localdomain>
In-Reply-To: <20121114152018.4708.63125.stgit@localhost.localdomain>
References: <20121114152018.4708.63125.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This hash holds nfs4_clients info, which are network namespace aware.
So let's make it allocated per network namespace.

Note: this hash is used only by legacy tracker. So let's allocate hash in
tracker init.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h       |   12 ++++++
 fs/nfsd/nfs4recover.c |  100 ++++++++++++++++++++++++++++++++++++++-----------
 fs/nfsd/nfs4state.c   |   42 +++++++--------------
 fs/nfsd/state.h       |   12 +++---
 4 files changed, 111 insertions(+), 55 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 65c2431..49e5479 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -24,6 +24,11 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
+/* Hash tables for nfs4_clientid state */
+#define CLIENT_HASH_BITS                 4
+#define CLIENT_HASH_SIZE                (1 << CLIENT_HASH_BITS)
+#define CLIENT_HASH_MASK                (CLIENT_HASH_SIZE - 1)
+
 struct cld_net;
 
 struct nfsd_net {
@@ -38,6 +43,13 @@ struct nfsd_net {
 	struct lock_manager nfsd4_manager;
 	bool grace_ended;
 	time_t boot_time;
+
+	/*
+	 * reclaim_str_hashtbl[] holds known client info from previous reset/reboot
+	 * used in reboot/reset lease grace period processing
+	 */
+	struct list_head *reclaim_str_hashtbl;
+	int reclaim_str_hashtbl_size;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 9881bca..376692a 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -176,6 +176,7 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 	struct dentry *dir, *dentry;
 	struct nfs4_client_reclaim *crp;
 	int status;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
 	dprintk("NFSD: nfsd4_create_clid_dir for \"%s\"\n", dname);
 
@@ -222,7 +223,7 @@ out_unlock:
 	mutex_unlock(&dir->d_inode->i_mutex);
 	if (status == 0) {
 		if (in_grace) {
-			crp = nfs4_client_to_reclaim(dname);
+			crp = nfs4_client_to_reclaim(dname, nn);
 			if (crp)
 				crp->cr_clp = clp;
 		}
@@ -237,7 +238,7 @@ out_unlock:
 	nfs4_reset_creds(original_cred);
 }
 
-typedef int (recdir_func)(struct dentry *, struct dentry *);
+typedef int (recdir_func)(struct dentry *, struct dentry *, struct nfsd_net *);
 
 struct name_list {
 	char name[HEXDIR_LEN];
@@ -263,7 +264,7 @@ nfsd4_build_namelist(void *arg, const char *name, int namlen,
 }
 
 static int
-nfsd4_list_rec_dir(recdir_func *f)
+nfsd4_list_rec_dir(recdir_func *f, struct nfsd_net *nn)
 {
 	const struct cred *original_cred;
 	struct dentry *dir = rec_file->f_path.dentry;
@@ -292,7 +293,7 @@ nfsd4_list_rec_dir(recdir_func *f)
 				status = PTR_ERR(dentry);
 				break;
 			}
-			status = f(dir, dentry);
+			status = f(dir, dentry, nn);
 			dput(dentry);
 		}
 		list_del(&entry->list);
@@ -336,6 +337,7 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
 	struct nfs4_client_reclaim *crp;
 	char dname[HEXDIR_LEN];
 	int status;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
 	if (!rec_file || !test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
 		return;
@@ -359,9 +361,9 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
 		vfs_fsync(rec_file, 0);
 		if (in_grace) {
 			/* remove reclaim record */
-			crp = nfsd4_find_reclaim_client(dname);
+			crp = nfsd4_find_reclaim_client(dname, nn);
 			if (crp)
-				nfs4_remove_reclaim_record(crp);
+				nfs4_remove_reclaim_record(crp, nn);
 		}
 	}
 out_drop_write:
@@ -373,11 +375,11 @@ out:
 }
 
 static int
-purge_old(struct dentry *parent, struct dentry *child)
+purge_old(struct dentry *parent, struct dentry *child, struct nfsd_net *nn)
 {
 	int status;
 
-	if (nfs4_has_reclaimed_state(child->d_name.name))
+	if (nfs4_has_reclaimed_state(child->d_name.name, nn))
 		return 0;
 
 	status = vfs_rmdir(parent->d_inode, child);
@@ -392,6 +394,7 @@ static void
 nfsd4_recdir_purge_old(struct net *net, time_t boot_time)
 {
 	int status;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	in_grace = false;
 	if (!rec_file)
@@ -399,19 +402,19 @@ nfsd4_recdir_purge_old(struct net *net, time_t boot_time)
 	status = mnt_want_write_file(rec_file);
 	if (status)
 		goto out;
-	status = nfsd4_list_rec_dir(purge_old);
+	status = nfsd4_list_rec_dir(purge_old, nn);
 	if (status == 0)
 		vfs_fsync(rec_file, 0);
 	mnt_drop_write_file(rec_file);
 out:
-	nfs4_release_reclaim();
+	nfs4_release_reclaim(nn);
 	if (status)
 		printk("nfsd4: failed to purge old clients from recovery"
 			" directory %s\n", rec_file->f_path.dentry->d_name.name);
 }
 
 static int
-load_recdir(struct dentry *parent, struct dentry *child)
+load_recdir(struct dentry *parent, struct dentry *child, struct nfsd_net *nn)
 {
 	if (child->d_name.len != HEXDIR_LEN - 1) {
 		printk("nfsd4: illegal name %s in recovery directory\n",
@@ -419,18 +422,19 @@ load_recdir(struct dentry *parent, struct dentry *child)
 		/* Keep trying; maybe the others are OK: */
 		return 0;
 	}
-	nfs4_client_to_reclaim(child->d_name.name);
+	nfs4_client_to_reclaim(child->d_name.name, nn);
 	return 0;
 }
 
 static int
-nfsd4_recdir_load(void) {
+nfsd4_recdir_load(struct net *net) {
 	int status;
+	struct nfsd_net *nn =  net_generic(net, nfsd_net_id);
 
 	if (!rec_file)
 		return 0;
 
-	status = nfsd4_list_rec_dir(load_recdir);
+	status = nfsd4_list_rec_dir(load_recdir, nn);
 	if (status)
 		printk("nfsd4: failed loading clients from recovery"
 			" directory %s\n", rec_file->f_path.dentry->d_name.name);
@@ -474,11 +478,53 @@ nfsd4_init_recdir(void)
 	return status;
 }
 
+
+static int
+nfs4_legacy_state_init(struct net *net)
+{
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	int i;
+
+	nn->reclaim_str_hashtbl = kmalloc(sizeof(struct list_head) *
+					  CLIENT_HASH_SIZE, GFP_KERNEL);
+	if (!nn->reclaim_str_hashtbl)
+		return -ENOMEM;
+
+	for (i = 0; i < CLIENT_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&nn->reclaim_str_hashtbl[i]);
+	nn->reclaim_str_hashtbl_size = 0;
+
+	return 0;
+}
+
+static void
+nfs4_legacy_state_shutdown(struct net *net)
+{
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
+	kfree(nn->reclaim_str_hashtbl);
+}
+
 static int
 nfsd4_load_reboot_recovery_data(struct net *net)
 {
 	int status;
 
+	nfs4_lock_state();
+	status = nfsd4_init_recdir();
+	if (!status)
+		status = nfsd4_recdir_load(net);
+	nfs4_unlock_state();
+	if (status)
+		printk(KERN_ERR "NFSD: Failure reading reboot recovery data\n");
+	return status;
+}
+
+static int
+nfsd4_legacy_tracking_init(struct net *net)
+{
+	int status;
+
 	/* XXX: The legacy code won't work in a container */
 	if (net != &init_net) {
 		WARN(1, KERN_ERR "NFSD: attempt to initialize legacy client "
@@ -486,13 +532,17 @@ nfsd4_load_reboot_recovery_data(struct net *net)
 		return -EINVAL;
 	}
 
-	nfs4_lock_state();
-	status = nfsd4_init_recdir();
-	if (!status)
-		status = nfsd4_recdir_load();
-	nfs4_unlock_state();
+	status = nfs4_legacy_state_init(net);
 	if (status)
-		printk(KERN_ERR "NFSD: Failure reading reboot recovery data\n");
+		return status;
+
+	status = nfsd4_load_reboot_recovery_data(net);
+	if (status)
+		goto err;
+	return 0;
+
+err:
+	nfs4_legacy_state_shutdown(net);
 	return status;
 }
 
@@ -508,8 +558,11 @@ nfsd4_shutdown_recdir(void)
 static void
 nfsd4_legacy_tracking_exit(struct net *net)
 {
-	nfs4_release_reclaim();
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
+	nfs4_release_reclaim(nn);
 	nfsd4_shutdown_recdir();
+	nfs4_legacy_state_shutdown(net);
 }
 
 /*
@@ -545,6 +598,7 @@ nfsd4_check_legacy_client(struct nfs4_client *clp)
 	int status;
 	char dname[HEXDIR_LEN];
 	struct nfs4_client_reclaim *crp;
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
 	/* did we already find that this client is stable? */
 	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
@@ -557,7 +611,7 @@ nfsd4_check_legacy_client(struct nfs4_client *clp)
 	}
 
 	/* look for it in the reclaim hashtable otherwise */
-	crp = nfsd4_find_reclaim_client(dname);
+	crp = nfsd4_find_reclaim_client(dname, nn);
 	if (crp) {
 		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
 		crp->cr_clp = clp;
@@ -568,7 +622,7 @@ nfsd4_check_legacy_client(struct nfs4_client *clp)
 }
 
 static struct nfsd4_client_tracking_ops nfsd4_legacy_tracking_ops = {
-	.init		= nfsd4_load_reboot_recovery_data,
+	.init		= nfsd4_legacy_tracking_init,
 	.exit		= nfsd4_legacy_tracking_exit,
 	.create		= nfsd4_create_clid_dir,
 	.remove		= nfsd4_remove_clid_dir,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9b4df00..58b4870 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -393,11 +393,6 @@ unhash_delegation(struct nfs4_delegation *dp)
 /* client_lock protects the client lru list and session hash table */
 static DEFINE_SPINLOCK(client_lock);
 
-/* Hash tables for nfs4_clientid state */
-#define CLIENT_HASH_BITS                 4
-#define CLIENT_HASH_SIZE                (1 << CLIENT_HASH_BITS)
-#define CLIENT_HASH_MASK                (CLIENT_HASH_SIZE - 1)
-
 static unsigned int clientid_hashval(u32 id)
 {
 	return id & CLIENT_HASH_MASK;
@@ -409,11 +404,8 @@ static unsigned int clientstr_hashval(const char *name)
 }
 
 /*
- * reclaim_str_hashtbl[] holds known client info from previous reset/reboot
- * used in reboot/reset lease grace period processing
- *
  * conf_id_hashtbl[], and conf_name_tree hold confirmed
- * setclientid_confirmed info. 
+ * setclientid_confirmed info.
  *
  * unconf_id_hashtbl[] and unconf_name_tree hold unconfirmed
  * setclientid info.
@@ -426,8 +418,6 @@ static unsigned int clientstr_hashval(const char *name)
  *
  * All of the above fields are protected by the client_mutex.
  */
-static struct list_head	reclaim_str_hashtbl[CLIENT_HASH_SIZE];
-static int reclaim_str_hashtbl_size = 0;
 static struct list_head	conf_id_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head	unconf_id_hashtbl[CLIENT_HASH_SIZE];
 static struct rb_root conf_name_tree;
@@ -4509,11 +4499,11 @@ alloc_reclaim(void)
 }
 
 bool
-nfs4_has_reclaimed_state(const char *name)
+nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn)
 {
 	struct nfs4_client_reclaim *crp;
 
-	crp = nfsd4_find_reclaim_client(name);
+	crp = nfsd4_find_reclaim_client(name, nn);
 	return (crp && crp->cr_clp);
 }
 
@@ -4521,7 +4511,7 @@ nfs4_has_reclaimed_state(const char *name)
  * failure => all reset bets are off, nfserr_no_grace...
  */
 struct nfs4_client_reclaim *
-nfs4_client_to_reclaim(const char *name)
+nfs4_client_to_reclaim(const char *name, struct nfsd_net *nn)
 {
 	unsigned int strhashval;
 	struct nfs4_client_reclaim *crp;
@@ -4531,42 +4521,42 @@ nfs4_client_to_reclaim(const char *name)
 	if (crp) {
 		strhashval = clientstr_hashval(name);
 		INIT_LIST_HEAD(&crp->cr_strhash);
-		list_add(&crp->cr_strhash, &reclaim_str_hashtbl[strhashval]);
+		list_add(&crp->cr_strhash, &nn->reclaim_str_hashtbl[strhashval]);
 		memcpy(crp->cr_recdir, name, HEXDIR_LEN);
 		crp->cr_clp = NULL;
-		reclaim_str_hashtbl_size++;
+		nn->reclaim_str_hashtbl_size++;
 	}
 	return crp;
 }
 
 void
-nfs4_remove_reclaim_record(struct nfs4_client_reclaim *crp)
+nfs4_remove_reclaim_record(struct nfs4_client_reclaim *crp, struct nfsd_net *nn)
 {
 	list_del(&crp->cr_strhash);
 	kfree(crp);
-	reclaim_str_hashtbl_size--;
+	nn->reclaim_str_hashtbl_size--;
 }
 
 void
-nfs4_release_reclaim(void)
+nfs4_release_reclaim(struct nfsd_net *nn)
 {
 	struct nfs4_client_reclaim *crp = NULL;
 	int i;
 
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
-		while (!list_empty(&reclaim_str_hashtbl[i])) {
-			crp = list_entry(reclaim_str_hashtbl[i].next,
+		while (!list_empty(&nn->reclaim_str_hashtbl[i])) {
+			crp = list_entry(nn->reclaim_str_hashtbl[i].next,
 			                struct nfs4_client_reclaim, cr_strhash);
-			nfs4_remove_reclaim_record(crp);
+			nfs4_remove_reclaim_record(crp, nn);
 		}
 	}
-	BUG_ON(reclaim_str_hashtbl_size);
+	BUG_ON(nn->reclaim_str_hashtbl_size);
 }
 
 /*
  * called from OPEN, CLAIM_PREVIOUS with a new clientid. */
 struct nfs4_client_reclaim *
-nfsd4_find_reclaim_client(const char *recdir)
+nfsd4_find_reclaim_client(const char *recdir, struct nfsd_net *nn)
 {
 	unsigned int strhashval;
 	struct nfs4_client_reclaim *crp = NULL;
@@ -4574,7 +4564,7 @@ nfsd4_find_reclaim_client(const char *recdir)
 	dprintk("NFSD: nfs4_find_reclaim_client for recdir %s\n", recdir);
 
 	strhashval = clientstr_hashval(recdir);
-	list_for_each_entry(crp, &reclaim_str_hashtbl[strhashval], cr_strhash) {
+	list_for_each_entry(crp, &nn->reclaim_str_hashtbl[strhashval], cr_strhash) {
 		if (same_name(crp->cr_recdir, recdir)) {
 			return crp;
 		}
@@ -4732,7 +4722,6 @@ nfs4_state_init(void)
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&conf_id_hashtbl[i]);
 		INIT_LIST_HEAD(&unconf_id_hashtbl[i]);
-		INIT_LIST_HEAD(&reclaim_str_hashtbl[i]);
 	}
 	conf_name_tree = RB_ROOT;
 	unconf_name_tree = RB_ROOT;
@@ -4749,7 +4738,6 @@ nfs4_state_init(void)
 	INIT_LIST_HEAD(&close_lru);
 	INIT_LIST_HEAD(&client_lru);
 	INIT_LIST_HEAD(&del_recall_lru);
-	reclaim_str_hashtbl_size = 0;
 }
 
 /*
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index ca8ee8c..26a912c 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -466,9 +466,10 @@ extern __be32 nfs4_preprocess_stateid_op(struct net *net,
 		stateid_t *stateid, int flags, struct file **filp);
 extern void nfs4_lock_state(void);
 extern void nfs4_unlock_state(void);
-void nfs4_remove_reclaim_record(struct nfs4_client_reclaim *);
-extern void nfs4_release_reclaim(void);
-extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir);
+void nfs4_remove_reclaim_record(struct nfs4_client_reclaim *, struct nfsd_net *);
+extern void nfs4_release_reclaim(struct nfsd_net *);
+extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir,
+							struct nfsd_net *nn);
 extern __be32 nfs4_check_open_reclaim(clientid_t *clid, bool sessions);
 extern void nfs4_free_openowner(struct nfs4_openowner *);
 extern void nfs4_free_lockowner(struct nfs4_lockowner *);
@@ -482,8 +483,9 @@ extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
-extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name);
-extern bool nfs4_has_reclaimed_state(const char *name);
+extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
+							struct nfsd_net *nn);
+extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
 extern void release_session_client(struct nfsd4_session *);
 extern void nfsd4_purge_closed_stateid(struct nfs4_stateowner *);
 

