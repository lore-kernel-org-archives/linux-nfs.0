From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 38/51] nfsd41: support for 3-word long attribute bitmask
Date: Mon, 10 Nov 2008 22:53:44 +0200
Message-ID: <1226350424-11541-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57430 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188AbYKJUx5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:53:57 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also, use client minorversion to generate supported attrs

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c        |   24 +++++++++----
 fs/nfsd/nfs4xdr.c         |   82 ++++++++++++++++++++++++++++++++++++--------
 include/linux/nfsd/nfsd.h |   51 +++++++++++++++++++++++++++-
 include/linux/nfsd/xdr4.h |   29 +++++++++++----
 4 files changed, 154 insertions(+), 32 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6f6d221..5164040 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -459,6 +459,7 @@ static __be32
 nfsd4_getattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	      struct nfsd4_getattr *getattr)
 {
+	u32 minorversion;
 	__be32 status;
 
 	status = fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_NOP);
@@ -468,8 +469,10 @@ nfsd4_getattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (getattr->ga_bmval[1] & NFSD_WRITEONLY_ATTRS_WORD1)
 		return nfserr_inval;
 
-	getattr->ga_bmval[0] &= NFSD_SUPPORTED_ATTRS_WORD0;
-	getattr->ga_bmval[1] &= NFSD_SUPPORTED_ATTRS_WORD1;
+	minorversion = nfsd4_compound_minorversion(cstate);
+	getattr->ga_bmval[0] &= nfsd_suppattrs0(minorversion);
+	getattr->ga_bmval[1] &= nfsd_suppattrs1(minorversion);
+	getattr->ga_bmval[2] &= nfsd_suppattrs2(minorversion);
 
 	getattr->ga_fhp = &cstate->current_fh;
 	return nfs_ok;
@@ -557,6 +560,7 @@ static __be32
 nfsd4_readdir(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	      struct nfsd4_readdir *readdir)
 {
+	u32 minorversion;
 	u64 cookie = readdir->rd_cookie;
 	static const nfs4_verifier zeroverf;
 
@@ -565,8 +569,10 @@ nfsd4_readdir(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (readdir->rd_bmval[1] & NFSD_WRITEONLY_ATTRS_WORD1)
 		return nfserr_inval;
 
-	readdir->rd_bmval[0] &= NFSD_SUPPORTED_ATTRS_WORD0;
-	readdir->rd_bmval[1] &= NFSD_SUPPORTED_ATTRS_WORD1;
+	minorversion = nfsd4_compound_minorversion(cstate);
+	readdir->rd_bmval[0] &= nfsd_suppattrs0(minorversion);
+	readdir->rd_bmval[1] &= nfsd_suppattrs1(minorversion);
+	readdir->rd_bmval[2] &= nfsd_suppattrs2(minorversion);
 
 	if ((cookie > ~(u32)0) || (cookie == 1) || (cookie == 2) ||
 	    (cookie == 0 && memcmp(readdir->rd_verf.data, zeroverf.data, NFS4_VERIFIER_SIZE)))
@@ -754,14 +760,17 @@ _nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	__be32 *buf, *p;
 	int count;
+	u32 minorversion;
 	__be32 status;
 
 	status = fh_verify(rqstp, &cstate->current_fh, 0, NFSD_MAY_NOP);
 	if (status)
 		return status;
 
-	if ((verify->ve_bmval[0] & ~NFSD_SUPPORTED_ATTRS_WORD0)
-	    || (verify->ve_bmval[1] & ~NFSD_SUPPORTED_ATTRS_WORD1))
+	minorversion = nfsd4_compound_minorversion(cstate);
+	if ((verify->ve_bmval[0] & ~nfsd_suppattrs0(minorversion))
+	    || (verify->ve_bmval[1] & ~nfsd_suppattrs1(minorversion))
+	    || (verify->ve_bmval[2] & ~nfsd_suppattrs2(minorversion)))
 		return nfserr_attrnotsupp;
 	if ((verify->ve_bmval[0] & FATTR4_WORD0_RDATTR_ERROR)
 	    || (verify->ve_bmval[1] & NFSD_WRITEONLY_ATTRS_WORD1))
@@ -781,7 +790,7 @@ _nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				    cstate->current_fh.fh_export,
 				    cstate->current_fh.fh_dentry, buf,
 				    &count, verify->ve_bmval,
-				    rqstp, 0);
+				    rqstp, 0, verify->ve_minorversion);
 
 	/* this means that nfsd4_encode_fattr() ran out of space */
 	if (status == nfserr_resource && count == 0)
@@ -903,6 +912,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	resp->tag = args->tag;
 	resp->opcnt = 0;
 	resp->rqstp = rqstp;
