Received: from fout-b1-smtp.messagingengine.com (fout-b1-smtp.messagingengine.com [202.12.124.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7FFDC351C22
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:34:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262857; cv=none; b=DLflM1ulvd6gUN7ZXLAXRAig9TKiy96ZFOAAhMd57ohMSq/BDgmZ95+jeH2o6GMVJNp9905LcKukWgCPjyVOHRumwpZ9lkHsHmpsNxu2NyPxmVm3oSzqWDCtuRJN4lCzXMXtkirkrpSjaxMlaGXvm38/PYlnZQoV7b65qAY1aps=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262857; c=relaxed/simple;
	bh=NPXfqbPkrCgG3i+Iw++Y5kamDir+EzidVD0qZs2UaQ0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=goTbcfV46c/YySI5RM3gaeiSWlymBjjy1ZaXGJAD7ziEIRFn6R2hVu4SwtlnFrB3SI6uAeyI1Gc7Y1ch0Pqg/g+uAPPewzcncLG5MHIihviOfzWcLx79BcoC5i2ecz87WyjTisy3axrC2ohHxC8aQBU06uHBmPQMF8MC/RbuSWs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=gYmgZhU0; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=fCDtWztu; arc=none smtp.client-ip=202.12.124.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="gYmgZhU0";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="fCDtWztu"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.stl.internal (Postfix) with ESMTP id DB7E81D000BE;
	Fri, 17 Jul 2026 00:34:12 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Fri, 17 Jul 2026 00:34:13 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262852;
	 x=1784349252; bh=1sn2rhlYKqCHMXNYQXEmJ/zLU1Dng3CypQdG/lJxouA=; b=
	gYmgZhU0aj6ldWVF8yoA2TpNuDdJtngdtxl1O0CjDuQsKxShvrMC2ndN0xwFAWXM
	FQ35604sseVC09cHfgJ8r/Csmqz4OsUSdNiAGfpMgdh9/Y5ieB8dkxf0BHjV2W+G
	VOPg407aCnZ5z50Nq+Y6auLEMa18PfryDb/AO7ROGag2q7bJagukG5AsBqOEGExt
	UcD9Zv3xdhOYwY1Gk12dXlvhmhf0PocBin21g9zGdfKDsphA/vrmqG2cg2IU3dCh
	JEGxbKx5fkWbk1RmFEmAvnFntyo+zyP0x8pQVI0mffY+xWM3GYkcOEwV+acsxZ4z
	pTeffQlJndKvjliYpgvTyQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262852; x=1784349252; bh=1
	sn2rhlYKqCHMXNYQXEmJ/zLU1Dng3CypQdG/lJxouA=; b=fCDtWztuORxBGnUxP
	hsi4U6tdUYXxHmyZcr3A03RhalKTRp7CP22fRB/7mKoo5Eh3xudu1+v44M5wx1+t
	cZkmnkCpSuyLpTXqiA7cmAglDwKkBxMFZ3iYvGMGxfPRsbrw0hHmiAHWL2IPF4ps
	4BbHkUQRK7IDyBRR2ltC1lhlKTOpFPbjmma90Nhx9Cc9PJYh8D9/H5e+7LyU2hBr
	DCq5qnhGV7C1Y5trBHOH/cOZak6TyEtSn4E4jErlE8NfPhhegy2B6RYnj5HU1wCf
	bJF0Z/aVnOyhTIRasY1QWSujw9zYwzB1mo58sOfv6oKKT0Wpk8MvLJ4mdKO5RsHg
	dnDmA==
X-ME-Sender: <xms:xLBZajJ-Jk_97Qh781HrWgRe74gIcOg2ExRU_qDBKU4LWimYeFtT0g>
    <xme:xLBZaq3oTfJZARREvf0MpqVA8hx2VK-9Rvx0a3b3d9Xi6jMTlc2TIfimXmLglbmLo
    -dKCfEqE0kXt23gMaYJLuC35Rl4bn_sjO6BQfso0SToiX24>
X-ME-Received: <xmr:xLBZaljadvj-bD1waFridb3bNQBnvZs-FMaBdQzMFSIaKtxTjF-E_ohQnKQJH9NiY3Q6CdmgDGF-KrIi3z7ZDxlXzR1_s44>
X-ME-Proxy-Cause: dmFkZTGtzEPgWoFX1HUXLL/KRlJz4LEgfA3b47g20HgSuyMYWaSVrwJolCANVQQKXlJuyL
    hByFbYFVBQeR0zWcFFFOHYGgf2AdUOSwPBMf7vTcl9Cljkp/R9rDqepV8ZhmRoeEOqTH1G
    tHVFDXnth88ioMD9D6Z2Xqe1UhwOO3hyJ0mACnfB9Q5IPaFkBho6v1t7u0a/CrxV7+uytF
    5WVU+i9A/yrWHTpEW0WdFgZ32piLWuxrZ3EAfZ8Ngf0Oinlvy0egAzguYexaNQPYLhuBz6
    vpPb9N+qH2fHehYBdVWmllHcixm5DSHO9n0lXPAJ0ubfEJf4LVr2UC30cpTjrPVOWM1sRu
    KT3tfcWOAzSc+TMWQBU20IzDX/DK/XormAPa7HxWkP7ued1k90kuo02x9Gps5GumW61yzJ
    E5wfy4LICd2SVnP30E+TEG6iFF9n9GvuD7JhGwkUR9qOxP72tr/UeeM3e+D/NQLEwftDDC
    l+gfRxu4pphHB1DnSC/w5Ppv/pZv3gr2bo8Xuxpi/tJoQd9L0CqSgOVgzKDrDbhMtqKFQ4
    6VwjCQ6wGeEkJ7aSeB493T3NoLlH8cGVrb2KJH2SjySiWaBO08kfGgANQmza1DKtMkRRGW
    NXwHqOwB+1C08FKXOyTa3iGbGtudm31bkAtO5hJleIAXm5H1g2Kz0OFaHNOg
X-ME-Proxy: <xmx:xLBZajV30w9JCVAwPBU9WEPt9bVcfhVnWsnNtagr-1NOaHdRN4CTBg>
    <xmx:xLBZasUudfuZevnrUZgOIAcE7q1mooeSpKBmuRgdVKqAWtUrfivJLQ>
    <xmx:xLBZargGttswYwoCnh0Ca-nt4ERpyrt0BHXgi2wBuN5Pv9fcXdQYgA>
    <xmx:xLBZavaiMubTEuA495_wIJO6rW8slD7gnbw1vcGik6klqB4O1iBgVA>
    <xmx:xLBZaspB1U5a_DqjCA4Cu9pDzLTGoLiymwKrHYWxhRIT40tNWeXtXs8Z>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:34:10 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 17/18] nfsd: separate out VFS-specific code from nfsd4_create_file()
Date: Fri, 17 Jul 2026 14:31:15 +1000
Message-ID: <20260717043242.1865905-18-neilb@ownmail.net>
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
index 760354818189..9db63f9062a5 100644
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
+	int want_write_error = 0;
+
+	want_write_error = mnt_want_write(parent->mnt);
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
+	} else if (want_write_error) {
+		filp = ERR_PTR(want_write_error);
+	} else {
+		filp = dentry_create(&path, oflags, mode, current_cred());
+		child = path.dentry;
+	}
+	end_creating(child);
+out:
+	if (!want_write_error)
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
+		if (status == NFSERR_NOENT && create_status)
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

