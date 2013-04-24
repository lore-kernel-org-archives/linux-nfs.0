Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40488 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757814Ab3DXUXK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 16:23:10 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 10/17] NFSv4: Extend fattr bitmaps to support all 3 words
Date: Wed, 24 Apr 2013 16:17:56 -0400
Message-Id: <1366834683-29075-11-git-send-email-SteveD@redhat.com>
In-Reply-To: <1366834683-29075-1-git-send-email-SteveD@redhat.com>
References: <1366834683-29075-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Quigley <dpquigl@davequigley.com>

The fattr handling bitmap code only uses the first two fattr words sofar. This
patch adds the 3rd word to being sent but doesn't populate it yet.

Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
---
 fs/nfs/nfs4_fs.h          |  6 +++---
 fs/nfs/nfs4proc.c         | 10 +++++-----
 fs/nfs/nfs4xdr.c          | 20 ++++++++++++--------
 fs/nfs/super.c            |  1 +
 include/linux/nfs_fs_sb.h |  2 +-
 5 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 944c9a5..1de30a8 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -295,10 +295,10 @@ is_ds_client(struct nfs_client *clp)
 extern const struct nfs4_minor_version_ops *nfs_v4_minor_ops[];
 
 extern const u32 nfs4_fattr_bitmap[3];
-extern const u32 nfs4_statfs_bitmap[2];
-extern const u32 nfs4_pathconf_bitmap[2];
+extern const u32 nfs4_statfs_bitmap[3];
+extern const u32 nfs4_pathconf_bitmap[3];
 extern const u32 nfs4_fsinfo_bitmap[3];
-extern const u32 nfs4_fs_locations_bitmap[2];
+extern const u32 nfs4_fs_locations_bitmap[3];
 
 void nfs4_free_client(struct nfs_client *);
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3fd1040..5c50495 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -159,7 +159,7 @@ static const u32 nfs4_open_noattr_bitmap[3] = {
 	| FATTR4_WORD0_FILEID,
 };
 
-const u32 nfs4_statfs_bitmap[2] = {
+const u32 nfs4_statfs_bitmap[3] = {
 	FATTR4_WORD0_FILES_AVAIL
 	| FATTR4_WORD0_FILES_FREE
 	| FATTR4_WORD0_FILES_TOTAL,
@@ -168,7 +168,7 @@ const u32 nfs4_statfs_bitmap[2] = {
 	| FATTR4_WORD1_SPACE_TOTAL
 };
 
-const u32 nfs4_pathconf_bitmap[2] = {
+const u32 nfs4_pathconf_bitmap[3] = {
 	FATTR4_WORD0_MAXLINK
 	| FATTR4_WORD0_MAXNAME,
 	0
@@ -183,7 +183,7 @@ const u32 nfs4_fsinfo_bitmap[3] = { FATTR4_WORD0_MAXFILESIZE
 			FATTR4_WORD2_LAYOUT_BLKSIZE
 };
 
-const u32 nfs4_fs_locations_bitmap[2] = {
+const u32 nfs4_fs_locations_bitmap[3] = {
 	FATTR4_WORD0_TYPE
 	| FATTR4_WORD0_CHANGE
 	| FATTR4_WORD0_SIZE
@@ -199,7 +199,7 @@ const u32 nfs4_fs_locations_bitmap[2] = {
 	| FATTR4_WORD1_TIME_ACCESS
 	| FATTR4_WORD1_TIME_METADATA
 	| FATTR4_WORD1_TIME_MODIFY
-	| FATTR4_WORD1_MOUNTED_ON_FILEID
+	| FATTR4_WORD1_MOUNTED_ON_FILEID,
 };
 
 static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dentry,
@@ -5136,7 +5136,7 @@ static int _nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
 				   struct page *page)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
-	u32 bitmask[2] = {
+	u32 bitmask[3] = {
 		[0] = FATTR4_WORD0_FSID | FATTR4_WORD0_FS_LOCATIONS,
 	};
 	struct nfs4_fs_locations_arg args = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e3edda5..4fa0bf1 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -983,15 +983,16 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 	int len;
 	uint32_t bmval0 = 0;
 	uint32_t bmval1 = 0;
+	uint32_t bmval2 = 0;
 
 	/*
 	 * We reserve enough space to write the entire attribute buffer at once.
 	 * In the worst-case, this would be
-	 *   12(bitmap) + 4(attrlen) + 8(size) + 4(mode) + 4(atime) + 4(mtime)
-	 *          = 36 bytes, plus any contribution from variable-length fields
+	 * 16(bitmap) + 4(attrlen) + 8(size) + 4(mode) + 4(atime) + 4(mtime)
+	 * = 40 bytes, plus any contribution from variable-length fields
 	 *            such as owner/group.
 	 */
-	len = 16;
+	len = 20;
 
 	/* Sigh */
 	if (iap->ia_valid & ATTR_SIZE)
@@ -1035,9 +1036,9 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 	 * We write the bitmap length now, but leave the bitmap and the attribute
 	 * buffer length to be backfilled at the end of this routine.
 	 */
-	*p++ = cpu_to_be32(2);
+	*p++ = cpu_to_be32(3);
 	q = p;
-	p += 3;
+	p += 4;
 
 	if (iap->ia_valid & ATTR_SIZE) {
 		bmval0 |= FATTR4_WORD0_SIZE;
@@ -1086,9 +1087,10 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 				len, ((char *)p - (char *)q) + 4);
 		BUG();
 	}
-	len = (char *)p - (char *)q - 12;
+	len = (char *)p - (char *)q - 16;
 	*q++ = htonl(bmval0);
 	*q++ = htonl(bmval1);
+	*q++ = htonl(bmval2);
 	*q = htonl(len);
 
 /* out: */
@@ -1194,8 +1196,10 @@ encode_getattr_three(struct xdr_stream *xdr,
 
 static void encode_getfattr(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
 {
-	encode_getattr_two(xdr, bitmask[0] & nfs4_fattr_bitmap[0],
-			   bitmask[1] & nfs4_fattr_bitmap[1], hdr);
+	encode_getattr_three(xdr, bitmask[0] & nfs4_fattr_bitmap[0],
+			   bitmask[1] & nfs4_fattr_bitmap[1],
+			   bitmask[2] & nfs4_fattr_bitmap[2],
+			   hdr);
 }
 
 static void encode_getfattr_open(struct xdr_stream *xdr, const u32 *bitmask,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d84eb57..00af026 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -833,6 +833,7 @@ int nfs_show_stats(struct seq_file *m, struct dentry *root)
 		seq_printf(m, "\n\tnfsv4:\t");
 		seq_printf(m, "bm0=0x%x", nfss->attr_bitmask[0]);
 		seq_printf(m, ",bm1=0x%x", nfss->attr_bitmask[1]);
+		seq_printf(m, ",bm2=0x%x", nfss->attr_bitmask[2]);
 		seq_printf(m, ",acl=0x%x", nfss->acl_bitmask);
 		show_sessions(m, nfss);
 		show_pnfs(m, nfss);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index d507357..e6ed3c2 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -145,7 +145,7 @@ struct nfs_server {
 	u32			attr_bitmask[3];/* V4 bitmask representing the set
 						   of attributes supported on this
 						   filesystem */
-	u32			cache_consistency_bitmask[2];
+	u32			cache_consistency_bitmask[3];
 						/* V4 bitmask representing the subset
 						   of change attribute, size, ctime
 						   and mtime attributes supported by
-- 
1.8.1.4

