Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29922 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755863Ab1GGLU1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jul 2011 07:20:27 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] FS-Cache: Add a helper to bulk uncache pages on an inode
To: torvalds@osdl.org, akpm@linux-foundation.com
Cc: sjayaraman@suse.de, jlayton@redhat.com, linux-cifs@vger.kernel.org,
        linux-cachefs@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, stable@kernel.org,
        David Howells <dhowells@redhat.com>, stable@kernel.org
Date: Thu, 07 Jul 2011 12:19:48 +0100
Message-ID: <20110707111948.3704.24268.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Add an FS-Cache helper to bulk uncache pages on an inode.  This will only work
for the circumstance where the pages in the cache correspond 1:1 with the pages
attached to an inode's page cache.

This is required for CIFS and NFS: When disabling inode cookie, we were
returning the cookie and setting cifsi->fscache to NULL but failed to
invalidate any previously mapped pages.  This resulted in "Bad page state"
errors and manifested in other kind of errors when running fsstress.  Fix it by
uncaching mapped pages when we disable the inode cookie.

This patch should fix the following oops and "Bad page state" errors seen
during fsstress testing.

[  417.302635] ------------[ cut here ]------------
[  417.304903] kernel BUG at fs/cachefiles/namei.c:201!
[  417.307613] invalid opcode: 0000 [#1] SMP
[  417.309860] last sysfs file: /sys/devices/system/cpu/cpu1/cache/index2/shared_cpu_map
[  417.313868] CPU 1
[  417.314855] Modules linked in: fuse nls_utf8 cifs sunrpc cachefiles fscache ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables joydev microcode i2c_piix4 virtio_balloon i2c_core virtio_net ipv6 virtio_blk [last unloaded: mperf]
[  417.328983]
[  417.329923] Pid: 5, comm: kworker/u:0 Not tainted 2.6.38.7-30.fc15.x86_64 #1 Bochs Bochs
[  417.333928] RIP: 0010:[<ffffffffa00bebe4>]  [<ffffffffa00bebe4>] cachefiles_walk_to_object+0x436/0x745 [cachefiles]
[  417.338967] RSP: 0018:ffff88002ce6dd00  EFLAGS: 00010282
[  417.341761] RAX: ffff88002ef165f0 RBX: ffff88001811f500 RCX: 0000000000000000
[  417.344943] RDX: 0000000000000000 RSI: 0000000000000100 RDI: 0000000000000282
[  417.348639] RBP: ffff88002ce6dda0 R08: 0000000000000100 R09: ffffffff81b3a300
[  417.351813] R10: 0000ffff00066c0a R11: 0000000000000003 R12: ffff88002ae54840
[  417.355522] R13: ffff88002ae54840 R14: ffff880029c29c00 R15: ffff88001811f4b0
[  417.358879] FS:  00007f394dd32720(0000) GS:ffff88002ef00000(0000) knlGS:0000000000000000
[  417.362780] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  417.365651] CR2: 00007fffcb62ddf8 CR3: 000000001825f000 CR4: 00000000000006e0
[  417.368830] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  417.372688] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  417.375876] Process kworker/u:0 (pid: 5, threadinfo ffff88002ce6c000, task ffff88002ce55cc0)
[  417.379863] Stack:
[  417.380891]  0000000000000246 ffff88002ce55cc0 ffff88002ce6dd58 ffff88001815dc00
[  417.384864]  ffff8800185246c0 ffff88001811f618 ffff880029c29d18 ffff88001811f380
[  417.388935]  ffff88002ce6dd50 ffffffff814757e4 ffff88002ce6dda0 ffffffff8106ac56
[  417.392907] Call Trace:
[  417.394580]  [<ffffffff814757e4>] ? _raw_spin_unlock_irqrestore+0x17/0x19
[  417.397739]  [<ffffffff8106ac56>] ? __queue_work+0x256/0x265
[  417.400607]  [<ffffffffa00bd91f>] cachefiles_lookup_object+0x78/0xd4 [cachefiles]
[  417.403898]  [<ffffffffa00a9977>] ? fscache_object_work_func+0x0/0x669 [fscache]
[  417.407659]  [<ffffffffa00a95da>] fscache_lookup_object+0x131/0x16d [fscache]
[  417.410832]  [<ffffffffa00a9b33>] fscache_object_work_func+0x1bc/0x669 [fscache]
[  417.414598]  [<ffffffffa00a9977>] ? fscache_object_work_func+0x0/0x669 [fscache]
[  417.417956]  [<ffffffff8106afb6>] process_one_work+0x186/0x298
[  417.420876]  [<ffffffff8106b343>] worker_thread+0xda/0x15d
[  417.423693]  [<ffffffff8106b269>] ? worker_thread+0x0/0x15d
[  417.426546]  [<ffffffff8106b269>] ? worker_thread+0x0/0x15d
[  417.428877]  [<ffffffff8106ebaf>] kthread+0x84/0x8c
[  417.431712]  [<ffffffff8100a9e4>] kernel_thread_helper+0x4/0x10
[  417.434615]  [<ffffffff8106eb2b>] ? kthread+0x0/0x8c
[  417.436809]  [<ffffffff8100a9e0>] ? kernel_thread_helper+0x0/0x10
[  417.439746] Code: 05 77 2a 48 c7 c7 ce 1c 0c a0 31 c0 e8 c6 db 3a e1 48 c7 c7 77 1f 0c a0 31 c0 e8 b8 db 3a e1 48 8b 75 98 48 89 df e8 ae 23 00 00 <0f> 0b 48 8b 55 98 f0 ff 82 20 01 00 00 48 8b 7d 90 e8 86 f5 ff
[  417.453802] RIP  [<ffffffffa00bebe4>] cachefiles_walk_to_object+0x436/0x745 [cachefiles]
[  417.457781]  RSP <ffff88002ce6dd00>
[  417.459638] ---[ end trace 1d481c9af1804caa ]---


