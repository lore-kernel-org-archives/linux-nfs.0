Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7EA322DCC13;
	Thu, 10 Sep 2026 00:30:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789000216; cv=none; b=We19aLlejn3AYEiYZSqwcCpsFvKfzQts4y3hcr1J3/AeDiX1AXx3+NHMlLAsl9gpvNFsTp4Z15N2YP866eg9E4fzzE/faHLDMSL+TqwWf7UPz5bGKoSllJcQ0tA4e5zBtQDFKXBkVy08WRRGsCTIKR5SwAUnFJS5KA36RbZq4RY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789000216; c=relaxed/simple;
	bh=IbJBUsp9Nw7KlNIE4wEWER+J6Yf82Pbs6ARS989tNHc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=KuLpNW7pE39KZfyyRwDZxUQHisU63GpIz18Au0EVwDEZF63RQTz56+uQd5EKWE6Y+EtXn6q88OkC92KjADzl4MvNREehxtlt349aCXHAUVH2NLS4wnpi6of46HWxpFsLDf9rBKoIZejhPNv+lr1XeJxJZPUEw7V1wltK5TLgpPE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=lxsvNHsF; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=YnwWmXUW; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="lxsvNHsF";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="YnwWmXUW"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 6E34E7A00BD;
	Wed,  9 Sep 2026 20:30:14 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Wed, 09 Sep 2026 20:30:14 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789000214;
	 x=1789086614; bh=EMpr5mGZT82FtVXHwnHmc5JMIQUGs+9eDWqeOE1D7x4=; b=
	lxsvNHsFVT7fFtz6CnP97kRYlTwqlbxBCSvH9lbFMXADwGYovJMCVRP5cgqupgHO
	OzeqwtHr659gosbaOHZP+SXrSY7G+ztWBdY+J3HzWLs6/BQf/ZOhQNrjX/Suak4f
	cyDI/0G4cD0lcBfGXrVX2RF36Z9/jsLfp8a3cDQU2Gs95Jy29aMUuYG6BwHteYI1
	pe//0mRVzLK2SWVXJTMfApRkyMd8zY7oz2HjHQ8DmaXurSr40ylKqwRKrPVdJiTM
	ilZgEGINLASne3qzJkRvp/o5/4/fPQk4GiO734yPvDCPtvbVXnf84zh4LGaWUNPL
	Eyz9mbnTjbRbjEpSDU7rkA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789000214; x=1789086614; bh=E
	Mpr5mGZT82FtVXHwnHmc5JMIQUGs+9eDWqeOE1D7x4=; b=YnwWmXUWApTWuNnP9
	HF3hJrpcgH7Sl5vddNHLE/zxV1+DwZERv036uwck6T3YwXWgR020GFDEPVBQWT1P
	R2XiaFzoZHo/A7j+ZaylMMLs0+qcquDsBWFe60BE84ZJQLTFotRVmIgoKBiXjDeQ
	1wS0Svs+A3wdV7nmE4ru41fHWQ+rZJ2a+sDuZd4/v6y+llFDdsf6FibPvu4dLBIq
	j7CzgCZw5XcNBvxUIFNoAmwcdoA2Vq3mMi3TfCICfdKh7X1WJFQx1RpCw2xqlowV
	am0qihdJ5IPGOuXwjUpT3FJfzHDC8EIC819VA+3a5yBWyseXYIR4rBBVbR84O9Bj
	4+4uA==
X-ME-Sender: <xms:FvqhatzL3ayVhrE3DMMCIu_XQWblNsMJLejt1bbbF_QT5CUaDq3ATg>
    <xme:Fvqhavh4NZX90qL6_zmRVSvd2XFD6uryvCGi0H86nMPDf6HE8C0ptveQtfNjHO9fb
    m0-vdaogWOK5Bl7QW5Bq_6rz7iSKSLMZsNF_S-hLukTg4J8fN8>
