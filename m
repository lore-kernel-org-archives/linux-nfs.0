Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10927 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756531Ab3CYLoQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Mar 2013 07:44:16 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 05/14] NFSv4: Add label recommended attribute and NFSv4 flags
Date: Mon, 25 Mar 2013 07:42:49 -0400
Message-Id: <1364211778-29172-6-git-send-email-SteveD@redhat.com>
In-Reply-To: <1364211778-29172-1-git-send-email-SteveD@redhat.com>
References: <1364211778-29172-1-git-send-email-SteveD@redhat.com>
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
 include/linux/nfs_xdr.h   | 4 +++-
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 7b8fc73..0fa29f4 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -377,6 +377,7 @@ enum lock_type4 {
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
index 4b993d3..9f2dba3 100644
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
-- 
1.8.1.4