I tested the uncaching by the following means:

 (1) Create a big file on my NFS server (104857600 bytes).

 (2) Read the file into the cache with md5sum on the NFS client.  Look in
     /proc/fs/fscache/stats:

	Pages  : mrk=25601 unc=0

 (3) Open the file for read/write ("bash 5<>/warthog/bigfile").  Look in proc
     again:

	Pages  : mrk=25601 unc=25601

Reported-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-and-Tested-by: Suresh Jayaraman <sjayaraman@suse.de>
cc: stable@kernel.org
---

 Documentation/filesystems/caching/netfs-api.txt |   16 ++++++++
 fs/cifs/fscache.c                               |    1 +
 fs/fscache/page.c                               |   44 +++++++++++++++++++++++
 fs/nfs/fscache.c                                |    8 ++--
 include/linux/fscache.h                         |   21 +++++++++++
 5 files changed, 85 insertions(+), 5 deletions(-)

diff --git a/Documentation/filesystems/caching/netfs-api.txt b/Documentation/filesystems/caching/netfs-api.txt
index a167ab8..7cc6bf2 100644
--- a/Documentation/filesystems/caching/netfs-api.txt
+++ b/Documentation/filesystems/caching/netfs-api.txt
@@ -673,6 +673,22 @@ storage request to complete, or it may attempt to cancel the storage request -
 in which case the page will not be stored in the cache this time.
 
 
+BULK INODE PAGE UNCACHE
+-----------------------
+
+A convenience routine is provided to perform an uncache on all the pages
+attached to an inode.  This assumes that the pages on the inode correspond on a
+1:1 basis with the pages in the cache.
+
+	void fscache_uncache_all_inode_pages(struct fscache_cookie *cookie,
+					     struct inode *inode);
+
+This takes the netfs cookie that the pages were cached with and the inode that
+the pages are attached to.  This function will wait for pages to finish being
+written to the cache and for the cache to finish with the page generally.  No
+error is returned.
+
+
 ==========================
 INDEX AND DATA FILE UPDATE
 ==========================
