Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51766 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756739AbcJ1UXw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Oct 2016 16:23:52 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] nfs: add support for the umask attribute
Date: Fri, 28 Oct 2016 16:23:47 -0400
Message-Id: <1477686228-12158-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1477686228-12158-1-git-send-email-bfields@redhat.com>
References: <1477686228-12158-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruenba@redhat.com>

Clients can set the umask attribute when creating files to cause the
server to apply it always except when inheriting permissions from the
parent directory.  That way, the new files will end up with the same
permissions as files created locally.

See https://tools.ietf.org/html/draft-ietf-nfsv4-umask-02 for more details.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/dir.c              |  7 ++++++-
 fs/nfs/nfs4proc.c         | 21 ++++++++++++++++-----
 fs/nfs/nfs4xdr.c          | 36 ++++++++++++++++++++++++------------
 include/linux/nfs4.h      |  1 +
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   |  2 ++
 6 files changed, 50 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 5f1af4cd1a33..eeb111e11972 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1535,8 +1535,13 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 		return -ENAMETOOLONG;
 
 	if (open_flags & O_CREAT) {
+		struct nfs_server *server = NFS_SERVER(dir);
+
+		if (!(server->caps & NFS_CAP_UMASK))
+			mode &= ~current_umask();
+
 		attr.ia_valid |= ATTR_MODE;
-		attr.ia_mode = mode & ~current_umask();
+		attr.ia_mode = mode;
 	}
 	if (open_flags & O_TRUNC) {
 		attr.ia_valid |= ATTR_SIZE;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7897826d7c51..da08768e3cb3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1239,6 +1239,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.bitmask = nfs4_bitmask(server, label);
 	p->o_arg.open_bitmap = &nfs4_fattr_bitmap[0];
 	p->o_arg.label = nfs4_label_copy(p->a_label, label);
+	p->o_arg.umask = current_umask();
 	p->o_arg.claim = nfs4_map_atomic_open_claim(server, claim);
 	switch (p->o_arg.claim) {
 	case NFS4_OPEN_CLAIM_NULL:
@@ -3277,7 +3278,7 @@ static void nfs4_close_context(struct nfs_open_context *ctx, int is_sync)
 
 #define FATTR4_WORD1_NFS40_MASK (2*FATTR4_WORD1_MOUNTED_ON_FILEID - 1UL)
 #define FATTR4_WORD2_NFS41_MASK (2*FATTR4_WORD2_SUPPATTR_EXCLCREAT - 1UL)
-#define FATTR4_WORD2_NFS42_MASK (2*FATTR4_WORD2_SECURITY_LABEL - 1UL)
+#define FATTR4_WORD2_NFS42_MASK (2*FATTR4_WORD2_UMASK - 1UL)
 
 static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle)
 {
@@ -3322,7 +3323,8 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 				NFS_CAP_MODE|NFS_CAP_NLINK|NFS_CAP_OWNER|
 				NFS_CAP_OWNER_GROUP|NFS_CAP_ATIME|
 				NFS_CAP_CTIME|NFS_CAP_MTIME|
-				NFS_CAP_SECURITY_LABEL);
+				NFS_CAP_SECURITY_LABEL|
+				NFS_CAP_UMASK);
 		if (res.attr_bitmask[0] & FATTR4_WORD0_ACL &&
 				res.acl_bitmask & ACL4_SUPPORT_ALLOW_ACL)
 			server->caps |= NFS_CAP_ACLS;
@@ -3350,6 +3352,8 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 		if (res.attr_bitmask[2] & FATTR4_WORD2_SECURITY_LABEL)
 			server->caps |= NFS_CAP_SECURITY_LABEL;
 #endif
