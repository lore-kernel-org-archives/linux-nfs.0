Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f42.google.com ([209.85.216.42]:45650 "EHLO
	mail-qw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195Ab1IBQn4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Sep 2011 12:43:56 -0400
Received: by qwi4 with SMTP id 4so2943403qwi.1
        for <linux-nfs@vger.kernel.org>; Fri, 02 Sep 2011 09:43:55 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] NFSD: Add a cache for fs_locations information
To: linux-nfs@vger.kernel.org
Date: Fri, 02 Sep 2011 12:38:42 -0400
Message-ID: <20110902163842.32190.52896.stgit@matisse.1015granger.net>
In-Reply-To: <20110902162210.32190.5880.stgit@matisse.1015granger.net>
References: <20110902162210.32190.5880.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
[ cel: since this is server-side, use nfsd4_ prefix instead of nfs4_ prefix. ]
[ cel: implement S_ISVTX filter in bfields-normal form ]
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsd.h |    7 +++++++
 fs/nfsd/vfs.c  |   16 ++++++++++++++++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 7ecfa24..d314812 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -335,6 +335,13 @@ static inline u32 nfsd_suppattrs2(u32 minorversion)
 #define NFSD_SUPPATTR_EXCLCREAT_WORD2 \
 	NFSD_WRITEABLE_ATTRS_WORD2
 
+extern int nfsd4_is_junction(struct dentry *dentry);
+#else
+static inline int nfsd4_is_junction(struct dentry *dentry)
+{
+	return 0;
+}
+
 #endif /* CONFIG_NFSD_V4 */
 
 #endif /* LINUX_NFSD_NFSD_H */
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index fd0acca..1f2d5bf 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -168,6 +168,8 @@ int nfsd_mountpoint(struct dentry *dentry, struct svc_export *exp)
 {
 	if (d_mountpoint(dentry))
 		return 1;
+	if (nfsd4_is_junction(dentry))
+		return 1;
 	if (!(exp->ex_flags & NFSEXP_V4ROOT))
 		return 0;
 	return dentry->d_inode != NULL;
@@ -592,6 +594,20 @@ nfsd4_get_nfs4_acl(struct svc_rqst *rqstp, struct dentry *dentry, struct nfs4_ac
 	return error;
 }
 
+#define NFSD_XATTR_JUNCTION_PREFIX XATTR_TRUSTED_PREFIX "junction."
+#define NFSD_XATTR_JUNCTION_TYPE NFSD_XATTR_JUNCTION_PREFIX "type"
+int nfsd4_is_junction(struct dentry *dentry)
+{
+	struct inode *inode = dentry->d_inode;
+
+	if (inode == NULL)
+		return 0;
+	if (!(inode->i_mode & S_ISVTX))
+		return 0;
+	if (vfs_getxattr(dentry, NFSD_XATTR_JUNCTION_TYPE, NULL, 0) <= 0)
+		return 0;
+	return 1;
+}
 #endif /* defined(CONFIG_NFSD_V4) */
 
 #ifdef CONFIG_NFSD_V3

