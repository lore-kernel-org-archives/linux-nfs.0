Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55449 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750729AbdHRHOL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Aug 2017 03:14:11 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 18 Aug 2017 17:12:52 +1000
Subject: [PATCH 6/8] NFS: flush data when locking a file to ensure cache
 coherence for mmap.
Cc: linux-nfs@vger.kernel.org
Message-ID: <150304037202.30218.1015616186302440289.stgit@noble>
In-Reply-To: <150304014011.30218.1636255532744321171.stgit@noble>
References: <150304014011.30218.1636255532744321171.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a byte range lock (or flock) is taken out on an NFS file, the
validity of the cached data is checked and the inode is marked
NFS_INODE_INVALID_DATA.  However the cached data isn't flushed from
the page cache.

This is sufficient for future read() requests or mmap() requests as
they call nfs_revalidate_mapping() which performs the flush if
necessary.

However an existing mapping is not affected.  Accessing data through
that mapping will continue to return old data even though the inode is
marked NFS_INODE_INVALID_DATA.

This can easily be confirmed using the 'nfs' tool in
  git://github.com/okirch/twopence-nfs.git
and running

   nfs coherence FILENAME
on one client, and
   nfs coherence -r FILENAME
on another client.

It appears that prior to Linux 2.6.0 this worked correctly.

However commit:

http://git.kernel.org/cgit/linux/kernel/git/history/history.git/commit/?id=ca9268fe3ddd075714005adecd4afbd7f9ab87d0

removed the call to inode_invalidate_pages() from nfs_zap_caches().  I
haven't tested this code, but inspection suggests that prior to this
commit, file locking would invalidate all inode pages.

This patch adds a call to nfs_revalidate_mapping() after a
successful SETLK so that invalid data is flushed.  With this patch the
above test passes.  To minimize impact (and possibly avoid a GETATTR
call) this only happens if the mapping might be mapped into
userspace.

Cc: Olaf Kirch <okir@suse.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/file.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index aa883d8b24e6..d67cd3dbfa67 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -750,15 +750,18 @@ do_setlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 		goto out;
 
 	/*
-	 * Revalidate the cache if the server has time stamps granular
-	 * enough to detect subsecond changes.  Otherwise, clear the
-	 * cache to prevent missing any changes.
+	 * Invalidate cache to prevent missing any changes.  If
+	 * the file is mapped, clear the page cache as well so
+	 * those mappings will be loaded.
 	 *
 	 * This makes locking act as a cache coherency point.
 	 */
 	nfs_sync_mapping(filp->f_mapping);
-	if (!NFS_PROTO(inode)->have_delegation(inode, FMODE_READ))
+	if (!NFS_PROTO(inode)->have_delegation(inode, FMODE_READ)) {
 		nfs_zap_caches(inode);
+		if (mapping_mapped(filp->f_mapping))
+			nfs_revalidate_mapping(inode, filp->f_mapping);
+	}
 out:
 	return status;
 }


