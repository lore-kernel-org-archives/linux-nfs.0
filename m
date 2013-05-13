Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52718 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753285Ab3EMQW0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 May 2013 12:22:26 -0400
Date: Mon, 13 May 2013 12:22:23 -0400
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com, David Quigley <dpquigl@davequigley.com>
Subject: [PATCH] NFSD: Server implementation of MAC Labeling
Message-ID: <20130513162223.GE1931@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Quigley <dpquigl@davequigley.com>

Implement labeled NFS on the server: encoding and decoding, and writing
and reading, of file labels.

Enabled with CONFIG_NFSD_V4_SECURITY_LABEL.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/Kconfig    |   16 ++++++++
 fs/nfsd/nfs4proc.c |   41 ++++++++++++++++++++
 fs/nfsd/nfs4xdr.c  |  108 ++++++++++++++++++++++++++++++++++++++++++++++++----
 fs/nfsd/nfsd.h     |   18 ++++++++-
 fs/nfsd/vfs.c      |   28 ++++++++++++++
 fs/nfsd/vfs.h      |    2 +
 fs/nfsd/xdr4.h     |    4 ++
 7 files changed, 207 insertions(+), 10 deletions(-)

Steved, this patch includes your fixes from the weekend--is it working
for you now?

If so, I'll go ahead and commit for 3.11.

It applies on top of the for-3.11 branch at

	git://linux-nfs.org/~bfields/linux.git for-3.11

--b.

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 430b687..dc8f1ef 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -81,6 +81,22 @@ config NFSD_V4
 
 	  If unsure, say N.
 
+config NFSD_V4_SECURITY_LABEL
+	bool "Provide Security Label support for NFSv4 server"
+	depends on NFSD_V4 && SECURITY
+	help
+
+	Say Y here if you want enable fine-grained security label attribute
+	support for NFS version 4.  Security labels allow security modules like
+	SELinux and Smack to label files to facilitate enforcement of their policies.
+	Without this an NFSv4 mount will have the same label on each file.
+
+	If you do not wish to enable fine-grained security labels SELinux or
+	Smack policies on NFSv4 files, say N.
+
+	WARNING: there is still a chance of backwards-incompatible protocol changes.
+	For now we recommend "Y" only for developers and testers."
+
 config NFSD_FAULT_INJECTION
 	bool "NFS server manual fault injection"
 	depends on NFSD_V4 && DEBUG_KERNEL
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 27d74a2..1a1ff24 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -42,6 +42,36 @@
 #include "current_stateid.h"
 #include "netns.h"
 
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+#include <linux/security.h>
+
+static inline void
+nfsd4_security_inode_setsecctx(struct svc_fh *resfh, struct xdr_netobj *label, u32 *bmval)
+{
+	struct inode *inode = resfh->fh_dentry->d_inode;
+	int status;
+
+	mutex_lock(&inode->i_mutex);
+	status = security_inode_setsecctx(resfh->fh_dentry,
+		label->data, label->len);
+	mutex_unlock(&inode->i_mutex);
+
+	if (status)
+		/*
+		 * XXX: We should really fail the whole open, but we may
+		 * already have created a new file, so it may be too
+		 * late.  For now this seems the least of evils:
+		 */
+		bmval[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
+
+	return;
+}
+#else
+static inline void
+nfsd4_security_inode_setsecctx(struct svc_fh *resfh, struct xdr_netobj *label, u32 *bmval)
+{ }
+#endif
+
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
 static u32 nfsd_attrmask[] = {
@@ -239,6 +269,9 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
 					(u32 *)open->op_verf.data,
 					&open->op_truncate, &open->op_created);
 
+		if (!status && open->op_label.len)
+			nfsd4_security_inode_setsecctx(resfh, &open->op_label, open->op_bmval);
+
 		/*
 		 * Following rfc 3530 14.2.16, use the returned bitmask
 		 * to indicate which attributes we used to store the
@@ -637,6 +670,9 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		goto out;
 
+	if (create->cr_label.len)
+		nfsd4_security_inode_setsecctx(&resfh, &create->cr_label, create->cr_bmval);
+
 	if (create->cr_acl != NULL)
 		do_set_nfs4_acl(rqstp, &resfh, create->cr_acl,
 				create->cr_bmval);
@@ -916,6 +952,11 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					    setattr->sa_acl);
 	if (status)
 		goto out;
+	if (setattr->sa_label.len)
+		status = nfsd4_set_nfs4_label(rqstp, &cstate->current_fh,
+				&setattr->sa_label);
+	if (status)
+		goto out;
 	status = nfsd_setattr(rqstp, &cstate->current_fh, &setattr->sa_iattr,
 				0, (time_t)0);
 out:
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 9aeacdd..dfca512 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -55,6 +55,11 @@
 #include "cache.h"
 #include "netns.h"
 
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+#include <linux/security.h>
+#endif
+
+
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
 /*
@@ -242,7 +247,8 @@ nfsd4_decode_bitmap(struct nfsd4_compoundargs *argp, u32 *bmval)
 
 static __be32
 nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
-		   struct iattr *iattr, struct nfs4_acl **acl)
+		   struct iattr *iattr, struct nfs4_acl **acl,
+		   struct xdr_netobj *label)
 {
 	int expected_len, len = 0;
 	u32 dummy32;
@@ -380,6 +386,32 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 			goto xdr_error;
 		}
 	}
+
+	label->len = 0;
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+	if (bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
+		READ_BUF(4);
+		len += 4;
+		READ32(dummy32); /* lfs: we don't use it */
+		READ_BUF(4);
+		len += 4;
+		READ32(dummy32); /* pi: we don't use it either */
+		READ_BUF(4);
+		len += 4;
+		READ32(dummy32);
+		READ_BUF(dummy32);
+		if (dummy32 > NFSD4_MAX_SEC_LABEL_LEN)
+			return nfserr_badlabel;
+		len += (XDR_QUADLEN(dummy32) << 2);
+		READMEM(buf, dummy32);
+		label->data = kzalloc(dummy32 + 1, GFP_KERNEL);
+		if (!label->data)
+			return nfserr_jukebox;
+		defer_free(argp, kfree, label->data);
+		memcpy(label->data, buf, dummy32);
+	}
+#endif
+
 	if (bmval[0] & ~NFSD_WRITEABLE_ATTRS_WORD0
 	    || bmval[1] & ~NFSD_WRITEABLE_ATTRS_WORD1
 	    || bmval[2] & ~NFSD_WRITEABLE_ATTRS_WORD2)
