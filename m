Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 24EF04C2272
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576164; cv=none; b=hjeGc9S1uL6y+f+KPtNvJysaaTJHMBumzUQ/wy4XYzj1QCcuLa39p7hZTjxeVbu43gLfD61EzYI6WNVCrGosmNq05S1wVD5Zhlf/Z3aQ+xdA1oz3eb90gD52vpUgZrYic4UlirwrXV7Chq8vaK9ARk/6P08FqFsbqNHQxGdvvvc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576164; c=relaxed/simple;
	bh=apMEQ1zC3D3Chwt/dK36v+Ko+02XjaVkyKmf/SRKwr4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=cqWhU5xPR4RE+TGLnexPg+LcZJo1b0p7RWkXvcJa9dMyn4AEkf3QpPh7YHJ55YClcvDWWbU7t0G93MHPHVrZUueQHDTaJLMK0RuSsDF40PbR+Ct318eGwoluDJ7zD1ihls6mITfe3mZA92ncIE6MZ7nc34MpwewQl9JxY7mXcrQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MeDGgcUz; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MeDGgcUz"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 13D1A1F00899;
	Wed, 16 Sep 2026 16:29:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576160;
	bh=P3X7QEwrYV6+HGT0Fj/JRhnuL0B4vKDLx+hcokJOAyM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=MeDGgcUzgwPrInTROHVfnW48cJmi43VuPws5pvveT8PUFt8737C/4g1LXngMfgM7e
	 Jy0WsS+bUljxCTJWsN9VloZcFYLrStJA1PcbBkUS57qaHJq0ARewTmDek4StzAI87o
	 eWv4DUAI3UGzXcGVB+RJ461zfVt+stzgSf/BqfVyQy+iBrfNGuwAIbNwnp3/iNVge5
	 OeECQgLSIHW8RJXbOQ4p7QEwIFd9Wltxi2m7SfwZoFx253rNVqzygAZCt19QAJawWh
	 6VXxVXHLPPJ/ImM/OTb74OvwfU/s3mv8AJix0wicdsK+2srve3IcRx5gC+Oy+1FTz1
	 BgWd6RGO/C/gw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 15/27] NFSD: Refactor nfsd_proc_create()
Date: Wed, 16 Sep 2026 12:28:46 -0400
Message-ID: <20260916162859.2051-18-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260916162859.2051-1-cel@kernel.org>
References: <20260916162859.2051-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

In a spirit consistent with commit df9606abddfb ("NFSD: Refactor
NFSv3 CREATE"), extract NFSv2-specific create behaviors into a
helper function. This clearly delineates the NFSv2-specific
semantics from the generic nfsd_create() utility.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c | 138 ++++++++++++++++++++++++----------------------
 1 file changed, 71 insertions(+), 67 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 4d09da326070..e041598ce68e 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -627,85 +627,77 @@ static __be32 nfsd_proc_write(struct svc_rqst *rqstp)
 }
 
 /*
- * CREATE processing is complicated. The keyword here is `overloaded.'
- * The parent directory is kept locked between the check for existence
- * and the actual create() call in compliance with VFS protocols.
- * N.B. After this call _both_ argp->fh and resp->fh need an fh_put
+ * Implement NFSv2's unchecked CREATE semantics. Based on type bits in the
+ * mode field, NFSv2 CREATE can create regular files, devices, and FIFOs.
+ *
+ * Caller must release @fhp and @resfhp.
  */
 static __be32
