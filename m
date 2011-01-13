Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18189 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932676Ab1AMTQM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Jan 2011 14:16:12 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] NFS: Fix NFSv3 exclusive open semantics
Date: Thu, 13 Jan 2011 14:15:50 -0500
Message-Id: <1294946150-9248-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Commit c0204fd2b8fe047b18b67e07e1bf2a03691240cd (NFS: Clean up
nfs4_proc_create()) broke NFSv3 exclusive open by removing the code
that passes the O_EXCL flag down to nfs3_proc_create(). This patch
reverts that offending hunk from the original commit.

Reported-by: Nick Bowler <nbowler@elliptictech.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@kernel.org    [2.6.37]
Tested-by: Nick Bowler <nbowler@elliptictech.com>
---
 fs/nfs/dir.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index abe4f0c..f9d6a37 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1583,6 +1583,7 @@ static int nfs_create(struct inode *dir, struct dentry *dentry, int mode,
 {
 	struct iattr attr;
 	int error;
+	int open_flags = 0;
 
 	dfprintk(VFS, "NFS: create(%s/%ld), %s\n",
 			dir->i_sb->s_id, dir->i_ino, dentry->d_name.name);
@@ -1590,7 +1591,10 @@ static int nfs_create(struct inode *dir, struct dentry *dentry, int mode,
 	attr.ia_mode = mode;
 	attr.ia_valid = ATTR_MODE;
 
-	error = NFS_PROTO(dir)->create(dir, dentry, &attr, 0, NULL);
+	if ((nd->flags & LOOKUP_CREATE) != 0)
+		open_flags = nd->intent.open.flags;
+
+	error = NFS_PROTO(dir)->create(dir, dentry, &attr, open_flags, NULL);
 	if (error != 0)
 		goto out_err;
 	return 0;
-- 
1.7.3.4

