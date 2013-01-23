Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50890 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752475Ab3AWWzk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jan 2013 17:55:40 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r0NMteIQ019518
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 23 Jan 2013 17:55:40 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/7] nfsd4: simplify nfsd4_encode_fattr interface slightly
Date: Wed, 23 Jan 2013 17:55:33 -0500
Message-Id: <1358981738-5649-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1358981738-5649-1-git-send-email-bfields@redhat.com>
References: <1358981738-5649-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

It seems slightly simpler to make nfsd4_encode_fattr rather than its
callers responsible for advancing the write pointer on success.

(Also: the count == 0 check in the verify case looks superfluous.
Running out of buffer space is really the only reason fattr encoding
should fail with eresource.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |  7 ++++---
 fs/nfsd/nfs4xdr.c  | 21 ++++++++-------------
 fs/nfsd/xdr4.h     |  2 +-
 3 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index f45096e..6b5c20c 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -993,14 +993,15 @@ _nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (!buf)
 		return nfserr_jukebox;
 
+	p = buf;
 	status = nfsd4_encode_fattr(&cstate->current_fh,
 				    cstate->current_fh.fh_export,
-				    cstate->current_fh.fh_dentry, buf,
-				    &count, verify->ve_bmval,
+				    cstate->current_fh.fh_dentry, &p,
+				    count, verify->ve_bmval,
 				    rqstp, 0);
 
 	/* this means that nfsd4_encode_fattr() ran out of space */
-	if (status == nfserr_resource && count == 0)
+	if (status == nfserr_resource)
 		status = nfserr_not_same;
 	if (status)
 		goto out_kfree;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0dc1158..fcb5bed 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2006,12 +2006,11 @@ static int get_parent_attributes(struct svc_export *exp, struct kstat *stat)
  * Note: @fhp can be NULL; in this case, we might have to compose the filehandle
  * ourselves.
  *
- * @countp is the buffer size in _words_; upon successful return this becomes
- * replaced with the number of words written.
+ * countp is the buffer size in _words_
  */
 __be32
 nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
-		struct dentry *dentry, __be32 *buffer, int *countp, u32 *bmval,
+		struct dentry *dentry, __be32 **buffer, int count, u32 *bmval,
 		struct svc_rqst *rqstp, int ignore_crossmnt)
 {
 	u32 bmval0 = bmval[0];
@@ -2020,12 +2019,12 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 	struct kstat stat;
 	struct svc_fh tempfh;
 	struct kstatfs statfs;
-	int buflen = *countp << 2;
+	int buflen = count << 2;
 	__be32 *attrlenp;
 	u32 dummy;
 	u64 dummy64;
 	u32 rdattr_err = 0;
-	__be32 *p = buffer;
+	__be32 *p = *buffer;
 	__be32 status;
 	int err;
 	int aclsupport = 0;
@@ -2431,7 +2430,7 @@ out_acl:
 	}
 
 	*attrlenp = htonl((char *)p - (char *)attrlenp - 4);
-	*countp = p - buffer;
+	*buffer = p;
 	status = nfs_ok;
 
 out:
@@ -2443,7 +2442,6 @@ out_nfserr:
 	status = nfserrno(err);
 	goto out;
 out_resource:
-	*countp = 0;
 	status = nfserr_resource;
 	goto out;
 out_serverfault:
@@ -2462,7 +2460,7 @@ static inline int attributes_need_mount(u32 *bmval)
 
 static __be32
 nfsd4_encode_dirent_fattr(struct nfsd4_readdir *cd,
-		const char *name, int namlen, __be32 *p, int *buflen)
+		const char *name, int namlen, __be32 **p, int buflen)
 {
 	struct svc_export *exp = cd->rd_fhp->fh_export;
 	struct dentry *dentry;
@@ -2568,10 +2566,9 @@ nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
 	p = xdr_encode_hyper(p, NFS_OFFSET_MAX);    /* offset of next entry */
 	p = xdr_encode_array(p, name, namlen);      /* name length & name */
 
-	nfserr = nfsd4_encode_dirent_fattr(cd, name, namlen, p, &buflen);
+	nfserr = nfsd4_encode_dirent_fattr(cd, name, namlen, &p, buflen);
 	switch (nfserr) {
 	case nfs_ok:
-		p += buflen;
 		break;
 	case nfserr_resource:
 		nfserr = nfserr_toosmall;
@@ -2698,10 +2695,8 @@ nfsd4_encode_getattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 
 	buflen = resp->end - resp->p - (COMPOUND_ERR_SLACK_SPACE >> 2);
 	nfserr = nfsd4_encode_fattr(fhp, fhp->fh_export, fhp->fh_dentry,
-				    resp->p, &buflen, getattr->ga_bmval,
+				    &resp->p, buflen, getattr->ga_bmval,
 				    resp->rqstp, 0);
-	if (!nfserr)
-		resp->p += buflen;
 	return nfserr;
 }
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 0889bfb..546f898 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -563,7 +563,7 @@ __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *, u32);
 void nfsd4_encode_operation(struct nfsd4_compoundres *, struct nfsd4_op *);
 void nfsd4_encode_replay(struct nfsd4_compoundres *resp, struct nfsd4_op *op);
 __be32 nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
-		       struct dentry *dentry, __be32 *buffer, int *countp,
+		       struct dentry *dentry, __be32 **buffer, int countp,
 		       u32 *bmval, struct svc_rqst *, int ignore_crossmnt);
 extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
-- 
1.7.11.7

