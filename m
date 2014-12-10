Return-Path: linux-kernel-owner@vger.kernel.org
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>,
        NeilBrown <neilb@suse.de>
Subject: [PATCH v2 11/16] nfsd: keep a reference to the fs_struct in svc_rqst
Date: Wed, 10 Dec 2014 14:07:55 -0500
Message-Id: <1418238480-18857-12-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
References: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we convert this code to use a workqueue, we won't want to allocate
a new fs_struct to handle each RPC. Doing so might also be problematic
since we'd be swapping out the ->fs value on a "public" workqueue
kthread.

Change the code to allocate an fs struct when when allocating a svc_rqst
and then switch to using that in the "nfsd" function. Once we add
workqueue support, we'll have the work function switch to the new fs
struct when doing the work and then switch it back.

Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/fs_struct.c             | 59 +++++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/nfssvc.c           | 17 ++++++-------
 include/linux/fs_struct.h  |  3 +++
 include/linux/sunrpc/svc.h |  1 +
 net/sunrpc/svc.c           |  8 +++++++
 5 files changed, 69 insertions(+), 19 deletions(-)

diff --git a/fs/fs_struct.c b/fs/fs_struct.c
index 7dca743b2ce1..9bc08ea2f433 100644
--- a/fs/fs_struct.c
+++ b/fs/fs_struct.c
@@ -127,26 +127,67 @@ struct fs_struct *copy_fs_struct(struct fs_struct *old)
 	}
 	return fs;
 }
+EXPORT_SYMBOL_GPL(copy_fs_struct);
 
-int unshare_fs_struct(void)
+/* Replace current fs struct with one given. Return a pointer to old one. */
+static struct fs_struct *
+swap_fs_struct(struct fs_struct *new_fs)
 {
-	struct fs_struct *fs = current->fs;
-	struct fs_struct *new_fs = copy_fs_struct(fs);
-	int kill;
-
-	if (!new_fs)
-		return -ENOMEM;
+	struct fs_struct *old_fs;
 
 	task_lock(current);
+	old_fs = current->fs;
+	current->fs = new_fs;
+	task_unlock(current);
+
+	return old_fs;
+}
+
+/* Put a reference to a fs_struct. */
+void put_fs_struct(struct fs_struct *fs)
+{
+	bool kill;
+
 	spin_lock(&fs->lock);
 	kill = !--fs->users;
-	current->fs = new_fs;
 	spin_unlock(&fs->lock);
-	task_unlock(current);
 
 	if (kill)
 		free_fs_struct(fs);
+}
+EXPORT_SYMBOL_GPL(put_fs_struct);
+
+/* Take an extra reference to a fs_struct. Caller must already hold one! */
+struct fs_struct *
+get_fs_struct(struct fs_struct *fs)
+{
+	spin_lock(&fs->lock);
+	++fs->users;
+	spin_unlock(&fs->lock);
+	return fs;
+}
+EXPORT_SYMBOL_GPL(get_fs_struct);
+
+/*
+ * Swap in a new fs_struct and drop the reference on the old one.
+ * Caller must have already taken the reference to the new one.
+ */
+void replace_fs_struct(struct fs_struct *new_fs)
+{
+	struct fs_struct *old_fs = swap_fs_struct(new_fs);
+
+	put_fs_struct(old_fs);
+}
+EXPORT_SYMBOL_GPL(replace_fs_struct);
+
+int unshare_fs_struct(void)
+{
+	struct fs_struct *new_fs = copy_fs_struct(current->fs);
+
+	if (!new_fs)
+		return -ENOMEM;
 
+	replace_fs_struct(new_fs);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(unshare_fs_struct);
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 71e7b180c0d9..f37bd7db2176 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -582,15 +582,13 @@ nfsd(void *vrqstp)
 	/* Lock module and set up kernel thread */
 	mutex_lock(&nfsd_mutex);
 
-	/* At this point, the thread shares current->fs
-	 * with the init process. We need to create files with a
-	 * umask of 0 instead of init's umask. */
-	if (unshare_fs_struct() < 0) {
-		printk("Unable to start nfsd thread: out of memory\n");
-		goto out;
-	}
-
-	current->fs->umask = 0;
+	/*
+	 * At this point, the thread shares current->fs with the init process.
+	 * We need to create files with a umask of 0 instead of init's umask,
+	 * so switch to the fs_struct associated with the rqstp.
+	 */
+	get_fs_struct(rqstp->rq_fs);
+	replace_fs_struct(rqstp->rq_fs);
 
 	/*
 	 * thread is spawned with all signals set to SIG_IGN, re-enable
@@ -632,7 +630,6 @@ nfsd(void *vrqstp)
 	mutex_lock(&nfsd_mutex);
 	nfsdstats.th_cnt --;
 
-out:
 	rqstp->rq_server = NULL;
 
 	/* Release the thread */
diff --git a/include/linux/fs_struct.h b/include/linux/fs_struct.h
index 0efc3e62843a..d2b7a1942790 100644
--- a/include/linux/fs_struct.h
+++ b/include/linux/fs_struct.h
@@ -21,7 +21,10 @@ extern void set_fs_root(struct fs_struct *, const struct path *);
 extern void set_fs_pwd(struct fs_struct *, const struct path *);
 extern struct fs_struct *copy_fs_struct(struct fs_struct *);
 extern void free_fs_struct(struct fs_struct *);
+extern void replace_fs_struct(struct fs_struct *);
 extern int unshare_fs_struct(void);
+struct fs_struct *get_fs_struct(struct fs_struct *);
+void put_fs_struct(struct fs_struct *);
 
 static inline void get_fs_root(struct fs_struct *fs, struct path *root)
 {
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 43efdaae943a..695bc989c007 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -298,6 +298,7 @@ struct svc_rqst {
 	struct svc_cacherep *	rq_cacherep;	/* cache info */
 	struct task_struct	*rq_task;	/* service thread */
 	spinlock_t		rq_lock;	/* per-request lock */
+	struct fs_struct 	*rq_fs;
 	struct work_struct	rq_work;	/* per-request work */
 };
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 9aad6619aa56..78395f790b54 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -20,6 +20,7 @@
 #include <linux/module.h>
 #include <linux/kthread.h>
 #include <linux/slab.h>
+#include <linux/fs_struct.h>
 
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/xdr.h>
@@ -622,6 +623,11 @@ svc_rqst_alloc(struct svc_serv *serv, struct svc_pool *pool, int node)
 	if (!svc_init_buffer(rqstp, serv->sv_max_mesg, node))
 		goto out_enomem;
 
+	rqstp->rq_fs = copy_fs_struct(current->fs);
+	if (!rqstp->rq_fs)
+		goto out_enomem;
+
+	rqstp->rq_fs->umask = 0;
 	return rqstp;
 out_enomem:
 	svc_rqst_free(rqstp);
@@ -784,6 +790,8 @@ svc_rqst_free(struct svc_rqst *rqstp)
 	kfree(rqstp->rq_resp);
 	kfree(rqstp->rq_argp);
 	kfree(rqstp->rq_auth_data);
+	if (rqstp->rq_fs)
+		put_fs_struct(rqstp->rq_fs);
 	kfree_rcu(rqstp, rq_rcu_head);
 }
 EXPORT_SYMBOL_GPL(svc_rqst_free);
-- 
2.1.0

