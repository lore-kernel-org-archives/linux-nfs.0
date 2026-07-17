Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 832493C108E
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:31:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.145
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280693; cv=none; b=gY75OJ1kox1xHteew2Ga2rRnF97Wd8tKK5p7rKvaw3LLqkFw6FZCUOCE/micGInj2JBCYT4dBmYLaf6f0a/LJCcYCn1YjKvMNLbqg9Fg9ee5sc5LALIWaXB4LNzeFyG7jvWgfs9KfrBvKeDFpIgevgoVEDO3qGvY1U/cfF2qTh0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280693; c=relaxed/simple;
	bh=dr6xRQWBk5PcsL+aVVeZjUIBnUY0AHQak5iemVtdAWY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=s46XepHgjDOmvQ0P/pod9HlDpk4QhoTjBKp6dGGS4SP3NXMOIjIIpYDXrG5m9euF0BZCNG6mM+biNWLnFpEIYSWrCGtF0f7prqRntiKzoLlZmc1HcVqgktFlNYzKyqOKljEofQjAp4duOWwBAyUoAEnR91sstW4PUk06/5/jESI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=cDw/9y9u; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=kGXvUymW; arc=none smtp.client-ip=103.168.172.145
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="cDw/9y9u";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="kGXvUymW"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfout.phl.internal (Postfix) with ESMTP id 75C43EC0099;
	Fri, 17 Jul 2026 05:31:30 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Fri, 17 Jul 2026 05:31:30 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280690;
	 x=1784367090; bh=8qoR4j0j+3XCaRMwmBNF8VBHAitZVmjZe2WI9WPHr8U=; b=
	cDw/9y9uf4XHdABCsmUNOJtprvEx30dJ09DelcSTXtYxG3xqjOtM+ITw1mYHKKpF
	fh2RbZ3253IsUGFZBBtI7GGfQtTEAd0t2VfFt8p/sEXhY0oes6FAeerqPIHwqxKB
	echVfwc8TrEI/U7a5PUFTKKWLy140tKOqW3+TsLukeaMtuZ/MgCvBo8uyEgXFayS
	eq1RjGqFwpQp1R3Ht0aBkIT8WLuFHEFeDS/Oio0AgcXXKyP5pI5uA9j0TWm4hV37
	o5ecbDBr+/rv/o08zsWkfkx0ILJtMneCSaI+bko7YaUSp7gYu2V+RiBvPTxyx9MV
	kj2dTQG47PqOOdoi8qyYuQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280690; x=1784367090; bh=8
	qoR4j0j+3XCaRMwmBNF8VBHAitZVmjZe2WI9WPHr8U=; b=kGXvUymWmdN477zZz
	UplykBTYs+FOqm0mp3TaJpLdBwQhRwS7eXCI/zeOKkQm6OpmxXBPzWlKQKvkBzZO
	dxiplZ024fAiC5iBNG+BrSEMjJ7uqEx6eM1YtZAQ19mC+qCdgflFoue1WfEWJBzn
	PjfPAP86d4Wm0IrDWls7vcAU9ky6oqH3JgYN5JPGDqoUy1mc2gxbWu1UJSRJzHSL
	NgBITFwOpfHnmZ9yU/XoQ5GsmlmD3cKWi8Ps/qD9R5A1OreKARxsVXDpBbK4clim
	sptTHWd4QCJIBfsMNbmovvLWaOI9eKhPcU3g9nH6ivVHlJAKBFUvredDtLzetUx/
	Z9Mdw==
X-ME-Sender: <xms:cvZZauYVDaZlNhgdLMIsyWcM43w7gOGpBgdDG44EFBsr_djJWgirsA>
    <xme:cvZZalE4uBD0XKbtfKRY-eUyfUgP2syj-HUruuJgjbORbpVRVrloMJYYh0QTGXkvH
    BOq3ydB455Vj68XkA5BXHefTvtJ-1AKz3WrFAduoBifM3OCuA>
