Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:59461 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069Ab2CUNwR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Mar 2012 09:52:17 -0400
Received: by yenl12 with SMTP id l12so915228yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Mar 2012 06:52:16 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v10 2/8] nfsd: add nfsd4_client_tracking_ops struct and a way to set it
Date: Wed, 21 Mar 2012 09:52:03 -0400
Message-Id: <1332337929-18580-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
References: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Abstract out the mechanism that we use to track clients into a set of
client name tracking functions.

This gives us a mechanism to plug in a new set of client tracking
functions without disturbing the callers. It also gives us a way to
decide on what tracking scheme to use at runtime.

For now, this just looks like pointless abstraction, but later we'll
add a new alternate scheme for tracking clients on stable storage.

Note too that this patch anticipates the eventual containerization
of this code by passing in struct net pointers in places. No attempt
is made to containerize the legacy client tracker however.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c |  136 +++++++++++++++++++++++++++++++++++++++++++++----
 fs/nfsd/nfs4state.c   |   61 +++++++---------------
 fs/nfsd/state.h       |   15 +++--
 3 files changed, 155 insertions(+), 57 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 6523809..e616f88 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -43,9 +43,20 @@
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
+/* Declarations */
+struct nfsd4_client_tracking_ops {
+	int (*init)(struct net *);
+	void (*exit)(struct net *);
+	void (*create)(struct nfs4_client *);
+	void (*remove)(struct nfs4_client *);
+	int (*check)(struct nfs4_client *);
+	void (*grace_done)(struct net *, time_t);
+};
+
 /* Globals */
 static struct file *rec_file;
 static char user_recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
+static struct nfsd4_client_tracking_ops *client_tracking_ops;
 
 static int
 nfs4_save_creds(const struct cred **original_creds)
@@ -117,7 +128,8 @@ out_no_tfm:
 	return status;
 }
 
-void nfsd4_create_clid_dir(struct nfs4_client *clp)
+static void
+nfsd4_create_clid_dir(struct nfs4_client *clp)
 {
 	const struct cred *original_cred;
 	char *dname = clp->cl_recdir;
@@ -264,7 +276,7 @@ out_unlock:
 	return status;
 }
 
-void
+static void
 nfsd4_remove_clid_dir(struct nfs4_client *clp)
 {
 	const struct cred *original_cred;
@@ -291,7 +303,6 @@ out:
 	if (status)
 		printk("NFSD: Failed to remove expired client state directory"
 				" %.*s\n", HEXDIR_LEN, clp->cl_recdir);
-	return;
 }
 
 static int
@@ -310,8 +321,9 @@ purge_old(struct dentry *parent, struct dentry *child)
 	return 0;
 }
 
