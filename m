Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35334 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903AbbC0Qw0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:52:26 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [RFC 33/39] nfsd: Add richacl support
Date: Fri, 27 Mar 2015 17:50:31 +0100
Message-Id: <5c9f7d23399017c28314596d53e08f0218be7bee.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On file systems with richacls enabled, get and set richacls directly instead of
converting from / to posix acls.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/nfsd/nfs4acl.c  | 89 ++++++++++++++++++++++++++++++++++++++++++++----------
 fs/nfsd/nfs4proc.c |  2 +-
 fs/nfsd/nfs4xdr.c  | 21 ++++++++++---
 3 files changed, 91 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index 9e65a19..8e0cea1 100644
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
@@ -127,8 +129,8 @@ static short ace2type(struct richace *);
 static void _posix_to_richacl_one(struct posix_acl *, struct richacl_alloc *,
 				unsigned int);
 
-int
-nfsd4_get_acl(struct svc_rqst *rqstp, struct dentry *dentry, struct richacl **acl)
+static int
+nfsd4_get_posix_acl(struct svc_rqst *rqstp, struct dentry *dentry, struct richacl **acl)
 {
 	struct inode *inode = dentry->d_inode;
 	int error = 0;
@@ -144,7 +146,8 @@ nfsd4_get_acl(struct svc_rqst *rqstp, struct dentry *dentry, struct richacl **ac
 	if (IS_ERR(pacl))
 		return PTR_ERR(pacl);
 
-	/* allocate for worst case: one (deny, allow) pair each: */
+	/* Allocate for worst case: one (deny, allow) pair each.  The resulting
+	   acl will be released shortly and won't be cached. */
 	count = 2 * pacl->a_count;
 
 	if (S_ISDIR(inode->i_mode)) {
@@ -178,6 +181,38 @@ rel_pacl:
 	return error;
 }
 
+static int
+nfsd4_get_richacl(struct svc_rqst *rqstp, struct dentry *dentry, struct richacl **acl)
+{
+	struct inode *inode = dentry->d_inode;
+	struct richacl *acl2;
+	int error;
+
+	acl2 = get_richacl(inode);
+	if (!acl2)
+		acl2 = richacl_from_mode(inode->i_mode);
+
+	if (IS_ERR(acl2))
+		return PTR_ERR(acl2);
+	error = richacl_apply_masks(&acl2);
+	if (error)
+		richacl_put(acl2);
+	else
+		*acl = acl2;
+	return error;
+}
+
+int
+nfsd4_get_acl(struct svc_rqst *rqstp, struct dentry *dentry, struct richacl **acl)
+{
+	struct inode *inode = dentry->d_inode;
+
+	if (IS_RICHACL(inode))
+		return nfsd4_get_richacl(rqstp, dentry, acl);
+	else
+		return nfsd4_get_posix_acl(rqstp, dentry, acl);
+}
+
 struct posix_acl_summary {
 	unsigned short owner;
 	unsigned short users;
@@ -788,24 +823,14 @@ out_estate:
 	return ret;
 }
 
-__be32
-nfsd4_set_acl(struct svc_rqst *rqstp, struct svc_fh *fhp, struct richacl *acl)
+static __be32
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
 		return nfserr_attrnotsupp;
 
@@ -837,6 +862,38 @@ out_nfserr:
 		return nfserrno(host_error);
 }
 
+static __be32
+nfsd4_set_richacl(struct svc_rqst *rqstp, struct dentry *dentry, struct richacl *acl)
+{
+	size_t size = richacl_xattr_size(acl);
+	char *buffer;
+	int error;
+
+	buffer = kmalloc(size, GFP_KERNEL);
+	if (!buffer)
+		return -ENOMEM;
+	richacl_to_xattr(&init_user_ns, acl, buffer, size);
+	error = vfs_setxattr(dentry, RICHACL_XATTR, buffer, size, 0);
+	kfree(buffer);
+	return error;
+}
+
+__be32
+nfsd4_set_acl(struct svc_rqst *rqstp, struct svc_fh *fhp, struct richacl *acl)
+{
+	struct dentry *dentry;
+	__be32 error;
+
+	error = fh_verify(rqstp, fhp, 0, NFSD_MAY_SATTR);
+	if (error)
+		return error;
+	dentry = fhp->fh_dentry;
+
+	if (IS_RICHACL(dentry->d_inode))
+		return nfsd4_set_richacl(rqstp, dentry, acl);
+	else
+		return nfsd4_set_posix_acl(rqstp, dentry, acl);
+}
 
 static short
 ace2type(struct richace *ace)
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 687726c..a477477c 100644
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
index a882a86..d33335e 100644
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
+			if (dummy32 & ~RICHACE_VALID_MASK)
+				return nfserr_inval;
+			ace->e_mask = dummy32;
+
 			dummy32 = be32_to_cpup(p++);
 			READ_BUF(dummy32);
 			len += XDR_QUADLEN(dummy32) << 2;
-- 
2.1.0

