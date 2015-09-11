Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:36805 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792AbbIKKzB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2015 06:55:01 -0400
Received: by ykdt18 with SMTP id t18so66773767ykd.3
        for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2015 03:55:01 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH v4 08/16] nfsd: add a new struct file caching facility to nfsd
Date: Fri, 11 Sep 2015 06:54:34 -0400
Message-Id: <1441968882-7851-9-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1441968882-7851-1-git-send-email-jeff.layton@primarydata.com>
References: <1441968882-7851-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, NFSv2/3 reads and writes have to open a file, do the read or
write and then close it again for each RPC. This is highly inefficient,
especially when the underlying filesystem has a relatively slow open
routine.

This patch adds a new open file cache to knfsd. Rather than doing an
open for each RPC, the read/write handlers can call into this cache to
see if there is one already there for the correct filehandle and
NFS_MAY_READ/WRITE flags.

If there isn't an entry, then we create a new one and attempt to
perform the open. If there is, then we wait until the entry is fully
instantiated and return it if it is at the end of the wait. If it's
not, then we attempt to take over construction.

Since the main goal is to speed up NFSv2/3 I/O, we don't want to
close these files on last put of these objects. We need to keep them
around for a little while since we never know when the next READ/WRITE
will come in.

Note that this patch just adds the infrastructure to allow the caching
of open files. Later patches will actually make nfsd use it.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/Kconfig     |   2 +
 fs/nfsd/Makefile    |   3 +-
 fs/nfsd/export.c    |  14 ++
 fs/nfsd/filecache.c | 552 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/filecache.h |  37 ++++
 fs/nfsd/nfssvc.c    |  10 +-
 fs/nfsd/trace.h     | 127 ++++++++++++
 fs/nfsd/vfs.c       |   3 +-
 fs/nfsd/vfs.h       |   1 +
 9 files changed, 746 insertions(+), 3 deletions(-)
 create mode 100644 fs/nfsd/filecache.c
 create mode 100644 fs/nfsd/filecache.h

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index a0b77fc1bd39..95e0a91d41ef 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -6,6 +6,8 @@ config NFSD
 	select SUNRPC
 	select EXPORTFS
 	select NFS_ACL_SUPPORT if NFSD_V2_ACL
+	select SRCU
+	select FSNOTIFY
 	depends on MULTIUSER
 	help
 	  Choose Y here if you want to allow other computers to access
diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
index 9a6028e120c6..8908bb467727 100644
--- a/fs/nfsd/Makefile
+++ b/fs/nfsd/Makefile
@@ -10,7 +10,8 @@ obj-$(CONFIG_NFSD)	+= nfsd.o
 nfsd-y			+= trace.o
 
 nfsd-y 			+= nfssvc.o nfsctl.o nfsproc.o nfsfh.o vfs.o \
-			   export.o auth.o lockd.o nfscache.o nfsxdr.o stats.o
+			   export.o auth.o lockd.o nfscache.o nfsxdr.o \
+			   stats.o filecache.o
 nfsd-$(CONFIG_NFSD_FAULT_INJECTION) += fault_inject.o
 nfsd-$(CONFIG_NFSD_V2_ACL) += nfs2acl.o
 nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index b4d84b579f20..4b504edff121 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -21,6 +21,7 @@
 #include "nfsfh.h"
 #include "netns.h"
 #include "pnfs.h"
+#include "filecache.h"
 
 #define NFSDDBG_FACILITY	NFSDDBG_EXPORT
 
@@ -231,6 +232,18 @@ static struct cache_head *expkey_alloc(void)
 		return NULL;
 }
 
