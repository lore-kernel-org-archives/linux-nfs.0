From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 32/35] nfsd41: support for 3-word long attribute bitmask
Date: Fri,  3 Apr 2009 08:29:11 +0300
Message-ID: <1238736551-18079-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:22239 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757867AbZDCF3Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:29:16 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Also, use client minorversion to generate supported attrs

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c        |   15 +++++++----
 fs/nfsd/nfs4xdr.c         |   59 +++++++++++++++++++++++++++++++++++---------
 include/linux/nfsd/nfsd.h |   34 ++++++++++++++++++++++++-
 include/linux/nfsd/xdr4.h |   12 ++++----
 4 files changed, 94 insertions(+), 26 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 937853f..e206053 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -463,8 +463,9 @@ nfsd4_getattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (getattr->ga_bmval[1] & NFSD_WRITEONLY_ATTRS_WORD1)
 		return nfserr_inval;
 
-	getattr->ga_bmval[0] &= NFSD_SUPPORTED_ATTRS_WORD0;
-	getattr->ga_bmval[1] &= NFSD_SUPPORTED_ATTRS_WORD1;
+	getattr->ga_bmval[0] &= nfsd_suppattrs0(cstate->minorversion);
+	getattr->ga_bmval[1] &= nfsd_suppattrs1(cstate->minorversion);
+	getattr->ga_bmval[2] &= nfsd_suppattrs2(cstate->minorversion);
 
 	getattr->ga_fhp = &cstate->current_fh;
 	return nfs_ok;
@@ -555,8 +556,9 @@ nfsd4_readdir(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (readdir->rd_bmval[1] & NFSD_WRITEONLY_ATTRS_WORD1)
 		return nfserr_inval;
 
-	readdir->rd_bmval[0] &= NFSD_SUPPORTED_ATTRS_WORD0;
-	readdir->rd_bmval[1] &= NFSD_SUPPORTED_ATTRS_WORD1;
+	readdir->rd_bmval[0] &= nfsd_suppattrs0(cstate->minorversion);
+	readdir->rd_bmval[1] &= nfsd_suppattrs1(cstate->minorversion);
+	readdir->rd_bmval[2] &= nfsd_suppattrs2(cstate->minorversion);
 
 	if ((cookie > ~(u32)0) || (cookie == 1) || (cookie == 2) ||
 	    (cookie == 0 && memcmp(readdir->rd_verf.data, zeroverf.data, NFS4_VERIFIER_SIZE)))
@@ -746,8 +748,9 @@ _nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		return status;
 
-	if ((verify->ve_bmval[0] & ~NFSD_SUPPORTED_ATTRS_WORD0)
-	    || (verify->ve_bmval[1] & ~NFSD_SUPPORTED_ATTRS_WORD1))
+	if ((verify->ve_bmval[0] & ~nfsd_suppattrs0(cstate->minorversion))
+	    || (verify->ve_bmval[1] & ~nfsd_suppattrs1(cstate->minorversion))
+	    || (verify->ve_bmval[2] & ~nfsd_suppattrs2(cstate->minorversion)))
 		return nfserr_attrnotsupp;
 	if ((verify->ve_bmval[0] & FATTR4_WORD0_RDATTR_ERROR)
 	    || (verify->ve_bmval[1] & NFSD_WRITEONLY_ATTRS_WORD1))
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 42f9fb6..70296fe 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -236,6 +236,7 @@ nfsd4_decode_bitmap(struct nfsd4_compoundargs *argp, u32 *bmval)
 
 	bmval[0] = 0;
 	bmval[1] = 0;
+	bmval[2] = 0;
 
 	READ_BUF(4);
 	READ32(bmlen);
@@ -247,13 +248,16 @@ nfsd4_decode_bitmap(struct nfsd4_compoundargs *argp, u32 *bmval)
 		READ32(bmval[0]);
 	if (bmlen > 1)
 		READ32(bmval[1]);
+	if (bmlen > 2)
+		READ32(bmval[2]);
 
 	DECODE_TAIL;
 }
 
 static u32 nfsd_attrmask[] = {
 	NFSD_WRITEABLE_ATTRS_WORD0,
-	NFSD_WRITEABLE_ATTRS_WORD1
+	NFSD_WRITEABLE_ATTRS_WORD1,
+	NFSD_WRITEABLE_ATTRS_WORD2
 };
 
 static __be32
