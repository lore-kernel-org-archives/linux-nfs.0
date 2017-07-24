Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41277 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752092AbdGXDbh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 23 Jul 2017 23:31:37 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 24 Jul 2017 13:18:50 +1000
Subject: [PATCH 1/2] NFS: invalidate file size when taking a lock.
Cc: linux-nfs@vger.kernel.org
Message-ID: <150086633057.13837.5774453985896444097.stgit@noble>
In-Reply-To: <150086579083.13837.3550463220871996964.stgit@noble>
References: <150086579083.13837.3550463220871996964.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Prior to commit ca0daa277aca ("NFS: Cache aggressively when file is open
for writing"), NFS would revalidate, or invalidate, the file size when
taking a lock.  Since that commit it only invalidates the file content.

If the file size is changed on the server while wait for the lock, the
client will have an incorrect understanding of the file size and could
corrupt data.  This particularly happens when writing beyond the
(supposed) end of file and can be easily be demonstrated with
posix_fallocate().

If an application opens an empty file, waits for a write lock, and then
calls posix_fallocate(), glibc will determine that the underlying
filesystem doesn't support fallocate (assuming version 4.1 or earlier)
and will write out a '0' byte at the end of each 4K page in the region
being fallocated that is after the end of the file.
NFS will (usually) detect that these writes are beyond EOF and will
expand them to cover the whole page, and then will merge the pages.
Consequently, NFS will write out large blocks of zeroes beyond where it
thought EOF was.  If EOF had moved, the pre-existing part of the file
will be over-written.  Locking should have protected against this,
but it doesn't.

This patch restores the use of nfs_zap_caches() which invalidated the
cached attributes.  When posix_fallocate() asks for the file size, the
request will go to the server and get a correct answer.

cc: stable@vger.kernel.org (v4.8+)
Fixes: ca0daa277aca ("NFS: Cache aggressively when file is open for writing")
Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/file.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 5713eb32a45e..d264363559db 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -750,7 +750,7 @@ do_setlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	 */
 	nfs_sync_mapping(filp->f_mapping);
 	if (!NFS_PROTO(inode)->have_delegation(inode, FMODE_READ))
-		nfs_zap_mapping(inode, filp->f_mapping);
+		nfs_zap_caches(inode);
 out:
 	return status;
 }


