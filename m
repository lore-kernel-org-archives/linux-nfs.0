Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 183.141.211.66.inaddr.G4.NET ([66.211.141.183]:54600 "EHLO
	Dobby.4dicksons.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955Ab3AVNk4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2013 08:40:56 -0500
From: Steve Dickson <steved@redhat.com>
To: David Quigley <selinux@davequigley.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 08/14] NFSv4: Extend fattr bitmaps to support all 3 words
Date: Tue, 22 Jan 2013 08:40:36 -0500
Message-Id: <1358862042-27520-9-git-send-email-steved@redhat.com>
In-Reply-To: <1358862042-27520-1-git-send-email-steved@redhat.com>
References: <1358862042-27520-1-git-send-email-steved@redhat.com>
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
 fs/nfs/nfs4proc.c         | 20 +++++++++++++-------
 fs/nfs/nfs4xdr.c          | 20 ++++++++++++--------
 fs/nfs/super.c            |  1 +
 include/linux/nfs_fs_sb.h |  2 +-
 5 files changed, 30 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a3f488b..dfaee53 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -291,10 +291,10 @@ is_ds_client(struct nfs_client *clp)
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
index cf747ef..625ac4c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -130,7 +130,8 @@ const u32 nfs4_fattr_bitmap[3] = {
 	| FATTR4_WORD1_SPACE_USED
 	| FATTR4_WORD1_TIME_ACCESS
 	| FATTR4_WORD1_TIME_METADATA
-	| FATTR4_WORD1_TIME_MODIFY
+	| FATTR4_WORD1_TIME_MODIFY,
+	0
 };
 
 static const u32 nfs4_pnfs_open_bitmap[3] = {
@@ -157,18 +158,20 @@ static const u32 nfs4_open_noattr_bitmap[3] = {
 	| FATTR4_WORD0_FILEID,
 };
 
-const u32 nfs4_statfs_bitmap[2] = {
+const u32 nfs4_statfs_bitmap[3] = {
 	FATTR4_WORD0_FILES_AVAIL
 	| FATTR4_WORD0_FILES_FREE
 	| FATTR4_WORD0_FILES_TOTAL,
 	FATTR4_WORD1_SPACE_AVAIL
 	| FATTR4_WORD1_SPACE_FREE
-	| FATTR4_WORD1_SPACE_TOTAL
+	| FATTR4_WORD1_SPACE_TOTAL,
+	0
 };
 
-const u32 nfs4_pathconf_bitmap[2] = {
+const u32 nfs4_pathconf_bitmap[3] = {
 	FATTR4_WORD0_MAXLINK
 	| FATTR4_WORD0_MAXNAME,
+	0,
 	0
 };
 
@@ -181,7 +184,7 @@ const u32 nfs4_fsinfo_bitmap[3] = { FATTR4_WORD0_MAXFILESIZE
 			FATTR4_WORD2_LAYOUT_BLKSIZE
 };
 
-const u32 nfs4_fs_locations_bitmap[2] = {
+const u32 nfs4_fs_locations_bitmap[3] = {
 	FATTR4_WORD0_TYPE
 	| FATTR4_WORD0_CHANGE
 	| FATTR4_WORD0_SIZE
@@ -197,7 +200,8 @@ const u32 nfs4_fs_locations_bitmap[2] = {
 	| FATTR4_WORD1_TIME_ACCESS
 	| FATTR4_WORD1_TIME_METADATA
 	| FATTR4_WORD1_TIME_MODIFY
-	| FATTR4_WORD1_MOUNTED_ON_FILEID
+	| FATTR4_WORD1_MOUNTED_ON_FILEID,
+	0
 };
 
 static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dentry,
@@ -5082,8 +5086,10 @@ static int _nfs4_proc_fs_locations(struct rpc_clnt *client, struct inode *dir,
 				   struct page *page)
 {
 	struct nfs_server *server = NFS_SERVER(dir);
-	u32 bitmask[2] = {
+	u32 bitmask[3] = {
 		[0] = FATTR4_WORD0_FSID | FATTR4_WORD0_FS_LOCATIONS,
+		[1] = 0,
+		[2] = 0
 	};
 	struct nfs4_fs_locations_arg args = {
 		.dir_fh = NFS_FH(dir),
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 26b1439..a9353d1 100644
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
index 6eeb94b..86442f4 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -877,6 +877,7 @@ int nfs_show_stats(struct seq_file *m, struct dentry *root)
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
1.8.1