@@ -274,9 +278,12 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval, u32 *writable,
 	 * According to spec, unsupported attributes return ERR_ATTRNOTSUPP;
 	 * read-only attributes return ERR_INVAL.
 	 */
-	if ((bmval[0] & ~NFSD_SUPPORTED_ATTRS_WORD0) || (bmval[1] & ~NFSD_SUPPORTED_ATTRS_WORD1))
+	if ((bmval[0] & ~nfsd_suppattrs0(argp->minorversion)) ||
+	    (bmval[1] & ~nfsd_suppattrs1(argp->minorversion)) ||
+	    (bmval[2] & ~nfsd_suppattrs2(argp->minorversion)))
 		return nfserr_attrnotsupp;
-	if ((bmval[0] & ~writable[0]) || (bmval[1] & ~writable[1]))
+	if ((bmval[0] & ~writable[0]) || (bmval[1] & ~writable[1]) ||
+	    (bmval[2] & ~writable[2]))
 		return nfserr_inval;
 
 	READ_BUF(4);
@@ -411,6 +418,7 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval, u32 *writable,
 			goto xdr_error;
 		}
 	}
+	BUG_ON(bmval[2]);	/* no such writeable attr supported yet */
 	if (len != expected_len)
 		goto xdr_error;
 
@@ -1726,6 +1734,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 {
 	u32 bmval0 = bmval[0];
 	u32 bmval1 = bmval[1];
+	u32 bmval2 = bmval[2];
 	struct kstat stat;
 	struct svc_fh tempfh;
 	struct kstatfs statfs;
@@ -1739,12 +1748,16 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 	int err;
 	int aclsupport = 0;
 	struct nfs4_acl *acl = NULL;
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
+	u32 minorversion = resp->cstate.minorversion;
 
 	BUG_ON(bmval1 & NFSD_WRITEONLY_ATTRS_WORD1);
-	BUG_ON(bmval0 & ~NFSD_SUPPORTED_ATTRS_WORD0);
-	BUG_ON(bmval1 & ~NFSD_SUPPORTED_ATTRS_WORD1);
+	BUG_ON(bmval0 & ~nfsd_suppattrs0(minorversion));
+	BUG_ON(bmval1 & ~nfsd_suppattrs1(minorversion));
+	BUG_ON(bmval2 & ~nfsd_suppattrs2(minorversion));
 
 	if (exp->ex_fslocs.migrated) {
+		BUG_ON(bmval[2]);
 		status = fattr_handle_absent_fs(&bmval0, &bmval1, &rdattr_err);
 		if (status)
 			goto out;
@@ -1790,22 +1803,42 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 	if ((buflen -= 16) < 0)
 		goto out_resource;
 
-	WRITE32(2);
-	WRITE32(bmval0);
-	WRITE32(bmval1);
+	if (unlikely(bmval2)) {
+		WRITE32(3);
+		WRITE32(bmval0);
+		WRITE32(bmval1);
+		WRITE32(bmval2);
+	} else if (likely(bmval1)) {
+		WRITE32(2);
+		WRITE32(bmval0);
+		WRITE32(bmval1);
+	} else {
+		WRITE32(1);
+		WRITE32(bmval0);
+	}
 	attrlenp = p++;                /* to be backfilled later */
 
 	if (bmval0 & FATTR4_WORD0_SUPPORTED_ATTRS) {
-		u32 word0 = NFSD_SUPPORTED_ATTRS_WORD0;
+		u32 word0 = nfsd_suppattrs0(minorversion);
+		u32 word1 = nfsd_suppattrs1(minorversion);
+		u32 word2 = nfsd_suppattrs2(minorversion);
+
 		if ((buflen -= 12) < 0)
 			goto out_resource;
 		if (!aclsupport)
 			word0 &= ~FATTR4_WORD0_ACL;
 		if (!exp->ex_fslocs.locations)
 			word0 &= ~FATTR4_WORD0_FS_LOCATIONS;
-		WRITE32(2);
-		WRITE32(word0);
-		WRITE32(NFSD_SUPPORTED_ATTRS_WORD1);
+		if (!word2) {
+			WRITE32(2);
+			WRITE32(word0);
+			WRITE32(word1);
+		} else {
+			WRITE32(3);
+			WRITE32(word0);
+			WRITE32(word1);
+			WRITE32(word2);
+		}
 	}
 	if (bmval0 & FATTR4_WORD0_TYPE) {
 		if ((buflen -= 4) < 0)
@@ -2115,6 +2148,8 @@ out_acl:
 		}
 		WRITE64(stat.ino);
 	}
+	BUG_ON(bmval2);	/* FIXME: not implemented yet */
+
 	*attrlenp = htonl((char *)p - (char *)attrlenp - 4);
 	*countp = p - buffer;
 	status = nfs_ok;
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 5bed509..69ca788 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -346,7 +346,7 @@ extern struct timeval	nfssvc_boot;
  *    TIME_BACKUP   (unlikely to be supported any time soon)
  *    TIME_CREATE   (unlikely to be supported any time soon)
  */
-#define NFSD_SUPPORTED_ATTRS_WORD0                                                          \
+#define NFSD4_SUPPORTED_ATTRS_WORD0                                                         \
 (FATTR4_WORD0_SUPPORTED_ATTRS   | FATTR4_WORD0_TYPE         | FATTR4_WORD0_FH_EXPIRE_TYPE   \
  | FATTR4_WORD0_CHANGE          | FATTR4_WORD0_SIZE         | FATTR4_WORD0_LINK_SUPPORT     \
  | FATTR4_WORD0_SYMLINK_SUPPORT | FATTR4_WORD0_NAMED_ATTR   | FATTR4_WORD0_FSID             \
@@ -358,7 +358,7 @@ extern struct timeval	nfssvc_boot;
  | FATTR4_WORD0_MAXFILESIZE     | FATTR4_WORD0_MAXLINK      | FATTR4_WORD0_MAXNAME          \
  | FATTR4_WORD0_MAXREAD         | FATTR4_WORD0_MAXWRITE     | FATTR4_WORD0_ACL)
 
-#define NFSD_SUPPORTED_ATTRS_WORD1                                                          \
+#define NFSD4_SUPPORTED_ATTRS_WORD1                                                         \
 (FATTR4_WORD1_MODE              | FATTR4_WORD1_NO_TRUNC     | FATTR4_WORD1_NUMLINKS         \
  | FATTR4_WORD1_OWNER	        | FATTR4_WORD1_OWNER_GROUP  | FATTR4_WORD1_RAWDEV           \
  | FATTR4_WORD1_SPACE_AVAIL     | FATTR4_WORD1_SPACE_FREE   | FATTR4_WORD1_SPACE_TOTAL      \
@@ -366,6 +366,35 @@ extern struct timeval	nfssvc_boot;
  | FATTR4_WORD1_TIME_DELTA   | FATTR4_WORD1_TIME_METADATA    \
  | FATTR4_WORD1_TIME_MODIFY     | FATTR4_WORD1_TIME_MODIFY_SET | FATTR4_WORD1_MOUNTED_ON_FILEID)
 
+#define NFSD4_SUPPORTED_ATTRS_WORD2 0
+
+#define NFSD4_1_SUPPORTED_ATTRS_WORD0 \
+	NFSD4_SUPPORTED_ATTRS_WORD0
+
+#define NFSD4_1_SUPPORTED_ATTRS_WORD1 \
+	NFSD4_SUPPORTED_ATTRS_WORD1
+
+#define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
+	NFSD4_SUPPORTED_ATTRS_WORD2
+
+static inline u32 nfsd_suppattrs0(u32 minorversion)
+{
+	return minorversion ? NFSD4_1_SUPPORTED_ATTRS_WORD0
+			    : NFSD4_SUPPORTED_ATTRS_WORD0;
+}
+
+static inline u32 nfsd_suppattrs1(u32 minorversion)
+{
+	return minorversion ? NFSD4_1_SUPPORTED_ATTRS_WORD1
+			    : NFSD4_SUPPORTED_ATTRS_WORD1;
+}
+
+static inline u32 nfsd_suppattrs2(u32 minorversion)
+{
+	return minorversion ? NFSD4_1_SUPPORTED_ATTRS_WORD2
+			    : NFSD4_SUPPORTED_ATTRS_WORD2;
+}
+
 /* These will return ERR_INVAL if specified in GETATTR or READDIR. */
 #define NFSD_WRITEONLY_ATTRS_WORD1							    \
 (FATTR4_WORD1_TIME_ACCESS_SET   | FATTR4_WORD1_TIME_MODIFY_SET)
@@ -376,6 +405,7 @@ extern struct timeval	nfssvc_boot;
 #define NFSD_WRITEABLE_ATTRS_WORD1                                                          \
 (FATTR4_WORD1_MODE              | FATTR4_WORD1_OWNER         | FATTR4_WORD1_OWNER_GROUP     \
  | FATTR4_WORD1_TIME_ACCESS_SET | FATTR4_WORD1_TIME_MODIFY_SET)
+#define NFSD_WRITEABLE_ATTRS_WORD2 0
 
 #endif /* CONFIG_NFSD_V4 */
 
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 5e16935..c07d8fe 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -102,7 +102,7 @@ struct nfsd4_create {
 			u32 specdata2;
 		} dev;    /* NF4BLK, NF4CHR */
 	} u;
