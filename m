Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:34277 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751119AbdBWITv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2017 03:19:51 -0500
Received: by mail-ot0-f196.google.com with SMTP id w44so2834642otw.1
        for <linux-nfs@vger.kernel.org>; Thu, 23 Feb 2017 00:18:36 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: some problems about permission of subdirectory
To: houlinfei <hou.linfei@h3c.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <7c4bbc9f.5827.15a691a3e04.Coremail.hou.linfei@h3c.com>
Cc: bfields@fieldses.org, neilb@suse.com, SteveD@redhat.com,
        zhengbin.08747@h3c.com, Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <080b9f95-a3c7-7df1-246f-83093db532e2@gmail.com>
Date: Thu, 23 Feb 2017 16:18:25 +0800
MIME-Version: 1.0
In-Reply-To: <7c4bbc9f.5827.15a691a3e04.Coremail.hou.linfei@h3c.com>
Content-Type: text/plain; charset=gbk
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cc Bruce, Steven,

On 2/23/2017 11:53, houlinfei wrote:
> hi Kinglong,
> I try again, it's okay. but we want to modify the code, till now we are not familiar with nfs, can you tell us where should we modify?

The logic is set a mark on the exported dir when exporting dir,
nfsd kernel checks the mark when finding export entry.

There are two patches I have a little test,
fs/nfsd/vfs.c is the kernel source, and 
utils/exportfs/exportfs.c is the nfs-utils source.

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 26c6fdb..c03566c 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -456,6 +456,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
  * NFS junction information is stored in an extended attribute.
  */
 #define NFSD_JUNCTION_XATTR_NAME	XATTR_TRUSTED_PREFIX "junction.nfs"
+#define NFSD_EXPORTED_XATTR_NAME	NFSD_JUNCTION_XATTR_NAME ".exported"
 
 /**
  * nfsd4_is_junction - Test if an object could be an NFS junction
@@ -471,6 +472,8 @@ int nfsd4_is_junction(struct dentry *dentry)
 
 	if (inode == NULL)
 		return 0;
+	if (vfs_getxattr(dentry, NFSD_EXPORTED_XATTR_NAME, NULL, 0) > 0)
+		return 1;
 	if (inode->i_mode & S_IXUGO)
 		return 0;
 	if (!(inode->i_mode & S_ISVTX))

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 02d5b6d..3c6e36b 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -28,6 +28,7 @@
 #include <errno.h>
 #include <limits.h>
 #include <time.h>
+#include <linux/xattr.h>
 
 #define INT_TO_LONG_THRESHOLD_SECS (INT_MAX - (60 * 60 * 24))
 
@@ -556,6 +557,9 @@ validate_export(nfs_export *exp)
 		return;
 
 	}
+
+#define NFSD_EXPORTED_XATTR_NAME  XATTR_TRUSTED_PREFIX "junction.nfs.exported"
+	setxattr(path, NFSD_EXPORTED_XATTR_NAME, "exported", 8, 0);
 }
 
 static _Bool


thanks,
Kinglong Mee