+	resp->minorversion = args->minorversion;
 
 	/*
 	 * According to RFC3010, this takes precedence over all other errors.
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e6cad37..89e7b0d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -237,6 +237,7 @@ nfsd4_decode_bitmap(struct nfsd4_compoundargs *argp, u32 *bmval)
 
 	bmval[0] = 0;
 	bmval[1] = 0;
+	bmval[2] = 0;
 
 	READ_BUF(4);
 	READ32(bmlen);
@@ -248,13 +249,19 @@ nfsd4_decode_bitmap(struct nfsd4_compoundargs *argp, u32 *bmval)
 		READ32(bmval[0]);
 	if (bmlen > 1)
 		READ32(bmval[1]);
+#if defined(CONFIG_NFSD_V4_1)
+	if (bmlen > 2) {
+		READ32(bmval[2]);
+	}
+#endif /* CONFIG_NFSD_V4_1 */
 
 	DECODE_TAIL;
 }
 
 static u32 nfsd_attrmask[] = {
 	NFSD_WRITEABLE_ATTRS_WORD0,
-	NFSD_WRITEABLE_ATTRS_WORD1
+	NFSD_WRITEABLE_ATTRS_WORD1,
+	NFSD_WRITEABLE_ATTRS_WORD2
 };
 
 static __be32
@@ -275,9 +282,12 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval, u32 *writable,
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
@@ -412,6 +422,7 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval, u32 *writable,
 			goto xdr_error;
 		}
 	}
+	BUG_ON(bmval[2]);	/* no such writeable attr supported yet */
 	if (len != expected_len)
 		goto xdr_error;
 
@@ -796,6 +807,7 @@ nfsd4_decode_readdir(struct nfsd4_compoundargs *argp, struct nfsd4_readdir *read
 	COPYMEM(readdir->rd_verf.data, sizeof(readdir->rd_verf.data));
 	READ32(readdir->rd_dircount);    /* just in case you needed a useless field... */
 	READ32(readdir->rd_maxcount);
+	readdir->minorversion = argp->minorversion;
 	if ((status = nfsd4_decode_bitmap(argp, readdir->rd_bmval)))
 		goto out;
 
@@ -949,6 +961,7 @@ nfsd4_decode_verify(struct nfsd4_compoundargs *argp, struct nfsd4_verify *verify
 	READ32(verify->ve_attrlen);
 	READ_BUF(verify->ve_attrlen);
 	SAVEMEM(verify->ve_attrval, verify->ve_attrlen);
+	verify->ve_minorversion = argp->minorversion;
 
 	DECODE_TAIL;
 }
@@ -1738,10 +1751,11 @@ static __be32 fattr_handle_absent_fs(u32 *bmval0, u32 *bmval1, u32 *rdattr_err)
 __be32
 nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		struct dentry *dentry, __be32 *buffer, int *countp, u32 *bmval,
-		struct svc_rqst *rqstp, int ignore_crossmnt)
+		struct svc_rqst *rqstp, int ignore_crossmnt, u32 minorversion)
 {
 	u32 bmval0 = bmval[0];
 	u32 bmval1 = bmval[1];
+	u32 bmval2 = bmval[2];
 	struct kstat stat;
 	struct svc_fh tempfh;
 	struct kstatfs statfs;
@@ -1757,10 +1771,25 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 	struct nfs4_acl *acl = NULL;
 
 	BUG_ON(bmval1 & NFSD_WRITEONLY_ATTRS_WORD1);
-	BUG_ON(bmval0 & ~NFSD_SUPPORTED_ATTRS_WORD0);
-	BUG_ON(bmval1 & ~NFSD_SUPPORTED_ATTRS_WORD1);
+	/* FIXME: change warnings back into BUG_ON */;
+	if (bmval0 & ~nfsd_suppattrs0(minorversion)) {
+		printk("%s: minorversion=%u bmval0=0x%08x suppattrs0=0x%08x\n",
+			__func__, minorversion, bmval0, nfsd_suppattrs0(minorversion));
+		WARN_ON(1);
+	}
+	if (bmval1 & ~nfsd_suppattrs1(minorversion)) {
+		printk("%s: minorversion=%u bmval1=0x%08x suppattrs1=0x%08x\n",
+			__func__, minorversion, bmval1, nfsd_suppattrs1(minorversion));
+		WARN_ON(1);
+	}
+	if (bmval2 & ~nfsd_suppattrs2(minorversion)) {
+		printk("%s: minorversion=%u bmval2=0x%08x suppattrs2=0x%08x\n",
+			__func__, minorversion, bmval2, nfsd_suppattrs2(minorversion));
+		WARN_ON(1);
+	}
 
 	if (exp->ex_fslocs.migrated) {
+		BUG_ON(bmval[2]);
 		status = fattr_handle_absent_fs(&bmval0, &bmval1, &rdattr_err);
 		if (status)
 			goto out;
@@ -1806,22 +1835,42 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
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
@@ -2131,6 +2180,8 @@ out_acl:
 		}
 		WRITE64(stat.ino);
 	}