X-ME-Received: <xmr:cvZZaiwbeBLd6E2CwQSirMO0cCKiU_603VK-Hz0dG8ftf8Fyks3lpW8do4ugA5DoklqEKmXSgqgRnbo1b9hpa-VMdRGQg1Y>
X-ME-Proxy-Cause: dmFkZTEnb706x3QJ2/Jb/NUTXU9moduQvByEJSYzwfN1T+uVnhvOYzZmIjwMB30shUQCVj
    LvX41BSnFAwBSWEOy1VFeh0IwIsE1k5uujn1kxe9uz2+KFtqLXaNb8yNpcqyr4JQfuwjcV
    qf1P5KLsm9JeMBVgtpYpYi0Nq/gZqUXz/nixaiIwj7e3FEXE4DQM6TRKzzEZXEvPfHl87X
    nEsRynpsa6Mmiu162mNm5Ug0kD9sMh0qZlGZgEkOCofbKC0YRQ8BLlvPAwDgY92JegsDnq
    6pV8HVfFbSjzU4ssGparbIPRx9KWPzNRB/PRv2JFysx+d357wTu43dTjgbEgW7cIy7kFaV
    ZcOTC/jKLlLbHZ8jIaQ36wgfXWqoGaMoushfJvWqc3AM+bKsV8Ac/KP1c30nNyJEpYDkEq
    QFJf297lVLJoHkHDHp82SrO+aTNXnATHzrbFiDL1KtdNX+c498CkhyU1kjMvQru2Qht9PF
    EpW6GeD9zGmFCeijZ7cWhxrXGNDuIPy9uZyJKLejHGfEV+Y7Q6aiFCqU0WSQaq0hvAfRyI
    Mafe1umYF0tMeLbRteK25qAYQ7j9Uy+O/MUtVdk8wcMfPVU5xsP+OmDoSWfgHigxXrdLKF
    bH1E/pcVR8NC2GCifGys0BikDETkD9KuEbMvGs9evYh8EtLdtrqroiRnW6bQ
X-ME-Proxy: <xmx:cvZZanmJCt4-vjmlPqD93iwxNx5hx1JKsqjTBDbz6MEMcWWVLqm7jw>
    <xmx:cvZZarkNARIvZznmPeWbYR1OhDkcMrhuNpaQIfRWidyoZhi3vSiPHw>
    <xmx:cvZZapwsg0B9Vy8UV92jIG-ZN1p18AXdw9cFKSaevAhKAdFzbJv4LA>
    <xmx:cvZZagqdxsf4sHYtg7oe27L701QO8ctLz0PyAqBXuAQJcxvIZVbycg>
    <xmx:cvZZan4Cz34XrLrugrNpKBpL9UtA03qO0pR9KIXuTJE7HeAAoj1DG3GN>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:31:28 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 17/18] nfsd: separate out VFS-specific code from nfsd4_create_file()
Date: Fri, 17 Jul 2026 19:28:05 +1000
Message-ID: <20260717093001.1972119-18-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260717093001.1972119-1-neilb@ownmail.net>
References: <20260717093001.1972119-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

All the code in nfsd4_create_file() that is VFS manipulation, with now
NFS-specific knowledge, has been localised.  Now we split that out into
a separate function: do_lookup_open().

It is planned to provide a vfs_lookup_open() in vfs code which provides
this functionality.  This will share more code with the syscall open
path, and make it easier to modify locking at the VFS level.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 118 ++++++++++++++++++++++++---------------------
 1 file changed, 64 insertions(+), 54 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 760354818189..b7fdc75c4b81 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -196,6 +196,51 @@ static inline bool nfsd4_create_is_exclusive(int createmode)
 		createmode == NFS4_CREATE_EXCLUSIVE4_1;
 }
 
