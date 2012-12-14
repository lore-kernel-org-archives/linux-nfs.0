Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:29374 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932303Ab2LNVxK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Dec 2012 16:53:10 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: "neilb@suse.de" <neilb@suse.de>, Ricky Ng-Adam <rngadam@lophilo.com>,
        Al Viro <viro@ZenIV.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] NFS: Fix calls to drop_nlink()
Date: Fri, 14 Dec 2012 16:53:01 -0500
Message-Id: <1355521981-50094-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1355521981-50094-1-git-send-email-Trond.Myklebust@netapp.com>
References: <20121214075138.7ab828da@tlielax.poochiereds.net>
 <1355521981-50094-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is almost always wrong for NFS to call drop_nlink() after removing a
file. What we really want is to mark the inode's attributes for
revalidation, and we want to ensure that the VFS drops it if we're
reasonably sure that this is the final unlink().
Do the former using the usual cache validity flags, and the latter
by testing if inode->i_nlink == 1, and clearing it in that case.

This also fixes the following warning reported by Neil Brown and
Jeff Layton (among others).

[634155.004438] WARNING:
at /home/abuild/rpmbuild/BUILD/kernel-desktop-3.5.0/lin [634155.004442]
Hardware name: Latitude E6510 [634155.004577]  crc_itu_t crc32c_intel
snd_hwdep snd_pcm snd_timer snd soundcor [634155.004609] Pid: 13402, comm:
bash Tainted: G        W    3.5.0-36-desktop # [634155.004611] Call Trace:
[634155.004630]  [<ffffffff8100444a>] dump_trace+0xaa/0x2b0
[634155.004641]  [<ffffffff815a23dc>] dump_stack+0x69/0x6f
[634155.004653]  [<ffffffff81041a0b>] warn_slowpath_common+0x7b/0xc0
[634155.004662]  [<ffffffff811832e4>] drop_nlink+0x34/0x40
[634155.004687]  [<ffffffffa05bb6c3>] nfs_dentry_iput+0x33/0x70 [nfs]
[634155.004714]  [<ffffffff8118049e>] dput+0x12e/0x230
[634155.004726]  [<ffffffff8116b230>] __fput+0x170/0x230
[634155.004735]  [<ffffffff81167c0f>] filp_close+0x5f/0x90
[634155.004743]  [<ffffffff81167cd7>] sys_close+0x97/0x100
[634155.004754]  [<ffffffff815c3b39>] system_call_fastpath+0x16/0x1b
[634155.004767]  [<00007f2a73a0d110>] 0x7f2a73a0d10f

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ce8cb92..a46a746 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1155,11 +1155,14 @@ static int nfs_dentry_delete(const struct dentry *dentry)
 
 }
 
+/* Ensure that we revalidate inode->i_nlink */
 static void nfs_drop_nlink(struct inode *inode)
 {
 	spin_lock(&inode->i_lock);
-	if (inode->i_nlink > 0)
-		drop_nlink(inode);
+	/* drop the inode if we're reasonably sure this is the last link */
+	if (inode->i_nlink == 1)
+		clear_nlink(inode);
+	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR;
 	spin_unlock(&inode->i_lock);
 }
 
@@ -1174,8 +1177,8 @@ static void nfs_dentry_iput(struct dentry *dentry, struct inode *inode)
 		NFS_I(inode)->cache_validity |= NFS_INO_INVALID_DATA;
 
 	if (dentry->d_flags & DCACHE_NFSFS_RENAMED) {
-		drop_nlink(inode);
 		nfs_complete_unlink(dentry, inode);
+		nfs_drop_nlink(inode);
 	}
 	iput(inode);
 }
@@ -1646,10 +1649,8 @@ static int nfs_safe_remove(struct dentry *dentry)
 	if (inode != NULL) {
 		NFS_PROTO(inode)->return_delegation(inode);
 		error = NFS_PROTO(dir)->remove(dir, &dentry->d_name);
-		/* The VFS may want to delete this inode */
 		if (error == 0)
 			nfs_drop_nlink(inode);
-		nfs_mark_for_revalidate(inode);
 	} else
 		error = NFS_PROTO(dir)->remove(dir, &dentry->d_name);
 	if (error == -ENOENT)
-- 
1.7.11.7

