Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37288 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964824AbeCAAZj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Feb 2018 19:25:39 -0500
Received: by mail-pg0-f66.google.com with SMTP id y26so1618269pgv.4
        for <linux-nfs@vger.kernel.org>; Wed, 28 Feb 2018 16:25:39 -0800 (PST)
From: "Eric Rannaud" <e@nanocritical.com>
To: linux-nfs@vger.kernel.org
Cc: Eric Rannaud <e@nanocritical.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.Schumaker@netapp.com>,
        Jessica Peters <jessica.peters@netapp.com>
Subject: [PATCH] nfs: nfs_fileid_valid() is wrong on NFSv3 and incomplete on NFSv4
Date: Wed, 28 Feb 2018 16:25:05 -0800
Message-Id: <643b19f35980727fbf9a1756c33a59981b538dd0.1519862053.git.e@nanocritical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On NFSv3, in normal circumstances, NFS_ATTR_FATTR_MOUNTED_ON_FILEID is
not set on fattr->valid. It is only set in nfs3_decode_dirent() if
entry->fattr->fileid != entry->ino, which typically only happens for
mountpoints. (See 1ae04b252351 NFSv3: Use the readdir fileid as the
mounted-on-fileid.)

nfs_fileid_valid() returns 'ret1 || ret2', initializing both ret1 and
ret2 to true, but sets them only conditionally. Therefore, in normal
circumstances, nfs_fileid_valid() wrongly returns 'false || true' when
the fileid has changed.

There is another bug in this function for NFSv4: a server may return a
fattr with NFS_ATTR_FATTR_FILEID|NFS_ATTR_FATTR_MOUNTED_ON_FILEID.
nfs_fileid_valid() will fail to detect a change in fileid in the case
where the fattr->fileid happens to match, by chance, the stored
nfsi->fileid (copied from a previous fattr->mounted_on_fileid).

If this is a mountpoint, the current fattr->fileid and the old
fattr->mounted_on_fileid come from different filesystems and may well
happen to be identical.

The condition should be written as an if / else if:

	if (fattr->valid & NFS_ATTR_FATTR_MOUNTED_ON_FILEID)
	else if (fattr->valid & NFS_ATTR_FATTR_FILEID)

as is done elsewhere in NFSv4 code.
---
 fs/nfs/inode.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 7d893543cf3b..e1ad5ec75795 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1717,13 +1717,11 @@ EXPORT_SYMBOL_GPL(nfs_post_op_update_inode_force_wcc);
 static inline bool nfs_fileid_valid(struct nfs_inode *nfsi,
 				    struct nfs_fattr *fattr)
 {
-	bool ret1 = true, ret2 = true;
-
-	if (fattr->valid & NFS_ATTR_FATTR_FILEID)
-		ret1 = (nfsi->fileid == fattr->fileid);
 	if (fattr->valid & NFS_ATTR_FATTR_MOUNTED_ON_FILEID)
-		ret2 = (nfsi->fileid == fattr->mounted_on_fileid);
-	return ret1 || ret2;
+		return nfsi->fileid == fattr->mounted_on_fileid;
+	else if (fattr->valid & NFS_ATTR_FATTR_FILEID)
+		return nfsi->fileid == fattr->fileid;
+	return true;
 }
 
 /*
-- 
2.16.2

