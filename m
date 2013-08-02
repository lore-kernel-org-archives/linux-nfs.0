Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f180.google.com ([209.85.217.180]:33689 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753244Ab3HBPjl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Aug 2013 11:39:41 -0400
Received: by mail-lb0-f180.google.com with SMTP id a16so547277lbj.25
        for <linux-nfs@vger.kernel.org>; Fri, 02 Aug 2013 08:39:40 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Chao Ye <cye@redhat.com>
Subject: [PATCH] nfs: verify open flags before allowing an atomic open
Date: Fri,  2 Aug 2013 11:39:32 -0400
Message-Id: <1375457972-22054-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, you can open a NFSv4 file with O_APPEND|O_DIRECT, but cannot
fcntl(F_SETFL,...) with those flags. This flag combination is explicitly
forbidden on NFSv3 opens, and it seems like it should also be on NFSv4.

Reported-by: Chao Ye <cye@redhat.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/dir.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e474ca2b..39e69d4 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1413,6 +1413,10 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 	dfprintk(VFS, "NFS: atomic_open(%s/%ld), %s\n",
 			dir->i_sb->s_id, dir->i_ino, dentry->d_name.name);
 
+	err = nfs_check_flags(open_flags);
+	if (err)
+		return err;
+
 	/* NFS only supports OPEN on regular files */
 	if ((open_flags & O_DIRECTORY)) {
 		if (!d_unhashed(dentry)) {
-- 
1.8.3.1

