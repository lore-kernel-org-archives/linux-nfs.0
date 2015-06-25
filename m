Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32851 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751097AbbFYNZv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Jun 2015 09:25:51 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond.Myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: verify open flags before allowing open
Date: Thu, 25 Jun 2015 09:25:50 -0400
Message-Id: <910360a6f0390839799e173e0d43736b3d538db8.1435238640.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 9597c13b forbade opens with O_APPEND|O_DIRECT for NFSv4:

    nfs: verify open flags before allowing an atomic open

    Currently, you can open a NFSv4 file with O_APPEND|O_DIRECT, but cannot
    fcntl(F_SETFL,...) with those flags. This flag combination is explicitly
    forbidden on NFSv3 opens, and it seems like it should also be on NFSv4.

However, you can still open a file with O_DIRECT|O_APPEND if there exists a
cached dentry for the file because nfs4_file_open() is used instead of
nfs_atomic_open() and the check is bypassed.  Add the check in
nfs4_file_open() as well.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4file.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index f58c17b..dcd39d4 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -41,6 +41,10 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 
 	dprintk("NFS: open file(%pd2)\n", dentry);
 
+	err = nfs_check_flags(openflags);
+	if (err)
+		return err;
+
 	if ((openflags & O_ACCMODE) == 3)
 		openflags--;
 
-- 
1.7.1

