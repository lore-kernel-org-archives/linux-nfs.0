Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:31185 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934066AbdGKQpC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:45:02 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 42/42] NFSD delay the umount after COPY
Date: Tue, 11 Jul 2017 12:44:16 -0400
Message-ID: <20170711164416.1982-43-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After COPY is done, we always unmounted right away. However, if
another copy arrives right after it (ie, large copy that's broken
down into pieces), then we want to save the time of re-establishing
the clientid/session with the source server.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c  | 41 +++++++++++++++++++++++++++++++++++++----
 fs/nfsd/nfs4state.c |  6 ++++++
 fs/nfsd/state.h     |  2 ++
 fs/nfsd/xdr4.h      |  5 +++++
 4 files changed, 50 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 86c20fa..7dbe8df 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -78,6 +78,7 @@
 #endif
 
 static struct workqueue_struct *copy_wq;
+static struct workqueue_struct *umount_wq;
 
 int nfsd4_create_copy_queue(void)
 {
@@ -98,6 +99,19 @@ void nfsd4_shutdown_copy(struct nfs4_client *clp)
 	flush_workqueue(copy_wq);
 }
 
+int nfsd4_create_umount_queue(void)
+{
+	umount_wq = create_singlethread_workqueue("nfsd4_umount");
+	if (!umount_wq)
+		return -ENOMEM;
+	return 0;
+}
+
+void nfsd4_destroy_umount_queue(void)
+{
+	destroy_workqueue(umount_wq);
+}
+
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
 static u32 nfsd_attrmask[] = {
@@ -1211,12 +1225,24 @@ extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
 }
 
 static void
-nfsd4_interssc_disconnect(struct vfsmount *ss_mnt)
+_nfsd4_interssc_disconnect(struct vfsmount *ss_mnt)
 {
 	mntput(ss_mnt);
 	nfs_sb_deactive(ss_mnt->mnt_sb);
 }
 
+static void
+nfsd4_interssc_disconnect(struct work_struct *work)
+{
+	struct delayed_work *dwork = to_delayed_work(work);
+	struct nfsd4_delayed_umount *mount =
+		container_of(dwork, struct nfsd4_delayed_umount, work);
+
+	_nfsd4_interssc_disconnect(mount->ss_mnt);
+	kfree(mount);
+}
+
+
 /**
  * nfsd4_setup_inter_ssc
  *
@@ -1270,11 +1296,18 @@ extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
 nfsd4_cleanup_inter_ssc(struct vfsmount *ss_mnt, struct file *src,
 			struct file *dst)
 {
+	struct nfsd4_delayed_umount *umount;
 	nfs42_ssc_close(src);
 	fput(src);
 	fput(dst);
 
-	nfsd4_interssc_disconnect(ss_mnt);
+	umount = kzalloc(sizeof(struct nfsd4_delayed_umount), GFP_KERNEL);
+	if (!umount)
+		return;
+	umount->ss_mnt = ss_mnt;
+	mntget(ss_mnt);
+	INIT_DELAYED_WORK(&umount->work, nfsd4_interssc_disconnect);
+	queue_delayed_work(umount_wq, &umount->work, 90 * HZ);
 
 }
 
@@ -1465,7 +1498,7 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 	kfree(copy);
 	return;
 out_err:
-	nfsd4_interssc_disconnect(copy->ss_mnt);
+	_nfsd4_interssc_disconnect(copy->ss_mnt);
 	goto out;
 }
 
@@ -1520,7 +1553,7 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 out:
 	return status;
 out_err:
-	nfsd4_interssc_disconnect(copy->ss_mnt);
+	_nfsd4_interssc_disconnect(copy->ss_mnt);
 	status = nfserrno(-ENOMEM);
 	goto out;
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7727ce53..daee2cc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7138,8 +7138,13 @@ static int nfs4_state_create_net(struct net *net)
 	ret = nfsd4_create_copy_queue();
 	if (ret)
 		goto out_free_callback;
+	ret = nfsd4_create_umount_queue();
+	if (ret)
+		goto out_free_copy_queue;
 
 	return 0;
+out_free_copy_queue:
+	nfsd4_destroy_copy_queue();
 out_free_callback:
 	nfsd4_destroy_callback_queue();
 out_free_laundry:
@@ -7205,6 +7210,7 @@ static int nfs4_state_create_net(struct net *net)
 	nfsd4_destroy_callback_queue();
 	cleanup_callback_cred();
 	nfsd4_destroy_copy_queue();
+	nfsd4_destroy_umount_queue();
 }
 
 static void
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 25c5d82..69db34d 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -657,6 +657,8 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
 extern int nfsd4_create_copy_queue(void);
 extern void nfsd4_destroy_copy_queue(void);
+extern int nfsd4_create_umount_queue(void);
+extern void nfsd4_destroy_umount_queue(void);
 extern __be32 find_cp_state(struct nfsd_net *nn, stateid_t *st,
 			struct nfs4_cp_state **cps);
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index ae5c6e3..3b2176f 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -551,6 +551,11 @@ struct nfsd4_copy {
 	struct nfs4_cp_state	*cps;
 };
 
+struct nfsd4_delayed_umount {
+	struct vfsmount		*ss_mnt;
+	struct delayed_work	work;
+};
+
 struct nfsd4_seek {
 	/* request */
 	stateid_t	seek_stateid;
-- 
1.8.3.1