+	BUG_ON(bmval2);	/* FIXME: not implemented yet */
+
 	*attrlenp = htonl((char *)p - (char *)attrlenp - 4);
 	*countp = p - buffer;
 	status = nfs_ok;
@@ -2203,7 +2254,8 @@ nfsd4_encode_dirent_fattr(struct nfsd4_readdir *cd,
 
 	}
 	nfserr = nfsd4_encode_fattr(NULL, exp, dentry, p, buflen, cd->rd_bmval,
-					cd->rd_rqstp, ignore_crossmnt);
+					cd->rd_rqstp, ignore_crossmnt,
+					cd->minorversion);
 out_put:
 	dput(dentry);
 	exp_put(exp);
@@ -2369,7 +2421,7 @@ nfsd4_encode_getattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 	buflen = resp->end - resp->p - (COMPOUND_ERR_SLACK_SPACE >> 2);
 	nfserr = nfsd4_encode_fattr(fhp, fhp->fh_export, fhp->fh_dentry,
 				    resp->p, &buflen, getattr->ga_bmval,
-				    resp->rqstp, 0);
+				    resp->rqstp, 0, resp->minorversion);
 	if (!nfserr)
 		resp->p += buflen;
 	return nfserr;
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index ffb7897..46b8110 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -321,7 +321,7 @@ extern struct timeval	nfssvc_boot;
  *    TIME_BACKUP   (unlikely to be supported any time soon)
  *    TIME_CREATE   (unlikely to be supported any time soon)
  */
-#define NFSD_SUPPORTED_ATTRS_WORD0                                                          \
+#define NFSD4_SUPPORTED_ATTRS_WORD0                                                         \
 (FATTR4_WORD0_SUPPORTED_ATTRS   | FATTR4_WORD0_TYPE         | FATTR4_WORD0_FH_EXPIRE_TYPE   \
  | FATTR4_WORD0_CHANGE          | FATTR4_WORD0_SIZE         | FATTR4_WORD0_LINK_SUPPORT     \
  | FATTR4_WORD0_SYMLINK_SUPPORT | FATTR4_WORD0_NAMED_ATTR   | FATTR4_WORD0_FSID             \
@@ -333,7 +333,7 @@ extern struct timeval	nfssvc_boot;
  | FATTR4_WORD0_MAXFILESIZE     | FATTR4_WORD0_MAXLINK      | FATTR4_WORD0_MAXNAME          \
  | FATTR4_WORD0_MAXREAD         | FATTR4_WORD0_MAXWRITE     | FATTR4_WORD0_ACL)
 
-#define NFSD_SUPPORTED_ATTRS_WORD1                                                          \
+#define NFSD4_SUPPORTED_ATTRS_WORD1                                                         \
 (FATTR4_WORD1_MODE              | FATTR4_WORD1_NO_TRUNC     | FATTR4_WORD1_NUMLINKS         \
  | FATTR4_WORD1_OWNER	        | FATTR4_WORD1_OWNER_GROUP  | FATTR4_WORD1_RAWDEV           \
  | FATTR4_WORD1_SPACE_AVAIL     | FATTR4_WORD1_SPACE_FREE   | FATTR4_WORD1_SPACE_TOTAL      \
@@ -341,6 +341,52 @@ extern struct timeval	nfssvc_boot;
  | FATTR4_WORD1_TIME_DELTA   | FATTR4_WORD1_TIME_METADATA    \
  | FATTR4_WORD1_TIME_MODIFY     | FATTR4_WORD1_TIME_MODIFY_SET | FATTR4_WORD1_MOUNTED_ON_FILEID)
 
+#define NFSD4_SUPPORTED_ATTRS_WORD2 0
+
+#if defined(CONFIG_NFSD_V4_1)
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
+#else  /* CONFIG_NFSD_V4_1 */
+static inline u32 nfsd_suppattrs0(u32 minorversion)
+{
+	return NFSD4_SUPPORTED_ATTRS_WORD0;
+}
+
+static inline u32 nfsd_suppattrs1(u32 minorversion)
+{
+	return NFSD4_SUPPORTED_ATTRS_WORD1;
+}
+
+static inline u32 nfsd_suppattrs2(u32 minorversion)
+{
+	return NFSD4_SUPPORTED_ATTRS_WORD2;
+}
+#endif /* CONFIG_NFSD_V4_1 */
+
 /* These will return ERR_INVAL if specified in GETATTR or READDIR. */
 #define NFSD_WRITEONLY_ATTRS_WORD1							    \
 (FATTR4_WORD1_TIME_ACCESS_SET   | FATTR4_WORD1_TIME_MODIFY_SET)
