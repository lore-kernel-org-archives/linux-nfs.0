Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:54218 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751209AbaLIVTT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 16:19:19 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: Fix use of nfs_attr_use_mounted_on_fileid()
Date: Tue, 9 Dec 2014 16:19:16 -0500
Message-ID: <1418159956-10853-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This function call was being optimized out during nfs_fhget(), leading
to situations where we have a valid fileid but still want to use the
mounted_on_fileid.  For example, imagine we have our server configured
like this:

server % df
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda1       9.1G  6.5G  1.9G  78% /
/dev/vdb1       487M  2.3M  456M   1% /exports
/dev/vdc1       487M  2.3M  456M   1% /exports/vol1
/dev/vdd1       487M  2.3M  456M   1% /exports/vol2

If our client mounts /exports and tries to do a "chown -R" across the
entire mountpoint, we will get a nasty message warning us about a circular
directory structure.  Running chown with strace tells me that each directory
has the same device and inode number:

newfstatat(AT_FDCWD, "/nfs/", {st_dev=makedev(0, 38), st_ino=2, ...}) = 0
newfstatat(4, "vol1", {st_dev=makedev(0, 38), st_ino=2, ...}) = 0
newfstatat(4, "vol2", {st_dev=makedev(0, 38), st_ino=2, ...}) = 0

With this patch the mounted_on_fileid values are used for st_ino, so the
directory loop warning isn't reported.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/inode.c    | 5 +++--
 fs/nfs/internal.h | 2 --
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 4bffe63..2211f6b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -352,8 +352,9 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 
 	nfs_attr_check_mountpoint(sb, fattr);
 
-	if (((fattr->valid & NFS_ATTR_FATTR_FILEID) == 0) &&
-	    !nfs_attr_use_mounted_on_fileid(fattr))
+	if (nfs_attr_use_mounted_on_fileid(fattr))
+		fattr->fileid = fattr->mounted_on_fileid;
+	else if ((fattr->valid & NFS_ATTR_FATTR_FILEID) == 0)
 		goto out_no_inode;
 	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) == 0)
 		goto out_no_inode;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index efaa31c..b6f34bf 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -31,8 +31,6 @@ static inline int nfs_attr_use_mounted_on_fileid(struct nfs_fattr *fattr)
 	    (((fattr->valid & NFS_ATTR_FATTR_MOUNTPOINT) == 0) &&
 	     ((fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL) == 0)))
 		return 0;
-
-	fattr->fileid = fattr->mounted_on_fileid;
 	return 1;
 }
 
-- 
2.1.3

