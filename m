Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:60227 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752364Ab1LSTiq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Dec 2011 14:38:46 -0500
Received: by vcbfk14 with SMTP id fk14so4305276vcb.19
        for <linux-nfs@vger.kernel.org>; Mon, 19 Dec 2011 11:38:46 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFSD: Change name of extended attribute containing junction
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, fedfs-utils-devel@oss.oracle.com
Date: Mon, 19 Dec 2011 14:38:43 -0500
Message-ID: <20111219193843.30843.56764.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As of fedfs-utils-0.8.0, user space stores all NFS junction
information in a single extended attribute: "trusted.junction.nfs".

Both FedFS and NFS basic junctions are stored in this one attribute,
and the intention is that all future forms of NFS junction metadata
will be stored in this attribute.  Other protocols may use a different
extended attribute.

Thus NFSD needs to look only for that one extended attribute.  The
"trusted.junction.type" xattr is deprecated.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/vfs.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index d1d4d5e..b494f86 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -594,8 +594,19 @@ nfsd4_get_nfs4_acl(struct svc_rqst *rqstp, struct dentry *dentry, struct nfs4_ac
 	return error;
 }
 
-#define NFSD_XATTR_JUNCTION_PREFIX XATTR_TRUSTED_PREFIX "junction."
-#define NFSD_XATTR_JUNCTION_TYPE NFSD_XATTR_JUNCTION_PREFIX "type"
+/*
+ * NFS junction information is stored in an extended attribute.
+ */
+#define NFSD_JUNCTION_XATTR_NAME	XATTR_TRUSTED_PREFIX "junction.nfs"
+
+/**
+ * nfsd4_is_junction - Test if an object could be an NFS junction
+ *
+ * @dentry: object to test
+ *
+ * Returns 1 if "dentry" appears to contain NFS junction information.
+ * Otherwise 0 is returned.
+ */
 int nfsd4_is_junction(struct dentry *dentry)
 {
 	struct inode *inode = dentry->d_inode;
@@ -606,7 +617,7 @@ int nfsd4_is_junction(struct dentry *dentry)
 		return 0;
 	if (!(inode->i_mode & S_ISVTX))
 		return 0;
-	if (vfs_getxattr(dentry, NFSD_XATTR_JUNCTION_TYPE, NULL, 0) <= 0)
+	if (vfs_getxattr(dentry, NFSD_JUNCTION_XATTR_NAME, NULL, 0) <= 0)
 		return 0;
 	return 1;
 }

