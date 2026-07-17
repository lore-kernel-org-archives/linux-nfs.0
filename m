Received: from fout-b1-smtp.messagingengine.com (fout-b1-smtp.messagingengine.com [202.12.124.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6CF782868B5
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:33:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262817; cv=none; b=qtxB2I2b9IE4xTC66dPOe524W37K2BD49dxnQtH6shwpwM3L0EYvyUYXiYhVv0SG+8nPddvsdcj9VqksSVhtNBoAW/cSE8U0SIURzQ9EX/eCIvpztElHewH2B2h7PPN0px4wcpT7xF4i7zMpIMqbsXkzO4wFzPy650sdTMVgDug=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262817; c=relaxed/simple;
	bh=jNTIu877zslvePgZAUX9+LFgWN5VLLPIeMCbIc32TKI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=aB8IF9wjxT0FWFPlK5D1/ZcTA+72m8EzmG2Y3XE5gVqz+tw2H1V1XP6a+FWi2YGUW1oXjNFQbuYCqcc5nPOP9KMtA7fm+z+tvJ3yfiDUIyWFgXcD1Y6Z1xl4Eob0iGTcfiMQUUuvFss35einPMjKM7t79PabSGCRuSiFd4iHHXQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=LYKxKnVf; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=eLhdi0O/; arc=none smtp.client-ip=202.12.124.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="LYKxKnVf";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="eLhdi0O/"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfout.stl.internal (Postfix) with ESMTP id 7C9091D0001D;
	Fri, 17 Jul 2026 00:33:29 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Fri, 17 Jul 2026 00:33:29 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262809;
	 x=1784349209; bh=d8WCyzOhjsgie7OuaIqj7FW7j4SdX4IUfLrw2HCkwn8=; b=
	LYKxKnVfeHvmBj9SI+1xME/8IB7g85JLzbEtCKCZ3561jQEiZWwmOo0OOcGnyoD/
	KfFpLgovcCTKX/e3vnUMZwO7SaPw/wqe4S5cUcv8JCHMx/lTELtB+nzQ0jMa17xn
	Jt87gZWOQx/CASyW6Pgp0XjkdKOAsAGF+SyikZmcYli3E58NjPGDYRBZhlYqM4TQ
	ratDs1gssqGobHauzw1lTuDpOF/hfIS+4ukGP5RJfmqyJlvUuKVLjr8KN1GpVArJ
	8IaquwXcb0BR3e3RhD0XJcrJzJmsbEYtWfGH4WhX9vf6jcLncfFIBOLfoolh49RN
	T0w23pr4sa+pxZNFG6wi+Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262809; x=1784349209; bh=d
	8WCyzOhjsgie7OuaIqj7FW7j4SdX4IUfLrw2HCkwn8=; b=eLhdi0O/rnrPcQQGD
	9brKZaM7IFA2lryWufckZG31K1fByDDVshmXz7dTBAN8UOKwcHn0EMfdaqz4a5PZ
	eWLF228glRfhaF1WkfIxmIi7K8Xw2u8XlFMLhrZY6jCJjPg74lgxtFkHiz5gQDfn
	tlyQmZgHJgtg6hefifB//I3xvJ3L07QdL+fcZSWo4jvx06MeSGKL9HEfZlaKe9hz
	bW9olHbO9GaIvVTMDW1V7fI22b5Kt/Xb6fNnsCyjLaKKZ6/lSQgdzu5BDmghaXMP
	yS+3Qj+ggN5P4FEOO7XBhDe0f7Za8YF1c/vareVzU1h0JFZ2YHJklki9KdQ1wiaW
	s4tLw==
X-ME-Sender: <xms:mbBZasJig-JgOWMLNy9JYlDPmBNUQxsCeoMYg2Z1DQQoow76OmKtDQ>
    <xme:mbBZav2Z9Lo1U5tWtPR5C9zDup0wkjbajthXS0UfK45qyAPISkykUDC6EGApJR-vO
    MaXGLvYTnV0Tgrn5b5B_SgGdrXpsFSY00yfcrnInHYEB8fGvWs>
X-ME-Received: <xmr:mbBZamg5fgDLRsx353OA3CrUreBsiO6_6T4fnCkbtjun6FotHR6lLLr9IB9RQyA1uoRPzIeUcGTtZQ7COYNT2bTj3PgT6vI>
X-ME-Proxy-Cause: dmFkZTEYbV/O4rHrcG2pD7g+lcRX3B/+gNPg2GmR980GEuAuHei5en8xSXbHzI3CGul9WZ
    2wyTVMqKjH3Gwr8l0bxq3+gJYxAuCaKsWNQqLRXWJMJ4PsRsuumSSsv/v6MJO7XYC6xpIa
    vcnnDVTuUuMQk5cAowe2NwKaJfSCnmBAw0ipwGptG+ww7YtnuPy4gDHn7ZdBpl0ZsZpkwP
    MnyIuVgfV+AX6SJU5C/DP56d1Wt/NDzA2IXtopXrm9Sb4Kn913mOAzz3mkvTJArWN7bgvP
    G7RfvyjNaPhNpWwcaCH1o0rbK0rNbwsgX9TYV1xS3Iq3WSAnK9mVoidV/lV9qVPcqwMrAe
    nN+LvPsYkuIuE3AK0IWl5lLdaV0JBHUSfDDm2pjey2o6vaQe4hTBax0nqQ2qYM0fgZQgDK
    uksyIQDMlqvW/3woO+kGU8kMUFUPPUZ9RgvAZlT902Df/ViYt+7nlaehhJTtk9ErNT3feX
    Mj0ujIdfCLGAZitG3zLYXJI+QT7FCQ1pjIgVVCxjfuQLYzDXOqBkuMbVy31SX6+a3M61Te
    AmHHX1GcslFWOmOymewRj+C0+ZFUWEI8e/jfGoyEUoaAaWEYmQcn3pv7SfNUFpX+PhWnIv
    pVCHoDjTub6waSWnsQOmYAgb/sdK2YJCL8Z5oBgaWllHuYghB0S76pgbpGQg
X-ME-Proxy: <xmx:mbBZagVRH5351CLt8JdYu-q-YwYSDc5nZp2abkQQ3PICZOs_Y0nuSg>
    <xmx:mbBZalXMMXZT-zmS7RMJncsH2fN7V4g88JlxkZvFMBFkh2CXAB7_kA>
    <xmx:mbBZagh9VLR-J4V5YrK9oV_SW1brYSL2w5AMfWgSdp-G23FMGYZhCg>
    <xmx:mbBZagbjtvGXKl7926OfDCK76OUvhWQJQMJdeXNJyKUoS4LUbUlDWQ>
    <xmx:mbBZalp69wJ0tq9l0xXie2OsRkFqjbGTwvaXV0lSlAfiO2UaGaF2_PR4>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:33:27 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 08/18] nfsd: in nfsd4_create_file() let VFS report if file was created.
Date: Fri, 17 Jul 2026 14:31:06 +1000
Message-ID: <20260717043242.1865905-9-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260717043242.1865905-1-neilb@ownmail.net>
References: <20260717043242.1865905-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

nfsd4_create_file() currently assumes that if a lookup failed but then a
create succeeds, then the "create" operation actually created the file.
With atomic_open this may not be the case - some other actor might have
created the file between the lookup and the create.

So we move the call to nfsd4_vfs_create() earlier and set ->op_created
based on the FMODE_CREATED flag that it set.  Then use "!  ->op_created"
to trigger nfserr_exist handling.

The switch statement is split up into two if() statements.
First we check for the possibility of a successful exclusive
create and set ->op_create to true if appropriate.
Then we check for NFS4_CREATE_UNCHECKED to decide if a
pre-existing file means an error or success.

This allows us to combine the two fh_compose() calls to one place.

A subtle difference here is that we now must only pass O_EXCL to
dentry_create() for NFS4_CREATE_GUARDED.  For the EXCLUSIVE create modes
we want a successful open even if the file already exists.  We then
check the verifier after the open succeeded to see if it was exclusive.

The above requires changing dentry_create() to reliably set
FMODE_CREATED when the file was actually created.  Previously it only
sets this flag when atomic_open is used.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/namei.c         |  2 ++
 fs/nfsd/nfs4proc.c | 69 ++++++++++++++++++++--------------------------
 2 files changed, 32 insertions(+), 39 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 19ce43c9a6e6..9af1d5bc89fc 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -5077,6 +5077,8 @@ struct file *dentry_create(struct path *path, int flags, umode_t mode,
 		error = vfs_create(mnt_idmap(path->mnt), path->dentry, mode, NULL);
 		if (!error)
 			error = vfs_open(path, file);
+		if (!error)
+			file->f_mode |= FMODE_CREATED;
 	}
 	if (unlikely(error))
 		return ERR_PTR(error);
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a311810abfde..8840f6dd8a0a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -211,7 +211,11 @@ nfsd4_vfs_create(struct svc_fh *fhp, struct dentry **child,
 	int oflags;
 
 	oflags = O_CREAT | O_LARGEFILE;
-	if (nfsd4_create_is_exclusive(open->op_createmode))
+	/*
+	 * For the EXCLUSIVE modes we do our own uniqueness tests
+	 * so don't want O_EXCL.
+	 */
+	if (open->op_createmode == NFS4_CREATE_GUARDED)
 		oflags |= O_EXCL;
 
 	switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
@@ -360,22 +364,30 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
 		if (status != nfs_ok)
 			goto out;
-	}
 
-	if (d_really_is_positive(child)) {
-		/* NFSv4 protocol requires change attributes even though
-		 * no change happened.
-		 */
-		fh_fill_post_noop(fhp);
-
-		status = fh_compose(resfhp, fhp->fh_export, child, fhp);
+		status = nfsd4_vfs_create(fhp, &child, open);
 		if (status != nfs_ok)
 			goto out;
+		open->op_created = open->op_filp->f_mode & FMODE_CREATED;
+	}
 
-		switch (open->op_createmode) {
-		case NFS4_CREATE_UNCHECKED:
-			if (!d_is_reg(child))
-				break;
+	status = fh_compose(resfhp, fhp->fh_export, child, fhp);
+	if (status != nfs_ok)
+		goto out;
+
+	if (!open->op_created &&
+	    nfsd4_create_is_exclusive(open->op_createmode) &&
+	    inode_get_mtime_sec(d_inode(child)) == v_mtime &&
+	    inode_get_atime_sec(d_inode(child)) == v_atime &&
+	    d_inode(child)->i_size == 0)
+		open->op_created = true;
+
+	if (!open->op_created) {
+		if (open->op_createmode == NFS4_CREATE_UNCHECKED) {
+			/* NFSv4 protocol requires change attributes
+			 * even though no change happened.
+			 */
+			fh_fill_post_noop(fhp);
 
 			/*
 			 * In NFSv4, we don't want to truncate the file
@@ -383,41 +395,20 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			 * some other reason. Furthermore, if the size is
 			 * nonzero, we should ignore it according to spec!
 			 */
-			open->op_truncate = (iap->ia_valid & ATTR_SIZE) &&
-						!iap->ia_size;
-			break;
-		case NFS4_CREATE_GUARDED:
-			status = nfserr_exist;
-			break;
-		case NFS4_CREATE_EXCLUSIVE:
-		case NFS4_CREATE_EXCLUSIVE4_1:
-			if (inode_get_mtime_sec(d_inode(child)) == v_mtime &&
-			    inode_get_atime_sec(d_inode(child)) == v_atime &&
-			    d_inode(child)->i_size == 0) {
-				open->op_created = true;
-				goto set_attr;
-			}
+			open->op_truncate = (d_is_reg(child) &&
+					     (iap->ia_valid & ATTR_SIZE) &&
+					     !iap->ia_size);
+		} else
 			status = nfserr_exist;
-			break;
-		}
 		goto out;
 	}
-
-	status = nfsd4_vfs_create(fhp, &child, open);
-	if (status != nfs_ok)
-		goto out;
-	open->op_created = true;
+	/* file was created */
 	fh_fill_post_attrs(fhp);
 
-	status = fh_compose(resfhp, fhp->fh_export, child, fhp);
-	if (status != nfs_ok)
-		goto out;
-
 	/* A newly created file already has a file size of zero. */
 	if ((iap->ia_valid & ATTR_SIZE) && (iap->ia_size == 0))
 		iap->ia_valid &= ~ATTR_SIZE;
 
-set_attr:
 	status = nfsd_create_setattr(rqstp, fhp, resfhp, &attrs);
 
 	if (attrs.na_labelerr)
-- 
2.50.0.107.gf914562f5916.dirty

