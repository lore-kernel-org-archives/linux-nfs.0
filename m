Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 009913C37BA
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:31:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.145
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280674; cv=none; b=KvzW0ybYawbQ/yDSNIqWvkddjYzuNORhMzO+5sw/MiPMCpBr978ubmQqaXbMc/mpcYfZO1HUxdM1j/oE7Sbuluc3m9ZV3jUHLwYXyUFx1ndA3OFxchzYGzzyZy6YGTQ3/I8n63sbp5F+E2GRrt8XE5dDh1AdBX0YTenMcNc91Y0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280674; c=relaxed/simple;
	bh=FYTGrjpbttGQezkDmyLZLppfj6IUP7qNyH74iWuzxKU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qKXUl79sUEEploYTAqox/tUL+7Yi0SRBvntx+1FOS74UblqQrh65UmQ3jC3jHsMgTdWla0iqgC6eWL3sUU2g9CHsew1MHgs2pPOOeu4r4o7f8IvENVC7RRkTr5xNYR459YezV46bL5qiJ8eURg61RJUnGGkF6B2YF/iKrUsKqLA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=RZ2d5JFy; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=T6FTtYHE; arc=none smtp.client-ip=103.168.172.145
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="RZ2d5JFy";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="T6FTtYHE"
Received: from phl-compute-11.internal (phl-compute-11.internal [10.202.2.51])
	by mailfout.phl.internal (Postfix) with ESMTP id 240C0EC0099;
	Fri, 17 Jul 2026 05:31:12 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-11.internal (MEProxy); Fri, 17 Jul 2026 05:31:12 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280672;
	 x=1784367072; bh=MKz7zSBg6h/83wlgEHrS8dEM37A+8DH1lr+8okz5dbk=; b=
	RZ2d5JFyry1wi2eEyRe2Os0nakDoOH6T+hzalrvQSKLBJNCMbVLFj1NNROXjJoor
	caDdPs0cQ/asO88oqaH3gVlvHDheXW1gW53VBCcrGrbshUDsrAy3gr2j5olQRGDh
	Xwfe66ZfooE+wt8fBBpNpoutQa3JTjeUPKkukjJHAha0NxaJeWYMVt252/MU7OIa
	v8prI/MoknVCmvwUSJvzK9HkaFMTTwjaVoYkSxhFqpFRmGRKzpmZ1x8c0Mv804WC
	zEtVLBbcIaFhoOh1XVuOZQfn3ofbasVs9JrdnTxK593+UvpxI9iIT9H6EXUEFnZY
	V5hQyLupxuVWGBHrOkSEXw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280672; x=1784367072; bh=M
	Kz7zSBg6h/83wlgEHrS8dEM37A+8DH1lr+8okz5dbk=; b=T6FTtYHEX9JN0C2Jn
	x4Arzf8EGzdTkSbRKC0e+MaNhUERJk2tjpo5QZ8bb2QlG/DD+f0jynoOm8Ccv1Rz
	ammwpCOx37pwCVjQ23wbVPw5x49s/8F/WPJu5HjqmQfEKwebafMeBi6wNM26eNAk
	Yh6sp+kTdzCpmZR2IP9scpfZnxBZiHTsBIZMm21m9GdX2AjjLKbGvyJT+lSgu5qA
	R6bABk+G0jC+x6ekE+/CSkD6sD3XTczF7fg07IyVShIA4PLqrpzUPbZSr2kUpgk+
	FpONCy5NQXwekoK5JI+ohJsZ04aqFrvBUe2Y0EOaJtrj7pNtYhdqkqWPHDIVVedY
	xpobA==
X-ME-Sender: <xms:YPZZavGqqYrAay4w_hRIeeXFPi1o15I9PeysHSmlLlFFdg57-VJaiQ>
    <xme:YPZZagCQbwWdinIKzQvT0gg_NyjcmAvWr3tvn87q81SlmpJVc_i6w098hVkRWBpK2
    doDWWsdKk2Mx5I1IXc8j0v0fut8LNUo0Xm_uuUA5IJiTvI>
X-ME-Received: <xmr:YPZZaq-qo5QSaJUTQLpXmm7_hhBrzYPsDA7ag203J51hrtLJY2yETY0UpUmOYI411Ey5VIHJEZn2gF9FSRKQEXzzkHUWmjo>
X-ME-Proxy-Cause: dmFkZTEApqFO5jAKqrP3EdbU0Ae0MCQnQFfvSrW+r84mL3qL2UFfbuf83R37o+6oMtcUaH
    6DPJoG+34uUdqXbvR7Bw2l/P4dHaUP7HQXwsVpft7xVFNPuQCF7CPPRrJ8RbY/S97ZLP41
    U7XX1t/FfVPe+wX4TXpm1uyeb7KPzLLiiaQZAxoL0T352PWKJdXBYkCUMqwJ+Qc6GUYgZ3
    Uoo8xLxf76by20kMmFLftmzj5U0bznLrEBN2m623yRBHfn2OKPGMWK6sTxb/HqvCRKz8H9
    PuQ4+q7R9RbgvgWOq6XwvxxK5Vgvb3Gcdtw7XfnM+DdDvQvzx8yPyLi9NGYtfL0WuGqtLN
    kh60/ypui3FFlaeQndvYFvV/rGGW3tXBEOIq0T+6yHtWZrl5DcrnaDU07/Nwjz0nFy1fej
    JqVWMOLA7Ps6FAU0ZJSlg1ZJ4wYBa3hSL3sEdtkL2XboLT0vs0PiosxmbbzQtv4fofdgbq
    QGGkZGdoGX3Mdv3d6Z9nNmZWkcK+i2GHxdjAItad5b3xciioJS82RWOXNriUQB+nbbG+Sl
    tDzk4zGwOHn6t+81GNefTj8haunBCAztm86WHOm/mKPeBnmT41Y5FCbdtcDwg4H20I8pL/
    dJLSpnvu8KAjDzF5sijGWWO6Yc+Fl0iiywHKsVvQC+79pWBAGGMO5ZhcaV0w
