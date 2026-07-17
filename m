Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C12A3C2763
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:30:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.145
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280652; cv=none; b=utR5YtuFvhOrXmYhwubt2FNUkZAjKiy5LSUQ1XNgyJPlVAtR1qFf5C73FhJowlhK5+4v+xPRW5+uLX9ZnHUD/VT298bOnF7TFpnPls66JdHaMTnmzo287+zfU4XKApCdoXpUu2ehOOqHsqrZATAjP64MoUadiF5Q/hpJ2eZmTi4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280652; c=relaxed/simple;
	bh=jNTIu877zslvePgZAUX9+LFgWN5VLLPIeMCbIc32TKI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=baprP4A+5c5HvBuoxJM0TgwkJH8r2om1Yio/wSmp4JZZLB/zHi5j0cHSUYF5kShsIoegoqf8Aj8uPcISZ407k6dK3H7JrVgoL2J0hKcs5gmWOFTDj+r8uZDZJq2QcTNK5y+xrfTe1aPx/gUHAKC43oqkcmsAlW6qcpHw1wAMUXs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=LBzsfTP5; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=bu/YubCD; arc=none smtp.client-ip=103.168.172.145
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="LBzsfTP5";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="bu/YubCD"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfout.phl.internal (Postfix) with ESMTP id CAAC0EC012B;
	Fri, 17 Jul 2026 05:30:49 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-05.internal (MEProxy); Fri, 17 Jul 2026 05:30:49 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280649;
	 x=1784367049; bh=d8WCyzOhjsgie7OuaIqj7FW7j4SdX4IUfLrw2HCkwn8=; b=
	LBzsfTP5fX8MBQYo90+Edy4Pvub81VRIQMcl7mxdtNPM0vkfbpL4x+UTbZZyolqP
	z51TcD+C8VfmK+6s/cDThmWv/tzKEaJfkZrkuMJXAExE11rc5AvikeL3SIynrF4V
	BiCLZ1EjJwPi2t3P/jEgjbaNN6rMV/GHVME+hLFVtZA/pke4jiZXqlgVgnX2BDyN
	gOaAzDVksKCNQMcewlZ7JdeWv8sIlGeE+gTkDNmarncc+sxYBWoZTzcZqkM1wacY
	p9h9n+6xEqY752pfq1vnRlH6mr/bkz9K8Xyclhdixb1jyY1wheo7Q1oS/EFoytlR
	y4H41ueyex5ddQrP7cyREg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280649; x=1784367049; bh=d
	8WCyzOhjsgie7OuaIqj7FW7j4SdX4IUfLrw2HCkwn8=; b=bu/YubCD68nUzURGe
	UcGIGJoysXLVbNDBAxldCdAvEBWanV7FW2A75DTkKYxzXpT2rWQiFkiZ6QcksBZK
	FZMMvAjq4wrEYv5CSauta7jHkeUn5RXNRbbnEfwmyD8ecnT59v1JZ2bxTGnru4Md
	aDUBIPXr4hImY38eb11hr5k+ynq0f4r+FiLlv/Pd5aoxnPwh4uh47T3PAz23si0W
	oth4uoPFnSb3VuHJ3jvXYYjmaAqTWx5EIdCcAPG83qas8fwrysc8rNas/M/ZJHM0
	1osvCBaaxksZ/uFIGzjA4x9QEydEGDNKE6nrzeHh3yNxQu43YITCR3EI6nMkFkES
	pVmiw==
X-ME-Sender: <xms:SfZZahY5ObSf1faGPnFMlQYxH1Fnvqy_RegWEYQWKe7hWLYxW31e5A>
    <xme:SfZZasFTYNG057Rixr8RMM3hZmMAje6AvulCQMHPdFEJOdSV7kPUm3IiecjAy9Gsw
    i9AG7j_hrd4w2lyALi8MYoCh5_Bh7TCFgOIiSfJADsKNxFE>
X-ME-Received: <xmr:SfZZatxp8o2eInlKHb4Jcv02BwY5qtUKH62vaZZQaz1XcQ7rHfJlOHd_HlQAIa1pYh9C9mPwIYYkSXX_3X24gVkPpadAG3c>
X-ME-Proxy-Cause: dmFkZTEX57Ex8LbShfUXWkvJih4a1baE9EfQ6TgUPnJ0DaKnRO3Du70CAhhY681g13Zhbl
    7+6gjM4A0f7dNvQc03aRIz3FZBRqrxctlwbzsG3ndQuoUarocORY0qObpi2VHZQgoKrsuo
    Pz8T2Hzo9NtU7WBXPVmdapAMdiqKaX+pxxqioqIbP8tlHObQF+a7Mp8hX7zOHvDB6EOMWg
    1sbeLGfkgUP3SWNtJdyCx4zo2FvbCdw3kEs1ZvMn58hsAfPpvA+oTbrgQ0oPjv71NDjjPy
    WnL4ClTcOz8/DrmfPbmbnRXwAb95LZ30NPNsYA/6r5bUfJzKa9KuHLiAmSCPierLaaggIa
    ySFhPGfdOYap7/rhuhYGy2MW8zVT51RSEmCWj556i4WIYz+sfvN2VlBnQzHYFe4qUC9kpU
    fJyQgvH7PMgqXDbKuxK7DOkXg3F89+eG2T9GUHP5klFlW6cKTtWKX9ACktuiDMa5BqgAsn
    xPoSsfD088P9H16OmbRAKZX0Ve7uLdTXUPGdzk+JlQ6AuxZNDO57uR9zxpLfqcXNbhcd12
    Mgs8AS70Kq8sv/MV1nXxj/gjkhF96Z9In47ags6ihfSFoidXmI6KwI8ffpnSlu2/24e6Mj
    X56zTiRQtqRULy0TTFjb+mTPEWhBBxxxg70xMkbhFW6DCMYOGdLnjb9LOtWQ
X-ME-Proxy: <xmx:SfZZamkqEH5HgGvTurh-dnFaDS3-aI9b6R1MzvatjU8m21E6DJdn6A>
    <xmx:SfZZaukzPsBbrMrUKpm-TnBtTeHUOPogdwESdJofS1Od2PiX55hiuQ>
    <xmx:SfZZagyPGzU2x8U_0_yp63soOI-OOu0n2YD81dC-IGrBD0impzYn2A>
    <xmx:SfZZaromWbSPcCRJ7jsXl5dgDWth9LtF_e1q5x8iQWk6WkNAUbZ5QQ>
    <xmx:SfZZaq4BJe_aPi0Pg_r1Hd5eZB1zWu6NWdjqRyDKXTLzQRcrSYvkZfcg>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:30:47 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 08/18] nfsd: in nfsd4_create_file() let VFS report if file was created.
Date: Fri, 17 Jul 2026 19:27:56 +1000
Message-ID: <20260717093001.1972119-9-neilb@ownmail.net>
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