-	u32		cr_bmval[2];        /* request */
+	u32		cr_bmval[3];        /* request */
 	struct iattr	cr_iattr;           /* request */
 	struct nfsd4_change_info  cr_cinfo; /* response */
 	struct nfs4_acl *cr_acl;
@@ -117,7 +117,7 @@ struct nfsd4_delegreturn {
 };
 
 struct nfsd4_getattr {
-	u32		ga_bmval[2];        /* request */
+	u32		ga_bmval[3];        /* request */
 	struct svc_fh	*ga_fhp;            /* response */
 };
 
@@ -218,7 +218,7 @@ struct nfsd4_open {
 	stateid_t       op_delegate_stateid; /* request - response */
 	u32		op_create;     	    /* request */
 	u32		op_createmode;      /* request */
-	u32		op_bmval[2];        /* request */
+	u32		op_bmval[3];        /* request */
 	union {                             /* request */
 		struct iattr	iattr;                      /* UNCHECKED4,GUARDED4 */
 		nfs4_verifier	verf;                                /* EXCLUSIVE4 */
@@ -271,7 +271,7 @@ struct nfsd4_readdir {
 	nfs4_verifier	rd_verf;            /* request */
 	u32		rd_dircount;        /* request */
 	u32		rd_maxcount;        /* request */
-	u32		rd_bmval[2];        /* request */
+	u32		rd_bmval[3];        /* request */
 	struct svc_rqst *rd_rqstp;          /* response */
 	struct svc_fh * rd_fhp;             /* response */
 
@@ -313,7 +313,7 @@ struct nfsd4_secinfo {
 
 struct nfsd4_setattr {
 	stateid_t	sa_stateid;         /* request */
-	u32		sa_bmval[2];        /* request */
+	u32		sa_bmval[3];        /* request */
 	struct iattr	sa_iattr;           /* request */
 	struct nfs4_acl *sa_acl;
 };
@@ -339,7 +339,7 @@ struct nfsd4_setclientid_confirm {
 
 /* also used for NVERIFY */
 struct nfsd4_verify {
-	u32		ve_bmval[2];        /* request */
+	u32		ve_bmval[3];        /* request */
 	u32		ve_attrlen;         /* request */
 	char *		ve_attrval;         /* request */
 };
-- 
1.6.2.1

