Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:34699 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965015AbbDXLFk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 07:05:40 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC v3 35/45] nfsd: Add richacl support
Date: Fri, 24 Apr 2015 13:04:32 +0200
Message-Id: <3ed8441b2d0c6833ff2ba83b6f7418a1dc40a5c4.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On file systems with richacls enabled, get and set richacls directly instead of
converting from / to posix acls.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/nfsd/acl.h      |   3 +-
 fs/nfsd/nfs4acl.c  | 123 +++++++++++++++++++++++++++++++++++++----------------
 fs/nfsd/nfs4proc.c |   2 +-
 fs/nfsd/nfs4xdr.c  |  34 +++++++++++----
 4 files changed, 115 insertions(+), 47 deletions(-)

diff --git a/fs/nfsd/acl.h b/fs/nfsd/acl.h
index 1c5deb5..d73c664 100644
--- a/fs/nfsd/acl.h
+++ b/fs/nfsd/acl.h
@@ -53,8 +53,7 @@ __be32 nfsd4_decode_ace_who(struct richace *ace, struct svc_rqst *rqstp,
 __be32 nfsd4_encode_ace_who(struct xdr_stream *xdr, struct svc_rqst *rqstp,
 			    struct richace *ace);
 
-int nfsd4_get_acl(struct svc_rqst *rqstp, struct dentry *dentry,
-		  struct richacl **acl);
+struct richacl *nfsd4_get_acl(struct svc_rqst *rqstp, struct dentry *dentry);
 __be32 nfsd4_set_acl(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		     struct richacl *acl);
 
diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index 9e65a19..b753d76 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -38,6 +38,8 @@
 #include <linux/nfs_fs.h>
 #include <linux/richacl_compat.h>
 #include <linux/nfs4acl.h>
+#include <linux/xattr.h>
+#include <linux/richacl_xattr.h>
 #include "nfsfh.h"
 #include "nfsd.h"
 #include "idmap.h"
@@ -127,31 +129,28 @@ static short ace2type(struct richace *);
 static void _posix_to_richacl_one(struct posix_acl *, struct richacl_alloc *,
 				unsigned int);
 
-int
-nfsd4_get_acl(struct svc_rqst *rqstp, struct dentry *dentry, struct richacl **acl)
+static struct richacl *
+nfsd4_get_posix_acl(struct svc_rqst *rqstp, struct dentry *dentry)
 {
 	struct inode *inode = dentry->d_inode;
-	int error = 0;
 	struct posix_acl *pacl = NULL, *dpacl = NULL;
 	struct richacl_alloc x;
 	unsigned int flags = 0;
 	int count;
 
 	pacl = get_acl(inode, ACL_TYPE_ACCESS);
-	if (!pacl)
-		pacl = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
-
-	if (IS_ERR(pacl))
-		return PTR_ERR(pacl);
+	if (IS_ERR_OR_NULL(pacl))
+		return (void *)pacl;
 
-	/* allocate for worst case: one (deny, allow) pair each: */
+	/* Allocate for worst case: one (deny, allow) pair each.  The resulting
+	   acl will be released shortly and won't be cached. */
 	count = 2 * pacl->a_count;
 
 	if (S_ISDIR(inode->i_mode)) {
 		flags = FLAG_DIRECTORY;
 		dpacl = get_acl(inode, ACL_TYPE_DEFAULT);
 		if (IS_ERR(dpacl)) {
-			error = PTR_ERR(dpacl);
+			x.acl = (void *)dpacl;
 			goto rel_pacl;
 		}
 
@@ -160,7 +159,7 @@ nfsd4_get_acl(struct svc_rqst *rqstp, struct dentry *dentry, struct richacl **ac
 	}
 
 	if (!richacl_prepare(&x, count)) {
-		error = -ENOMEM;
+		x.acl = ERR_PTR(-ENOMEM);
 		goto out;
 	}
 
@@ -169,13 +168,37 @@ nfsd4_get_acl(struct svc_rqst *rqstp, struct dentry *dentry, struct richacl **ac
 	if (dpacl)
 		_posix_to_richacl_one(dpacl, &x, flags | FLAG_DEFAULT_ACL);
 
-	*acl = x.acl;
-
 out:
 	posix_acl_release(dpacl);
 rel_pacl:
 	posix_acl_release(pacl);
-	return error;
+	return x.acl;
+}
+
+struct richacl *
+nfsd4_get_acl(struct svc_rqst *rqstp, struct dentry *dentry)
+{
+	struct inode *inode = dentry->d_inode;
+	struct richacl *acl;
+	int error;
+
+	if (IS_RICHACL(inode))
+		acl = get_richacl(inode);
+	else
+		acl = nfsd4_get_posix_acl(rqstp, dentry);
+	if (IS_ERR(acl))
+		return acl;
+	else if (acl == NULL) {
+		acl = richacl_from_mode_unmasked(inode->i_mode);
+		if (acl == NULL)
+			acl = ERR_PTR(-ENOMEM);
+	}
+	error = richacl_apply_masks(&acl);
+	if (error) {
+		richacl_put(acl);
+		acl = ERR_PTR(error);
+	}
+	return acl;
 }
 
 struct posix_acl_summary {
@@ -788,56 +811,84 @@ out_estate:
 	return ret;
 }
 
-__be32
-nfsd4_set_acl(struct svc_rqst *rqstp, struct svc_fh *fhp, struct richacl *acl)
+static int
+nfsd4_set_posix_acl(struct svc_rqst *rqstp, struct dentry *dentry, struct richacl *acl)
 {
-	__be32 error;
 	int host_error;
-	struct dentry *dentry;
-	struct inode *inode;
+	struct inode *inode = dentry->d_inode;
 	struct posix_acl *pacl = NULL, *dpacl = NULL;
 	unsigned int flags = 0;
 
-	/* Get inode */
-	error = fh_verify(rqstp, fhp, 0, NFSD_MAY_SATTR);
-	if (error)
-		return error;
-
-	dentry = fhp->fh_dentry;
-	inode = dentry->d_inode;
-
 	if (!inode->i_op->set_acl || !IS_POSIXACL(inode))
-		return nfserr_attrnotsupp;
+		return -EOPNOTSUPP;
 
 	if (S_ISDIR(inode->i_mode))
 		flags = FLAG_DIRECTORY;
 
 	host_error = nfs4_richacl_to_posix(acl, &pacl, &dpacl, flags);
 	if (host_error == -EINVAL)
-		return nfserr_attrnotsupp;
+		return -EOPNOTSUPP;
 	if (host_error < 0)
-		goto out_nfserr;
+		return host_error;
 
 	host_error = inode->i_op->set_acl(inode, pacl, ACL_TYPE_ACCESS);
 	if (host_error < 0)
 		goto out_release;
 
-	if (S_ISDIR(inode->i_mode)) {
-		host_error = inode->i_op->set_acl(inode, dpacl,
-						  ACL_TYPE_DEFAULT);
-	}
+	if (S_ISDIR(inode->i_mode))
+		host_error = inode->i_op->set_acl(inode, dpacl, ACL_TYPE_DEFAULT);
 
 out_release:
 	posix_acl_release(pacl);
 	posix_acl_release(dpacl);
-out_nfserr:
+	return host_error;
+}
+
+static int
+nfsd4_set_richacl(struct svc_rqst *rqstp, struct dentry *dentry, struct richacl *acl)
+{
+	int host_error;
+	struct inode *inode = dentry->d_inode;
+	size_t size = richacl_xattr_size(acl);
+	char *buffer;
+
+	if (!inode->i_op->setxattr || !IS_RICHACL(inode))
+		return -EOPNOTSUPP;
+
+	richacl_compute_max_masks(acl);
+
+	buffer = kmalloc(size, GFP_KERNEL);
+	if (!buffer)
+		return -ENOMEM;
+	richacl_to_xattr(&init_user_ns, acl, buffer, size);
+	host_error = inode->i_op->setxattr(dentry, RICHACL_XATTR, buffer, size, 0);
+	kfree(buffer);
+	return host_error;
+}
+
+__be32
+nfsd4_set_acl(struct svc_rqst *rqstp, struct svc_fh *fhp, struct richacl *acl)
+{
+	struct dentry *dentry;
+	int host_error;
+	__be32 error;
+
+	error = fh_verify(rqstp, fhp, 0, NFSD_MAY_SATTR);
+	if (error)
+		return error;
+	dentry = fhp->fh_dentry;
+
+	if (IS_RICHACL(dentry->d_inode))
+		host_error = nfsd4_set_richacl(rqstp, dentry, acl);
+	else
+		host_error = nfsd4_set_posix_acl(rqstp, dentry, acl);
+
 	if (host_error == -EOPNOTSUPP)
 		return nfserr_attrnotsupp;
 	else
 		return nfserrno(host_error);
 }
 
-
 static short
 ace2type(struct richace *ace)
 {
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 658da6e..2117e52 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -110,7 +110,7 @@ check_attr_support(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 * in current environment or not.
 	 */
 	if (bmval[0] & FATTR4_WORD0_ACL) {
-		if (!IS_POSIXACL(dentry->d_inode))
+		if (!IS_ACL(dentry->d_inode))
 			return nfserr_attrnotsupp;
 	}
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f3c1880..c0e1b3c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -339,11 +339,24 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 
 		richacl_for_each_entry(ace, *acl) {
 			READ_BUF(16); len += 16;
-			ace->e_type = be32_to_cpup(p++);
-			ace->e_flags = be32_to_cpup(p++);
-			ace->e_mask = be32_to_cpup(p++);
-			if (ace->e_flags & RICHACE_SPECIAL_WHO)
+
+			dummy32 = be32_to_cpup(p++);
+			if (dummy32 > RICHACE_ACCESS_DENIED_ACE_TYPE)
+				return nfserr_inval;
+			ace->e_type = dummy32;
+
+			dummy32 = be32_to_cpup(p++);
+			if (dummy32 & (~RICHACE_VALID_FLAGS |
+				       RICHACE_INHERITED_ACE |
+				       RICHACE_SPECIAL_WHO))
 				return nfserr_inval;
+			ace->e_flags = dummy32;
+
+			dummy32 = be32_to_cpup(p++);
+			if (dummy32 & ~NFS4_ACE_MASK_ALL)
+				return nfserr_inval;
+			ace->e_mask = dummy32;
+
 			dummy32 = be32_to_cpup(p++);
 			READ_BUF(dummy32);
 			len += XDR_QUADLEN(dummy32) << 2;
@@ -2274,7 +2287,11 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 		fhp = tempfh;
 	}
 	if (bmval0 & FATTR4_WORD0_ACL) {
-		err = nfsd4_get_nfs4_acl(rqstp, dentry, &acl);
+		acl = nfsd4_get_acl(rqstp, dentry);
+		if (IS_ERR(acl)) {
+			err = PTR_ERR(acl);
+			acl = NULL;
+		}
 		if (err == -EOPNOTSUPP)
 			bmval0 &= ~FATTR4_WORD0_ACL;
 		else if (err == -EINVAL) {
@@ -2333,7 +2350,7 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 		u32 word1 = nfsd_suppattrs1(minorversion);
 		u32 word2 = nfsd_suppattrs2(minorversion);
 
-		if (!IS_POSIXACL(dentry->d_inode))
+		if (!IS_ACL(dentry->d_inode))
 			word0 &= ~FATTR4_WORD0_ACL;
 		if (!contextsupport)
 			word2 &= ~FATTR4_WORD2_SECURITY_LABEL;
@@ -2468,7 +2485,8 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 			if (!p)
 				goto out_resource;
 			*p++ = cpu_to_be32(ace->e_type);
-			*p++ = cpu_to_be32(ace->e_flags & ~RICHACE_SPECIAL_WHO);
+			*p++ = cpu_to_be32(ace->e_flags &
+				~(RICHACE_SPECIAL_WHO | RICHACE_INHERITED_ACE));
 			*p++ = cpu_to_be32(ace->e_mask & NFS4_ACE_MASK_ALL);
 			status = nfsd4_encode_ace_who(xdr, rqstp, ace);
 			if (status)
@@ -2480,7 +2498,7 @@ out_acl:
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		*p++ = cpu_to_be32(IS_POSIXACL(dentry->d_inode) ?
+		*p++ = cpu_to_be32(IS_ACL(dentry->d_inode) ?
 			ACL4_SUPPORT_ALLOW_ACL|ACL4_SUPPORT_DENY_ACL : 0);
 	}
 	if (bmval0 & FATTR4_WORD0_CANSETTIME) {
-- 
2.1.0

