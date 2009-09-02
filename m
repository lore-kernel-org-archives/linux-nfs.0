From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 1/8] nfs4: Posix acl server side side-band protocol support
Date: Wed,  2 Sep 2009 17:54:21 +0530
Message-ID: <1251894268-1555-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org,
	nfsv4@linux-nfs.org, ffilzlnx@us.ibm.com, agruen@suse.de,
	aneesh.kumar@linux.vnet.ibm.com, sfrench@us.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([59.145.155.3]:33012 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbZIBMYw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 08:24:52 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp03.in.ibm.com (8.14.3/8.13.1) with ESMTP id n82COpaG026344
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:54:51 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n82COpew1773806
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:54:51 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n82COo2n001176
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 22:24:51 +1000
In-Reply-To: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/nfsd/Kconfig           |    6 +
 fs/nfsd/Makefile          |    1 +
 fs/nfsd/nfs4pacl.c        |  322 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfssvc.c          |   11 +-
 include/linux/nfsd/nfsd.h |    7 +-
 5 files changed, 341 insertions(+), 6 deletions(-)
 create mode 100644 fs/nfsd/nfs4pacl.c

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 503b9da..1156ae8 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -79,3 +79,9 @@ config NFSD_V4
 	  available from http://linux-nfs.org/.
 
 	  If unsure, say N.
+
+config NFSD_V4_PACL
+	bool "NFS server support for the NFSv4 POSIX ACL protocol extension"
+	depends on NFSD_V4
+	help
+	  POSIX ACL sideband protocol extension
diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
index 9b118ee..05b37bb 100644
--- a/fs/nfsd/Makefile
+++ b/fs/nfsd/Makefile
@@ -11,3 +11,4 @@ nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs3xdr.o
 nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
 nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o \
 			   nfs4acl.o nfs4callback.o nfs4recover.o
+nfsd-$(CONFIG_NFSD_V4_PACL) += nfs4pacl.o
diff --git a/fs/nfsd/nfs4pacl.c b/fs/nfsd/nfs4pacl.c
new file mode 100644
index 0000000..42d706a
--- /dev/null
+++ b/fs/nfsd/nfs4pacl.c
@@ -0,0 +1,322 @@
+/*
+ *
+ * Process version NFS4 POSIX ACL requests.
+ *
+ */
+
+#include <linux/sunrpc/svc.h>
+#include <linux/nfs4.h>
+#include <linux/nfsd/nfsd.h>
+#include <linux/nfsd/cache.h>
+#include <linux/posix_acl.h>
+#include <linux/nfsacl.h>
+
+
+#define nfs4svc_decode_voidargs		NULL
+#define nfs4svc_release_void		NULL
+struct nfsd4_voidargs {
+	int dummy;
+};
+#define nfsd4_voidres			nfsd4_voidargs
+
+struct nfsd4_getpaclargs {
+	struct svc_fh           fh;
+	int                     mask;
+};
+struct posix_acl;
+struct nfsd4_setpaclargs {
+	struct svc_fh           fh;
+	int                     mask;
+	struct posix_acl        *acl_access;
+	struct posix_acl        *acl_default;
+};
+struct nfsd4_getpaclres {
+	__be32                  status;
+	struct svc_fh           fh;
+	int                     mask;
+	struct posix_acl        *acl_access;
+	struct posix_acl        *acl_default;
+};
+struct nfsd4_setpaclres {
+	__be32 status;
+	struct svc_fh           fh;
+};
+union nfs4paclstore {
+	struct nfsd4_getpaclargs  gaclargs;
+	struct nfsd4_setpaclargs  saclargs;
+	struct nfsd4_getpaclres   gaclres;
+	struct nfsd4_setpaclres   saclres;
+};
+
+#define NFS4_SVC_ACLXDRSZ    sizeof(union nfs4paclstore)
+
+/*
+ * NULL call.
+ */
+static __be32
+nfsd4_proc_null(struct svc_rqst *rqstp, void *argp, void *resp)
+{
+	return nfs_ok;
+}
+
+/*
+ * Get the Access and/or Default ACL of a file.
+ */
+static __be32 nfsd4_proc_getpacl(struct svc_rqst *rqstp,
+		struct nfsd4_getpaclargs *argp, struct nfsd4_getpaclres *resp)
+{
+	svc_fh *fh;
+	struct posix_acl *acl;
+	__be32 nfserr = 0;
+
+	fh = fh_copy(&resp->fh, &argp->fh);
+	nfserr = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_NOP);
+	if (nfserr)
+		goto err_out;
+	if (argp->mask & ~(NFS_ACL|NFS_ACLCNT|NFS_DFACL|NFS_DFACLCNT)) {
+		nfserr = nfserr_inval;
+		goto err_out;
+	}
+	resp->mask = argp->mask;
+
+	if (resp->mask & (NFS_ACL|NFS_ACLCNT)) {
+		acl = nfsd_get_posix_acl(fh, ACL_TYPE_ACCESS);
+		if (IS_ERR(acl)) {
+			int err = PTR_ERR(acl);
+
+			if (err == -ENODATA || err == -EOPNOTSUPP)
+				acl = NULL;
+			else {
+				nfserr = nfserrno(err);
+				goto fail;
+			}
+		}
+		if (acl == NULL) {
+			/* Solaris returns the inode's minimum ACL. */
+
+			struct inode *inode = fh->fh_dentry->d_inode;
+			acl = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
+		}
+		resp->acl_access = acl;
+	}
+	if (resp->mask & (NFS_DFACL|NFS_DFACLCNT)) {
+		/* Check how Solaris handles requests for the Default ACL
+		   of a non-directory! */
+
+		acl = nfsd_get_posix_acl(fh, ACL_TYPE_DEFAULT);
+		if (IS_ERR(acl)) {
+			int err = PTR_ERR(acl);
+
+			if (err == -ENODATA || err == -EOPNOTSUPP)
+				acl = NULL;
+			else {
+				nfserr = nfserrno(err);
+				goto fail;
+			}
+		}
+		resp->acl_default = acl;
+	}
+
+	/*
+	 * resp->acl_{access,default} are released in
+	 * nfs4svc_release_getpacl.
+	 */
+	resp->status  = 0;
+	return 0;
+
+fail:
+	posix_acl_release(resp->acl_access);
+	posix_acl_release(resp->acl_default);
+err_out:
+	resp->status = nfserr;
+	return nfserr;
+}
+
+/*
+ * Set the Access and/or Default ACL of a file.
+ */
+static __be32 nfsd4_proc_setpacl(struct svc_rqst *rqstp,
+		struct nfsd4_setpaclargs *argp,
+		struct nfsd4_setpaclres *resp)
+{
+	svc_fh *fh;
+	__be32 nfserr = 0;
+
+	fh = fh_copy(&resp->fh, &argp->fh);
+	nfserr = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_SATTR);
+
+	if (!nfserr) {
+		nfserr = nfserrno( nfsd_set_posix_acl(
+			fh, ACL_TYPE_ACCESS, argp->acl_access));
+	}
+	if (!nfserr) {
+		nfserr = nfserrno( nfsd_set_posix_acl(
+			fh, ACL_TYPE_DEFAULT, argp->acl_default));
+	}
+
+	/* argp->acl_{access,default} may have been allocated in
+	   nfs4svc_decode_setpaclargs. */
+	posix_acl_release(argp->acl_access);
+	posix_acl_release(argp->acl_default);
+	resp->status = nfserr;
+	return nfserr;
+}
+
+/*
+ * XDR decode functions
+ */
+__be32 *nfs4svc_decode_fh(__be32 *p, struct svc_fh *fhp)
+{
+	unsigned int size;
+	fh_init(fhp, NFS4_FHSIZE);
+	size = ntohl(*p++);
+	if (size > NFS4_FHSIZE)
+		return NULL;
+
+	memcpy(&fhp->fh_handle.fh_base, p, size);
+	fhp->fh_handle.fh_size = size;
+	return p + XDR_QUADLEN(size);
+}
+static int nfs4svc_decode_getpaclargs(struct svc_rqst *rqstp, __be32 *p,
+		struct nfsd4_getpaclargs *args)
+{
+	p = nfs4svc_decode_fh(p, &args->fh);
+	if (!p)
+		return 0;
+	args->mask = ntohl(*p); p++;
+
+	return xdr_argsize_check(rqstp, p);
+}
+
+
+static int nfs4svc_decode_setpaclargs(struct svc_rqst *rqstp, __be32 *p,
+		struct nfsd4_setpaclargs *args)
+{
+	struct kvec *head = rqstp->rq_arg.head;
+	unsigned int base;
+	int n;
+
+	p = nfs4svc_decode_fh(p, &args->fh);
+	if (!p)
+		return 0;
+	args->mask = ntohl(*p++);
+	if (args->mask & ~(NFS_ACL|NFS_ACLCNT|NFS_DFACL|NFS_DFACLCNT) ||
+	    !xdr_argsize_check(rqstp, p))
+		return 0;
+
+	base = (char *)p - (char *)head->iov_base;
+	n = nfsacl_decode(&rqstp->rq_arg, base, NULL,
+			  (args->mask & NFS_ACL) ?
+			  &args->acl_access : NULL);
+	if (n > 0)
+		n = nfsacl_decode(&rqstp->rq_arg, base + n, NULL,
+				  (args->mask & NFS_DFACL) ?
+				  &args->acl_default : NULL);
+	return (n > 0);
+}
+
+/*
+ * XDR encode functions
+ */
+extern int nfs4svc_encode_voidres(struct svc_rqst *rqstp,
+				__be32 *p, void *dummy);
+
+/* GETPACL */
+static int nfs4svc_encode_getpaclres(struct svc_rqst *rqstp, __be32 *p,
+		struct nfsd4_getpaclres *resp)
+{
+	struct dentry *dentry = resp->fh.fh_dentry;
+
+	if (resp->status == 0 && dentry && dentry->d_inode) {
+		struct inode *inode = dentry->d_inode;
+		struct kvec *head = rqstp->rq_res.head;
+		unsigned int base;
+		int n;
+		int w;
+
+		*p++ = htonl(resp->mask);
+		if (!xdr_ressize_check(rqstp, p))
+			return 0;
+		base = (char *)p - (char *)head->iov_base;
+
+		rqstp->rq_res.page_len = w = nfsacl_size(
+			(resp->mask & NFS_ACL)   ? resp->acl_access  : NULL,
+			(resp->mask & NFS_DFACL) ? resp->acl_default : NULL);
+		while (w > 0) {
+			if (!rqstp->rq_respages[rqstp->rq_resused++])
+				return 0;
+			w -= PAGE_SIZE;
+		}
+
+		n = nfsacl_encode(&rqstp->rq_res, base, inode,
+				  resp->acl_access,
+				  resp->mask & NFS_ACL, 0);
+		if (n > 0)
+			n = nfsacl_encode(&rqstp->rq_res, base + n, inode,
+					  resp->acl_default,
+					  resp->mask & NFS_DFACL,
+					  NFS_ACL_DEFAULT);
+		if (n <= 0)
+			return 0;
+	} else
+		if (!xdr_ressize_check(rqstp, p))
+			return 0;
+
+	return 1;
+}
+
+/* SETPACL */
+static int nfs4svc_encode_setpaclres(struct svc_rqst *rqstp, __be32 *p,
+		struct nfsd4_setpaclres *resp)
+{
+	return xdr_ressize_check(rqstp, p);
+}
+
+/*
+ * XDR release functions
+ */
+static int nfs4svc_release_getpacl(struct svc_rqst *rqstp, __be32 *p,
+		struct nfsd4_getpaclres *resp)
+{
+	fh_put(&resp->fh);
+	posix_acl_release(resp->acl_access);
+	posix_acl_release(resp->acl_default);
+	return 1;
+}
+
+static int nfs4svc_release_setpacl(struct svc_rqst *rqstp, __be32 *p,
+			struct nfsd4_setpaclres *resp)
+{
+	fh_put(&resp->fh);
+	return 1;
+}
+
+#define PROC(name, argt, rest, relt, cache, respsize)	\
+ { (svc_procfunc) nfsd4_proc_##name,		\
+   (kxdrproc_t) nfs4svc_decode_##argt##args,	\
+   (kxdrproc_t) nfs4svc_encode_##rest##res,	\
+   (kxdrproc_t) nfs4svc_release_##relt,		\
+   sizeof(struct nfsd4_##argt##args),		\
+   sizeof(struct nfsd4_##rest##res),		\
+   0,						\
+   cache,					\
+   respsize,					\
+ }
+
+#define ST 1		/* status*/
+#define ACL (1+NFS_ACL_MAX_ENTRIES*3)  /* Access Control List */
+
+static struct svc_procedure		nfsd_pacl_procedures4[] = {
+  PROC(null,	void,		void,		void,	  RC_NOCACHE, ST),
+  PROC(getpacl,	getpacl,	getpacl,	getpacl,	  RC_NOCACHE, ST+1+2*(1+ACL)),
+  PROC(setpacl,	setpacl,	setpacl,	setpacl,   RC_NOCACHE, ST),
+};
+
+struct svc_version nfsd_pacl_version4 = {
+		.vs_vers	= 4,
+		.vs_nproc	= 3,
+		.vs_proc	= nfsd_pacl_procedures4,
+		.vs_dispatch	= nfsd_dispatch,
+		.vs_xdrsize	= NFS4_SVC_ACLXDRSZ,
+		.vs_hidden	= 1,
+};
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 492c79b..e970a60 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -66,11 +66,12 @@ struct timeval			nfssvc_boot;
 DEFINE_MUTEX(nfsd_mutex);
 struct svc_serv 		*nfsd_serv;
 
-#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
+#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL) || defined(CONFIG_NFSD_V4_PACL)
 static struct svc_stat	nfsd_acl_svcstats;
 static struct svc_version *	nfsd_acl_version[] = {
 	[2] = &nfsd_acl_version2,
 	[3] = &nfsd_acl_version3,
+	[4] = &nfsd_pacl_version4,
 };
 
 #define NFSD_ACL_MINVERS            2
@@ -107,7 +108,7 @@ static struct svc_version *	nfsd_version[] = {
 static struct svc_version *nfsd_versions[NFSD_NRVERS];
 
 struct svc_program		nfsd_program = {
-#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
+#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL) || defined(CONFIG_NFSD_V4_PACL)
 	.pg_next		= &nfsd_acl_program,
 #endif
 	.pg_prog		= NFS_PROGRAM,		/* program number */
@@ -129,14 +130,14 @@ int nfsd_vers(int vers, enum vers_op change)
 	switch(change) {
 	case NFSD_SET:
 		nfsd_versions[vers] = nfsd_version[vers];
-#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
+#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL) || defined(CONFIG_NFSD_V4_PACL)
 		if (vers < NFSD_ACL_NRVERS)
 			nfsd_acl_versions[vers] = nfsd_acl_version[vers];
 #endif
 		break;
 	case NFSD_CLEAR:
 		nfsd_versions[vers] = NULL;
-#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
+#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL) || defined(CONFIG_NFSD_V4_PACL)
 		if (vers < NFSD_ACL_NRVERS)
 			nfsd_acl_versions[vers] = NULL;
 #endif
@@ -213,7 +214,7 @@ void nfsd_reset_versions(void)
 	if (!found_one) {
 		for (i = NFSD_MINVERS; i < NFSD_NRVERS; i++)
 			nfsd_program.pg_vers[i] = nfsd_version[i];
-#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
+#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL) || defined(CONFIG_NFSD_V4_PACL)
 		for (i = NFSD_ACL_MINVERS; i < NFSD_ACL_NRVERS; i++)
 			nfsd_acl_program.pg_vers[i] =
 				nfsd_acl_version[i];
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 2b49d67..d9263b6 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -133,7 +133,7 @@ __be32		nfsd_permission(struct svc_rqst *, struct svc_export *,
 				struct dentry *, int);
 int		nfsd_sync_dir(struct dentry *dp);
 
-#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
+#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL) || defined(CONFIG_NFSD_V4_PACL)
 #ifdef CONFIG_NFSD_V2_ACL
 extern struct svc_version nfsd_acl_version2;
 #else
@@ -144,6 +144,11 @@ extern struct svc_version nfsd_acl_version3;
 #else
 #define nfsd_acl_version3 NULL
 #endif
+#ifdef CONFIG_NFSD_V4_PACL
+extern struct svc_version nfsd_pacl_version4;
+#else
+#define nfsd_pacl_version4 NULL
+#endif
 struct posix_acl *nfsd_get_posix_acl(struct svc_fh *, int);
 int nfsd_set_posix_acl(struct svc_fh *, int, struct posix_acl *);
 #endif
-- 
1.6.4.2.253.g0b1fac