-nfsd_proc_create(struct svc_rqst *rqstp)
+nfsd_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
+		 struct svc_fh *resfhp, struct nfsd_createargs *argp)
 {
-	struct nfsd_createargs *argp = rqstp->rq_argp;
-	struct nfsd_diropres *resp = rqstp->rq_resp;
-	svc_fh		*dirfhp = &argp->fh;
-	svc_fh		*newfhp = &resp->fh;
-	struct iattr	*attr = &argp->attrs;
+	struct iattr *attr = &argp->attrs;
+	dev_t rdev = 0, wanted = new_decode_dev(attr->ia_size);
 	struct nfsd_attrs attrs = {
 		.na_iattr	= attr,
 	};
 	struct svc_export *exp;
-	struct inode	*inode;
-	struct dentry	*dchild;
-	int		type, mode;
-	int		hosterr;
-	dev_t		rdev = 0, wanted = new_decode_dev(attr->ia_size);
+	struct dentry *dchild;
+	struct inode *inode;
+	int type, mode;
+	__be32 status;
+	int host_err;
 
-	/* First verify the parent file handle */
-	resp->status = fh_verify(rqstp, dirfhp, S_IFDIR, NFSD_MAY_EXEC);
-	if (resp->status != nfs_ok)
-		goto done; /* must fh_put dirfhp even on error */
-
-	/* Check for NFSD_MAY_WRITE in nfsd_create if necessary */
-
-	resp->status = nfserr_exist;
 	if (name_is_dot_dotdot(argp->name, argp->len))
-		goto done;
-	hosterr = fh_want_write(dirfhp);
-	if (hosterr) {
-		resp->status = nfserrno(hosterr);
-		goto done;
-	}
+		return nfserr_exist;
 
-	dchild = start_creating(&nop_mnt_idmap, dirfhp->fh_dentry,
+	status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
+	if (status != nfs_ok)
+		return status;
+
+	host_err = fh_want_write(fhp);
+	if (host_err)
+		return nfserrno(host_err);
+
+	dchild = start_creating(&nop_mnt_idmap, fhp->fh_dentry,
 				&QSTR_LEN(argp->name, argp->len));
 	if (IS_ERR(dchild)) {
-		resp->status = nfserrno(PTR_ERR(dchild));
-		goto out_write;
+		status = nfserrno(PTR_ERR(dchild));
+		goto out_drop_write;
 	}
 	/*
 	 * If name exists we need to check for mountpoints
 	 */
-	exp = exp_get(dirfhp->fh_export);
+	exp = exp_get(fhp->fh_export);
 	if (d_is_reg(dchild) &&
 	    unlikely(nfsd_mountpoint(dchild, exp))) {
-		resp->status = nfsd_cross_mnt(rqstp, &dchild, &exp);
-		if (resp->status != nfs_ok) {
+		status = nfsd_cross_mnt(rqstp, &dchild, &exp);
+		if (status != nfs_ok) {
 			exp_put(exp);
-			goto out_unlock;
+			goto out;
 		}
 	}
 
-	fh_init(newfhp, NFS_FHSIZE);
-	resp->status = fh_compose(newfhp, exp, dchild, dirfhp);
+	status = fh_compose(resfhp, exp, dchild, fhp);
 	exp_put(exp);
-	if (!resp->status && d_really_is_negative(dchild))
-		resp->status = nfserr_noent;
-	if (resp->status) {
-		if (resp->status != nfserr_noent)
-			goto out_unlock;
+	if (!status && d_really_is_negative(dchild))
+		status = nfserr_noent;
+	if (status) {
+		if (status != nfserr_noent)
+			goto out;
 		/*
 		 * If the new file handle wasn't verified, we can't tell
 		 * whether the file exists or not. Time to bail ...
 		 */
-		resp->status = nfserr_acces;
-		if (!newfhp->fh_dentry) {
+		status = nfserr_acces;
+		if (!resfhp->fh_dentry) {
 			printk(KERN_WARNING
 				"nfsd_proc_create: file handle not verified\n");
-			goto out_unlock;
+			goto out;
 		}
 	}
 
-	inode = d_inode(newfhp->fh_dentry);
+	inode = d_inode(resfhp->fh_dentry);
 
 	/* Unfudge the mode bits */
 	if (attr->ia_valid & ATTR_MODE) {
@@ -716,13 +708,12 @@ nfsd_proc_create(struct svc_rqst *rqstp)
 			 * else assume a file */
 			if (inode) {
 				type = inode->i_mode & S_IFMT;
-				switch(type) {
+				switch (type) {
 				case S_IFCHR:
 				case S_IFBLK:
 					/* reserve rdev for later checking */
 					rdev = inode->i_rdev;
 					attr->ia_valid |= ATTR_SIZE;
-
 					fallthrough;
 				case S_IFIFO:
 					/* this is probably a permission check..
@@ -730,13 +721,13 @@ nfsd_proc_create(struct svc_rqst *rqstp)
 					 *   echo thing > device-special-file-or-pipe
 					 * by doing a CREATE with type==0
 					 */
-					resp->status = nfsd_permission(
+					status = nfsd_permission(
 						&rqstp->rq_cred,
-						newfhp->fh_export,
-						newfhp->fh_dentry,
+						resfhp->fh_export,
+						resfhp->fh_dentry,
 						NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS);
-					if (resp->status && resp->status != nfserr_rofs)
-						goto out_unlock;
+					if (status && status != nfserr_rofs)
+						goto out;
 				}
 			} else
 				type = S_IFREG;
@@ -771,37 +762,50 @@ nfsd_proc_create(struct svc_rqst *rqstp)
 		attr->ia_valid &= ~ATTR_SIZE;
 
 		/* Make sure the type and device matches */
-		resp->status = nfserr_exist;
+		status = nfserr_exist;
 		if (inode && inode_wrong_type(inode, type))
-			goto out_unlock;
+			goto out;
 	}
 
-	resp->status = nfs_ok;
+	status = nfs_ok;
 	if (!inode) {
 		/* File doesn't exist. Create it and set attrs */
-		resp->status = nfsd_create_locked(rqstp, dirfhp, &attrs, type,
-						  rdev, newfhp);
+		status = nfsd_create_locked(rqstp, fhp, &attrs, type,
+					    rdev, resfhp);
 		/* nfsd_create_locked() unlocked the parent */
 		dput(dchild);
-		goto out_write;
+		goto out_drop_write;
 	} else if (type == S_IFREG) {
 		dprintk("nfsd:   existing %s, valid=%x, size=%ld\n",
-			argp->name, attr->ia_valid, (long) attr->ia_size);
+			argp->name, attr->ia_valid, (long)attr->ia_size);
 		/* File already exists. We ignore all attributes except
 		 * size, so that creat() behaves exactly like
 		 * open(..., O_CREAT|O_TRUNC|O_WRONLY).
 		 */
 		attr->ia_valid &= ATTR_SIZE;
 		if (attr->ia_valid)
-			resp->status = nfsd_setattr(rqstp, newfhp, &attrs,
-						    NULL);
+			status = nfsd_setattr(rqstp, resfhp, &attrs, NULL);
 	}
 
-out_unlock:
+out:
 	end_creating(dchild);
-out_write:
-	fh_drop_write(dirfhp);
-done:
+out_drop_write:
+	fh_drop_write(fhp);
+	return status;
+}
+
+/*
+ * N.B. After this call _both_ argp->fh and resp->fh need an fh_put
+ */
+static __be32
+nfsd_proc_create(struct svc_rqst *rqstp)
+{
+	struct nfsd_createargs *argp = rqstp->rq_argp;
+	struct nfsd_diropres *resp = rqstp->rq_resp;
+	svc_fh *dirfhp = &argp->fh;
+	svc_fh *newfhp = fh_init(&resp->fh, NFS_FHSIZE);
+
+	resp->status = nfsd_create_file(rqstp, dirfhp, newfhp, argp);
 	fh_put(dirfhp);
 	if (resp->status != nfs_ok)
 		goto out;
-- 
2.55.0