X-ME-Received: <xmr:FvqhapktVxIOMgAQoeyHVBXS3178YACvnFT05ES6ljlaTZbd45sHuw2j-7zSKaQCvRNVBqEpHRV5zb-uk0skrSSxZkb8SBM>
X-ME-Proxy-Cause: dmFkZTGYQd2RN1ulbB62MDmsv4b7I9OGIR3hW4ak9IKw5pML8nIEjTlSAF9R6jHmb3QIpw
    z9ohaTHUOnSA778n/SiVuqQSaGAyDLCMok4eORfyo1vBrNXNtYg+f8iGYDh3/z6H68l9VJ
    jIUhwU/KT4dqP9BLd8k03tX6pmVPpQV85MtYzO/XIOQXODUtxRpDBDaL7mQnaNVwTm9jZw
    jRSk18lM8Ziwpjvv+awvUu0neEaEeDukbZh2PFJ8Fyc8V1Tu5Oe1TuggeC2yZ7vLgtPIjZ
    uVXXNIbwhSxWoKZinIOIY84cun0U8/Y7Jmbl+c6fTOlG9suLSvFTEX7qg5RXRjU+v+5yJR
    /SZfTno/W2hf7D3nrtg2txr5TMB4NICI81dL4CE9AQP4O36xOgEkwpejMZvpk4kCyfm7Ed
    rTFqUouIFZ0R/vzOdgap+Fj4kwvhIhXxsrX4gySfiwzzgQwD5F+ydXo2mlJKM3Q6SS06Di
    uYcRJj9wBlZuO8IzjUMypB8Oyx+XDXGt25zRf8gBJJC6wAdNMP6YBXCBi0hQjQ2TowwsCN
    V5EXp8fbPEPbj9mBLzD8Vzyj3ckqtptplt0GuM6+ZCy6TUcrX48OG0OEdxNuIs0PbLbQiC
    uVGUZMsO9q+6RFU9qDeIMBoql3EfQgPwjELjYwT7SAgn+MDrTh46BWaLdi+g
X-ME-Proxy: <xmx:FvqhalhO0WdAMnh-IUpKNtaPCj9qbp3Fa3jqCyJ3-I6dsfqT9Sk64A>
    <xmx:Fvqhat0_VhGz-UcnmaVA4oRdyNruH7H_tw1JcaDiDkUga3sZV-Cydw>
    <xmx:FvqhauIeI7f7SyuVLNjsgWpWtbjCpHyVGPJet-AHWBIIJqZHAaI-ng>
    <xmx:FvqhatyN5W8av0M8TuSFoGyZZDXOAA3N08qHNzy9rZYSWlEPk3sCqQ>
    <xmx:Fvqhas-StTy_nAyMskm-0D9V3ji6UXNI5uPxf9jsRJg8ndy3J37_tdlw>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 9 Sep 2026 20:30:12 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 5/7] nfsd: switch NFS4 OPEN to use vfs_lookup_open()
Date: Thu, 10 Sep 2026 10:20:51 +1000
Message-ID: <20260910002934.192979-6-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260910002934.192979-1-neilb@ownmail.net>
References: <20260910002934.192979-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

The functionality that was recently gathered into do_lookup_open() is
now available from the vfs as vfs_lookup_open().  So nfsd4_create_file()
can call that, with a few adjustments.

This implementation shares more code with syscall open paths and so uses
some filesystem interfaces slightly more correctly.  It also takes the
responsibility for locking out of nfsd so that planned changes can
happen entirely in VFS code.

We need to pass O_NONBLOCK so that that EWOULDBLOCK errors from
break_lease of try_break_deleg() get passed back.

We need to mask any type out of "mode" else vfs_lookup_open() will warn.

vfs_lookup_open() always returns -EFTYPE if a non-regular-file was
found, and provides the dentry in parent.dentry.  We can use
nfsd_check_obj_is_reg() to turn this into an error.

As parent.dentry could be NULL, we enhance nfsd_check_obj_is_reg() to
cope with that.

