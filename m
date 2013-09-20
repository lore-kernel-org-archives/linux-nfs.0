Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56355 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751897Ab3ITPJc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Sep 2013 11:09:32 -0400
Subject: [PATCH 3/3] NFS: Use i_writecount to control whether to get an
 fscache cookie in nfs_open()
To: Trond.Myklebust@netapp.com, steved@redhat.com
From: David Howells <dhowells@redhat.com>
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        Mark Moseley <moseleymark@gmail.com>, linux-fsdevel@vger.kernel.org,
        ceph-devel@vger.kernel.org
Date: Fri, 20 Sep 2013 16:09:27 +0100
Message-ID: <20130920150927.16220.33305.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130920150902.16220.32737.stgit@warthog.procyon.org.uk>
References: <20130920150902.16220.32737.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use i_writecount to control whether to get an fscache cookie in nfs_open() as
NFS does not do write caching yet.  I *think* this is the cause of a problem
encountered by Mark Moseley whereby __fscache_uncache_page() gets a NULL
pointer dereference because cookie->def is NULL:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000010
IP: [<ffffffff812a1903>] __fscache_uncache_page+0x23/0x160
PGD 0
Thread overran stack, or stack corrupted
Oops: 0000 [#1] SMP
Modules linked in: ...
CPU: 7 PID: 18993 Comm: php Not tainted 3.11.1 #1
Hardware name: Dell Inc. PowerEdge R420/072XWF, BIOS 1.3.5 08/21/2012
task: ffff8804203460c0 ti: ffff880420346640
RIP: 0010:[<ffffffff812a1903>] __fscache_uncache_page+0x23/0x160
RSP: 0018:ffff8801053af878 EFLAGS: 00210286
RAX: 0000000000000000 RBX: ffff8800be2f8780 RCX: ffff88022ffae5e8
RDX: 0000000000004c66 RSI: ffffea00055ff440 RDI: ffff8800be2f8780
RBP: ffff8801053af898 R08: 0000000000000001 R09: 0000000000000003
R10: 0000000000000000 R11: 0000000000000000 R12: ffffea00055ff440
R13: 0000000000001000 R14: ffff8800c50be538 R15: 0000000000000000
FS: 0000000000000000(0000) GS:ffff88042fc60000(0063) knlGS:00000000e439c700
CS: 0010 DS: 002b ES: 002b CR0: 0000000080050033
CR2: 0000000000000010 CR3: 0000000001d8f000 CR4: 00000000000607f0
Stack:
...
Call Trace:
[<ffffffff81365a72>] __nfs_fscache_invalidate_page+0x42/0x70
[<ffffffff813553d5>] nfs_invalidate_page+0x75/0x90
[<ffffffff811b8f5e>] truncate_inode_page+0x8e/0x90
[<ffffffff811b90ad>] truncate_inode_pages_range.part.12+0x14d/0x620
[<ffffffff81d6387d>] ? __mutex_lock_slowpath+0x1fd/0x2e0
[<ffffffff811b95d3>] truncate_inode_pages_range+0x53/0x70
[<ffffffff811b969d>] truncate_inode_pages+0x2d/0x40
[<ffffffff811b96ff>] truncate_pagecache+0x4f/0x70
[<ffffffff81356840>] nfs_setattr_update_inode+0xa0/0x120
[<ffffffff81368de4>] nfs3_proc_setattr+0xc4/0xe0
[<ffffffff81357f78>] nfs_setattr+0xc8/0x150
[<ffffffff8122d95b>] notify_change+0x1cb/0x390
[<ffffffff8120a55b>] do_truncate+0x7b/0xc0
[<ffffffff8121f96c>] do_last+0xa4c/0xfd0
[<ffffffff8121ffbc>] path_openat+0xcc/0x670
[<ffffffff81220a0e>] do_filp_open+0x4e/0xb0
[<ffffffff8120ba1f>] do_sys_open+0x13f/0x2b0
[<ffffffff8126aaf6>] compat_SyS_open+0x36/0x50
[<ffffffff81d7204c>] sysenter_dispatch+0x7/0x24

The code at the instruction pointer was disassembled:

> (gdb) disas __fscache_uncache_page
> Dump of assembler code for function __fscache_uncache_page:
> ...
> 0xffffffff812a18ff <+31>: mov 0x48(%rbx),%rax
> 0xffffffff812a1903 <+35>: cmpb $0x0,0x10(%rax)
> 0xffffffff812a1907 <+39>: je 0xffffffff812a19cd <__fscache_uncache_page+237>

These instructions make up:

	ASSERTCMP(cookie->def->type, !=, FSCACHE_COOKIE_TYPE_INDEX);

That cmpb is the faulting instruction (%rax is 0).  So cookie->def is NULL -
which presumably means that the cookie has already been at least partway
through __fscache_relinquish_cookie().

What I think may be happening is something like a three-way race on the same
file:

	PROCESS 1	PROCESS 2	PROCESS 3
	===============	===============	===============
	open(O_TRUNC|O_WRONLY)
			open(O_RDONLY)
					open(O_WRONLY)
	-->nfs_open()
	-->nfs_fscache_set_inode_cookie()
	nfs_fscache_inode_lock()
	nfs_fscache_disable_inode_cookie()
	__fscache_relinquish_cookie()
	nfs_inode->fscache = NULL
	<--nfs_fscache_set_inode_cookie()

			-->nfs_open()
			-->nfs_fscache_set_inode_cookie()
			nfs_fscache_inode_lock()
			nfs_fscache_enable_inode_cookie()
			__fscache_acquire_cookie()
			nfs_inode->fscache = cookie
			<--nfs_fscache_set_inode_cookie()
	<--nfs_open()
	-->nfs_setattr()
	...
	...
	-->nfs_invalidate_page()
	-->__nfs_fscache_invalidate_page()
	cookie = nfsi->fscache
					-->nfs_open()
					-->nfs_fscache_set_inode_cookie()
					nfs_fscache_inode_lock()
					nfs_fscache_disable_inode_cookie()
					-->__fscache_relinquish_cookie()
	-->__fscache_uncache_page(cookie)
	<crash>
					<--__fscache_relinquish_cookie()
					nfs_inode->fscache = NULL
					<--nfs_fscache_set_inode_cookie()

What is needed is something to prevent process #2 from reacquiring the cookie
- and I think checking i_writecount should do the trick.

It's also possible to have a two-way race on this if the file is opened
O_TRUNC|O_RDONLY instead.

Reported-by: Mark Moseley <moseleymark@gmail.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/dir.c           |    2 -
 fs/nfs/fscache.c       |  192 ++++++++++++++----------------------------------
 fs/nfs/fscache.h       |   18 ++---
 fs/nfs/inode.c         |    6 +-
 fs/nfs/nfs4file.c      |    2 -
 include/linux/fs.h     |    5 +
 include/linux/nfs_fs.h |    8 ++
 7 files changed, 77 insertions(+), 156 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 854a8f0..4c5edcc 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1381,7 +1381,7 @@ static struct nfs_open_context *create_nfs_open_context(struct dentry *dentry, i
 
 static int do_open(struct inode *inode, struct file *filp)
 {
-	nfs_fscache_set_inode_cookie(inode, filp);
+	nfs_fscache_open_file(inode, filp);
 	return 0;
 }
 
diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index cd6e7ef..a01af20 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -178,163 +178,79 @@ void nfs_fscache_release_super_cookie(struct super_block *sb)
 /*
  * Initialise the per-inode cache cookie pointer for an NFS inode.
  */
-void nfs_fscache_init_inode_cookie(struct inode *inode)
+void nfs_fscache_init_inode(struct inode *inode)
 {
-	NFS_I(inode)->fscache = NULL;
-	if (S_ISREG(inode->i_mode))
-		set_bit(NFS_INO_FSCACHE, &NFS_I(inode)->flags);
-}
-
-/*
- * Get the per-inode cache cookie for an NFS inode.
- */
-static void nfs_fscache_enable_inode_cookie(struct inode *inode)
-{
-	struct super_block *sb = inode->i_sb;
 	struct nfs_inode *nfsi = NFS_I(inode);
 
-	if (nfsi->fscache || !NFS_FSCACHE(inode))
+	nfsi->fscache = NULL;
+	if (!S_ISREG(inode->i_mode))
 		return;
-
-	if ((NFS_SB(sb)->options & NFS_OPTION_FSCACHE)) {
-		nfsi->fscache = fscache_acquire_cookie(
-			NFS_SB(sb)->fscache,
-			&nfs_fscache_inode_object_def,
-			nfsi, true);
-
-		dfprintk(FSCACHE, "NFS: get FH cookie (0x%p/0x%p/0x%p)\n",
-			 sb, nfsi, nfsi->fscache);
-	}
+	nfsi->fscache = fscache_acquire_cookie(NFS_SB(inode->i_sb)->fscache,
+					       &nfs_fscache_inode_object_def,
+					       nfsi, false);
 }
 
 /*
  * Release a per-inode cookie.
  */
-void nfs_fscache_release_inode_cookie(struct inode *inode)
-{
-	struct nfs_inode *nfsi = NFS_I(inode);
-
-	dfprintk(FSCACHE, "NFS: clear cookie (0x%p/0x%p)\n",
-		 nfsi, nfsi->fscache);
-
-	fscache_relinquish_cookie(nfsi->fscache, 0);
-	nfsi->fscache = NULL;
-}
-
-/*
- * Retire a per-inode cookie, destroying the data attached to it.
- */
-void nfs_fscache_zap_inode_cookie(struct inode *inode)
+void nfs_fscache_clear_inode(struct inode *inode)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
+	struct fscache_cookie *cookie = nfs_i_fscache(inode);
 
-	dfprintk(FSCACHE, "NFS: zapping cookie (0x%p/0x%p)\n",
-		 nfsi, nfsi->fscache);
+	dfprintk(FSCACHE, "NFS: clear cookie (0x%p/0x%p)\n", nfsi, cookie);
 
-	fscache_relinquish_cookie(nfsi->fscache, 1);
+	fscache_relinquish_cookie(cookie, false);
 	nfsi->fscache = NULL;
 }
 
-/*
- * Turn off the cache with regard to a per-inode cookie if opened for writing,
- * invalidating all the pages in the page cache relating to the associated
- * inode to clear the per-page caching.
- */
-static void nfs_fscache_disable_inode_cookie(struct inode *inode)
-{
-	clear_bit(NFS_INO_FSCACHE, &NFS_I(inode)->flags);
-
-	if (NFS_I(inode)->fscache) {
-		dfprintk(FSCACHE,
-			 "NFS: nfsi 0x%p turning cache off\n", NFS_I(inode));
-
-		/* Need to uncache any pages attached to this inode that
-		 * fscache knows about before turning off the cache.
-		 */
-		fscache_uncache_all_inode_pages(NFS_I(inode)->fscache, inode);
-		nfs_fscache_zap_inode_cookie(inode);
-	}
-}
-
-/*
- * wait_on_bit() sleep function for uninterruptible waiting
- */
-static int nfs_fscache_wait_bit(void *flags)
-{
-	schedule();
-	return 0;
-}
-
-/*
- * Lock against someone else trying to also acquire or relinquish a cookie
- */
-static inline void nfs_fscache_inode_lock(struct inode *inode)
-{
-	struct nfs_inode *nfsi = NFS_I(inode);
-
-	while (test_and_set_bit(NFS_INO_FSCACHE_LOCK, &nfsi->flags))
-		wait_on_bit(&nfsi->flags, NFS_INO_FSCACHE_LOCK,
-			    nfs_fscache_wait_bit, TASK_UNINTERRUPTIBLE);
-}
-
-/*
- * Unlock cookie management lock
- */
-static inline void nfs_fscache_inode_unlock(struct inode *inode)
+static bool nfs_fscache_can_enable(void *data)
 {
-	struct nfs_inode *nfsi = NFS_I(inode);
+	struct inode *inode = data;
 
-	smp_mb__before_clear_bit();
-	clear_bit(NFS_INO_FSCACHE_LOCK, &nfsi->flags);
-	smp_mb__after_clear_bit();
-	wake_up_bit(&nfsi->flags, NFS_INO_FSCACHE_LOCK);
+	return !inode_is_open_for_write(inode);
 }
 
 /*
- * Decide if we should enable or disable local caching for this inode.
- * - For now, with NFS, only regular files that are open read-only will be able
- *   to use the cache.
- * - May be invoked multiple times in parallel by parallel nfs_open() functions.
- */
-void nfs_fscache_set_inode_cookie(struct inode *inode, struct file *filp)
-{
-	if (NFS_FSCACHE(inode)) {
-		nfs_fscache_inode_lock(inode);
-		if ((filp->f_flags & O_ACCMODE) != O_RDONLY)
-			nfs_fscache_disable_inode_cookie(inode);
-		else
-			nfs_fscache_enable_inode_cookie(inode);
-		nfs_fscache_inode_unlock(inode);
-	}
-}
-EXPORT_SYMBOL_GPL(nfs_fscache_set_inode_cookie);
-
-/*
- * Replace a per-inode cookie due to revalidation detecting a file having
- * changed on the server.
+ * Enable or disable caching for a file that is being opened as appropriate.
+ * The cookie is allocated when the inode is initialised, but is not enabled at
+ * that time.  Enablement is deferred to file-open time to avoid stat() and
+ * access() thrashing the cache.
+ *
+ * For now, with NFS, only regular files that are open read-only will be able
+ * to use the cache.
+ *
+ * We enable the cache for an inode if we open it read-only and it isn't
+ * currently open for writing.  We disable the cache if the inode is open
+ * write-only.
+ *
+ * The caller uses the file struct to pin i_writecount on the inode before
+ * calling us when a file is opened for writing, so we can make use of that.
+ *
+ * Note that this may be invoked multiple times in parallel by parallel
+ * nfs_open() functions.
  */
-void nfs_fscache_reset_inode_cookie(struct inode *inode)
+void nfs_fscache_open_file(struct inode *inode, struct file *filp)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
-	struct nfs_server *nfss = NFS_SERVER(inode);
-	NFS_IFDEBUG(struct fscache_cookie *old = nfsi->fscache);
-
-	nfs_fscache_inode_lock(inode);
-	if (nfsi->fscache) {
-		/* retire the current fscache cache and get a new one */
-		fscache_relinquish_cookie(nfsi->fscache, 1);
+	struct fscache_cookie *cookie = nfs_i_fscache(inode);
 
-		nfsi->fscache = fscache_acquire_cookie(
-			nfss->nfs_client->fscache,
-			&nfs_fscache_inode_object_def,
-			nfsi, true);
+	if (!fscache_cookie_valid(cookie))
+		return;
 
-		dfprintk(FSCACHE,
-			 "NFS: revalidation new cookie (0x%p/0x%p/0x%p/0x%p)\n",
-			 nfss, nfsi, old, nfsi->fscache);
+	if (inode_is_open_for_write(inode)) {
+		dfprintk(FSCACHE, "NFS: nfsi 0x%p disabling cache\n", nfsi);
+		clear_bit(NFS_INO_FSCACHE, &nfsi->flags);
+		fscache_disable_cookie(cookie, true);
+		fscache_uncache_all_inode_pages(cookie, inode);
+	} else {
+		dfprintk(FSCACHE, "NFS: nfsi 0x%p enabling cache\n", nfsi);
+		fscache_enable_cookie(cookie, nfs_fscache_can_enable, inode);
+		if (fscache_cookie_enabled(cookie))
+			set_bit(NFS_INO_FSCACHE, &NFS_I(inode)->flags);
 	}
-	nfs_fscache_inode_unlock(inode);
 }
+EXPORT_SYMBOL_GPL(nfs_fscache_open_file);
 
 /*
  * Release the caching state associated with a page, if the page isn't busy
@@ -345,7 +261,7 @@ int nfs_fscache_release_page(struct page *page, gfp_t gfp)
 {
 	if (PageFsCache(page)) {
 		struct nfs_inode *nfsi = NFS_I(page->mapping->host);
-		struct fscache_cookie *cookie = nfsi->fscache;
+		struct fscache_cookie *cookie = nfs_i_fscache(page->mapping->host);
 
 		BUG_ON(!cookie);
 		dfprintk(FSCACHE, "NFS: fscache releasepage (0x%p/0x%p/0x%p)\n",
@@ -368,7 +284,7 @@ int nfs_fscache_release_page(struct page *page, gfp_t gfp)
 void __nfs_fscache_invalidate_page(struct page *page, struct inode *inode)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
-	struct fscache_cookie *cookie = nfsi->fscache;
+	struct fscache_cookie *cookie = nfs_i_fscache(inode);
 
 	BUG_ON(!cookie);
 
@@ -417,9 +333,9 @@ int __nfs_readpage_from_fscache(struct nfs_open_context *ctx,
 
 	dfprintk(FSCACHE,
 		 "NFS: readpage_from_fscache(fsc:%p/p:%p(i:%lx f:%lx)/0x%p)\n",
-		 NFS_I(inode)->fscache, page, page->index, page->flags, inode);
+		 nfs_i_fscache(inode), page, page->index, page->flags, inode);
 
-	ret = fscache_read_or_alloc_page(NFS_I(inode)->fscache,
+	ret = fscache_read_or_alloc_page(nfs_i_fscache(inode),
 					 page,
 					 nfs_readpage_from_fscache_complete,
 					 ctx,
@@ -459,9 +375,9 @@ int __nfs_readpages_from_fscache(struct nfs_open_context *ctx,
 	int ret;
 
 	dfprintk(FSCACHE, "NFS: nfs_getpages_from_fscache (0x%p/%u/0x%p)\n",
-		 NFS_I(inode)->fscache, npages, inode);
+		 nfs_i_fscache(inode), npages, inode);
 
-	ret = fscache_read_or_alloc_pages(NFS_I(inode)->fscache,
+	ret = fscache_read_or_alloc_pages(nfs_i_fscache(inode),
 					  mapping, pages, nr_pages,
 					  nfs_readpage_from_fscache_complete,
 					  ctx,
@@ -506,15 +422,15 @@ void __nfs_readpage_to_fscache(struct inode *inode, struct page *page, int sync)
 
 	dfprintk(FSCACHE,
 		 "NFS: readpage_to_fscache(fsc:%p/p:%p(i:%lx f:%lx)/%d)\n",
-		 NFS_I(inode)->fscache, page, page->index, page->flags, sync);
+		 nfs_i_fscache(inode), page, page->index, page->flags, sync);
 
-	ret = fscache_write_page(NFS_I(inode)->fscache, page, GFP_KERNEL);
+	ret = fscache_write_page(nfs_i_fscache(inode), page, GFP_KERNEL);
 	dfprintk(FSCACHE,
 		 "NFS:     readpage_to_fscache: p:%p(i:%lu f:%lx) ret %d\n",
 		 page, page->index, page->flags, ret);
 
 	if (ret != 0) {
-		fscache_uncache_page(NFS_I(inode)->fscache, page);
+		fscache_uncache_page(nfs_i_fscache(inode), page);
 		nfs_add_fscache_stats(inode,
 				      NFSIOS_FSCACHE_PAGES_WRITTEN_FAIL, 1);
 		nfs_add_fscache_stats(inode, NFSIOS_FSCACHE_PAGES_UNCACHED, 1);
diff --git a/fs/nfs/fscache.h b/fs/nfs/fscache.h
index 4ecb766..d7fe3e7 100644
--- a/fs/nfs/fscache.h
+++ b/fs/nfs/fscache.h
@@ -76,11 +76,9 @@ extern void nfs_fscache_release_client_cookie(struct nfs_client *);
 extern void nfs_fscache_get_super_cookie(struct super_block *, const char *, int);
 extern void nfs_fscache_release_super_cookie(struct super_block *);
 
-extern void nfs_fscache_init_inode_cookie(struct inode *);
-extern void nfs_fscache_release_inode_cookie(struct inode *);
-extern void nfs_fscache_zap_inode_cookie(struct inode *);
-extern void nfs_fscache_set_inode_cookie(struct inode *, struct file *);
-extern void nfs_fscache_reset_inode_cookie(struct inode *);
+extern void nfs_fscache_init_inode(struct inode *);
+extern void nfs_fscache_clear_inode(struct inode *);
+extern void nfs_fscache_open_file(struct inode *, struct file *);
 
 extern void __nfs_fscache_invalidate_page(struct page *, struct inode *);
 extern int nfs_fscache_release_page(struct page *, gfp_t);
@@ -187,12 +185,10 @@ static inline void nfs_fscache_release_client_cookie(struct nfs_client *clp) {}
 
 static inline void nfs_fscache_release_super_cookie(struct super_block *sb) {}
 
-static inline void nfs_fscache_init_inode_cookie(struct inode *inode) {}
-static inline void nfs_fscache_release_inode_cookie(struct inode *inode) {}
-static inline void nfs_fscache_zap_inode_cookie(struct inode *inode) {}
-static inline void nfs_fscache_set_inode_cookie(struct inode *inode,
-						struct file *filp) {}
-static inline void nfs_fscache_reset_inode_cookie(struct inode *inode) {}
+static inline void nfs_fscache_init_inode(struct inode *inode) {}
+static inline void nfs_fscache_clear_inode(struct inode *inode) {}
+static inline void nfs_fscache_open_file(struct inode *inode,
+					 struct file *filp) {}
 
 static inline int nfs_fscache_release_page(struct page *page, gfp_t gfp)
 {
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index eda8879..bb90bff 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -122,7 +122,7 @@ void nfs_clear_inode(struct inode *inode)
 	WARN_ON_ONCE(!list_empty(&NFS_I(inode)->open_files));
 	nfs_zap_acl_cache(inode);
 	nfs_access_zap_cache(inode);
-	nfs_fscache_release_inode_cookie(inode);
+	nfs_fscache_clear_inode(inode);
 }
 EXPORT_SYMBOL_GPL(nfs_clear_inode);
 
@@ -459,7 +459,7 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 		nfsi->attrtimeo_timestamp = now;
 		nfsi->access_cache = RB_ROOT;
 
-		nfs_fscache_init_inode_cookie(inode);
+		nfs_fscache_init_inode(inode);
 
 		unlock_new_inode(inode);
 	} else
@@ -854,7 +854,7 @@ int nfs_open(struct inode *inode, struct file *filp)
 		return PTR_ERR(ctx);
 	nfs_file_set_open_context(filp, ctx);
 	put_nfs_open_context(ctx);
-	nfs_fscache_set_inode_cookie(inode, filp);
+	nfs_fscache_open_file(inode, filp);
 	return 0;
 }
 
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index e5b804d..5b8a618 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -74,7 +74,7 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 	nfs_file_set_open_context(filp, ctx);
-	nfs_fscache_set_inode_cookie(inode, filp);
+	nfs_fscache_open_file(inode, filp);
 	err = 0;
 
 out_put_ctx:
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3f40547..955dff5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2292,6 +2292,11 @@ static inline void allow_write_access(struct file *file)
 	if (file)
 		atomic_inc(&file_inode(file)->i_writecount);
 }
+static inline bool inode_is_open_for_write(const struct inode *inode)
+{
+	return atomic_read(&inode->i_writecount) > 0;
+}
+
 #ifdef CONFIG_IMA
 static inline void i_readcount_dec(struct inode *inode)
 {
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 3ea4cde..14a4820 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -269,9 +269,13 @@ static inline int NFS_STALE(const struct inode *inode)
 	return test_bit(NFS_INO_STALE, &NFS_I(inode)->flags);
 }
 
-static inline int NFS_FSCACHE(const struct inode *inode)
+static inline struct fscache_cookie *nfs_i_fscache(struct inode *inode)
 {
-	return test_bit(NFS_INO_FSCACHE, &NFS_I(inode)->flags);
+#ifdef CONFIG_NFS_FSCACHE
+	return NFS_I(inode)->fscache;
+#else
+	return NULL;
+#endif
 }
 
 static inline __u64 NFS_FILEID(const struct inode *inode)