+static void
+expkey_flush(void)
+{
+	/*
+	 * Take the nfsd_mutex here to ensure that the file cache is not
+	 * destroyed while we're in the middle of flushing.
+	 */
+	mutex_lock(&nfsd_mutex);
+	nfsd_file_cache_purge();
+	mutex_unlock(&nfsd_mutex);
+}
+
 static struct cache_detail svc_expkey_cache_template = {
 	.owner		= THIS_MODULE,
 	.hash_size	= EXPKEY_HASHMAX,
@@ -243,6 +256,7 @@ static struct cache_detail svc_expkey_cache_template = {
 	.init		= expkey_init,
 	.update       	= expkey_update,
 	.alloc		= expkey_alloc,
+	.flush		= expkey_flush,
 };
 
 static int
diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
new file mode 100644
index 000000000000..21ec7adbf58c
--- /dev/null
+++ b/fs/nfsd/filecache.c
@@ -0,0 +1,552 @@
+/*
+ * Open file cache.
+ *
+ * (c) 2015 - Jeff Layton <jeff.layton@primarydata.com>
+ */
+
+#include <linux/hash.h>
+#include <linux/slab.h>
+#include <linux/hash.h>
+#include <linux/file.h>
+#include <linux/sched.h>
+#include <linux/list_lru.h>
+#include <linux/fsnotify_backend.h>
+
+#include "vfs.h"
+#include "nfsd.h"
+#include "nfsfh.h"
+#include "filecache.h"
+#include "trace.h"
+
+#define NFSDDBG_FACILITY	NFSDDBG_FH
+
+/* hash table for nfs4_file */
+#define NFSD_FILE_HASH_BITS                   8
+#define NFSD_FILE_HASH_SIZE                  (1 << NFSD_FILE_HASH_BITS)
+
+/* We only care about NFSD_MAY_READ/WRITE for this cache */
+#define NFSD_FILE_MAY_MASK	(NFSD_MAY_READ|NFSD_MAY_WRITE)
+
+struct nfsd_fcache_bucket {
+	struct hlist_head	nfb_head;
+	spinlock_t		nfb_lock;
+};
+
+static struct nfsd_fcache_bucket	*nfsd_file_hashtbl;
+static struct list_lru			nfsd_file_lru;
+static struct fsnotify_group		*nfsd_file_fsnotify_group;
+
+/*
+ * The fsnotify_mark is embedded inside the nfsd_file and we don't want to
+ * explicitly free it. It'll be freed when the nfsd_file is and we always
+ * remove the mark from the inode before freeing it. So, this is a no-op.
+ */
+static void
+nfsd_file_free_mark(struct fsnotify_mark *mark)
+{
+}
+
+static struct nfsd_file *
+nfsd_file_alloc(struct inode *inode, unsigned int may, unsigned int hashval)
+{
+	struct nfsd_file *nf;
+
+	/* FIXME: create a new slabcache for these? */
+	nf = kzalloc(sizeof(*nf), GFP_KERNEL);
+	if (nf) {
+		INIT_HLIST_NODE(&nf->nf_node);
+		INIT_LIST_HEAD(&nf->nf_lru);
+		nf->nf_inode = inode;
+		nf->nf_hashval = hashval;
+		atomic_set(&nf->nf_ref, 1);
+		nf->nf_may = NFSD_FILE_MAY_MASK & may;
+		if (may & NFSD_MAY_NOT_BREAK_LEASE) {
+			if (may & NFSD_MAY_WRITE)
+				__set_bit(NFSD_FILE_BREAK_WRITE, &nf->nf_flags);
+			if (may & NFSD_MAY_READ)
+				__set_bit(NFSD_FILE_BREAK_READ, &nf->nf_flags);
+		}
+		fsnotify_init_mark(&nf->nf_mark, nfsd_file_free_mark);
+		nf->nf_mark.mask = FS_ATTRIB|FS_DELETE_SELF;
+		trace_nfsd_file_alloc(nf);
+	}
+	return nf;
+}
+
+static void
+nfsd_file_put_final(struct nfsd_file *nf)
+{
+	trace_nfsd_file_put_final(nf);
+	fsnotify_destroy_mark(&nf->nf_mark, nfsd_file_fsnotify_group);
+	if (nf->nf_file)
+		fput(nf->nf_file);
+	kfree_rcu(nf, nf_rcu);
+}
+
+static void
+nfsd_file_put_final_sync(struct nfsd_file *nf)
+{
+	trace_nfsd_file_put_final(nf);
+	fsnotify_destroy_mark(&nf->nf_mark, nfsd_file_fsnotify_group);
+	if (nf->nf_file)
+		fput_sync(nf->nf_file);
+	kfree_rcu(nf, nf_rcu);
+}
+
+static bool
+nfsd_file_unhash(struct nfsd_file *nf)
+{
+	lockdep_assert_held(&nfsd_file_hashtbl[nf->nf_hashval].nfb_lock);
+
+	trace_nfsd_file_unhash(nf);
+	if (test_bit(NFSD_FILE_HASHED, &nf->nf_flags)) {
+		clear_bit(NFSD_FILE_HASHED, &nf->nf_flags);
+		hlist_del_rcu(&nf->nf_node);
+		list_lru_del(&nfsd_file_lru, &nf->nf_lru);
+		return true;
+	}
+	return false;
+}
+
+static void
+nfsd_file_unhash_and_release_locked(struct nfsd_file *nf, struct list_head *dispose)
+{
+	lockdep_assert_held(&nfsd_file_hashtbl[nf->nf_hashval].nfb_lock);
+
+	trace_nfsd_file_unhash_and_release_locked(nf);
+	if (!nfsd_file_unhash(nf))
+		return;
+	if (!atomic_dec_and_test(&nf->nf_ref))
+		return;
+
+	list_add(&nf->nf_lru, dispose);
+}
+
+static void
+nfsd_file_unhash_and_release(struct nfsd_file *nf)
+{
+	bool destroy = false;
+
+	spin_lock(&nfsd_file_hashtbl[nf->nf_hashval].nfb_lock);
+	if (nfsd_file_unhash(nf))
+		destroy = atomic_dec_and_test(&nf->nf_ref);
+	spin_unlock(&nfsd_file_hashtbl[nf->nf_hashval].nfb_lock);
+	if (destroy)
+		nfsd_file_put_final_sync(nf);
+}
+
+void
+nfsd_file_put(struct nfsd_file *nf)
+{
+	trace_nfsd_file_put(nf);
+	list_lru_rotate(&nfsd_file_lru, &nf->nf_lru);
+	if (!atomic_dec_and_test(&nf->nf_ref))
+		return;
+
+	WARN_ON(test_bit(NFSD_FILE_HASHED, &nf->nf_flags));
+	nfsd_file_put_final(nf);
+}
+
+struct nfsd_file *
+nfsd_file_get(struct nfsd_file *nf)
+{
+	if (likely(atomic_inc_not_zero(&nf->nf_ref)))
+		return nf;
+	return NULL;
+}
+
+static void
+nfsd_file_dispose_list(struct list_head *dispose)
+{
+	struct nfsd_file *nf;
+
+	while(!list_empty(dispose)) {
+		nf = list_first_entry(dispose, struct nfsd_file, nf_lru);
+		list_del(&nf->nf_lru);
+		nfsd_file_put_final(nf);
+	}
+}
+
+static void
+nfsd_file_dispose_list_sync(struct list_head *dispose)
+{
+	struct nfsd_file *nf;
+
+	while(!list_empty(dispose)) {
+		nf = list_first_entry(dispose, struct nfsd_file, nf_lru);
+		list_del(&nf->nf_lru);
+		nfsd_file_put_final_sync(nf);
+	}
+}
+
+static enum lru_status
+nfsd_file_lru_cb(struct list_head *item, struct list_lru_one *lru,
+		 spinlock_t *lock, void *arg)
+	__releases(lock)
+	__acquires(lock)
+{
+	struct nfsd_file *nf = list_entry(item, struct nfsd_file, nf_lru);
+	bool unhashed;
+
+	if (atomic_read(&nf->nf_ref) > 1)
+		return LRU_SKIP;
+
+	spin_unlock(lock);
+	spin_lock(&nfsd_file_hashtbl[nf->nf_hashval].nfb_lock);
+	unhashed = nfsd_file_unhash(nf);
+	spin_unlock(&nfsd_file_hashtbl[nf->nf_hashval].nfb_lock);
+	if (unhashed)
+		nfsd_file_put(nf);
+	spin_lock(lock);
+	return unhashed ? LRU_REMOVED_RETRY : LRU_RETRY;
+}
+
+static unsigned long
+nfsd_file_lru_count(struct shrinker *s, struct shrink_control *sc)
+{
+	return list_lru_count(&nfsd_file_lru);
+}
+
+static unsigned long
+nfsd_file_lru_scan(struct shrinker *s, struct shrink_control *sc)
+{
+	return list_lru_shrink_walk(&nfsd_file_lru, sc, nfsd_file_lru_cb, NULL);
+}
+
+static struct shrinker	nfsd_file_shrinker = {
+	.scan_objects = nfsd_file_lru_scan,
+	.count_objects = nfsd_file_lru_count,
+	.seeks = 1,
+};
+
+static int
+nfsd_file_lease_notifier_call(struct notifier_block *nb, unsigned long arg,
+			    void *data)
+{
+	struct file_lock *fl = data;
+
+	/* Only close files for F_SETLEASE leases */
+	if (fl->fl_flags & FL_LEASE)
+		nfsd_file_close_inode_sync(file_inode(fl->fl_file));
+	return 0;
+}
+
+static struct notifier_block nfsd_file_lease_notifier = {
+	.notifier_call = nfsd_file_lease_notifier_call,
+};
+
+static int
+nfsd_file_fsnotify_handle_event(struct fsnotify_group *group,
+				struct inode *inode,
+				struct fsnotify_mark *inode_mark,
+				struct fsnotify_mark *vfsmount_mark,
+				u32 mask, void *data, int data_type,
+				const unsigned char *file_name, u32 cookie)
+{
+	struct nfsd_file	*nf;
+
+	trace_nfsd_file_fsnotify_handle_event(inode, mask);
+
+	/* Should be no marks on non-regular files */
+	if (!S_ISREG(inode->i_mode)) {
+		WARN_ON_ONCE(1);
+		return 0;
+	}
+
+	/* ...and we don't do anything with vfsmount marks */
+	BUG_ON(vfsmount_mark);
+
+	/* don't close files if this was not the last link */
+	if (mask & FS_ATTRIB) {
+		if (inode->i_nlink)
+			return 0;
+	}
+
+	/* FIXME: get container of mark, unhash and release it */
+	nf = container_of(inode_mark, struct nfsd_file, nf_mark);
+	nfsd_file_unhash_and_release(nf);
+	return 0;
+}
+
+
+const static struct fsnotify_ops nfsd_file_fsnotify_ops = {
+	.handle_event = nfsd_file_fsnotify_handle_event,
+};
+
+int
+nfsd_file_cache_init(void)
+{
+	int		ret = -ENOMEM;
+	unsigned int	i;
+
+	if (nfsd_file_hashtbl)
+		return 0;
+
+	nfsd_file_hashtbl = kcalloc(NFSD_FILE_HASH_SIZE,
+				sizeof(*nfsd_file_hashtbl), GFP_KERNEL);
+	if (!nfsd_file_hashtbl) {
+		pr_err("nfsd: unable to allocate nfsd_file_hashtbl\n");
+		goto out_err;
+	}
+
+	ret = list_lru_init(&nfsd_file_lru);
+	if (ret) {
+		pr_err("nfsd: failed to init nfsd_file_lru: %d\n", ret);
+		goto out_err;
+	}
+
+	ret = register_shrinker(&nfsd_file_shrinker);
+	if (ret) {
+		pr_err("nfsd: failed to register nfsd_file_shrinker: %d\n", ret);
+		goto out_lru;
+	}
+
+	ret = srcu_notifier_chain_register(&lease_notifier_chain,
+				&nfsd_file_lease_notifier);
+	if (ret) {
+		pr_err("nfsd: unable to register lease notifier: %d\n", ret);
+		goto out_shrinker;
+	}
+
+	nfsd_file_fsnotify_group = fsnotify_alloc_group(&nfsd_file_fsnotify_ops);
+	if (IS_ERR(nfsd_file_fsnotify_group)) {
+		pr_err("nfsd: unable to create fsnotify group: %ld\n",
+			PTR_ERR(nfsd_file_fsnotify_group));
+		nfsd_file_fsnotify_group = NULL;
+		goto out_notifier;
+	}
+
+	for (i = 0; i < NFSD_FILE_HASH_SIZE; i++) {
+		INIT_HLIST_HEAD(&nfsd_file_hashtbl[i].nfb_head);
+		spin_lock_init(&nfsd_file_hashtbl[i].nfb_lock);
+	}
+out:
+	return ret;
+out_notifier:
+	srcu_notifier_chain_unregister(&lease_notifier_chain,
+				&nfsd_file_lease_notifier);
+out_shrinker:
+	unregister_shrinker(&nfsd_file_shrinker);
+out_lru:
+	list_lru_destroy(&nfsd_file_lru);
+out_err:
+	kfree(nfsd_file_hashtbl);
+	nfsd_file_hashtbl = NULL;
+	goto out;
+}
+
+void
+nfsd_file_cache_purge(void)
+{
+	unsigned int		i;
+	struct nfsd_file	*nf;
+	LIST_HEAD(dispose);
+
+	if (!nfsd_file_hashtbl)
+		return;
+
+	for (i = 0; i < NFSD_FILE_HASH_SIZE; i++) {
+		spin_lock(&nfsd_file_hashtbl[i].nfb_lock);
+		while(!hlist_empty(&nfsd_file_hashtbl[i].nfb_head)) {
+			nf = hlist_entry(nfsd_file_hashtbl[i].nfb_head.first,
+					 struct nfsd_file, nf_node);
+			nfsd_file_unhash_and_release_locked(nf, &dispose);
+		}
+		spin_unlock(&nfsd_file_hashtbl[i].nfb_lock);
+		nfsd_file_dispose_list(&dispose);
+	}
+}
+
+void
+nfsd_file_cache_shutdown(void)
+{
+	LIST_HEAD(dispose);
+
+	srcu_notifier_chain_unregister(&lease_notifier_chain,
+				&nfsd_file_lease_notifier);
+	unregister_shrinker(&nfsd_file_shrinker);
+	nfsd_file_cache_purge();
+	fsnotify_put_group(nfsd_file_fsnotify_group);
+	nfsd_file_fsnotify_group = NULL;
+	list_lru_destroy(&nfsd_file_lru);
+	kfree(nfsd_file_hashtbl);
+	nfsd_file_hashtbl = NULL;
+}
+
+/*
+ * Search nfsd_file_hashtbl[] for file. We hash on the filehandle and also on
+ * the NFSD_MAY_READ/WRITE flags. If the file is open for r/w, then it's usable
+ * for either.
+ */
+static struct nfsd_file *
+nfsd_file_find_locked(struct inode *inode, unsigned int may_flags,
+			unsigned int hashval)
+{
+	struct nfsd_file *nf;
+	unsigned char need = may_flags & NFSD_FILE_MAY_MASK;
+
+	hlist_for_each_entry_rcu(nf, &nfsd_file_hashtbl[hashval].nfb_head,
+				 nf_node) {
+		if ((need & nf->nf_may) != need)
+			continue;
+		if (nf->nf_inode == inode)
+			return nfsd_file_get(nf);
+	}
+	return NULL;
+}
+
+/**
+ * nfsd_file_close_inode - attempt to forcibly close a nfsd_file
+ * @inode: inode of the file to attempt to remove
+ *
+ * Walk the whole hash bucket, looking for any files that correspond to "inode".
+ * If any do, then unhash them and put the hashtable reference to them.
+ */
+void
+nfsd_file_close_inode_sync(struct inode *inode)
+{
+	struct nfsd_file	*nf;
+	struct hlist_node	*tmp;
+	unsigned int		hashval = (unsigned int)hash_ptr(inode, NFSD_FILE_HASH_BITS);
+	LIST_HEAD(dispose);
+
+	spin_lock(&nfsd_file_hashtbl[hashval].nfb_lock);
+	hlist_for_each_entry_safe(nf, tmp, &nfsd_file_hashtbl[hashval].nfb_head, nf_node) {
+		if (inode == nf->nf_inode)
+			nfsd_file_unhash_and_release_locked(nf, &dispose);
+	}
+	spin_unlock(&nfsd_file_hashtbl[hashval].nfb_lock);
+	trace_nfsd_file_close_inode_sync(inode, hashval, !list_empty(&dispose));
+	nfsd_file_dispose_list_sync(&dispose);
+}
+
+__be32
+nfsd_file_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
+		  unsigned int may_flags, struct nfsd_file **pnf)
+{
+	__be32	status = nfs_ok;
+	struct nfsd_file *nf, *new = NULL;
+	struct inode *inode;
+	unsigned int hashval;
+
+	/* FIXME: skip this if fh_dentry is already set? */
+	status = fh_verify(rqstp, fhp, S_IFREG, may_flags|NFSD_MAY_OWNER_OVERRIDE);
+	if (status != nfs_ok)
+		return status;
+
+	inode = d_inode(fhp->fh_dentry);
+	hashval = (unsigned int)hash_ptr(inode, NFSD_FILE_HASH_BITS);
+retry:
+	rcu_read_lock();
+	nf = nfsd_file_find_locked(inode, may_flags, hashval);
+	rcu_read_unlock();
+	if (nf)
+		goto wait_for_construction;
+
+	if (!new) {
+		new = nfsd_file_alloc(inode, may_flags, hashval);
+		if (!new) {
+			trace_nfsd_file_acquire(hashval, inode, may_flags, NULL,
+						nfserr_jukebox);
+			return nfserr_jukebox;
+		}
+	}
+
+	spin_lock(&nfsd_file_hashtbl[hashval].nfb_lock);
+	nf = nfsd_file_find_locked(inode, may_flags, hashval);
+	if (likely(nf == NULL)) {
+		/* Take reference for the hashtable */
+		atomic_inc(&new->nf_ref);
+		__set_bit(NFSD_FILE_HASHED, &new->nf_flags);
+		__set_bit(NFSD_FILE_PENDING, &new->nf_flags);
+		list_lru_add(&nfsd_file_lru, &new->nf_lru);
+		hlist_add_head_rcu(&new->nf_node,
+				&nfsd_file_hashtbl[hashval].nfb_head);
+		spin_unlock(&nfsd_file_hashtbl[hashval].nfb_lock);
+
+		/* This should never fail since we set allow_dups to true */
+		WARN_ON_ONCE(fsnotify_add_mark(&new->nf_mark,
+			nfsd_file_fsnotify_group, inode, NULL, true));
+		nf = new;
+		new = NULL;
+		goto open_file;
+	}
+	spin_unlock(&nfsd_file_hashtbl[hashval].nfb_lock);
+
+wait_for_construction:
+	wait_on_bit(&nf->nf_flags, NFSD_FILE_PENDING, TASK_UNINTERRUPTIBLE);
+
+	/* Did construction of this file fail? */
+	if (!nf->nf_file) {
+		/*
+		 * We can only take over construction for this nfsd_file if the
+		 * MAY flags are equal. Otherwise, we put the reference and try
+		 * again.
+		 */
+		if ((may_flags & NFSD_FILE_MAY_MASK) != nf->nf_may) {
+			nfsd_file_put(nf);
+			goto retry;
+		}
+
+		/* try to take over construction for this file */
+		if (test_and_set_bit(NFSD_FILE_PENDING, &nf->nf_flags))
+			goto wait_for_construction;
+
+		/* sync up the BREAK_* flags with our may_flags */
+		if (may_flags & NFSD_MAY_NOT_BREAK_LEASE) {
+			if (may_flags & NFSD_MAY_WRITE)
+				set_bit(NFSD_FILE_BREAK_WRITE, &nf->nf_flags);
+			if (may_flags & NFSD_MAY_READ)
+				set_bit(NFSD_FILE_BREAK_READ, &nf->nf_flags);
+		} else {
+			clear_bit(NFSD_FILE_BREAK_WRITE, &nf->nf_flags);
+			clear_bit(NFSD_FILE_BREAK_READ, &nf->nf_flags);
+		}
+
+		goto open_file;
+	}
+
+	/*
+	 * We have a file that was opened in the context of another rqst. We
+	 * must check permissions. Since we're dealing with open files here,
+	 * we always want to set the OWNER_OVERRIDE bit.
+	 */
+	status = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
+					may_flags|NFSD_MAY_OWNER_OVERRIDE);
+
+	if (status == nfs_ok && !(may_flags & NFSD_MAY_NOT_BREAK_LEASE)) {
+		bool write = (may_flags & NFSD_MAY_WRITE);
+
+		if (test_bit(NFSD_FILE_BREAK_READ, &nf->nf_flags) ||
+		    (test_bit(NFSD_FILE_BREAK_WRITE, &nf->nf_flags) && write)) {
+			status = nfserrno(nfsd_open_break_lease(
+					file_inode(nf->nf_file), may_flags));
+			if (status == nfs_ok) {
+				clear_bit(NFSD_FILE_BREAK_READ, &nf->nf_flags);
+				if (write)
+					clear_bit(NFSD_FILE_BREAK_WRITE,
+						  &nf->nf_flags);
+			}
+		}
+	}
+out:
+	if (status == nfs_ok) {
+		*pnf = nf;
+	} else {
+		nfsd_file_put(nf);
+		nf = NULL;
+	}
+
+	if (new)
+		nfsd_file_put(new);
+
+	trace_nfsd_file_acquire(hashval, inode, may_flags, nf, status);
+	return status;
+open_file:
+	/* FIXME: should we abort opening if the link count goes to 0? */
+	status = nfsd_open(rqstp, fhp, S_IFREG, may_flags, &nf->nf_file);
+	clear_bit_unlock(NFSD_FILE_PENDING, &nf->nf_flags);
+	smp_mb__after_atomic();
+	wake_up_bit(&nf->nf_flags, NFSD_FILE_PENDING);
+	goto out;
+}
diff --git a/fs/nfsd/filecache.h b/fs/nfsd/filecache.h
new file mode 100644
index 000000000000..5c871c3114f2
--- /dev/null
+++ b/fs/nfsd/filecache.h
@@ -0,0 +1,37 @@
+#ifndef _FS_NFSD_FILECACHE_H
+#define _FS_NFSD_FILECACHE_H
+
+#include <linux/fsnotify_backend.h>
+
+/*
+ * A representation of a file that has been opened by knfsd. These are hashed
+ * in the hashtable by inode pointer value. Note that this object doesn't
+ * hold a reference to the inode by itself, so the nf_inode pointer should
+ * never be dereferenced, only be used for comparison.
+ */
+struct nfsd_file {
+	struct hlist_node	nf_node;
+	struct list_head	nf_lru;
+	struct rcu_head		nf_rcu;
+	struct file		*nf_file;
+#define NFSD_FILE_HASHED	(0)
+#define NFSD_FILE_PENDING	(1)
+#define NFSD_FILE_BREAK_READ	(2)
+#define NFSD_FILE_BREAK_WRITE	(3)
+	unsigned long		nf_flags;
+	struct inode		*nf_inode;
+	unsigned int		nf_hashval;
+	atomic_t		nf_ref;
+	unsigned char		nf_may;
+	struct fsnotify_mark	nf_mark;
+};
+
+int nfsd_file_cache_init(void);
+void nfsd_file_cache_purge(void);
+void nfsd_file_cache_shutdown(void);
+void nfsd_file_put(struct nfsd_file *nf);
+struct nfsd_file *nfsd_file_get(struct nfsd_file *nf);
+void nfsd_file_close_inode_sync(struct inode *inode);
+__be32 nfsd_file_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
+		  unsigned int may_flags, struct nfsd_file **nfp);
+#endif /* _FS_NFSD_FILECACHE_H */
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index ad4e2377dd63..d816bb3faa6e 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -22,6 +22,7 @@
 #include "cache.h"
 #include "vfs.h"
 #include "netns.h"
