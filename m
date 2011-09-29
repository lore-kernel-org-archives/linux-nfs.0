Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32338 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471Ab1I2OtO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Sep 2011 10:49:14 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 13/13] NFS: Use FS-Cache invalidation
To: moseleymark@gmail.com, mark@pogo.org.uk, jlayton@redhat.com,
        steved@redhat.com
Cc: linux-cachefs@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Date: Thu, 29 Sep 2011 15:48:14 +0100
Message-ID: <20110929144813.5812.6884.stgit@warthog.procyon.org.uk>
In-Reply-To: <20110929144536.5812.84405.stgit@warthog.procyon.org.uk>
References: <20110929144536.5812.84405.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Use the new FS-Cache invalidation facility from NFS to deal with foreign
changes being detected on the server rather than attempting to retire the old
cookie and get a new one.

The problem with the old method was that NFS did not wait for all outstanding
storage and retrieval ops on the cache to complete.  There was no automatic
wait between the calls to ->readpages() and calls to invalidate_inode_pages2()
as the latter can only wait on locked pages that have been added to the
pagecache (which they haven't yet on entry to ->readpages()).

This was leading to oopses like the one below when an outstanding read got cut
off from its cookie by a premature release.

BUG: unable to handle kernel NULL pointer dereference at 00000000000000a8
IP: [<ffffffffa0075118>] __fscache_read_or_alloc_pages+0x1dd/0x315 [fscache]
PGD 15889067 PUD 15890067 PMD 0
Oops: 0000 [#1] SMP
CPU 0
Modules linked in: cachefiles nfs fscache auth_rpcgss nfs_acl lockd sunrpc

Pid: 4544, comm: tar Not tainted 3.1.0-rc4-fsdevel+ #1064                  /DG965RY
RIP: 0010:[<ffffffffa0075118>]  [<ffffffffa0075118>] __fscache_read_or_alloc_pages+0x1dd/0x315 [fscache]
RSP: 0018:ffff8800158799e8  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff8800070d41e0 RCX: ffff8800083dc1b0
RDX: 0000000000000000 RSI: ffff880015879960 RDI: ffff88003e627b90
RBP: ffff880015879a28 R08: 0000000000000002 R09: 0000000000000002
R10: 0000000000000001 R11: ffff880015879950 R12: ffff880015879aa4
R13: 0000000000000000 R14: ffff8800083dc158 R15: ffff880015879be8
FS:  00007f671e9d87c0(0000) GS:ffff88003bc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000000000000a8 CR3: 000000001587f000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process tar (pid: 4544, threadinfo ffff880015878000, task ffff880015875040)
Stack:
 ffffffffa00b1759 ffff8800070dc158 ffff8800000213da ffff88002a286508
 ffff880015879aa4 ffff880015879be8 0000000000000001 ffff88002a2866e8
 ffff880015879a88 ffffffffa00b20be 00000000000200da ffff880015875040
Call Trace:
 [<ffffffffa00b1759>] ? nfs_fscache_wait_bit+0xd/0xd [nfs]
 [<ffffffffa00b20be>] __nfs_readpages_from_fscache+0x7e/0x13f [nfs]
 [<ffffffff81095fe7>] ? __alloc_pages_nodemask+0x156/0x662
 [<ffffffffa0098763>] nfs_readpages+0xee/0x187 [nfs]
 [<ffffffff81098a5e>] __do_page_cache_readahead+0x1be/0x267
 [<ffffffff81098942>] ? __do_page_cache_readahead+0xa2/0x267
 [<ffffffff81098d7b>] ra_submit+0x1c/0x20
 [<ffffffff8109900a>] ondemand_readahead+0x28b/0x29a
 [<ffffffff810990ce>] page_cache_sync_readahead+0x38/0x3a
 [<ffffffff81091d8a>] generic_file_aio_read+0x2ab/0x67e
 [<ffffffffa008cfbe>] nfs_file_read+0xa4/0xc9 [nfs]
 [<ffffffff810c22c4>] do_sync_read+0xba/0xfa
 [<ffffffff810a62c9>] ? might_fault+0x4e/0x9e
 [<ffffffff81177a47>] ? security_file_permission+0x7b/0x84
 [<ffffffff810c25dd>] ? rw_verify_area+0xab/0xc8
 [<ffffffff810c29a4>] vfs_read+0xaa/0x13a
 [<ffffffff810c2a79>] sys_read+0x45/0x6c
 [<ffffffff813ac37b>] system_call_fastpath+0x16/0x1b

Reported-by: Mark Moseley <moseleymark@gmail.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/fscache.h  |   20 +++++++++++++++++++-
 fs/nfs/inode.c    |   20 ++++++++++++++++----
 fs/nfs/nfs4proc.c |    2 ++
 3 files changed, 37 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/fscache.h b/fs/nfs/fscache.h
index b9c572d..851fee1 100644
--- a/fs/nfs/fscache.h
+++ b/fs/nfs/fscache.h
@@ -155,6 +155,22 @@ static inline void nfs_readpage_to_fscache(struct inode *inode,
 }
 
 /*
+ * Invalidate the contents of fscache for this inode.  This will not sleep.
+ */
+static inline void nfs_fscache_invalidate(struct inode *inode)
+{
+	fscache_invalidate(NFS_I(inode)->fscache);
+}
+
+/*
+ * Wait for an object to finish being invalidated.
+ */
+static inline void nfs_fscache_wait_on_invalidate(struct inode *inode)
+{
+	fscache_wait_on_invalidate(NFS_I(inode)->fscache);
+}
+
+/*
  * indicate the client caching state as readable text
  */
 static inline const char *nfs_server_fscache_state(struct nfs_server *server)
@@ -164,7 +180,6 @@ static inline const char *nfs_server_fscache_state(struct nfs_server *server)
 	return "no ";
 }
 
-
 #else /* CONFIG_NFS_FSCACHE */
 static inline int nfs_fscache_register(void) { return 0; }
 static inline void nfs_fscache_unregister(void) {}
@@ -213,6 +228,9 @@ static inline int nfs_readpages_from_fscache(struct nfs_open_context *ctx,
 static inline void nfs_readpage_to_fscache(struct inode *inode,
 					   struct page *page, int sync) {}
 
+
+static inline void nfs_fscache_invalidate(struct inode *inode) {}
+
 static inline const char *nfs_server_fscache_state(struct nfs_server *server)
 {
 	return "no ";
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index fe12037..24ea1f8 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -151,10 +151,12 @@ static void nfs_zap_caches_locked(struct inode *inode)
 	nfsi->attrtimeo_timestamp = jiffies;
 
 	memset(NFS_COOKIEVERF(inode), 0, sizeof(NFS_COOKIEVERF(inode)));
-	if (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode))
+	if (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode)) {
 		nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL|NFS_INO_REVAL_PAGECACHE;
-	else
+		nfs_fscache_invalidate(inode);
+	} else {
 		nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL|NFS_INO_REVAL_PAGECACHE;
+	}
 }
 
 void nfs_zap_caches(struct inode *inode)
