Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f48.google.com ([209.85.220.48]:51567 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbaDOJX2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Apr 2014 05:23:28 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so9369995pad.21
        for <linux-nfs@vger.kernel.org>; Tue, 15 Apr 2014 02:23:28 -0700 (PDT)
Message-ID: <534CFA73.4040801@gmail.com>
Date: Tue, 15 Apr 2014 17:22:59 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix memroy leak for double mounts
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When double mounting same nfs filesystem, the devname saved in d_fsdata
will be lost.The second mount should not change the devname that
be saved in d_fsdata.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/getroot.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index 66984a9..b94f804 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -120,7 +120,8 @@ struct dentry *nfs_get_root(struct super_block *sb,
struct nfs_fh *mntfh,

 	security_d_instantiate(ret, inode);
 	spin_lock(&ret->d_lock);
-	if (IS_ROOT(ret) && !(ret->d_flags & DCACHE_NFSFS_RENAMED)) {
+	if (IS_ROOT(ret) && !ret->d_fsdata &&
+	    !(ret->d_flags & DCACHE_NFSFS_RENAMED)) {
 		ret->d_fsdata = name;
 		name = NULL;
 	}
-- 
1.9.0