-void
-nfsd4_recdir_purge_old(void) {
+static void
+nfsd4_recdir_purge_old(struct net *net, time_t boot_time)
+{
 	int status;
 
 	if (!rec_file)
@@ -342,7 +354,7 @@ load_recdir(struct dentry *parent, struct dentry *child)
 	return 0;
 }
 
-int
+static int
 nfsd4_recdir_load(void) {
 	int status;
 
@@ -360,8 +372,8 @@ nfsd4_recdir_load(void) {
  * Hold reference to the recovery directory.
  */
 
-void
-nfsd4_init_recdir()
+static int
+nfsd4_init_recdir(void)
 {
 	const struct cred *original_cred;
 	int status;
@@ -376,20 +388,37 @@ nfsd4_init_recdir()
 		printk("NFSD: Unable to change credentials to find recovery"
 		       " directory: error %d\n",
 		       status);
-		return;
+		return status;
 	}
 
 	rec_file = filp_open(user_recovery_dirname, O_RDONLY | O_DIRECTORY, 0);
 	if (IS_ERR(rec_file)) {
 		printk("NFSD: unable to find recovery directory %s\n",
 				user_recovery_dirname);
+		status = PTR_ERR(rec_file);
 		rec_file = NULL;
 	}
 
 	nfs4_reset_creds(original_cred);
+	return status;
 }
 
-void
+static int
+nfsd4_load_reboot_recovery_data(struct net *net)
+{
+	int status;
+
+	nfs4_lock_state();
+	status = nfsd4_init_recdir();
+	if (!status)
+		status = nfsd4_recdir_load();
+	nfs4_unlock_state();
+	if (status)
+		printk(KERN_ERR "NFSD: Failure reading reboot recovery data\n");
+	return status;
+}
+
+static void
 nfsd4_shutdown_recdir(void)
 {
 	if (!rec_file)
@@ -398,6 +427,13 @@ nfsd4_shutdown_recdir(void)
 	rec_file = NULL;
 }
 
+static void
+nfsd4_legacy_tracking_exit(struct net *net)
+{
+	nfs4_release_reclaim();
+	nfsd4_shutdown_recdir();
+}
+
 /*
  * Change the NFSv4 recovery directory to recdir.
  */
@@ -424,3 +460,83 @@ nfs4_recoverydir(void)
 {
 	return user_recovery_dirname;
 }
+
+static int
+nfsd4_check_legacy_client(struct nfs4_client *clp)
+{
+	/* did we already find that this client is stable? */
+	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
+		return 0;
+
+	/* look for it in the reclaim hashtable otherwise */
+	if (nfsd4_find_reclaim_client(clp)) {
+		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
+		return 0;
+	}
+
+	return -ENOENT;
+}
+
+static struct nfsd4_client_tracking_ops nfsd4_legacy_tracking_ops = {
+	.init		= nfsd4_load_reboot_recovery_data,
+	.exit		= nfsd4_legacy_tracking_exit,
+	.create		= nfsd4_create_clid_dir,
+	.remove		= nfsd4_remove_clid_dir,
+	.check		= nfsd4_check_legacy_client,
+	.grace_done	= nfsd4_recdir_purge_old,
+};
+
+int
+nfsd4_client_tracking_init(struct net *net)
+{
+	int status;
+
+	client_tracking_ops = &nfsd4_legacy_tracking_ops;
+
+	status = client_tracking_ops->init(net);
+	if (status) {
+		printk(KERN_WARNING "NFSD: Unable to initialize client "
+				    "recovery tracking! (%d)\n", status);
+		client_tracking_ops = NULL;
+	}
+	return status;
+}
+
+void
+nfsd4_client_tracking_exit(struct net *net)
+{
+	if (client_tracking_ops) {
+		client_tracking_ops->exit(net);
+		client_tracking_ops = NULL;
+	}
+}
+
+void
+nfsd4_client_record_create(struct nfs4_client *clp)
+{
+	if (client_tracking_ops)
+		client_tracking_ops->create(clp);
+}
+
+void
+nfsd4_client_record_remove(struct nfs4_client *clp)
+{
+	if (client_tracking_ops)
+		client_tracking_ops->remove(clp);
+}
+
+int
+nfsd4_client_record_check(struct nfs4_client *clp)
+{
+	if (client_tracking_ops)
+		return client_tracking_ops->check(clp);
+
+	return -EOPNOTSUPP;
+}
+
+void
+nfsd4_record_grace_done(struct net *net, time_t boot_time)
+{
+	if (client_tracking_ops)
+		client_tracking_ops->grace_done(net, boot_time);
+}
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 534f82f1..fc65412 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2046,7 +2046,7 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 		goto out;
 
 	status = nfs_ok;
-	nfsd4_create_clid_dir(cstate->session->se_client);
+	nfsd4_client_record_create(cstate->session->se_client);
 out:
 	nfs4_unlock_state();
 	return status;
@@ -2241,7 +2241,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			conf = find_confirmed_client_by_str(unconf->cl_recdir,
 							    hash);
 			if (conf) {
-				nfsd4_remove_clid_dir(conf);
+				nfsd4_client_record_remove(conf);
 				expire_client(conf);
 			}
 			move_to_confirmed(unconf);
@@ -3066,7 +3066,7 @@ static void
 nfsd4_end_grace(void)
 {
 	dprintk("NFSD: end of grace period\n");
-	nfsd4_recdir_purge_old();
+	nfsd4_record_grace_done(&init_net, boot_time);
 	locks_end_grace(&nfsd4_manager);
 	/*
 	 * Now that every NFSv4 client has had the chance to recover and
@@ -3115,7 +3115,7 @@ nfs4_laundromat(void)
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 		dprintk("NFSD: purging unused client (clientid %08x)\n",
 			clp->cl_clientid.cl_id);
-		nfsd4_remove_clid_dir(clp);
+		nfsd4_client_record_remove(clp);
 		expire_client(clp);
 	}
 	spin_lock(&recall_lock);
@@ -3539,7 +3539,7 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	dprintk("NFSD: %s: success, seqid=%d stateid=" STATEID_FMT "\n",
 		__func__, oc->oc_seqid, STATEID_VAL(&stp->st_stid.sc_stateid));
 
-	nfsd4_create_clid_dir(oo->oo_owner.so_client);
+	nfsd4_client_record_create(oo->oo_owner.so_client);
 	status = nfs_ok;
 out:
 	if (!cstate->replay_owner)
@@ -4379,7 +4379,7 @@ nfs4_client_to_reclaim(const char *name)
 	return 1;
 }
 
-static void
+void
 nfs4_release_reclaim(void)
 {
 	struct nfs4_client_reclaim *crp = NULL;
@@ -4399,7 +4399,7 @@ nfs4_release_reclaim(void)
 
 /*
  * called from OPEN, CLAIM_PREVIOUS with a new clientid. */
-static struct nfs4_client_reclaim *
+struct nfs4_client_reclaim *
 nfsd4_find_reclaim_client(struct nfs4_client *clp)
 {
 	unsigned int strhashval;
@@ -4419,22 +4419,6 @@ nfsd4_find_reclaim_client(struct nfs4_client *clp)
 	return NULL;
 }
 
-static int
-nfsd4_client_record_check(struct nfs4_client *clp)
-{
-	/* did we already find that this client is stable? */
-	if (test_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags))
-		return 0;
-
-	/* look for it in the reclaim hashtable otherwise */
-	if (nfsd4_find_reclaim_client(clp)) {
-		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
-		return 0;
-	}
-
-	return -ENOENT;
-}
-
 /*
 * Called from OPEN. Look for clientid in reclaim list.
 */
@@ -4595,19 +4579,6 @@ nfs4_state_init(void)
 	reclaim_str_hashtbl_size = 0;
 }
 
-static void
-nfsd4_load_reboot_recovery_data(void)
-{
-	int status;
-
-	nfs4_lock_state();
-	nfsd4_init_recdir();
-	status = nfsd4_recdir_load();
-	nfs4_unlock_state();
-	if (status)
-		printk("NFSD: Failure reading reboot recovery data\n");
-}
-
 /*
  * Since the lifetime of a delegation isn't limited to that of an open, a
  * client may quite reasonably hang on to a delegation as long as it has
@@ -4636,7 +4607,15 @@ nfs4_state_start(void)
 {
 	int ret;
 
-	nfsd4_load_reboot_recovery_data();
+	/*
+	 * FIXME: For now, we hang most of the pernet global stuff off of
+	 * init_net until nfsd is fully containerized. Eventually, we'll
+	 * need to pass a net pointer into this function, take a reference
+	 * to that instead and then do most of the rest of this on a per-net
+	 * basis.
+	 */
+	get_net(&init_net);
+	nfsd4_client_tracking_init(&init_net);
 	boot_time = get_seconds();
 	locks_start_grace(&nfsd4_manager);
 	printk(KERN_INFO "NFSD: starting %ld-second grace period\n",
@@ -4660,8 +4639,8 @@ nfs4_state_start(void)
 out_free_laundry:
 	destroy_workqueue(laundry_wq);
 out_recovery:
-	nfs4_release_reclaim();
-	nfsd4_shutdown_recdir();
+	nfsd4_client_tracking_exit(&init_net);
+	put_net(&init_net);
 	return ret;
 }
 
@@ -4695,7 +4674,8 @@ __nfs4_state_shutdown(void)
 		unhash_delegation(dp);
 	}
 