@@ -576,7 +608,7 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
 		return status;
 
 	status = nfsd4_decode_fattr(argp, create->cr_bmval, &create->cr_iattr,
-				    &create->cr_acl);
+				    &create->cr_acl, &create->cr_label);
 	if (status)
 		goto out;
 
@@ -827,7 +859,7 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 		case NFS4_CREATE_UNCHECKED:
 		case NFS4_CREATE_GUARDED:
 			status = nfsd4_decode_fattr(argp, open->op_bmval,
-				&open->op_iattr, &open->op_acl);
+				&open->op_iattr, &open->op_acl, &open->op_label);
 			if (status)
 				goto out;
 			break;
@@ -841,7 +873,7 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 			READ_BUF(NFS4_VERIFIER_SIZE);
 			COPYMEM(open->op_verf.data, NFS4_VERIFIER_SIZE);
 			status = nfsd4_decode_fattr(argp, open->op_bmval,
-				&open->op_iattr, &open->op_acl);
+				&open->op_iattr, &open->op_acl, &open->op_label);
 			if (status)
 				goto out;
 			break;
@@ -1063,7 +1095,7 @@ nfsd4_decode_setattr(struct nfsd4_compoundargs *argp, struct nfsd4_setattr *seta
 	if (status)
 		return status;
 	return nfsd4_decode_fattr(argp, setattr->sa_bmval, &setattr->sa_iattr,
-				  &setattr->sa_acl);
+				  &setattr->sa_acl, &setattr->sa_label);
 }
 
 static __be32
