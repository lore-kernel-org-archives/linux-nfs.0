Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f44.google.com ([209.85.160.44]:58688 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422796Ab3CVSS3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Mar 2013 14:18:29 -0400
Received: by mail-pb0-f44.google.com with SMTP id wz12so3255906pbc.31
        for <linux-nfs@vger.kernel.org>; Fri, 22 Mar 2013 11:18:29 -0700 (PDT)
From: Kent Overstreet <koverstreet@google.com>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: Kent Overstreet <koverstreet@google.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Zach Brown <zab@redhat.com>
Subject: [PATCH] nfsd: fix bad offset use
Date: Fri, 22 Mar 2013 11:18:24 -0700
Message-Id: <1363976304-26093-1-git-send-email-koverstreet@google.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

vfs_writev() updates the offset argument - but the code then passes the
offset to vfs_fsync_range(). Since offset now points to the offset after
what was just written, this is probably not what was intended

Signed-off-by: Kent Overstreet <koverstreet@google.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Zach Brown <zab@redhat.com>
---
 fs/nfsd/vfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 2a7eb53..2b2e239 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1013,6 +1013,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	int			host_err;
 	int			stable = *stablep;
 	int			use_wgather;
+	loff_t			pos = offset;
 
 	dentry = file->f_path.dentry;
 	inode = dentry->d_inode;
@@ -1025,7 +1026,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 
 	/* Write the data. */
 	oldfs = get_fs(); set_fs(KERNEL_DS);
-	host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &offset);
+	host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &pos);
 	set_fs(oldfs);
 	if (host_err < 0)
 		goto out_nfserr;
-- 
1.8.1.3

