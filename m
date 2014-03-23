Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47857 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751503AbaCWBM0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Mar 2014 21:12:26 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 10/50] nfsd4: tweak nfsd4_encode_getattr to take xdr_stream
Date: Sat, 22 Mar 2014 21:11:41 -0400
Message-Id: <1395537141-10389-11-git-send-email-bfields@redhat.com>
In-Reply-To: <1395537141-10389-1-git-send-email-bfields@redhat.com>
References: <1395537141-10389-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Just change the nfsd4_encode_getattr api.  Not changing any code or
adding any new functionality yet.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |  6 +++---
 fs/nfsd/nfs4xdr.c  | 44 ++++++++++++++++++++++++++++++++------------
 fs/nfsd/xdr4.h     |  7 ++++---
 3 files changed, 39 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 27b8268..7248a78 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1072,10 +1072,10 @@ _nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_jukebox;
 
 	p = buf;
-	status = nfsd4_encode_fattr(&cstate->current_fh,
+	status = nfsd4_encode_fattr_to_buf(&p, count, &cstate->current_fh,
 				    cstate->current_fh.fh_export,
-				    cstate->current_fh.fh_dentry, &p,
-				    count, verify->ve_bmval,
+				    cstate->current_fh.fh_dentry,
+				    verify->ve_bmval,
 				    rqstp, 0);
 	/*
 	 * If nfsd4_encode_fattr() ran out of space, assume that's because
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 484a8aa..2ad423d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2046,12 +2046,10 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
 /*
  * Note: @fhp can be NULL; in this case, we might have to compose the filehandle
  * ourselves.
- *
- * countp is the buffer size in _words_
  */
 __be32
-nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
-		struct dentry *dentry, __be32 **buffer, int count, u32 *bmval,
+nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export *exp,
+		struct dentry *dentry, u32 *bmval,
 		struct svc_rqst *rqstp, int ignore_crossmnt)
 {
 	u32 bmval0 = bmval[0];
@@ -2060,12 +2058,12 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 	struct kstat stat;
 	struct svc_fh *tempfh = NULL;
 	struct kstatfs statfs;
-	int buflen = count << 2;
+	__be32 *p = xdr->p;
+	int buflen = xdr->buf->buflen;
 	__be32 *attrlenp;
 	u32 dummy;
 	u64 dummy64;
 	u32 rdattr_err = 0;
-	__be32 *p = *buffer;
 	__be32 status;
 	int err;
 	int aclsupport = 0;
@@ -2492,7 +2490,7 @@ out_acl:
 	}
 
 	*attrlenp = htonl((char *)p - (char *)attrlenp - 4);
-	*buffer = p;
+	xdr->p = p;
 	status = nfs_ok;
 
 out:
@@ -2512,6 +2510,26 @@ out_resource:
 	goto out;
 }
 
+__be32 nfsd4_encode_fattr_to_buf(__be32 **p, int words,
+			struct svc_fh *fhp, struct svc_export *exp,
+			struct dentry *dentry, u32 *bmval,
+	                struct svc_rqst *rqstp, int ignore_crossmnt)
+{
+	struct xdr_buf dummy = {
+			.head[0] = {
+				.iov_base = *p,
+			},
+			.buflen = words << 2,
+		};
+	struct xdr_stream xdr;
+	__be32 ret;
+
+	xdr_init_encode(&xdr, &dummy, NULL);
+	ret = nfsd4_encode_fattr(&xdr, fhp, exp, dentry, bmval, rqstp, ignore_crossmnt);
+	*p = xdr.p;
+	return ret;
+}
+
 static inline int attributes_need_mount(u32 *bmval)
 {
 	if (bmval[0] & ~(FATTR4_WORD0_RDATTR_ERROR | FATTR4_WORD0_LEASE_TIME))
@@ -2575,7 +2593,7 @@ nfsd4_encode_dirent_fattr(struct nfsd4_readdir *cd,
 
 	}
 out_encode:
-	nfserr = nfsd4_encode_fattr(NULL, exp, dentry, p, buflen, cd->rd_bmval,
+	nfserr = nfsd4_encode_fattr_to_buf(p, buflen, NULL, exp, dentry, cd->rd_bmval,
 					cd->rd_rqstp, ignore_crossmnt);
 out_put:
 	dput(dentry);
@@ -2745,14 +2763,16 @@ static __be32
 nfsd4_encode_getattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_getattr *getattr)
 {
 	struct svc_fh *fhp = getattr->ga_fhp;
-	int buflen;
+	struct xdr_stream *xdr = &resp->xdr;
+	struct xdr_buf *buf = resp->xdr.buf;
 
 	if (nfserr)
 		return nfserr;
 
-	buflen = resp->xdr.end - resp->xdr.p - (COMPOUND_ERR_SLACK_SPACE >> 2);
-	nfserr = nfsd4_encode_fattr(fhp, fhp->fh_export, fhp->fh_dentry,
-				    &resp->xdr.p, buflen, getattr->ga_bmval,
+	buf->buflen = (void *)resp->xdr.end - (void *)resp->xdr.p
+			- COMPOUND_ERR_SLACK_SPACE;
+	nfserr = nfsd4_encode_fattr(xdr, fhp, fhp->fh_export, fhp->fh_dentry,
+				    getattr->ga_bmval,
 				    resp->rqstp, 0);
 	return nfserr;
 }
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 6884d70..f62a055 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -562,9 +562,10 @@ int nfs4svc_encode_compoundres(struct svc_rqst *, __be32 *,
 __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *, u32);
 void nfsd4_encode_operation(struct nfsd4_compoundres *, struct nfsd4_op *);
 void nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op);
-__be32 nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
-		       struct dentry *dentry, __be32 **buffer, int countp,
-		       u32 *bmval, struct svc_rqst *, int ignore_crossmnt);
+__be32 nfsd4_encode_fattr_to_buf(__be32 **p, int words,
+		struct svc_fh *fhp, struct svc_export *exp,
+		struct dentry *dentry,
+		u32 *bmval, struct svc_rqst *, int ignore_crossmnt);
 extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid *setclid);
-- 
1.8.5.3

