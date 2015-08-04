Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33814 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933712AbbHDLzg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2015 07:55:36 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: [RFC v6 30/40] nfsd: Add richacl support
Date: Tue,  4 Aug 2015 13:53:28 +0200
Message-Id: <1438689218-6921-31-git-send-email-agruenba@redhat.com>
In-Reply-To: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
References: <1438689218-6921-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On file systems with richacls enabled, get and set richacls directly
instead of converting from / to posix acls.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/nfsd/acl.h      |   3 +-
 fs/nfsd/nfs4acl.c  | 124 ++++++++++++++++++++++++++++++++++++++---------------
 fs/nfsd/nfs4proc.c |   2 +-
 fs/nfsd/nfs4xdr.c  |  34 +++++++++++----
 4 files changed, 117 insertions(+), 46 deletions(-)

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
index 18fe74d..86a3d41 100644
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
@@ -127,32 +129,28 @@ static short ace2type(struct richace *);
 static void _posix_to_richacl_one(struct posix_acl *, struct richacl_alloc *,
 				unsigned int);
 
-int
-nfsd4_get_acl(struct svc_rqst *rqstp, struct dentry *dentry,
-	      struct richacl **acl)
+static struct richacl *
+nfsd4_get_posix_acl(struct svc_rqst *rqstp, struct dentry *dentry)
 {
 	struct inode *inode = d_inode(dentry);
-	int error = 0;
 	struct posix_acl *pacl = NULL, *dpacl = NULL;
 	struct richacl_alloc alloc;
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
+			alloc.acl = (void *)dpacl;
 			goto rel_pacl;
 		}
 
@@ -161,7 +159,7 @@ nfsd4_get_acl(struct svc_rqst *rqstp, struct dentry *dentry,
 	}
 
 	if (!richacl_prepare(&alloc, count)) {
-		error = -ENOMEM;
+		alloc.acl = ERR_PTR(-ENOMEM);
 		goto out;
 	}
 
@@ -170,13 +168,37 @@ nfsd4_get_acl(struct svc_rqst *rqstp, struct dentry *dentry,
 	if (dpacl)
 		_posix_to_richacl_one(dpacl, &alloc, flags | FLAG_DEFAULT_ACL);
 
-	*acl = alloc.acl;
-
 out:
 	posix_acl_release(dpacl);
 rel_pacl:
 	posix_acl_release(pacl);
-	return error;
+	return alloc.acl;
+}
+
+struct richacl *
+nfsd4_get_acl(struct svc_rqst *rqstp, struct dentry *dentry)
+{
+	struct inode *inode = d_inode(dentry);
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
+		acl = richacl_from_mode(inode->i_mode);
+		if (acl == NULL)
+			acl = ERR_PTR(-ENOMEM);
+	}
+	error = richacl_apply_masks(&acl, inode->i_uid);
+	if (error) {
+		richacl_put(acl);
+		acl = ERR_PTR(error);
+	}
+	return acl;
 }
 
 struct posix_acl_summary {
@@ -739,56 +761,88 @@ out_estate:
 	return ret;
 }
 
-__be32
-nfsd4_set_acl(struct svc_rqst *rqstp, struct svc_fh *fhp, struct richacl *acl)
+static int
+nfsd4_set_posix_acl(struct svc_rqst *rqstp, struct dentry *dentry,
+		    struct richacl *acl)
 {
-	__be32 error;
 	int host_error;
-	struct dentry *dentry;
-	struct inode *inode;
+	struct inode *inode = d_inode(dentry);
 	struct posix_acl *pacl = NULL, *dpacl = NULL;
 	unsigned int flags = 0;
 
-	/* Get inode */
-	error = fh_verify(rqstp, fhp, 0, NFSD_MAY_SATTR);
-	if (error)
-		return error;
-
-	dentry = fhp->fh_dentry;
-	inode = d_inode(dentry);
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
+	if (S_ISDIR(inode->i_mode))
 		host_error = inode->i_op->set_acl(inode, dpacl,
 						  ACL_TYPE_DEFAULT);
-	}
 
 out_release:
 	posix_acl_release(pacl);
 	posix_acl_release(dpacl);
-out_nfserr:
+	return host_error;
+}
+
+static int
+nfsd4_set_richacl(struct svc_rqst *rqstp, struct dentry *dentry,
+		  struct richacl *acl)
+{
+	int host_error;
+	struct inode *inode = d_inode(dentry);
+	size_t size = richacl_xattr_size(acl);
+	char *buffer;
+
+	if (!inode->i_op->setxattr || !IS_RICHACL(inode))
+		return -EOPNOTSUPP;
+
+	richacl_compute_max_masks(acl, inode->i_uid);
+
+	buffer = kmalloc(size, GFP_KERNEL);
+	if (!buffer)
+		return -ENOMEM;
+	richacl_to_xattr(&init_user_ns, acl, buffer, size);
+	host_error = inode->i_op->setxattr(dentry, RICHACL_XATTR,
+					   buffer, size, 0);
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
+	if (IS_RICHACL(d_inode(dentry)))
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
index 8c2cb16..9f8f0a8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -110,7 +110,7 @@ check_attr_support(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 * in current environment or not.
 	 */
 	if (bmval[0] & FATTR4_WORD0_ACL) {
-		if (!IS_POSIXACL(d_inode(dentry)))
+		if (!IS_ACL(d_inode(dentry)))
 			return nfserr_attrnotsupp;
 	}
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index b66e292..8628065 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -340,11 +340,24 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 
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
@@ -2275,7 +2288,11 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
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
@@ -2334,7 +2351,7 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 		u32 word1 = nfsd_suppattrs1(minorversion);
 		u32 word2 = nfsd_suppattrs2(minorversion);
 
-		if (!IS_POSIXACL(dentry->d_inode))
+		if (!IS_ACL(d_inode(dentry)))
 			word0 &= ~FATTR4_WORD0_ACL;
 		if (!contextsupport)
 			word2 &= ~FATTR4_WORD2_SECURITY_LABEL;
@@ -2469,7 +2486,8 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 			if (!p)
 				goto out_resource;
 			*p++ = cpu_to_be32(ace->e_type);
-			*p++ = cpu_to_be32(ace->e_flags & ~RICHACE_SPECIAL_WHO);
+			*p++ = cpu_to_be32(ace->e_flags &
+				~(RICHACE_SPECIAL_WHO | RICHACE_INHERITED_ACE));
 			*p++ = cpu_to_be32(ace->e_mask & NFS4_ACE_MASK_ALL);
 			status = nfsd4_encode_ace_who(xdr, rqstp, ace);
 			if (status)
@@ -2481,7 +2499,7 @@ out_acl:
 		p = xdr_reserve_space(xdr, 4);
 		if (!p)
 			goto out_resource;
-		*p++ = cpu_to_be32(IS_POSIXACL(dentry->d_inode) ?
+		*p++ = cpu_to_be32(IS_ACL(d_inode(dentry)) ?
 			ACL4_SUPPORT_ALLOW_ACL|ACL4_SUPPORT_DENY_ACL : 0);
 	}
 	if (bmval0 & FATTR4_WORD0_CANSETTIME) {
-- 
2.5.0