+		if (res.attr_bitmask[2] & FATTR4_WORD2_UMASK)
+			server->caps |= NFS_CAP_UMASK;
 		memcpy(server->attr_bitmask_nl, res.attr_bitmask,
 				sizeof(server->attr_bitmask));
 		server->attr_bitmask_nl[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
@@ -3953,6 +3957,7 @@ static int
 nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 		 int flags)
 {
+	struct nfs_server *server = NFS_SERVER(dir);
 	struct nfs4_label l, *ilabel = NULL;
 	struct nfs_open_context *ctx;
 	struct nfs4_state *state;
@@ -3964,7 +3969,8 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 
 	ilabel = nfs4_label_init_security(dir, dentry, sattr, &l);
 
-	sattr->ia_mode &= ~current_umask();
+	if (!(server->caps & NFS_CAP_UMASK))
+		sattr->ia_mode &= ~current_umask();
 	state = nfs4_do_open(dir, ctx, flags, sattr, ilabel, NULL);
 	if (IS_ERR(state)) {
 		status = PTR_ERR(state);
@@ -4172,6 +4178,7 @@ static struct nfs4_createdata *nfs4_alloc_createdata(struct inode *dir,
 		data->arg.attrs = sattr;
 		data->arg.ftype = ftype;
 		data->arg.bitmask = nfs4_bitmask(server, data->label);
+		data->arg.umask = current_umask();
 		data->res.server = server;
 		data->res.fh = &data->fh;
 		data->res.fattr = &data->fattr;
@@ -4269,13 +4276,15 @@ static int _nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 static int nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
 		struct iattr *sattr)
 {
+	struct nfs_server *server = NFS_SERVER(dir);
 	struct nfs4_exception exception = { };
 	struct nfs4_label l, *label = NULL;
 	int err;
 
 	label = nfs4_label_init_security(dir, dentry, sattr, &l);
 
-	sattr->ia_mode &= ~current_umask();
+	if (!(server->caps & NFS_CAP_UMASK))
+		sattr->ia_mode &= ~current_umask();
 	do {
 		err = _nfs4_proc_mkdir(dir, dentry, sattr, label);
 		trace_nfs4_mkdir(dir, &dentry->d_name, err);
@@ -4378,13 +4387,15 @@ static int _nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
 static int nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
 		struct iattr *sattr, dev_t rdev)
 {
+	struct nfs_server *server = NFS_SERVER(dir);
 	struct nfs4_exception exception = { };
 	struct nfs4_label l, *label = NULL;
 	int err;
 
 	label = nfs4_label_init_security(dir, dentry, sattr, &l);
 
-	sattr->ia_mode &= ~current_umask();
+	if (!(server->caps & NFS_CAP_UMASK))
+		sattr->ia_mode &= ~current_umask();
 	do {
 		err = _nfs4_proc_mknod(dir, dentry, sattr, label, rdev);
 		trace_nfs4_mknod(dir, &dentry->d_name, err);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index fc89e5ed07ee..09c1b63c73e8 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -52,6 +52,7 @@
 #include <linux/nfs.h>
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
+#include <linux/fs_struct.h>
 
 #include "nfs4_fs.h"
 #include "internal.h"
@@ -1003,7 +1004,7 @@ static void encode_nfs4_verifier(struct xdr_stream *xdr, const nfs4_verifier *ve
 static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 				const struct nfs4_label *label,
 				const struct nfs_server *server,
-				bool excl_check)
+				bool excl_check, const umode_t *umask)
 {
 	char owner_name[IDMAP_NAMESZ];
 	char owner_group[IDMAP_NAMESZ];
@@ -1017,18 +1018,21 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 
 	/*
 	 * We reserve enough space to write the entire attribute buffer at once.
-	 * In the worst-case, this would be
-	 * 16(bitmap) + 4(attrlen) + 8(size) + 4(mode) + 4(atime) + 4(mtime)
-	 * = 40 bytes, plus any contribution from variable-length fields
-	 *            such as owner/group.
 	 */
 	if (iap->ia_valid & ATTR_SIZE) {
 		bmval[0] |= FATTR4_WORD0_SIZE;
 		len += 8;
 	}
+	if (!(server->caps & NFS_CAP_UMASK))
+		umask = NULL;
 	if (iap->ia_valid & ATTR_MODE) {
-		bmval[1] |= FATTR4_WORD1_MODE;
-		len += 4;
+		if (umask) {
+			bmval[2] |= FATTR4_WORD2_UMASK;
+			len += 8;
+		} else {
+			bmval[1] |= FATTR4_WORD1_MODE;
+			len += 4;
+		}
 	}
 	if (iap->ia_valid & ATTR_UID) {
 		owner_namelen = nfs_map_uid_to_name(server, iap->ia_uid, owner_name, IDMAP_NAMESZ);
@@ -1129,6 +1133,10 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 		*p++ = cpu_to_be32(label->len);
 		p = xdr_encode_opaque_fixed(p, label->label, label->len);
 	}
+	if (bmval[2] & FATTR4_WORD2_UMASK) {
+		*p++ = cpu_to_be32(iap->ia_mode & S_IALLUGO);
+		*p++ = cpu_to_be32(*umask);
+	}
 
 /* out: */
 }
@@ -1183,7 +1191,8 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 	}
 
 	encode_string(xdr, create->name->len, create->name->name);
-	encode_attrs(xdr, create->attrs, create->label, create->server, false);
+	encode_attrs(xdr, create->attrs, create->label, create->server, false,
+		     &create->umask);
 }
 
 static void encode_getattr_one(struct xdr_stream *xdr, uint32_t bitmap, struct compound_hdr *hdr)
@@ -1403,11 +1412,13 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
 	switch(arg->createmode) {
 	case NFS4_CREATE_UNCHECKED:
 		*p = cpu_to_be32(NFS4_CREATE_UNCHECKED);
-		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server, false);
+		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server, false,
+			     &arg->umask);
 		break;
 	case NFS4_CREATE_GUARDED:
 		*p = cpu_to_be32(NFS4_CREATE_GUARDED);
-		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server, false);
+		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server, false,
+			     &arg->umask);
 		break;
 	case NFS4_CREATE_EXCLUSIVE:
 		*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE);
