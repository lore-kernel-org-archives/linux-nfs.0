Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59815 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753310Ab2LQPnU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 10:43:20 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 13/13] NFSD: Server implementation of MAC Labeling
Date: Mon, 17 Dec 2012 10:43:11 -0500
Message-Id: <1355758991-30049-14-git-send-email-steved@redhat.com>
In-Reply-To: <1355758991-30049-1-git-send-email-steved@redhat.com>
References: <1355758991-30049-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Quigley <dpquigl@davequigley.com>

This patch adds the ability to encode and decode file labels on the server for
the purpose of sending them to the client and also to process label change
requests from the client.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
---
 fs/nfsd/export.c   |   3 ++
 fs/nfsd/nfs4proc.c |  33 +++++++++++++++
 fs/nfsd/nfs4xdr.c  | 121 ++++++++++++++++++++++++++++++++++++++++++++++++++---
 fs/nfsd/vfs.c      |  31 ++++++++++++++
 fs/nfsd/vfs.h      |   2 +
 5 files changed, 184 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index a3946cf..251eca7 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1112,6 +1112,9 @@ static struct flags {
 	{ NFSEXP_ASYNC, {"async", "sync"}},
 	{ NFSEXP_GATHERED_WRITES, {"wdelay", "no_wdelay"}},
 	{ NFSEXP_NOHIDE, {"nohide", ""}},
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+	{ NFSEXP_SECURITY_LABEL, {"security_label", ""}},
+#endif
 	{ NFSEXP_CROSSMOUNT, {"crossmnt", ""}},
 	{ NFSEXP_NOSUBTREECHECK, {"no_subtree_check", ""}},
 	{ NFSEXP_NOAUTHNLM, {"insecure_locks", ""}},
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6c9a4b2..8e9c17c 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -41,6 +41,10 @@
 #include "vfs.h"
 #include "current_stateid.h"
 
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+#include <linux/security.h>
+#endif
+
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
 static u32 nfsd_attrmask[] = {
@@ -228,6 +232,18 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
 					(u32 *)open->op_verf.data,
 					&open->op_truncate, &open->op_created);
 
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+		if (!status && open->op_label != NULL) {
+			struct inode *inode = resfh->fh_dentry->d_inode;
+
+			mutex_lock(&inode->i_mutex);
+			/* Is it appropriate to just kick back an error? */
+			status = security_inode_setsecctx(resfh->fh_dentry,
+					open->op_label->label, open->op_label->len);
+			mutex_unlock(&inode->i_mutex);
+		}
+#endif
+
 		/*
 		 * Following rfc 3530 14.2.16, use the returned bitmask
 		 * to indicate which attributes we used to store the
@@ -588,6 +604,18 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfserr_badtype;
 	}
 
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+	if (!status && create->cr_label != NULL) {
+		struct inode *inode = resfh.fh_dentry->d_inode;
+
+		mutex_lock(&inode->i_mutex);
+		/* Is it appropriate to just kick back an error? */
+		status = security_inode_setsecctx(resfh.fh_dentry,
+				create->cr_label->label, create->cr_label->len);
+		mutex_unlock(&inode->i_mutex);
+	}
+#endif
+
 	if (status)
 		goto out;
 
@@ -869,6 +897,11 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					    setattr->sa_acl);
 	if (status)
 		goto out;
