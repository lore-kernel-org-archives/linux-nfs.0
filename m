From: akpm@linux-foundation.org
Subject: [patch 2/5] nfs/lsm: make NFSv4 set LSM mount options
Date: Fri, 02 May 2008 13:42:42 -0700
Message-ID: <200805022042.m42KggtE013875@imap1.linux-foundation.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
	akpm@linux-foundation.org, eparis@redhat.com,
	casey@schaufler-ca.com, jmorris@namei.org, sds@tycho.nsa.gov
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44261 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935259AbYEBUnW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2008 16:43:22 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Eric Paris <eparis@redhat.com>

NFSv3 get_sb operations call into the LSM layer to set security options passed
from userspace.  NFSv4 hooks were not originally added since it was reasonably
late in the merge window and NFSv3 was the only thing that had regressed (v4
has never supported any LSM options)

This patch makes NFSv4 call into the LSM to set security options rather than
just blindly dropping them with no notice to the user as happens today.  This
patch was tested in a simple NFSv4 environment with the context= option and
appeared to work as expected.

Signed-off-by: Eric Paris <eparis@redhat.com>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Stephen Smalley <sds@tycho.nsa.gov>
Acked-by: James Morris <jmorris@namei.org>
Cc: Casey Schaufler <casey@schaufler-ca.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/nfs/super.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff -puN fs/nfs/super.c~nfs-lsm-make-nfsv4-set-lsm-mount-options fs/nfs/super.c
--- a/fs/nfs/super.c~nfs-lsm-make-nfsv4-set-lsm-mount-options
+++ a/fs/nfs/super.c
@@ -2015,6 +2015,10 @@ static int nfs4_get_sb(struct file_syste
 		goto error_splat_super;
 	}
 
+	error = security_sb_set_mnt_opts(s, &data.lsm_opts);
+	if (error)
+		goto error_splat_root;
+
 	s->s_flags |= MS_ACTIVE;
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
@@ -2031,6 +2035,8 @@ out_free:
 	nfs_free_server(server);
 	goto out;
 
+error_splat_root:
+	dput(mntroot);
 error_splat_super:
 	up_write(&s->s_umount);
 	deactivate_super(s);
@@ -2114,6 +2120,8 @@ static int nfs4_xdev_get_sb(struct file_
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
 
+	security_sb_clone_mnt_opts(data->sb, s);
+
 	dprintk("<-- nfs4_xdev_get_sb() = 0\n");
 	return 0;
 
@@ -2197,6 +2205,8 @@ static int nfs4_referral_get_sb(struct f
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
 
+	security_sb_clone_mnt_opts(data->sb, s);
+
 	dprintk("<-- nfs4_referral_get_sb() = 0\n");
 	return 0;
 
_
