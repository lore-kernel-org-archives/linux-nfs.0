From: David Quigley <dpquigl@davequigley.com>
Subject: [PATCH 06/13] NFSv4: Add label recommended attribute and NFSv4 flags
Date: Mon, 12 Nov 2012 01:15:40 -0500
Message-ID: <1352700947-3915-7-git-send-email-dpquigl@davequigley.com>
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com>
Cc: linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org,
        David Quigley <dpquigl@davequigley.com>,
        "Matthew N. Dodd" <Matthew.Dodd@sparta.com>,
        Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>,
        Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>,
        Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
To: bfields@fieldses.org, trond.myklebust@netapp.com, sds@tycho.nsa.gov
Return-path: <owner-selinux-MESi4pFTnrejpDF0oNHs+n7yKkN/O5/Z@public.gmane.org>
In-Reply-To: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com>
Sender: owner-selinux@tycho.nsa.gov
List-ID: <linux-nfs.vger.kernel.org>

From: David Quigley <dpquigl@davequigley.com>

This patch adds several new flags to allow the NFS client and server to
determine if this attribute is supported and if it is being sent over the wire.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
Signed-off-by: David Quigley <dpquigl@davequigley.com>
---
 fs/nfsd/nfsd.h                   | 8 ++++----
 include/linux/nfs4.h             | 1 +
 include/linux/nfs_fs_sb.h        | 1 +
 include/linux/nfs_xdr.h          | 5 ++++-
 include/uapi/linux/nfs4.h        | 1 +
 include/uapi/linux/nfsd/export.h | 5 +++--
 6 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 80d5ce4..3a87cbb 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -322,10 +322,10 @@ extern time_t nfsd4_grace;
  | FATTR4_WORD1_OWNER	        | FATTR4_WORD1_OWNER_GROUP  | FATTR4_WORD1_RAWDEV           \
  | FATTR4_WORD1_SPACE_AVAIL     | FATTR4_WORD1_SPACE_FREE   | FATTR4_WORD1_SPACE_TOTAL      \
  | FATTR4_WORD1_SPACE_USED      | FATTR4_WORD1_TIME_ACCESS  | FATTR4_WORD1_TIME_ACCESS_SET  \
- | FATTR4_WORD1_TIME_DELTA   | FATTR4_WORD1_TIME_METADATA    \
- | FATTR4_WORD1_TIME_MODIFY     | FATTR4_WORD1_TIME_MODIFY_SET | FATTR4_WORD1_MOUNTED_ON_FILEID)
+ | FATTR4_WORD1_TIME_DELTA	| FATTR4_WORD1_TIME_METADATA | FATTR4_WORD1_TIME_MODIFY     \
+ | FATTR4_WORD1_TIME_MODIFY_SET | FATTR4_WORD1_MOUNTED_ON_FILEID)
 
-#define NFSD4_SUPPORTED_ATTRS_WORD2 0
+#define NFSD4_SUPPORTED_ATTRS_WORD2 FATTR4_WORD2_SECURITY_LABEL
 
 #define NFSD4_1_SUPPORTED_ATTRS_WORD0 \
 	NFSD4_SUPPORTED_ATTRS_WORD0
@@ -364,7 +364,7 @@ static inline u32 nfsd_suppattrs2(u32 minorversion)
 #define NFSD_WRITEABLE_ATTRS_WORD1 \
 	(FATTR4_WORD1_MODE | FATTR4_WORD1_OWNER | FATTR4_WORD1_OWNER_GROUP \
 	| FATTR4_WORD1_TIME_ACCESS_SET | FATTR4_WORD1_TIME_MODIFY_SET)
-#define NFSD_WRITEABLE_ATTRS_WORD2 0
+#define NFSD_WRITEABLE_ATTRS_WORD2 FATTR4_WORD2_SECURITY_LABEL
 
 #define NFSD_SUPPATTR_EXCLCREAT_WORD0 \
 	NFSD_WRITEABLE_ATTRS_WORD0
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
index a9e76ee..a794715 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -197,6 +197,7 @@ struct nfs_server {
 #define NFS_CAP_MTIME		(1U << 13)
 #define NFS_CAP_POSIX_LOCK	(1U << 14)
 #define NFS_CAP_UIDGID_NOMAP	(1U << 15)
+#define NFS_CAP_SECURITY_LABEL	(1U << 16)
 
 
 /* maximum number of slots to use */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a73ea89..a0669d3 100644
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
@@ -600,6 +602,7 @@ struct nfs_entry {
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
diff --git a/include/uapi/linux/nfsd/export.h b/include/uapi/linux/nfsd/export.h
index cf47c31..e6c76d9 100644
--- a/include/uapi/linux/nfsd/export.h
+++ b/include/uapi/linux/nfsd/export.h
@@ -28,7 +28,8 @@
 #define NFSEXP_ALLSQUASH	0x0008
 #define NFSEXP_ASYNC		0x0010
 #define NFSEXP_GATHERED_WRITES	0x0020
-/* 40 80 100 currently unused */
+#define NFSEXP_SECURITY_LABEL	0x0040  /* Support security label fattr4 */
+/* 80 100 currently unused */
 #define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define	NFSEXP_NOAUTHNLM	0x0800		/* Don't authenticate NLM requests - just trust */
@@ -47,7 +48,7 @@
  */
 #define	NFSEXP_V4ROOT		0x10000
 /* All flags that we claim to support.  (Note we don't support NOACL.) */
-#define NFSEXP_ALLFLAGS		0x17E3F
+#define NFSEXP_ALLFLAGS		0x17E7F
 
 /* The flags that may vary depending on security flavor: */
 #define NFSEXP_SECINFO_FLAGS	(NFSEXP_READONLY | NFSEXP_ROOTSQUASH \
-- 
1.7.11.7