X-ME-Proxy: <xmx:YPZZakBWSlTZNayzDcEX66mHloclpkegV_8Wi8vuSrZKB4fdC1DCGg>
    <xmx:YPZZanQImhbbX6-UzyRgrvdV1U4dMI2IUPFjNUkD1PPBSb49K_qQqQ>
    <xmx:YPZZajvwTfUR2clxUzKBmeN-WUUXxDxF5zpQ91FEeNsz_P1wrUJxhw>
    <xmx:YPZZar3BcCZSNBuTF-lgjWb9fy1rj4qrm-bjbCnJbfD5qjw1mYNXQQ>
    <xmx:YPZZakkzKZuIFQKuPdC8cbEOyYX1ekWUvwW6sXBLilW7bFY_W0T9dgeZ>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:31:09 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 13/18] nfsd: open-code nfsd4_vfs_create() into nfsd4_create_file()
Date: Fri, 17 Jul 2026 19:28:01 +1000
Message-ID: <20260717093001.1972119-14-neilb@ownmail.net>
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

Having this sub function separate doesn't really add clarity, and merging
allows for some refactoring and ultimately using a different VFS
interface.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 76 +++++++++++++++++++++-------------------------
 1 file changed, 34 insertions(+), 42 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index c04a021d9719..c3bec447a43e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -202,46 +202,6 @@ static inline bool nfsd4_create_is_exclusive(int createmode)
 		createmode == NFS4_CREATE_EXCLUSIVE4_1;
 }
 
-static __be32
-nfsd4_vfs_create(struct svc_fh *fhp, struct dentry **child,
-		 struct nfsd4_open *open)
-{
-	struct file *filp;
-	struct path path;
-	int oflags;
-
-	oflags = O_CREAT | O_LARGEFILE;
-	/*
-	 * For the EXCLUSIVE modes we do our own uniqueness tests
-	 * so don't want O_EXCL.
-	 */
-	if (open->op_createmode == NFS4_CREATE_GUARDED)
-		oflags |= O_EXCL;
-
-	switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
-	case NFS4_SHARE_ACCESS_WRITE:
-		oflags |= O_WRONLY;
-		break;
-	case NFS4_SHARE_ACCESS_BOTH:
-		oflags |= O_RDWR;
-		break;
-	default:
-		oflags |= O_RDONLY;
-	}
-
-	path.mnt = fhp->fh_export->ex_path.mnt;
-	path.dentry = *child;
-	filp = dentry_create(&path, oflags, open->op_iattr.ia_mode,
-			     current_cred());
-	*child = path.dentry;
-
-	if (IS_ERR(filp))
-		return nfserrno(PTR_ERR(filp));
-
-	open->op_filp = filp;
-	return nfs_ok;
-}
-
 /*
  * Implement NFSv4's unchecked, guarded, and exclusive create
  * semantics for regular files. Open state for this new file is
@@ -396,9 +356,41 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	} else if (create_status) {
 		status = create_status;
 	} else {
-		status = nfsd4_vfs_create(fhp, &child, open);
-		if (status == nfs_ok)
+		struct file *filp;
+		struct path path;
+		int oflags;
+
+		oflags = O_CREAT | O_LARGEFILE;
+		/*
+		 * For the EXCLUSIVE modes we do our own uniqueness tests
+		 * so don't want O_EXCL.
+		 */
+		if (open->op_createmode == NFS4_CREATE_GUARDED)
+			oflags |= O_EXCL;
+
+		switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
+		case NFS4_SHARE_ACCESS_WRITE:
+			oflags |= O_WRONLY;
+			break;
+		case NFS4_SHARE_ACCESS_BOTH:
+			oflags |= O_RDWR;
+			break;
+		default:
+			oflags |= O_RDONLY;
+		}
+
+		path.mnt = fhp->fh_export->ex_path.mnt;
+		path.dentry = child;
+		filp = dentry_create(&path, oflags, open->op_iattr.ia_mode,
+				     current_cred());
+		child = path.dentry;
+
+		if (IS_ERR(filp)) {
+			status = nfserrno(PTR_ERR(filp));
+		} else {
+			open->op_filp = filp;
 			open->op_created = open->op_filp->f_mode & FMODE_CREATED;
+		}
 	}
 	end_creating(child);
 	if (status != nfs_ok)
-- 
2.50.0.107.gf914562f5916.dirty