@@ -169,6 +171,7 @@ void nfs_zap_mapping(struct inode *inode, struct address_space *mapping)
 	if (mapping->nrpages != 0) {
 		spin_lock(&inode->i_lock);
 		NFS_I(inode)->cache_validity |= NFS_INO_INVALID_DATA;
+		nfs_fscache_invalidate(inode);
 		spin_unlock(&inode->i_lock);
 	}
 }
@@ -861,7 +864,7 @@ static int nfs_invalidate_mapping(struct inode *inode, struct address_space *map
 		memset(nfsi->cookieverf, 0, sizeof(nfsi->cookieverf));
 	spin_unlock(&inode->i_lock);
 	nfs_inc_stats(inode, NFSIOS_DATAINVALIDATE);
-	nfs_fscache_reset_inode_cookie(inode);
+	nfs_fscache_wait_on_invalidate(inode);
 	dfprintk(PAGECACHE, "NFS: (%s/%Ld) data cache invalidated\n",
 			inode->i_sb->s_id, (long long)NFS_FILEID(inode));
 	return 0;
@@ -926,6 +929,10 @@ static unsigned long nfs_wcc_update_inode(struct inode *inode, struct nfs_fattr
 		i_size_write(inode, nfs_size_to_loff_t(fattr->size));
 		ret |= NFS_INO_INVALID_ATTR;
 	}
+
+	if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
+		nfs_fscache_invalidate(inode);
+
 	return ret;
 }
 
@@ -1105,8 +1112,10 @@ static int nfs_post_op_update_inode_locked(struct inode *inode, struct nfs_fattr
 	struct nfs_inode *nfsi = NFS_I(inode);
 
 	nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_REVAL_PAGECACHE;
-	if (S_ISDIR(inode->i_mode))
+	if (S_ISDIR(inode->i_mode)) {
 		nfsi->cache_validity |= NFS_INO_INVALID_DATA;
+		nfs_fscache_invalidate(inode);
+	}
 	if ((fattr->valid & NFS_ATTR_FATTR) == 0)
 		return 0;
 	return nfs_refresh_inode_locked(inode, fattr);
@@ -1398,6 +1407,9 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			(save_cache_validity & NFS_INO_REVAL_FORCED))
 		nfsi->cache_validity |= invalid;
 
+	if (invalid & NFS_INO_INVALID_DATA)
+		nfs_fscache_invalidate(inode);
+
 	return 0;
  out_changed:
 	/*
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4700fae..d6b9734 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -60,6 +60,7 @@
 #include "iostat.h"
 #include "callback.h"
 #include "pnfs.h"
+#include "fscache.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
@@ -756,6 +757,7 @@ static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 	if (!cinfo->atomic || cinfo->before != nfsi->change_attr)
 		nfs_force_lookup_revalidate(dir);
 	nfsi->change_attr = cinfo->after;
+	nfs_fscache_invalidate(dir);
 	spin_unlock(&dir->i_lock);
 }
 