+	if (setattr->sa_label != NULL)
+		status = nfsd4_set_nfs4_label(rqstp, &cstate->current_fh,
+				setattr->sa_label);
+	if (status)
+		goto out;
 	status = nfsd_setattr(rqstp, &cstate->current_fh, &setattr->sa_iattr,
 				0, (time_t)0);
 out:
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fd548d1..58e205c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -54,6 +54,11 @@
 #include "state.h"
 #include "cache.h"
 
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+#include <linux/security.h>
+#endif
+
+
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
 /*
@@ -241,7 +246,8 @@ nfsd4_decode_bitmap(struct nfsd4_compoundargs *argp, u32 *bmval)
 
 static __be32
 nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
-		   struct iattr *iattr, struct nfs4_acl **acl)
+		   struct iattr *iattr, struct nfs4_acl **acl,
+		   struct nfs4_label **label)
 {
 	int expected_len, len = 0;
 	u32 dummy32;
@@ -385,6 +391,50 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 			goto xdr_error;
 		}
 	}
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+	if (bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
+		uint32_t pi;
+		uint32_t lfs;
+
+		READ_BUF(4);
+		len += 4;
+		READ32(lfs);
+		READ_BUF(4);
+		len += 4;
+		READ32(pi);
+		READ_BUF(4);
+		len += 4;
+		READ32(dummy32);
+		READ_BUF(dummy32);
+		len += (XDR_QUADLEN(dummy32) << 2);
+		READMEM(buf, dummy32);
+
+		if (dummy32 > NFS4_MAXLABELLEN)
+			return nfserr_resource;
+
+		*label = kzalloc(sizeof(struct nfs4_label), GFP_KERNEL);
+		if (*label == NULL) {
+			host_err = -ENOMEM;
+			goto out_nfserr;
+		}
+
+		(*label)->label = kmalloc(dummy32 + 1, GFP_KERNEL);
+		if ((*label)->label == NULL) {
+			host_err = -ENOMEM;
+			kfree(*label);
+			goto out_nfserr;
+		}
+
+		(*label)->len = dummy32;
+		memcpy((*label)->label, buf, dummy32);
+		((char *)(*label)->label)[dummy32] = '\0';
+		(*label)->pi = pi;
+		(*label)->lfs = lfs;
+
+		defer_free(argp, kfree, (*label)->label);
+		defer_free(argp, kfree, *label);
+	}
+#endif
 	if (bmval[0] & ~NFSD_WRITEABLE_ATTRS_WORD0
 	    || bmval[1] & ~NFSD_WRITEABLE_ATTRS_WORD1
 	    || bmval[2] & ~NFSD_WRITEABLE_ATTRS_WORD2)
@@ -494,7 +544,7 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
 		return status;
 
 	status = nfsd4_decode_fattr(argp, create->cr_bmval, &create->cr_iattr,
-				    &create->cr_acl);
+				    &create->cr_acl, &create->cr_label);
 	if (status)
 		goto out;
 
@@ -744,7 +794,7 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 		case NFS4_CREATE_UNCHECKED:
 		case NFS4_CREATE_GUARDED:
 			status = nfsd4_decode_fattr(argp, open->op_bmval,
-				&open->op_iattr, &open->op_acl);
+				&open->op_iattr, &open->op_acl, &open->op_label);
 			if (status)
 				goto out;
 			break;
@@ -758,7 +808,7 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 			READ_BUF(NFS4_VERIFIER_SIZE);
 			COPYMEM(open->op_verf.data, NFS4_VERIFIER_SIZE);
 			status = nfsd4_decode_fattr(argp, open->op_bmval,
-				&open->op_iattr, &open->op_acl);
+				&open->op_iattr, &open->op_acl, &open->op_label);
 			if (status)
 				goto out;
 			break;
@@ -981,7 +1031,7 @@ nfsd4_decode_setattr(struct nfsd4_compoundargs *argp, struct nfsd4_setattr *seta
 	if (status)
 		return status;
 	return nfsd4_decode_fattr(argp, setattr->sa_bmval, &setattr->sa_iattr,
-				  &setattr->sa_acl);
+				  &setattr->sa_acl, &setattr->sa_label);
 }
 
 static __be32
@@ -1045,7 +1095,7 @@ nfsd4_decode_verify(struct nfsd4_compoundargs *argp, struct nfsd4_verify *verify
 	 * nfsd4_proc_verify; however we still decode here just to return
 	 * correct error in case of bad xdr. */
 #if 0