@@ -351,6 +397,7 @@ extern struct timeval	nfssvc_boot;
 #define NFSD_WRITEABLE_ATTRS_WORD1                                                          \
 (FATTR4_WORD1_MODE              | FATTR4_WORD1_OWNER         | FATTR4_WORD1_OWNER_GROUP     \
  | FATTR4_WORD1_TIME_ACCESS_SET | FATTR4_WORD1_TIME_MODIFY_SET)
+#define NFSD_WRITEABLE_ATTRS_WORD2 0
 
 #endif /* CONFIG_NFSD_V4 */
 
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index d78ba3c..7812e8c 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -53,6 +53,15 @@ struct nfsd4_compound_state {
 #endif /* CONFIG_NFSD_V4_1 */
 };
 
+static inline u32 nfsd4_compound_minorversion(struct nfsd4_compound_state *cs)
+{
+#if defined(CONFIG_NFSD_V4_1)
+	return cs->current_ses ? 1 : 0;
+#else  /* CONFIG_NFSD_V4_1 */
+	return 0;
+#endif /* CONFIG_NFSD_V4_1 */
+}
+
 struct nfsd4_change_info {
 	u32		atomic;
 	u32		before_ctime_sec;
@@ -93,7 +102,7 @@ struct nfsd4_create {
 			u32 specdata2;
 		} dev;    /* NF4BLK, NF4CHR */
 	} u;
-	u32		cr_bmval[2];        /* request */
+	u32		cr_bmval[3];        /* request */
 	struct iattr	cr_iattr;           /* request */
 	struct nfsd4_change_info  cr_cinfo; /* response */
 	struct nfs4_acl *cr_acl;
@@ -109,7 +118,7 @@ struct nfsd4_delegreturn {
 };
 
 struct nfsd4_getattr {
-	u32		ga_bmval[2];        /* request */
+	u32		ga_bmval[3];        /* request */
 	struct svc_fh	*ga_fhp;            /* response */
 };
 
@@ -210,7 +219,7 @@ struct nfsd4_open {
 	stateid_t       op_delegate_stateid; /* request - response */
 	u32		op_create;     	    /* request */
 	u32		op_createmode;      /* request */
-	u32		op_bmval[2];        /* request */
+	u32		op_bmval[3];        /* request */
 	union {                             /* request */
 		struct iattr	iattr;                      /* UNCHECKED4,GUARDED4 */
 		nfs4_verifier	verf;                                /* EXCLUSIVE4 */
@@ -265,7 +274,7 @@ struct nfsd4_readdir {
 	nfs4_verifier	rd_verf;            /* request */
 	u32		rd_dircount;        /* request */
 	u32		rd_maxcount;        /* request */
-	u32		rd_bmval[2];        /* request */
+	u32		rd_bmval[3];        /* request */
 	struct svc_rqst *rd_rqstp;          /* response */
 	struct svc_fh * rd_fhp;             /* response */
 
@@ -273,6 +282,7 @@ struct nfsd4_readdir {
 	__be32 *		buffer;
 	int			buflen;
 	__be32 *		offset;
+	u32			minorversion;
 };
 
 struct nfsd4_release_lockowner {
@@ -308,7 +318,7 @@ struct nfsd4_secinfo {
 struct nfsd4_setattr {
 	stateid_t	sa_stateid;         /* request */
 	u32		sa_minorversion;    /* processing */
-	u32		sa_bmval[2];        /* request */
+	u32		sa_bmval[3];        /* request */
 	struct iattr	sa_iattr;           /* request */
 	struct nfs4_acl *sa_acl;
 };
@@ -334,9 +344,10 @@ struct nfsd4_setclientid_confirm {
 
 /* also used for NVERIFY */
 struct nfsd4_verify {
-	u32		ve_bmval[2];        /* request */
+	u32		ve_bmval[3];        /* request */
 	u32		ve_attrlen;         /* request */
 	char *		ve_attrval;         /* request */
+	u32		ve_minorversion;
 };
 
 struct nfsd4_write {
@@ -479,6 +490,7 @@ struct nfsd4_compoundres {
 	char *				tag;
 	u32				opcnt;
 	__be32 *			tagp; /* where to encode tag and  opcount */
+	u32				minorversion;
 };
 
 #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)
@@ -502,8 +514,9 @@ int nfs4svc_encode_compoundres(struct svc_rqst *, __be32 *,
 void nfsd4_encode_operation(struct nfsd4_compoundres *, struct nfsd4_op *);
 void nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op);
 __be32 nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
-		       struct dentry *dentry, __be32 *buffer, int *countp,
-		       u32 *bmval, struct svc_rqst *, int ignore_crossmnt);
+			  struct dentry *dentry, __be32 *buffer, int *countp,
+			  u32 *bmval, struct svc_rqst *, int ignore_crossmnt,
+			  u32 minorversion);
 extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid *setclid);
-- 
1.6.0.2