vfs_lookup_open() will return -EEXIST if required for
NFS_CREATE_GUARDED4 as O_EXCL is passed in.  Other checks for
and existing object need only test for nfsd4_create_is_exclusive().
Make both these tests (for non-regular and for regular) the same.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 83 ++++++++++++----------------------------------
 1 file changed, 21 insertions(+), 62 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3a82af381a8d..0fd5a6411ed3 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -225,8 +225,11 @@ do_open_permission(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfs
 
 static int nfsd_check_obj_isreg(struct dentry *child)
 {
-	umode_t mode = d_inode(child)->i_mode;
+	umode_t mode;
 
+	if (!child || !d_inode(child))
+		return -EFTYPE;
+	mode = d_inode(child)->i_mode;
 	if (S_ISREG(mode))
 		return 0;
 	if (S_ISDIR(mode))
@@ -250,52 +253,6 @@ static inline bool nfsd4_create_is_exclusive(int createmode)
 		createmode == NFS4_CREATE_EXCLUSIVE4_1;
 }
 
-static struct file *do_lookup_open(struct path *parent,
-				   struct qstr *name,
-				   unsigned int oflags,
-				   umode_t mode)
-{
-	struct file *filp = NULL;
-	struct path path;
-	struct dentry *child;
-	int want_write_err = 0;
-
-	want_write_err = mnt_want_write(parent->mnt);
-
-	child = start_creating(&nop_mnt_idmap, parent->dentry, name);
-	if (IS_ERR(child)) {
-		filp = ERR_CAST(child);
-		goto out;
-	}
-	path.mnt = parent->mnt;
-	path.dentry = child;
-
-	if (d_really_is_positive(child)) {
-		/*
-		 * open the file so that we consistently have a valid
-		 * op_filp and consequently a valid ->f_path.dentry.
-		 */
-		int err = nfsd_check_obj_isreg(child);
-
-		if (err)
-			filp = ERR_PTR(err);
-		else
-			filp = dentry_open(&path, oflags, current_cred());
-	} else if (!(oflags & O_CREAT)) {
-		filp = ERR_PTR(-ENOENT);
-	} else if (want_write_err) {
-		filp = ERR_PTR(want_write_err);
-	} else {
-		filp = dentry_create(&path, oflags, mode, current_cred());
-		child = path.dentry;
-	}
-	end_creating(child);
-out:
-	if (!want_write_err)
-		mnt_drop_write(parent->mnt);
-	return filp;
-}
-
 /*
  * Implement NFSv4's unchecked, guarded, and exclusive create
  * semantics for regular files. Open state for this new file is
@@ -312,7 +269,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		.na_iattr	= iap,
 		.na_seclabel	= &open->op_label,
 	};
-	int oflags = O_CREAT | O_LARGEFILE;
+	int oflags = O_CREAT | O_LARGEFILE | O_NONBLOCK;
 	struct dentry *child = ERR_PTR(-EINVAL);
 	struct path parent = {
 		.mnt = fhp->fh_export->ex_path.mnt,
@@ -424,28 +381,29 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		/* Might still succeed if no create is needed */
 		oflags &= ~O_CREAT;
 
-	open->op_filp = do_lookup_open(&parent,
-				       &QSTR_LEN(open->op_fname,
-						 open->op_fnamelen),
-				       oflags,
-				       open->op_iattr.ia_mode);
+	dget(parent.dentry);
+	open->op_filp = vfs_lookup_open(&parent,
+					&QSTR_LEN(open->op_fname,
+						  open->op_fnamelen),
+					oflags,
+					open->op_iattr.ia_mode & S_IALLUGO);
 	if (IS_ERR(open->op_filp)) {
 		int hosterr = PTR_ERR(open->op_filp);
 
-		if (open->op_createmode != NFS4_CREATE_UNCHECKED) {
-			switch (hosterr) {
-			case -EISDIR:
-			case -ELOOP:
-			case -EFTYPE:
+		if (hosterr == -EFTYPE) {
+			if (nfsd4_create_is_exclusive(open->op_createmode))
 				hosterr = -EEXIST;
-			}
+			else
+				hosterr = nfsd_check_obj_isreg(parent.dentry);
 		}
 		status = nfserrno(hosterr);
 		open->op_filp = NULL;
 		if (status == nfserr_noent && create_status)
 			status = create_status;
+		dput(parent.dentry);
 		goto out;
 	}
+	dput(parent.dentry);
 
 	child = open->op_filp->f_path.dentry;
 	open->op_created = open->op_filp->f_mode & FMODE_CREATED;
@@ -462,7 +420,9 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		open->op_created = true;
 
 	if (!open->op_created) {
-		if (open->op_createmode == NFS4_CREATE_UNCHECKED) {
+		if (nfsd4_create_is_exclusive(open->op_createmode)) {
+			status = nfserr_exist;
+		} else {
 			/* NFSv4 protocol requires change attributes
 			 * even though no change happened.
 			 */
@@ -477,8 +437,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			open->op_truncate = (d_is_reg(child) &&
 					     (iap->ia_valid & ATTR_SIZE) &&
 					     !iap->ia_size);
-		} else
-			status = nfserr_exist;
+		}
 		goto out;
 	}
 	/* file was created */
-- 
2.50.0.107.gf914562f5916.dirty

