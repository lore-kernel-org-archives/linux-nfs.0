From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: [PATCH 06/10] NFSv4: Add label recommended attribute and NFSv4 flags
Date: Wed,  7 Jul 2010 10:31:22 -0400
Message-ID: <1278513086-23964-7-git-send-email-dpquigl@tycho.nsa.gov>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-nfs@vger.kernel.org,
	"David P. Quigley" <dpquigl@tycho.nsa.gov>,
	"Matthew N. Dodd" <Matthew.Dodd@sparta.com>
To: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
	sds@tycho.nsa.gov, matthew.dodd@sparta.com,
	trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds a new recommended attribute named label into the NFSv4 file
attribute structure. It also adds several new flags to allow the NFS client and
server to determine if this attribute is supported and if it is being sent over
the wire.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
---
 fs/nfsd/nfsd.h              |    6 +++---
 include/linux/nfs4.h        |    2 ++
 include/linux/nfs_fs_sb.h   |    1 +
 include/linux/nfs_xdr.h     |    4 +++-
 include/linux/nfsd/export.h |    5 +++--
 5 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index e942a1a..ae20d51 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -277,8 +277,8 @@ extern struct timeval	nfssvc_boot;
  | FATTR4_WORD1_OWNER	        | FATTR4_WORD1_OWNER_GROUP  | FATTR4_WORD1_RAWDEV           \
  | FATTR4_WORD1_SPACE_AVAIL     | FATTR4_WORD1_SPACE_FREE   | FATTR4_WORD1_SPACE_TOTAL      \
  | FATTR4_WORD1_SPACE_USED      | FATTR4_WORD1_TIME_ACCESS  | FATTR4_WORD1_TIME_ACCESS_SET  \
- | FATTR4_WORD1_TIME_DELTA   | FATTR4_WORD1_TIME_METADATA    \
- | FATTR4_WORD1_TIME_MODIFY     | FATTR4_WORD1_TIME_MODIFY_SET | FATTR4_WORD1_MOUNTED_ON_FILEID)
+ | FATTR4_WORD1_TIME_DELTA   	| FATTR4_WORD1_TIME_METADATA | FATTR4_WORD1_TIME_MODIFY     \
+ | FATTR4_WORD1_TIME_MODIFY_SET | FATTR4_WORD1_MOUNTED_ON_FILEID | FATTR4_WORD1_SECURITY_LABEL)
 
 #define NFSD4_SUPPORTED_ATTRS_WORD2 0
 
@@ -318,7 +318,7 @@ static inline u32 nfsd_suppattrs2(u32 minorversion)
 (FATTR4_WORD0_SIZE              | FATTR4_WORD0_ACL                                         )
 #define NFSD_WRITEABLE_ATTRS_WORD1                                                          \
 (FATTR4_WORD1_MODE              | FATTR4_WORD1_OWNER         | FATTR4_WORD1_OWNER_GROUP     \
- | FATTR4_WORD1_TIME_ACCESS_SET | FATTR4_WORD1_TIME_MODIFY_SET)
+ | FATTR4_WORD1_TIME_ACCESS_SET | FATTR4_WORD1_TIME_MODIFY_SET | FATTR4_WORD1_SECURITY_LABEL)
 #define NFSD_WRITEABLE_ATTRS_WORD2 0
 
 #define NFSD_SUPPATTR_EXCLCREAT_WORD0 \
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 9b8299a..a2abd1a 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -23,6 +23,7 @@
 #define NFS4_MAXNAMLEN		NAME_MAX
 #define NFS4_OPAQUE_LIMIT	1024
 #define NFS4_MAX_SESSIONID_LEN	16
+#define NFS4_MAXLABELLEN	4096
 
 #define NFS4_ACCESS_READ        0x0001
 #define NFS4_ACCESS_LOOKUP      0x0002
@@ -471,6 +472,7 @@ enum lock_type4 {
 #define FATTR4_WORD1_TIME_MODIFY        (1UL << 21)
 #define FATTR4_WORD1_TIME_MODIFY_SET    (1UL << 22)
 #define FATTR4_WORD1_MOUNTED_ON_FILEID  (1UL << 23)
+#define FATTR4_WORD1_SECURITY_LABEL     (1UL << 31)
 
 #define NFSPROC4_NULL 0
 #define NFSPROC4_COMPOUND 1
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index e82957a..aa95a22 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -177,6 +177,7 @@ struct nfs_server {
 #define NFS_CAP_CTIME		(1U << 12)
 #define NFS_CAP_MTIME		(1U << 13)
 #define NFS_CAP_POSIX_LOCK	(1U << 14)
+#define NFS_CAP_SECURITY_LABEL	(1U << 15)
 
 
 /* maximum number of slots to use */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 89b2881..28cde54 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -78,6 +78,7 @@ struct nfs_fattr {
 #define NFS_ATTR_FATTR_CHANGE		(1U << 17)
 #define NFS_ATTR_FATTR_PRECHANGE	(1U << 18)
 #define NFS_ATTR_FATTR_V4_REFERRAL	(1U << 19)	/* NFSv4 referral */
+#define NFS_ATTR_FATTR_V4_SECURITY_LABEL (1U << 20)	/* NFSv4 Security Labels */
 
 #define NFS_ATTR_FATTR (NFS_ATTR_FATTR_TYPE \
 		| NFS_ATTR_FATTR_MODE \
@@ -97,7 +98,8 @@ struct nfs_fattr {
 		| NFS_ATTR_FATTR_SPACE_USED)
 #define NFS_ATTR_FATTR_V4 (NFS_ATTR_FATTR \
 		| NFS_ATTR_FATTR_SPACE_USED \
-		| NFS_ATTR_FATTR_CHANGE)
+		| NFS_ATTR_FATTR_CHANGE \
+		| NFS_ATTR_FATTR_V4_SECURITY_LABEL)
 
 /*
  * Info on the file system
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index 8ae78a6..72abeb6 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -31,7 +31,8 @@
 #define NFSEXP_ALLSQUASH	0x0008
 #define NFSEXP_ASYNC		0x0010
 #define NFSEXP_GATHERED_WRITES	0x0020
-/* 40 80 100 currently unused */
+#define NFSEXP_SECURITY_LABEL	0x0040  /* Support security label fattr4 */
+/* 80 100 currently unused */
 #define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define	NFSEXP_NOAUTHNLM	0x0800		/* Don't authenticate NLM requests - just trust */
@@ -50,7 +51,7 @@
  */
 #define	NFSEXP_V4ROOT		0x10000
 /* All flags that we claim to support.  (Note we don't support NOACL.) */
-#define NFSEXP_ALLFLAGS		0x17E3F
+#define NFSEXP_ALLFLAGS		0x17E7F
 
 /* The flags that may vary depending on security flavor: */
 #define NFSEXP_SECINFO_FLAGS	(NFSEXP_READONLY | NFSEXP_ROOTSQUASH \
-- 
1.6.2.5