+static struct file *do_lookup_open(struct path *parent,
+				   struct qstr *name,
+				   unsigned int oflags,
+				   umode_t mode)
+{
+	struct file *filp = NULL;
+	struct path path;
+	struct dentry *child;
+	int want_write_err = 0;
+
+	want_write_err = mnt_want_write(parent->mnt);
+
+	child = start_creating(&nop_mnt_idmap, parent->dentry, name);
+	if (IS_ERR(child)) {
+		filp = ERR_CAST(child);
+		goto out;
+	}
+	path.mnt = parent->mnt;
+	path.dentry = child;
+
+	if (d_really_is_positive(child)) {
+		/*
+		 * open the file so that we consistently have a valid
+		 * op_filp and consequently a valid ->f_path.dentry.
+		 */
+		int err = nfsd_check_obj_isreg(child);
+		if (err)
+			filp = ERR_PTR(err);
+		else
+			filp = dentry_open(&path, oflags, current_cred());
+	} else if (!(oflags & O_CREAT)) {
+		filp = ERR_PTR(-ENOENT);
+	} else if (want_write_err) {
+		filp = ERR_PTR(want_write_err);
+	} else {
+		filp = dentry_create(&path, oflags, mode, current_cred());
+		child = path.dentry;
+	}
+	end_creating(child);
+out:
+	if (!want_write_err)
+		mnt_drop_write(parent->mnt);
+	return filp;
+}
+
 /*
  * Implement NFSv4's unchecked, guarded, and exclusive create
  * semantics for regular files. Open state for this new file is
@@ -213,12 +258,12 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		.na_seclabel	= &open->op_label,
 	};
 	int oflags = O_CREAT | O_LARGEFILE;
-	struct dentry *parent, *child = ERR_PTR(-EINVAL);
-	struct path path = {
+	struct dentry *child = ERR_PTR(-EINVAL);
+	struct path parent = {
 		.mnt = fhp->fh_export->ex_path.mnt,
+		.dentry = fhp->fh_dentry,
 	};
 	__u32 v_mtime, v_atime;
-	struct inode *inode;
 	__be32 status, create_status;
 	int want_write_err;
 
@@ -230,8 +275,6 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
 	if (status != nfs_ok)
 		return status;
-	parent = fhp->fh_dentry;
-	inode = d_inode(parent);
 
 	if (open->op_createmode == NFS4_CREATE_UNCHECKED) {
 		/*
@@ -239,7 +282,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		 */
 		child = try_lookup_noperm(&QSTR_LEN(open->op_fname,
 						    open->op_fnamelen),
-					  parent);
+					  parent.dentry);
 		if (child && !IS_ERR(child) && d_is_reg(child) &&
 		    unlikely(nfsd_mountpoint(child, fhp->fh_export))) {
 			struct svc_export *exp = exp_get(fhp->fh_export);
@@ -259,7 +302,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			dput(child);
 	}
 
-	if (!IS_POSIXACL(inode))
+	if (!IS_POSIXACL(d_inode(parent.dentry)))
 		iap->ia_mode &= ~current_umask();
 
 	/*
@@ -324,58 +367,25 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	}
 
 	create_status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
-
-	want_write_err = fh_want_write(fhp);
-	if (want_write_err)
+	if (create_status)
 		/* Might still succeed if no create is needed */
-		create_status = nfserrno(want_write_err);
-
-	child = start_creating(&nop_mnt_idmap, parent,
-			       &QSTR_LEN(open->op_fname, open->op_fnamelen));
-	if (IS_ERR(child)) {
-		status = nfserrno(PTR_ERR(child));
-		if (!want_write_err)
-			fh_drop_write(fhp);
+		oflags &= ~O_CREAT;
+
+	open->op_filp = do_lookup_open(&parent,
+				       &QSTR_LEN(open->op_fname,
+						 open->op_fnamelen),
+				       oflags,
+				       open->op_iattr.ia_mode);
+	if (IS_ERR(open->op_filp)) {
+		status = nfserrno(PTR_ERR(open->op_filp));
+		open->op_filp = NULL;
+		if (status == nfserr_noent && create_status)
+			status = create_status;
 		goto out;
 	}
-	path.dentry = child;
-
-	if (d_really_is_positive(child)) {
-		/*
-		 * open the file so that we consistently have a valid
-		 * op_filp and consequently a valid ->f_path.dentry.
-		 */
-
-		status = nfserrno(nfsd_check_obj_isreg(child));
-		if (!status) {
-			open->op_filp = dentry_open(&path, oflags,
-						    current_cred());
-			if (IS_ERR(open->op_filp)) {
-				status = nfserrno(PTR_ERR(open->op_filp));
-				open->op_filp = NULL;
-			}
-		}
-	} else if (create_status) {
-		status = create_status;
-	} else {
-		open->op_filp = dentry_create(&path, oflags, open->op_iattr.ia_mode,
-					      current_cred());
-		child = path.dentry;
-
-		if (IS_ERR(open->op_filp)) {
-			status = nfserrno(PTR_ERR(open->op_filp));
-			open->op_filp = NULL;
-		} else {
-			open->op_created = open->op_filp->f_mode & FMODE_CREATED;
-		}
-	}
-	end_creating(child);
-	if (!want_write_err)
-		fh_drop_write(fhp);
-	if (status != nfs_ok)
-		goto out;
 
 	child = open->op_filp->f_path.dentry;
+	open->op_created = open->op_filp->f_mode & FMODE_CREATED;
 
 	status = fh_compose(resfhp, fhp->fh_export, child, fhp);
 	if (status != nfs_ok)
-- 
2.50.0.107.gf914562f5916.dirty