-	nfsd4_shutdown_recdir();
+	nfsd4_client_tracking_exit(&init_net);
+	put_net(&init_net);
 }
 
 void
@@ -4705,7 +4685,6 @@ nfs4_state_shutdown(void)
 	destroy_workqueue(laundry_wq);
 	locks_end_grace(&nfsd4_manager);
 	nfs4_lock_state();
-	nfs4_release_reclaim();
 	__nfs4_state_shutdown();
 	nfs4_unlock_state();
 	nfsd4_destroy_callback_queue();
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index b9c036d..a9ab5e0 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -466,6 +466,8 @@ extern __be32 nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 extern void nfs4_lock_state(void);
 extern void nfs4_unlock_state(void);
 extern int nfs4_in_grace(void);
+extern void nfs4_release_reclaim(void);
+extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(struct nfs4_client *crp);
 extern __be32 nfs4_check_open_reclaim(clientid_t *clid);
 extern void nfs4_free_openowner(struct nfs4_openowner *);
 extern void nfs4_free_lockowner(struct nfs4_lockowner *);
@@ -480,16 +482,17 @@ extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern __be32 nfs4_make_rec_clidname(char *clidname, struct xdr_netobj *clname);
-extern void nfsd4_init_recdir(void);
-extern int nfsd4_recdir_load(void);
-extern void nfsd4_shutdown_recdir(void);
 extern int nfs4_client_to_reclaim(const char *name);
 extern int nfs4_has_reclaimed_state(const char *name, bool use_exchange_id);
-extern void nfsd4_recdir_purge_old(void);
-extern void nfsd4_create_clid_dir(struct nfs4_client *clp);
-extern void nfsd4_remove_clid_dir(struct nfs4_client *clp);
 extern void release_session_client(struct nfsd4_session *);
 extern __be32 nfs4_validate_stateid(struct nfs4_client *, stateid_t *);
 extern void nfsd4_purge_closed_stateid(struct nfs4_stateowner *);
 
+/* nfs4recover operations */
+extern int nfsd4_client_tracking_init(struct net *net);
+extern void nfsd4_client_tracking_exit(struct net *net);
+extern void nfsd4_client_record_create(struct nfs4_client *clp);
+extern void nfsd4_client_record_remove(struct nfs4_client *clp);
+extern int nfsd4_client_record_check(struct nfs4_client *clp);
+extern void nfsd4_record_grace_done(struct net *net, time_t boot_time);
 #endif   /* NFSD4_STATE_H */
-- 
1.7.7.6

