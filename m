Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:57355 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463Ab1H2Sve (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2011 14:51:34 -0400
Received: by iabu26 with SMTP id u26so733149iab.19
        for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2011 11:51:33 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFSD: Add a cache for fs_locations information
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 29 Aug 2011 14:51:15 -0400
Message-ID: <20110829185115.3413.92459.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
[ cel: since this is server-side, use nfsd4_ prefix instead of nfs4_ prefix. ]
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsd.h |    7 +++++++
 fs/nfsd/vfs.c  |   15 +++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

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
index fd0acca..5dac667 100644
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
@@ -592,6 +594,19 @@ nfsd4_get_nfs4_acl(struct svc_rqst *rqstp, struct dentry *dentry, struct nfs4_ac
 	return error;
 }
 
+#define NFSD_XATTR_JUNCTION_PREFIX XATTR_TRUSTED_PREFIX "junction."
+#define NFSD_XATTR_JUNCTION_TYPE NFSD_XATTR_JUNCTION_PREFIX "type"
+int nfsd4_is_junction(struct dentry *dentry)
+{
+	ssize_t ret;
+
+	if (dentry->d_inode != NULL) {
+		ret = vfs_getxattr(dentry, NFSD_XATTR_JUNCTION_TYPE, NULL, 0);
+		if (ret > 0)
+			return 1;
+	}
+	return 0;
+}
 #endif /* defined(CONFIG_NFSD_V4) */
 
 #ifdef CONFIG_NFSD_V3