diff --git a/fs/cifs/fscache.c b/fs/cifs/fscache.c
index 8166966..42e5363 100644
--- a/fs/cifs/fscache.c
+++ b/fs/cifs/fscache.c
@@ -92,6 +92,7 @@ static void cifs_fscache_disable_inode_cookie(struct inode *inode)
 
 	if (cifsi->fscache) {
 		cFYI(1, "%s: (0x%p)", __func__, cifsi->fscache);
+		fscache_uncache_all_inode_pages(cifsi->fscache, inode);
 		fscache_relinquish_cookie(cifsi->fscache, 1);
 		cifsi->fscache = NULL;
 	}
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index 0b5433d..60315b3 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -971,3 +971,47 @@ void fscache_mark_pages_cached(struct fscache_retrieval *op,
 	pagevec_reinit(pagevec);
 }
 EXPORT_SYMBOL(fscache_mark_pages_cached);
+
+/*
+ * Uncache all the pages in an inode that are marked PG_fscache, assuming them
+ * to be associated with the given cookie.
+ */
+void __fscache_uncache_all_inode_pages(struct fscache_cookie *cookie,
+				       struct inode *inode)
+{
+	struct address_space *mapping = inode->i_mapping;
+	struct pagevec pvec;
+	pgoff_t next;
+	int i;
+
+	_enter("%p,%p", cookie, inode);
+
+	if (!mapping || mapping->nrpages == 0) {
+		_leave(" [no pages]");
+		return;
+	}
+
+	pagevec_init(&pvec, 0);
+	next = 0;
+	while (next <= (loff_t)-1 &&
+	       pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)
+	       ) {
+		for (i = 0; i < pagevec_count(&pvec); i++) {
+			struct page *page = pvec.pages[i];
+			pgoff_t page_index = page->index;
+
+			ASSERTCMP(page_index, >=, next);
+			next = page_index + 1;
+
+			if (PageFsCache(page)) {
+				__fscache_wait_on_page_write(cookie, page);
+				__fscache_uncache_page(cookie, page);
+			}
+		}
+		pagevec_release(&pvec);
+		cond_resched();
+	}
+
+	_leave("");
+}
+EXPORT_SYMBOL(__fscache_uncache_all_inode_pages);
diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index ce153a6..419119c 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -259,12 +259,10 @@ static void nfs_fscache_disable_inode_cookie(struct inode *inode)
 		dfprintk(FSCACHE,
 			 "NFS: nfsi 0x%p turning cache off\n", NFS_I(inode));
 
-		/* Need to invalidate any mapped pages that were read in before
-		 * turning off the cache.
+		/* Need to uncache any pages attached to this inode that
+		 * fscache knows about before turning off the cache.
 		 */
-		if (inode->i_mapping && inode->i_mapping->nrpages)
-			invalidate_inode_pages2(inode->i_mapping);
-
+		fscache_uncache_all_inode_pages(NFS_I(inode)->fscache, inode);
 		nfs_fscache_zap_inode_cookie(inode);
 	}
 }
diff --git a/include/linux/fscache.h b/include/linux/fscache.h
index 7c4d72f..9ec20de 100644
--- a/include/linux/fscache.h
+++ b/include/linux/fscache.h
@@ -204,6 +204,8 @@ extern bool __fscache_check_page_write(struct fscache_cookie *, struct page *);
 extern void __fscache_wait_on_page_write(struct fscache_cookie *, struct page *);
 extern bool __fscache_maybe_release_page(struct fscache_cookie *, struct page *,
 					 gfp_t);
+extern void __fscache_uncache_all_inode_pages(struct fscache_cookie *,
+					      struct inode *);
 
 /**
  * fscache_register_netfs - Register a filesystem as desiring caching services
@@ -643,4 +645,23 @@ bool fscache_maybe_release_page(struct fscache_cookie *cookie,
 	return false;
 }
 
+/**
+ * fscache_uncache_all_inode_pages - Uncache all an inode's pages
+ * @cookie: The cookie representing the inode's cache object.
+ * @inode: The inode to uncache pages from.
+ *
+ * Uncache all the pages in an inode that are marked PG_fscache, assuming them
+ * to be associated with the given cookie.
+ *
+ * This function may sleep.  It will wait for pages that are being written out
+ * and will wait whilst the PG_fscache mark is removed by the cache.
+ */
+static inline
+void fscache_uncache_all_inode_pages(struct fscache_cookie *cookie,
+				     struct inode *inode)
+{
+	if (fscache_cookie_valid(cookie))
+		__fscache_uncache_all_inode_pages(cookie, inode);
+}
+
 #endif /* _LINUX_FSCACHE_H */