-	status = nfsd4_decode_fattr(ve_bmval, &ve_iattr, &ve_acl);
+	status = nfsd4_decode_fattr(ve_bmval, &ve_iattr, &ve_acl, &ve_label);
 	if (status == nfserr_inval) {
 		status = nfserrno(status);
 		goto out;
@@ -1998,6 +2048,47 @@ nfsd4_encode_aclname(struct svc_rqst *rqstp, int whotype, uid_t id, int group,
 			      FATTR4_WORD0_RDATTR_ERROR)
 #define WORD1_ABSENT_FS_ATTRS FATTR4_WORD1_MOUNTED_ON_FILEID
 
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+	static inline __be32
+nfsd4_encode_security_label(struct svc_rqst *rqstp, struct dentry *dentry, __be32 **pp, int *buflen)
+{
+	void *context;
+	int err;
+	int len;
+	uint32_t pi = 0;
+	uint32_t lfs = 0;
+	__be32 *p = *pp;
+
+	err = 0;
+	(void)security_inode_getsecctx(dentry->d_inode, &context, &len);
+	if (len < 0)
+		return nfserrno(len);
+
+	if (*buflen < ((XDR_QUADLEN(len) << 2) + 4 + 4 + 4)) {
+		err = nfserr_resource;
+		goto out;
+	}
+
+	/* XXX: A call to the translation code should be placed here
+	 * for now send 0  until we have that to indicate the null
+	 * translation */ 
+
+	if ((*buflen -= 4) < 0)
+		return nfserr_resource;
+
+	WRITE32(lfs);	
+	WRITE32(pi);
+	p = xdr_encode_opaque(p, context, len);
+	*buflen -= (XDR_QUADLEN(len) << 2) + 4;
+	BUG_ON(*buflen < 0);
+
+	*pp = p;
+out:
+	security_release_secctx(context, len);
+	return err;
+}
+#endif
+
 static __be32 fattr_handle_absent_fs(u32 *bmval0, u32 *bmval1, u32 *rdattr_err)
 {
 	/* As per referral draft:  */
@@ -2122,6 +2213,14 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 
 		if (!aclsupport)
 			word0 &= ~FATTR4_WORD0_ACL;
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+		if (exp->ex_flags & NFSEXP_SECURITY_LABEL)
+			word2 |= FATTR4_WORD2_SECURITY_LABEL;
+		else
+			word2 &= ~FATTR4_WORD2_SECURITY_LABEL;
+#else
+		word2 &= ~FATTR4_WORD2_SECURITY_LABEL;
+#endif
 		if (!word2) {
 			if ((buflen -= 12) < 0)
 				goto out_resource;
@@ -2444,6 +2543,16 @@ out_acl:
 		}
 		WRITE64(stat.ino);
 	}
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+	if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
+		status = nfsd4_encode_security_label(rqstp, dentry,
+				&p, &buflen);
+		if (status == nfserr_resource)
+			goto out_resource;
+		if (status)
+			goto out;
+	}
+#endif
 	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
 		WRITE32(3);
 		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD0);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index c120b48..717fb60 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -28,6 +28,7 @@
 #include <asm/uaccess.h>
 #include <linux/exportfs.h>
 #include <linux/writeback.h>
+#include <linux/security.h>
 
 #ifdef CONFIG_NFSD_V3
 #include "xdr3.h"
@@ -621,6 +622,36 @@ int nfsd4_is_junction(struct dentry *dentry)
 		return 0;
 	return 1;
 }
+
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+__be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
+		struct nfs4_label *label)
+{
+	__be32 error;
+	int host_error;
+	struct dentry *dentry;
+
+	/* Get inode */
+	/* XXX: should we have a MAY_SSECCTX? */
+	error = fh_verify(rqstp, fhp, 0 /* S_IFREG */, NFSD_MAY_SATTR);
+	if (error)
+		return error;
+
+	dentry = fhp->fh_dentry;
+
+	mutex_lock(&dentry->d_inode->i_mutex);
+	host_error = security_inode_setsecctx(dentry, label->label, label->len);
+	mutex_unlock(&dentry->d_inode->i_mutex);
+	return nfserrno(host_error);
+}
+#else
+__be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
+		struct nfs4_label *label)
+{
+	return -EOPNOTSUPP;
+}
+#endif
+
 #endif /* defined(CONFIG_NFSD_V4) */
 
 #ifdef CONFIG_NFSD_V3
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 359594c..49c6cc0 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -55,6 +55,8 @@ int nfsd_mountpoint(struct dentry *, struct svc_export *);
 __be32          nfsd4_set_nfs4_acl(struct svc_rqst *, struct svc_fh *,
                     struct nfs4_acl *);
 int             nfsd4_get_nfs4_acl(struct svc_rqst *, struct dentry *, struct nfs4_acl **);
+__be32          nfsd4_set_nfs4_label(struct svc_rqst *, struct svc_fh *,
+		    struct nfs4_label *);
 #endif /* CONFIG_NFSD_V4 */
 __be32		nfsd_create(struct svc_rqst *, struct svc_fh *,
 				char *name, int len, struct iattr *attrs,
-- 
1.7.11.7

