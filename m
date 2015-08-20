Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:33384 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbbHTLRd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 07:17:33 -0400
Received: by ykll84 with SMTP id l84so33731915ykl.0
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 04:17:32 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@lst.de, kinglongmee@gmail.com
Subject: [PATCH v3 06/20] locks/nfsd: create a new notifier chain for lease attempts
Date: Thu, 20 Aug 2015 07:17:06 -0400
Message-Id: <1440069440-27454-7-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
References: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With the new file caching infrastructure in nfsd, we can end up holding
files open for an indefinite period of time, even when they are still
idle. This may prevent the kernel from handing out leases on the file,
which we don't really want to block.

Fix this by running a blocking notifier call chain whenever on any
lease attempt. nfsd can then purge the cache for that inode before
returning.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/locks.c          | 15 +++++++++++++++
 fs/nfsd/filecache.c | 27 +++++++++++++++++++++++++++
 include/linux/fs.h  |  1 +
 3 files changed, 43 insertions(+)

diff --git a/fs/locks.c b/fs/locks.c
index d3d558ba4da7..c81b96159e5c 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -167,6 +167,13 @@ DEFINE_STATIC_LGLOCK(file_lock_lglock);
 static DEFINE_PER_CPU(struct hlist_head, file_lock_list);
 
 /*
+ * Some subsystems would like to be notified if someone attempts to set a
+ * lease on a file. This notifier chain will be called whenever this occurs.
+ */
+BLOCKING_NOTIFIER_HEAD(lease_notifier_chain);
+EXPORT_SYMBOL_GPL(lease_notifier_chain);
+
+/*
  * The blocked_hash is used to find POSIX lock loops for deadlock detection.
  * It is protected by blocked_lock_lock.
  *
@@ -1795,10 +1802,18 @@ EXPORT_SYMBOL(generic_setlease);
  *
  * The "priv" pointer is passed directly to the lm_setup function as-is. It
  * may be NULL if the lm_setup operation doesn't require it.
+ *
+ * Kernel subsystems can also register to be notified on any attempt to set
+ * a new lease with the lease_notifier_chain. This is used by (e.g.) nfsd
+ * to close files that it may have cached when there is an attempt to set a
+ * conflicting lease.
  */
 int
 vfs_setlease(struct file *filp, long arg, struct file_lock **lease, void **priv)
 {
+	if (arg != F_UNLCK)
+		blocking_notifier_call_chain(&lease_notifier_chain, arg, *lease);
+
 	if (filp->f_op->setlease)
 		return filp->f_op->setlease(filp, arg, lease, priv);
 	else
diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 669e62f6f4f6..77041967d8ff 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -158,6 +158,22 @@ static struct shrinker	nfsd_file_shrinker = {
 	.seeks = 1,
 };
 
+static int
+nfsd_file_lease_notifier_call(struct notifier_block *nb, unsigned long arg,
+			    void *data)
+{
+	struct file_lock *fl = data;
+
+	/* Don't close files if we're the one trying to set the lease */
+	if (fl->fl_type == FL_LEASE)
+		nfsd_file_close_inode(file_inode(fl->fl_file));
+	return 0;
+}
+
+static struct notifier_block nfsd_file_lease_notifier = {
+	.notifier_call = nfsd_file_lease_notifier_call,
+};
+
 int
 nfsd_file_cache_init(void)
 {
@@ -186,12 +202,21 @@ nfsd_file_cache_init(void)
 		goto out_lru;
 	}
 
+	ret = blocking_notifier_chain_register(&lease_notifier_chain,
+				&nfsd_file_lease_notifier);
+	if (ret) {
+		pr_err("nfsd: unable to register lease notifier: %d\n", ret);
+		goto out_shrinker;
+	}
+
 	for (i = 0; i < NFSD_FILE_HASH_SIZE; i++) {
 		INIT_HLIST_HEAD(&nfsd_file_hashtbl[i].nfb_head);
 		spin_lock_init(&nfsd_file_hashtbl[i].nfb_lock);
 	}
 out:
 	return ret;
+out_shrinker:
+	unregister_shrinker(&nfsd_file_shrinker);
 out_lru:
 	list_lru_destroy(&nfsd_file_lru);
 out_err:
@@ -207,6 +232,8 @@ nfsd_file_cache_shutdown(void)
 	struct nfsd_file	*nf;
 	LIST_HEAD(dispose);
 
+	blocking_notifier_chain_unregister(&lease_notifier_chain,
+				&nfsd_file_lease_notifier);
 	unregister_shrinker(&nfsd_file_shrinker);
 	for (i = 0; i < NFSD_FILE_HASH_SIZE; i++) {
 		spin_lock(&nfsd_file_hashtbl[i].nfb_lock);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9a9d314f7b27..01bb82eae684 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1041,6 +1041,7 @@ extern int fcntl_setlease(unsigned int fd, struct file *filp, long arg);
 extern int fcntl_getlease(struct file *filp);
 
 /* fs/locks.c */
+extern struct blocking_notifier_head	lease_notifier_chain;
 void locks_free_lock_context(struct file_lock_context *ctx);
 void locks_free_lock(struct file_lock *fl);
 extern void locks_init_lock(struct file_lock *);
-- 
2.4.3

