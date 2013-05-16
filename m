Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60406 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753111Ab3EPP47 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 May 2013 11:56:59 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 06/13] NFSv4: Add label recommended attribute and NFSv4 flags
Date: Thu, 16 May 2013 11:56:41 -0400
Message-Id: <1368719808-14584-7-git-send-email-SteveD@redhat.com>
In-Reply-To: <1368719808-14584-1-git-send-email-SteveD@redhat.com>
References: <1368719808-14584-1-git-send-email-SteveD@redhat.com>
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
 include/linux/nfs_fs_sb.h | 1 +
 include/linux/nfs_xdr.h   | 4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 3b7fa2a..2ddd00a 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -200,5 +200,6 @@ struct nfs_server {
 #define NFS_CAP_UIDGID_NOMAP	(1U << 15)
 #define NFS_CAP_STATEID_NFSV41	(1U << 16)
 #define NFS_CAP_ATOMIC_OPEN_V1	(1U << 17)
+#define NFS_CAP_SECURITY_LABEL	(1U << 18)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 104b62f..bfdf6e0 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -101,6 +101,7 @@ struct nfs_fattr {
 #define NFS_ATTR_FATTR_MOUNTED_ON_FILEID (1U << 22)
 #define NFS_ATTR_FATTR_OWNER_NAME	(1U << 23)
 #define NFS_ATTR_FATTR_GROUP_NAME	(1U << 24)
+#define NFS_ATTR_FATTR_V4_SECURITY_LABEL (1U << 25)
 
 #define NFS_ATTR_FATTR (NFS_ATTR_FATTR_TYPE \
 		| NFS_ATTR_FATTR_MODE \
@@ -120,7 +121,8 @@ struct nfs_fattr {
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