@@ -1954,6 +1986,36 @@ nfsd4_encode_aclname(struct svc_rqst *rqstp, struct nfs4_ace *ace,
 			      FATTR4_WORD0_RDATTR_ERROR)
 #define WORD1_ABSENT_FS_ATTRS FATTR4_WORD1_MOUNTED_ON_FILEID
 
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+static inline __be32
+nfsd4_encode_security_label(struct svc_rqst *rqstp, void *context, int len, __be32 **pp, int *buflen)
+{
+	__be32 *p = *pp;
+
+	if (*buflen < ((XDR_QUADLEN(len) << 2) + 4 + 4 + 4))
+		return nfserr_resource;
+
+	/*
+	 * For now we use a 0 here to indicate the null translation; in
+	 * the future we may place a call to translation code here.
+	 */
+	if ((*buflen -= 8) < 0)
+		return nfserr_resource;
+
+	WRITE32(0); /* lfs */
+	WRITE32(0); /* pi */
+	p = xdr_encode_opaque(p, context, len);
+	*buflen -= (XDR_QUADLEN(len) << 2) + 4;
+
+	*pp = p;
+	return 0;
+}
+#else
+static inline __be32
+nfsd4_encode_security_label(struct svc_rqst *rqstp, struct dentry *dentry, __be32 **pp, int *buflen)
+{ return 0; }
+#endif
+
 static __be32 fattr_handle_absent_fs(u32 *bmval0, u32 *bmval1, u32 *rdattr_err)
 {
 	/* As per referral draft:  */
@@ -2013,6 +2075,9 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 	int err;
 	int aclsupport = 0;
 	struct nfs4_acl *acl = NULL;
+	void *context = NULL;
+	int contextlen;
+	bool contextsupport = false;
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	u32 minorversion = resp->cstate.minorversion;
 	struct path path = {
@@ -2066,6 +2131,21 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		}
 	}
 
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+	if ((bmval[2] & FATTR4_WORD2_SECURITY_LABEL) ||
+			bmval[0] & FATTR4_WORD0_SUPPORTED_ATTRS) {
+		err = security_inode_getsecctx(dentry->d_inode,
+						&context, &contextlen);
+		contextsupport = (err == 0);
+		if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
+			if (err == -EOPNOTSUPP)
+				bmval2 &= ~FATTR4_WORD2_SECURITY_LABEL;
+			else if (err)
+				goto out_nfserr;
+		}
+	}
+#endif /* CONFIG_NFSD_V4_SECURITY_LABEL */
+
 	if (bmval2) {
 		if ((buflen -= 16) < 0)
 			goto out_resource;
@@ -2094,6 +2174,8 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 
 		if (!aclsupport)
 			word0 &= ~FATTR4_WORD0_ACL;
+		if (!contextsupport)
+			word2 &= ~FATTR4_WORD2_SECURITY_LABEL;
 		if (!word2) {
 			if ((buflen -= 12) < 0)
 				goto out_resource;
@@ -2401,6 +2483,12 @@ out_acl:
 			get_parent_attributes(exp, &stat);
 		WRITE64(stat.ino);
 	}
+	if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
+		status = nfsd4_encode_security_label(rqstp, context,
+				contextlen, &p, &buflen);
+		if (status)
+			goto out;
+	}
 	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
 		WRITE32(3);
 		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD0);
@@ -2413,6 +2501,8 @@ out_acl:
 	status = nfs_ok;
 
 out:
+	if (context)
+		security_release_secctx(context, contextlen);
 	kfree(acl);
 	if (fhp == &tempfh)
 		fh_put(&tempfh);