@@ -1416,7 +1427,8 @@ static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_op
 	case NFS4_CREATE_EXCLUSIVE4_1:
 		*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE4_1);
 		encode_nfs4_verifier(xdr, &arg->u.verifier);
-		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server, true);
+		encode_attrs(xdr, arg->u.attrs, arg->label, arg->server, true,
+			     &arg->umask);
 	}
 }
 
@@ -1672,7 +1684,7 @@ static void encode_setattr(struct xdr_stream *xdr, const struct nfs_setattrargs
 {
 	encode_op_hdr(xdr, OP_SETATTR, decode_setattr_maxsz, hdr);
 	encode_nfs4_stateid(xdr, &arg->stateid);
-	encode_attrs(xdr, arg->iap, arg->label, server, false);
+	encode_attrs(xdr, arg->iap, arg->label, server, false, NULL);
 }
 
 static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclientid *setclientid, struct compound_hdr *hdr)
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 9094faf0699d..2f0d37937afc 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -440,6 +440,7 @@ enum lock_type4 {
 #define FATTR4_WORD2_MDSTHRESHOLD       (1UL << 4)
 #define FATTR4_WORD2_CLONE_BLKSIZE	(1UL << 13)
 #define FATTR4_WORD2_SECURITY_LABEL     (1UL << 16)
+#define FATTR4_WORD2_UMASK		(1UL << 17)
 
 /* MDS threshold bitmap bits */
 #define THRESHOLD_RD                    (1UL << 0)
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index b34097c67848..001625fae763 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -250,5 +250,6 @@ struct nfs_server {
 #define NFS_CAP_LAYOUTSTATS	(1U << 22)
 #define NFS_CAP_CLONE		(1U << 23)
 #define NFS_CAP_COPY		(1U << 24)
+#define NFS_CAP_UMASK		(1U << 25)
 
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index beb1e10f446e..ff82f42da656 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -418,6 +418,7 @@ struct nfs_openargs {
 	enum open_claim_type4	claim;
 	enum createmode4	createmode;
 	const struct nfs4_label *label;
+	umode_t			umask;
 };
 
 struct nfs_openres {
@@ -937,6 +938,7 @@ struct nfs4_create_arg {
 	const struct nfs_fh *		dir_fh;
 	const u32 *			bitmask;
 	const struct nfs4_label		*label;
+	umode_t				umask;
 };
 
 struct nfs4_create_res {
-- 
2.7.4