+#include "filecache.h"
 
 #define NFSDDBG_FACILITY	NFSDDBG_SVC
 
@@ -224,11 +225,17 @@ static int nfsd_startup_generic(int nrservs)
 	if (ret)
 		goto dec_users;
 
-	ret = nfs4_state_start();
+	ret = nfsd_file_cache_init();
 	if (ret)
 		goto out_racache;
+
+	ret = nfs4_state_start();
+	if (ret)
+		goto out_file_cache;
 	return 0;
 
+out_file_cache:
+	nfsd_file_cache_shutdown();
 out_racache:
 	nfsd_racache_shutdown();
 dec_users:
@@ -242,6 +249,7 @@ static void nfsd_shutdown_generic(void)
 		return;
 
 	nfs4_state_shutdown();
+	nfsd_file_cache_shutdown();
 	nfsd_racache_shutdown();
 }
 
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 0befe762762b..49f0d1f9c949 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -10,6 +10,8 @@
 #include <linux/tracepoint.h>
 
 #include "state.h"
+#include "filecache.h"
+#include "vfs.h"
 
 DECLARE_EVENT_CLASS(nfsd_stateid_class,
 	TP_PROTO(stateid_t *stp),
@@ -48,6 +50,131 @@ DEFINE_STATEID_EVENT(layout_recall_done);
 DEFINE_STATEID_EVENT(layout_recall_fail);
 DEFINE_STATEID_EVENT(layout_recall_release);
 
+#define show_nf_flags(val)						\
+	__print_flags(val, "|",						\
+		{ 1 << NFSD_FILE_HASHED,	"HASHED" },		\
+		{ 1 << NFSD_FILE_PENDING,	"PENDING" },		\
+		{ 1 << NFSD_FILE_BREAK_READ,	"BREAK_READ" },		\
+		{ 1 << NFSD_FILE_BREAK_WRITE,	"BREAK_WRITE" })
+
+/* FIXME: This should probably be fleshed out in the future. */
+#define show_nf_may(val)						\
+	__print_flags(val, "|",						\
+		{ NFSD_MAY_READ,		"READ" },		\
+		{ NFSD_MAY_WRITE,		"WRITE" },		\
+		{ NFSD_MAY_NOT_BREAK_LEASE,	"NOT_BREAK_LEASE" })
+
+DECLARE_EVENT_CLASS(nfsd_file_class,
+	TP_PROTO(struct nfsd_file *nf),
+	TP_ARGS(nf),
+	TP_STRUCT__entry(
+		__field(unsigned int, nf_hashval)
+		__field(void *, nf_inode)
+		__field(int, nf_ref)
+		__field(unsigned long, nf_flags)
+		__field(unsigned char, nf_may)
+		__field(struct file *, nf_file)
+	),
+	TP_fast_assign(
+		__entry->nf_hashval = nf->nf_hashval;
+		__entry->nf_inode = nf->nf_inode;
+		__entry->nf_ref = atomic_read(&nf->nf_ref);
+		__entry->nf_flags = nf->nf_flags;
+		__entry->nf_may = nf->nf_may;
+		__entry->nf_file = nf->nf_file;
+	),
+	TP_printk("hash=0x%x inode=0x%p ref=%d flags=%s may=%s file=%p",
+		__entry->nf_hashval,
+		__entry->nf_inode,
+		__entry->nf_ref,
+		show_nf_flags(__entry->nf_flags),
+		show_nf_may(__entry->nf_may),
+		__entry->nf_file)
+)
+
+#define DEFINE_NFSD_FILE_EVENT(name) \
+DEFINE_EVENT(nfsd_file_class, name, \
+	TP_PROTO(struct nfsd_file *nf), \
+	TP_ARGS(nf))
+
+DEFINE_NFSD_FILE_EVENT(nfsd_file_alloc);
+DEFINE_NFSD_FILE_EVENT(nfsd_file_put_final);
+DEFINE_NFSD_FILE_EVENT(nfsd_file_unhash);
+DEFINE_NFSD_FILE_EVENT(nfsd_file_put);
+DEFINE_NFSD_FILE_EVENT(nfsd_file_unhash_and_release_locked);
+
+TRACE_EVENT(nfsd_file_acquire,
+	TP_PROTO(unsigned int hash, struct inode *inode,
+		 unsigned int may_flags, struct nfsd_file *nf,
+		 __be32 status),
+
+	TP_ARGS(hash, inode, may_flags, nf, status),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, hash)
+		__field(void *, inode)
+		__field(unsigned int, may_flags)
+		__field(int, nf_ref)
+		__field(unsigned long, nf_flags)
+		__field(unsigned char, nf_may)
+		__field(struct file *, nf_file)
+		__field(__be32, status)
+	),
+
+	TP_fast_assign(
+		__entry->hash = hash;
+		__entry->inode = inode;
+		__entry->may_flags = may_flags;
+		__entry->nf_ref = nf ? atomic_read(&nf->nf_ref) : 0;
+		__entry->nf_flags = nf ? nf->nf_flags : 0;
+		__entry->nf_may = nf ? nf->nf_may : 0;
+		__entry->nf_file = nf ? nf->nf_file : NULL;
+		__entry->status = status;
+	),
+
+	TP_printk("hash=0x%x inode=0x%p may_flags=%s ref=%d nf_flags=%s nf_may=%s nf_file=0x%p status=%u",
+			__entry->hash, __entry->inode,
+			show_nf_may(__entry->may_flags), __entry->nf_ref,
+			show_nf_flags(__entry->nf_flags),
+			show_nf_may(__entry->nf_may), __entry->nf_file,
+			be32_to_cpu(__entry->status))
+);
+
+TRACE_EVENT(nfsd_file_close_inode_sync,
+	TP_PROTO(struct inode *inode, unsigned int hash, int found),
+	TP_ARGS(inode, hash, found),
+	TP_STRUCT__entry(
+		__field(struct inode *, inode)
+		__field(unsigned int, hash)
+		__field(int, found)
+	),
+	TP_fast_assign(
+		__entry->inode = inode;
+		__entry->hash = hash;
+		__entry->found = found;
+	),
+	TP_printk("hash=0x%x inode=0x%p found=%d", __entry->hash,
+			__entry->inode, __entry->found)
+);
+
+TRACE_EVENT(nfsd_file_fsnotify_handle_event,
+	TP_PROTO(struct inode *inode, u32 mask),
+	TP_ARGS(inode, mask),
+	TP_STRUCT__entry(
+		__field(struct inode *, inode)
+		__field(unsigned int, nlink)
+		__field(umode_t, mode)
+		__field(u32, mask)
+	),
+	TP_fast_assign(
+		__entry->inode = inode;
+		__entry->nlink = inode->i_nlink;
+		__entry->mode = inode->i_mode;
+		__entry->mask = mask;
+	),
+	TP_printk("inode=0x%p nlink=%u mode=0%ho mask=0x%x", __entry->inode,
+			__entry->nlink, __entry->mode, __entry->mask)
+);
 #endif /* _NFSD_TRACE_H */
 
 #undef TRACE_INCLUDE_PATH
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 2ea6c6a37364..4ce447e56155 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -623,7 +623,8 @@ nfsd_access(struct svc_rqst *rqstp, struct svc_fh *fhp, u32 *access, u32 *suppor
 }
 #endif /* CONFIG_NFSD_V3 */
 
-static int nfsd_open_break_lease(struct inode *inode, int access)
+int
+nfsd_open_break_lease(struct inode *inode, int access)
 {
 	unsigned int mode;
 
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index fee2451ae248..4bc127e0ca15 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -69,6 +69,7 @@ __be32		do_nfsd_create(struct svc_rqst *, struct svc_fh *,
 __be32		nfsd_commit(struct svc_rqst *, struct svc_fh *,
 				loff_t, unsigned long);
 #endif /* CONFIG_NFSD_V3 */
+int		nfsd_open_break_lease(struct inode *, int);
 __be32		nfsd_open(struct svc_rqst *, struct svc_fh *, umode_t,
 				int, struct file **);
 struct raparms;
-- 
2.4.3