@@ -3177,16 +3267,18 @@ nfsd4_encode_setattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 {
 	__be32 *p;
 
-	RESERVE_SPACE(12);
+	RESERVE_SPACE(16);
 	if (nfserr) {
-		WRITE32(2);
+		WRITE32(3);
+		WRITE32(0);
 		WRITE32(0);
 		WRITE32(0);
 	}
 	else {
-		WRITE32(2);
+		WRITE32(3);
 		WRITE32(setattr->sa_bmval[0]);
 		WRITE32(setattr->sa_bmval[1]);
+		WRITE32(setattr->sa_bmval[2]);
 	}
 	ADJUST_ARGS();
 	return nfserr;
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 15e7e1d..2bbd94e 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -328,6 +328,13 @@ void		nfsd_lockd_shutdown(void);
 #define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
 	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT)
 
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+#define NFSD4_2_SUPPORTED_ATTRS_WORD2 \
+	(NFSD4_1_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SECURITY_LABEL)
+#else
+#define NFSD4_2_SUPPORTED_ATTRS_WORD2 0
+#endif
+
 static inline u32 nfsd_suppattrs0(u32 minorversion)
 {
 	return minorversion ? NFSD4_1_SUPPORTED_ATTRS_WORD0
@@ -342,8 +349,11 @@ static inline u32 nfsd_suppattrs1(u32 minorversion)
 
 static inline u32 nfsd_suppattrs2(u32 minorversion)
 {
-	return minorversion ? NFSD4_1_SUPPORTED_ATTRS_WORD2
-			    : NFSD4_SUPPORTED_ATTRS_WORD2;
+	switch (minorversion) {
+	default: return NFSD4_2_SUPPORTED_ATTRS_WORD2;
+	case 1:  return NFSD4_1_SUPPORTED_ATTRS_WORD2;
+	case 0:  return NFSD4_SUPPORTED_ATTRS_WORD2;
+	}
 }
 
 /* These will return ERR_INVAL if specified in GETATTR or READDIR. */
@@ -356,7 +366,11 @@ static inline u32 nfsd_suppattrs2(u32 minorversion)
 #define NFSD_WRITEABLE_ATTRS_WORD1 \
 	(FATTR4_WORD1_MODE | FATTR4_WORD1_OWNER | FATTR4_WORD1_OWNER_GROUP \
 	| FATTR4_WORD1_TIME_ACCESS_SET | FATTR4_WORD1_TIME_MODIFY_SET)
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+#define NFSD_WRITEABLE_ATTRS_WORD2 FATTR4_WORD2_SECURITY_LABEL
+#else
 #define NFSD_WRITEABLE_ATTRS_WORD2 0
+#endif
 
 #define NFSD_SUPPATTR_EXCLCREAT_WORD0 \
 	NFSD_WRITEABLE_ATTRS_WORD0
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 84ce601..1e757fa 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -28,6 +28,7 @@
 #include <asm/uaccess.h>
 #include <linux/exportfs.h>
 #include <linux/writeback.h>
+#include <linux/security.h>
 
 #ifdef CONFIG_NFSD_V3
 #include "xdr3.h"
@@ -621,6 +622,33 @@ int nfsd4_is_junction(struct dentry *dentry)
 		return 0;
 	return 1;
 }
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+__be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
+		struct xdr_netobj *label)
+{
+	__be32 error;
+	int host_error;
+	struct dentry *dentry;
+
+	error = fh_verify(rqstp, fhp, 0 /* S_IFREG */, NFSD_MAY_SATTR);
+	if (error)
+		return error;
+
+	dentry = fhp->fh_dentry;
+
+	mutex_lock(&dentry->d_inode->i_mutex);
+	host_error = security_inode_setsecctx(dentry, label->data, label->len);
+	mutex_unlock(&dentry->d_inode->i_mutex);
+	return nfserrno(host_error);
+}
+#else
+__be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
+		struct xdr_netobj *label)
+{
+	return nfserr_notsupp;
+}
+#endif
+
 #endif /* defined(CONFIG_NFSD_V4) */
 
 #ifdef CONFIG_NFSD_V3
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 8d2b40d..a4be2e3 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -55,6 +55,8 @@ int nfsd_mountpoint(struct dentry *, struct svc_export *);
 __be32          nfsd4_set_nfs4_acl(struct svc_rqst *, struct svc_fh *,
                     struct nfs4_acl *);
 int             nfsd4_get_nfs4_acl(struct svc_rqst *, struct dentry *, struct nfs4_acl **);
+__be32          nfsd4_set_nfs4_label(struct svc_rqst *, struct svc_fh *,
+		    struct xdr_netobj *);
 #endif /* CONFIG_NFSD_V4 */
 __be32		nfsd_create(struct svc_rqst *, struct svc_fh *,
 				char *name, int len, struct iattr *attrs,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 3b271d2..b3ed644 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -40,6 +40,7 @@
 #include "state.h"
 #include "nfsd.h"
 
+#define NFSD4_MAX_SEC_LABEL_LEN	2048
 #define NFSD4_MAX_TAGLEN	128
 #define XDR_LEN(n)                     (((n) + 3) & ~3)
 
@@ -118,6 +119,7 @@ struct nfsd4_create {
 	struct iattr	cr_iattr;           /* request */
 	struct nfsd4_change_info  cr_cinfo; /* response */
 	struct nfs4_acl *cr_acl;
+	struct xdr_netobj cr_label;
 };
 #define cr_linklen	u.link.namelen
 #define cr_linkname	u.link.name
@@ -246,6 +248,7 @@ struct nfsd4_open {
 	struct nfs4_file *op_file;          /* used during processing */
 	struct nfs4_ol_stateid *op_stp;	    /* used during processing */
 	struct nfs4_acl *op_acl;
+	struct xdr_netobj op_label;
 };
 #define op_iattr	iattr
 
@@ -330,6 +333,7 @@ struct nfsd4_setattr {
 	u32		sa_bmval[3];        /* request */
 	struct iattr	sa_iattr;           /* request */
 	struct nfs4_acl *sa_acl;
+	struct xdr_netobj sa_label;
 };
 
 struct nfsd4_setclientid {
-- 
1.7.9.5

