Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 183.141.211.66.inaddr.G4.NET ([66.211.141.183]:54594 "EHLO
	Dobby.4dicksons.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563Ab3AVNky (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2013 08:40:54 -0500
From: Steve Dickson <steved@redhat.com>
To: David Quigley <selinux@davequigley.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 06/14] NFSv4: Add label recommended attribute and NFSv4 flags
Date: Tue, 22 Jan 2013 08:40:34 -0500
Message-Id: <1358862042-27520-7-git-send-email-steved@redhat.com>
In-Reply-To: <1358862042-27520-1-git-send-email-steved@redhat.com>
References: <1358862042-27520-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Quigley <dpquigl@davequigley.com>

This patch adds several new flags to allow the NFS client and server to
determine if this attribute is supported and if it is being sent over the wire.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
---
 include/linux/nfs4.h      | 1 +
 include/linux/nfs_fs_sb.h | 1 +
 include/linux/nfs_xdr.h   | 5 ++++-
 include/uapi/linux/nfs4.h | 1 +
 4 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index e111fa4..f9235b4 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -373,6 +373,7 @@ enum lock_type4 {
 #define FATTR4_WORD1_MOUNTED_ON_FILEID  (1UL << 23)
 #define FATTR4_WORD1_FS_LAYOUT_TYPES    (1UL << 30)
 #define FATTR4_WORD2_LAYOUT_BLKSIZE     (1UL << 1)
+#define FATTR4_WORD2_SECURITY_LABEL     (1UL << 17)
 #define FATTR4_WORD2_MDSTHRESHOLD       (1UL << 4)
 
 /* MDS threshold bitmap bits */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 6c6ed15..d507357 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -197,5 +197,6 @@ struct nfs_server {
 #define NFS_CAP_MTIME		(1U << 13)
 #define NFS_CAP_POSIX_LOCK	(1U << 14)
 #define NFS_CAP_UIDGID_NOMAP	(1U << 15)
+#define NFS_CAP_SECURITY_LABEL	(1U << 16)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 29adb12..fac114d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -104,6 +104,7 @@ struct nfs_fattr {
 #define NFS_ATTR_FATTR_MOUNTED_ON_FILEID (1U << 22)
 #define NFS_ATTR_FATTR_OWNER_NAME	(1U << 23)
 #define NFS_ATTR_FATTR_GROUP_NAME	(1U << 24)
+#define NFS_ATTR_FATTR_V4_SECURITY_LABEL (1U << 25)
 
 #define NFS_ATTR_FATTR (NFS_ATTR_FATTR_TYPE \
 		| NFS_ATTR_FATTR_MODE \
@@ -123,7 +124,8 @@ struct nfs_fattr {
 #define NFS_ATTR_FATTR_V3 (NFS_ATTR_FATTR \
 		| NFS_ATTR_FATTR_SPACE_USED)
 #define NFS_ATTR_FATTR_V4 (NFS_ATTR_FATTR \
-		| NFS_ATTR_FATTR_SPACE_USED)
+		| NFS_ATTR_FATTR_SPACE_USED \
+		| NFS_ATTR_FATTR_V4_SECURITY_LABEL)
 
 /*
  * Info on the file system
@@ -597,6 +599,7 @@ struct nfs_entry {
 	int			eof;
 	struct nfs_fh *		fh;
 	struct nfs_fattr *	fattr;
+	struct nfs4_label	*label;
 	unsigned char		d_type;
 	struct nfs_server *	server;
 };
diff --git a/include/uapi/linux/nfs4.h b/include/uapi/linux/nfs4.h
index 788128e..dcc8582 100644
--- a/include/uapi/linux/nfs4.h
+++ b/include/uapi/linux/nfs4.h
@@ -25,6 +25,7 @@
 #define NFS4_MAXNAMLEN		NAME_MAX
 #define NFS4_OPAQUE_LIMIT	1024
 #define NFS4_MAX_SESSIONID_LEN	16
+#define NFS4_MAXLABELLEN	4096
 
 #define NFS4_ACCESS_READ        0x0001
 #define NFS4_ACCESS_LOOKUP      0x0002
-- 
1.8.1

