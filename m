Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54785 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938983AbdEYVH4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 May 2017 17:07:56 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: selinux@tycho.nsa.gov, linux-nfs@vger.kernel.org
Cc: Paul Moore <paul@paul-moore.com>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Eric Paris <eparis@parisplace.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH RFC 1/2] selinux: allow SECURITY_LSM_NATIVE_LABELS to be set on an already initialized superblock
Date: Thu, 25 May 2017 17:07:53 -0400
Message-Id: <20170525210754.24265-2-smayhew@redhat.com>
In-Reply-To: <20170525210754.24265-1-smayhew@redhat.com>
References: <20170404232646.GB24146@parsley.fieldses.org>
 <20170525210754.24265-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When an NFSv4 client performs a mount operation, it first mounts the
NFSv4 root and then does path walk to the exported path and performs a
submount on that, cloning the security mount options from the root's
superblock to the submount's superblock in the process.

Unless the NFS server has an explicit fsid=0 export with the
"security_label" option, the NFSv4 root superblock will not have
SBLABEL_MNT set, and neither will the submount superblock after cloning
the security mount options.  As a result, setxattr's of security labels
over NFSv4.2 will fail.

Allowing the NFSv4 client to override the SECURITY_LSM_NATIVE_LABELS
flag on an initialized superblock will ensure that SBLABEL_MNT is set
when the client traverses from an exported path without the
"security_label" option to one with the "security_label" option.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 security/selinux/hooks.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index e67a526..366ab86 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -730,7 +730,7 @@ static int selinux_set_mnt_opts(struct super_block *sb,
 	 * will be used for both mounts)
 	 */
 	if ((sbsec->flags & SE_SBINITIALIZED) && (sb->s_type->fs_flags & FS_BINARY_MOUNTDATA)
-	    && (num_opts == 0))
+	    && (num_opts == 0) && !(kern_flags & SECURITY_LSM_NATIVE_LABELS))
 		goto out;
 
 	root_isec = backing_inode_security_novalidate(root);
@@ -797,7 +797,7 @@ static int selinux_set_mnt_opts(struct super_block *sb,
 		}
 	}
 
-	if (sbsec->flags & SE_SBINITIALIZED) {
+	if (sbsec->flags & SE_SBINITIALIZED && !(kern_flags & SECURITY_LSM_NATIVE_LABELS)) {
 		/* previously mounted with options, but not on this attempt? */
 		if ((sbsec->flags & SE_MNTMASK) && !num_opts)
 			goto out_double_mount;
-- 
2.9.3

