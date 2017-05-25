Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37532 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936107AbdEYVH4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 May 2017 17:07:56 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: selinux@tycho.nsa.gov, linux-nfs@vger.kernel.org
Cc: Paul Moore <paul@paul-moore.com>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Eric Paris <eparis@parisplace.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH RFC 2/2] nfs: update labeling behavior on a superblock when submounting
Date: Thu, 25 May 2017 17:07:54 -0400
Message-Id: <20170525210754.24265-3-smayhew@redhat.com>
In-Reply-To: <20170525210754.24265-1-smayhew@redhat.com>
References: <20170404232646.GB24146@parsley.fieldses.org>
 <20170525210754.24265-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the client traverses from filesystem exported without the
"security_label" option to one exported with the "security_label"
option, it needs to pass SECURITY_LSM_NATIVE_LABELS to
security_sb_set_mnt_opts() so that the new superblock has SBLABEL_MNT
set in its security mount options.  Otherwise, attempts to set security
labels via setxattr over NFSv4.2 will fail.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/super.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2f3822a..d7a3b89 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2544,10 +2544,31 @@ EXPORT_SYMBOL_GPL(nfs_set_sb_security);
 int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
 			  struct nfs_mount_info *mount_info)
 {
+	int error;
+	unsigned long kflags = 0, kflags_out = 0;
+	struct security_mnt_opts opts;
+
 	/* clone any lsm security options from the parent to the new sb */
 	if (d_inode(mntroot)->i_op != NFS_SB(s)->nfs_client->rpc_ops->dir_inode_ops)
 		return -ESTALE;
-	return security_sb_clone_mnt_opts(mount_info->cloned->sb, s);
+	error = security_sb_clone_mnt_opts(mount_info->cloned->sb, s);
+	if (error)
+		goto err;
+
+	if (NFS_SB(s)->caps & NFS_CAP_SECURITY_LABEL &&
+		!(NFS_SB(mount_info->cloned->sb)->caps & NFS_CAP_SECURITY_LABEL)) {
+		memset(&opts, 0, sizeof(opts));
+		kflags |= SECURITY_LSM_NATIVE_LABELS;
+
+		error = security_sb_set_mnt_opts(s, &opts, kflags, &kflags_out);
+		if (error)
+			goto err;
+
+		if (!(kflags_out & SECURITY_LSM_NATIVE_LABELS))
+			NFS_SB(s)->caps &= ~NFS_CAP_SECURITY_LABEL;
+	}
+err:
+	return error;
 }
 EXPORT_SYMBOL_GPL(nfs_clone_sb_security);
 
-- 
2.9.3

