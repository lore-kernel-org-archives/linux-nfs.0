Received: from fhigh-a7-smtp.messagingengine.com (fhigh-a7-smtp.messagingengine.com [103.168.172.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 617A73C3F49
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:31:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.158
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280678; cv=none; b=gANJ2THxLs+FQJsa0uS5i8dcaHbVUP1F6BSEjLZKpL3kK+u9q3iLrdDE6CBOfKFqp1anB9o7grZPcC3UAN/N2DIhQwoT9KvnwPF/1UHktFdjMtoJ8nRgH+AZ4LCUODpN5DQl0+KG7NWKp6hwsEF9VboYxVGvo3jg/wlaiZMSOGM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280678; c=relaxed/simple;
	bh=50uUGzwbfWXHwAV0bLMHrouLSJwmbmAO8S30vY0peaE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=RFN3Pm1QObkDk8NJyOOxCjrU9cDZ9xf8bx6n25oG0PGOV7h0gHf4ZaSxuU5Yvv8KzjkALIzyz1OR0PeNKCiILkiljA7niCwaBZx9WbS9liDTq0An5ylmqUsJaPoo4eaiKknwJSsb7E8mRhbjGbZlzx/e+nnDZELZyNRRvYMUqCw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Djk59JCQ; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=eCehWQoi; arc=none smtp.client-ip=103.168.172.158
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Djk59JCQ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="eCehWQoi"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 9DEB61400032;
	Fri, 17 Jul 2026 05:31:16 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Fri, 17 Jul 2026 05:31:16 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280676;
	 x=1784367076; bh=Fuyzqpvxc8agHaMf/aODtsOj7CWtTNw/eEsqZqAxmJo=; b=
	Djk59JCQg9gnOR7E4wglKyIz/TCdAv7agrNwZpqTWvM9aGtfdE2Ue/b+2VVHFxgm
	Pp1usrO3mSN5Mry/a5uXdkYvCjcJ8QDvwzFxR/R1pkX3SgEsFZW9oSS0PP+rJawu
	SePgLWSDWUVRyJNTXdRP8gz7NnklpOSejuDBBPhmt2sp6k9O4Dolo5RxHRJd3iTu
	yttY+g3pLrCiEu9YcmRs2XDahIFQ8QSa9BTxt5hII9Q/O+28DKZ/nfJOkpxIwDzw
	Omwec4+8hLuGZnszSS1XCyb9YRMxordP5HVLRJvceQGnx7+mIRdArgZ+TwDivwBH
	fDv1kavgR8FPdkfe2+SkxA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280676; x=1784367076; bh=F
	uyzqpvxc8agHaMf/aODtsOj7CWtTNw/eEsqZqAxmJo=; b=eCehWQoirQsznR44x
	A+EiUsT3DRx1hkscVEzA4oSy9uwZ4rSnoZUxE2PdGN4kzv5XLyWsX1xR2fcFY3KC
	Swf4BWkrcqx4SiYOaXtLDdMgDiRJYZgLjI19qGCWsUngjRnOwdNmHwLq0Ugve3w7
	Gv4BnSitvLH8EaNKWabO2MJUdBtW7dojOYn66YYDAueZHX5SK9bxGz56SV1F0UEl
	nIBNoHtjowlu4xhz78HCU5XfmXx/lo+8v7Q1+2twbYRGtl9hZZDTGCuf0G135SX4
	J3XfMQGdOLoS7v2JJu65J2WVjaQNzTeq57v1/OWwnInnnQ7SMWzZhVW/ouHoKJF7
	RP6Og==
X-ME-Sender: <xms:ZPZZan3OQNTsylGxUAVp5wxUk7wcMOpPhR0vIVHyDyp6mxxKq7p2zA>
    <xme:ZPZZapx6yVHe2zTvnbcGJGtymj3Yh3oLq-r7edsy4e4RDToSAfSYUZyp9ASga3n5B
    sm5c-a_2OmFZJSbtXxfn1_oWSluOE8Ee5KbQP8Hsmr98JM>
X-ME-Received: <xmr:ZPZZahu3hG-Ex5wL7NYCfQdUgx4NluqnO3h8Awk4kG7k1sYcUChQ1KYbwo2F1k1C0OeSmAdUNx8f5PKQZ7pj8W843jWNrok>
X-ME-Proxy-Cause: dmFkZTFt/ltHQiQnjOnec5Xwf7HAyfv/h6swQd9Lp4S8lAVdynG6lr/bMlDadX3a6MZaNI
    xARu8dwnt5/EKu9g11Xxlo5cFffflZKrI1fbT4sSobshHOocQ5fK7d3tI7rh7yGEguG5js
    SqTubOs7Q1Ji7gqDKvmCOslN+YMh5QmMGMkgdI4Rh10FgF7mn0JKW4SNmo14KiFpivov8C
    +UzA+fJ2Fmt2HPUW8tILOaqDOjiyN/I09G9/CmpiIJyiNHUxhCdpGgyFgzGgqafrlcFmsv
    RKOGDGknxA+ctU9mmjkFL44NELF9JXjKsTr1S+qon4sfNZpuA7EeL1QNk0SIiYNxaEpghL
    YRgg2P3O8yRdl7y9Q9vJNCTq6v9reFnMQVG0FkLGjUXwm5vY/pW9G39uJB8wOHCrQdIDWd
    HZkO+Nq/z0ah555871+cO8alOHffheWAvbZRg9aGAeaIH9PV3iT27EdGTVIHfKsUh1lm69
    q1rtThUQ7MAJV+tc046K0opkeiOzVwPwU00YOGDvFTY0x8qDbJYcea/TaJ+wgXCSDvSYZW
    ecsyiFTPBwzV9qqne5pCTnNt0XmLFOh2w1vYRSUgNcrR8jJTiOUobTtSuDrFDyS5hck90X
    ksM30/OeXE8YsUkprBFuvXEmlm/ltUhHcB8ZiGRPeQR41X+xyY0yWLP3koWA
X-ME-Proxy: <xmx:ZPZZajyo1dL-HeW3S6SCXbbDrWEZZipSsMiv9otxQbh8re7pVN8iIw>
    <xmx:ZPZZasBY5D8dDbFfGSykH53hPRYwBkZz7fUmkPGM2YHcPl_qzEzrhg>
    <xmx:ZPZZapdoJjzhZLCwji2tMdGAihflXoO90XvO828uYtl9AnQI1HGw1A>
    <xmx:ZPZZaumojokpXnVHVItVMZmRfBK9oTbp3dPIU53jYo-41UHC3WTDWQ>
    <xmx:ZPZZatW9ryh7pT28mr4KolFeIH5nVKTe1OiotwZ9GsAPAMdHfqShzhjh>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:31:14 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 14/18] nfsd: move some code out of the d_really_is_negative() branch in nfsd4_create_file()
Date: Fri, 17 Jul 2026 19:28:02 +1000
Message-ID: <20260717093001.1972119-15-neilb@ownmail.net>
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

The benefit of this code movement isn't immediately obvious, but it will
make it easier to switch to using vfs_lookup_open().

One immediate benefit is that common code in the d_is_positive() branch
can be discarded.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 73 ++++++++++++++++++----------------------------
 1 file changed, 28 insertions(+), 45 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index c3bec447a43e..7a67e1385b76 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -220,7 +220,11 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		.na_iattr	= iap,
 		.na_seclabel	= &open->op_label,
 	};
+	int oflags = O_CREAT | O_LARGEFILE;
 	struct dentry *parent, *child = ERR_PTR(-EINVAL);
+	struct path path = {
+		.mnt = fhp->fh_export->ex_path.mnt,
+	};
 	__u32 v_mtime, v_atime;
 	struct inode *inode;
 	__be32 status, create_status;
@@ -266,6 +270,24 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (!IS_POSIXACL(inode))
 		iap->ia_mode &= ~current_umask();
 
+	/*
+	 * For the EXCLUSIVE modes we do our own uniqueness tests
+	 * so don't want O_EXCL.
+	 */
+	if (open->op_createmode == NFS4_CREATE_GUARDED)
+		oflags |= O_EXCL;
+
+	switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
+	case NFS4_SHARE_ACCESS_WRITE:
+		oflags |= O_WRONLY;
+		break;
+	case NFS4_SHARE_ACCESS_BOTH:
+		oflags |= O_RDWR;
+		break;
+	default:
+		oflags |= O_RDONLY;
+	}
+
 	if (!is_create_with_attrs(open)) {
 		/* No attrs to check */
 	} else if (open->op_acl) {
@@ -322,27 +344,13 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		status = nfserrno(PTR_ERR(child));
 		goto out;
 	}
+	path.dentry = child;
 
 	if (d_really_is_positive(child)) {
 		/*
 		 * open the file so that we consistently have a valid
 		 * op_filp and consequently a valid ->f_path.dentry.
 		 */
-		struct path path = {.mnt = fhp->fh_export->ex_path.mnt,
-				    .dentry = child,
-		};
-		unsigned int oflags = O_LARGEFILE;
-
-		switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
-		case NFS4_SHARE_ACCESS_WRITE:
-			oflags |= O_WRONLY;
-			break;
-		case NFS4_SHARE_ACCESS_BOTH:
-			oflags |= O_RDWR;
-			break;
-		default:
-			oflags |= O_RDONLY;
-		}
 
 		status = nfsd_check_obj_isreg(child, cstate->minorversion);
 		if (status == nfs_ok) {
@@ -356,39 +364,14 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	} else if (create_status) {
 		status = create_status;
 	} else {
-		struct file *filp;
-		struct path path;
-		int oflags;
-
-		oflags = O_CREAT | O_LARGEFILE;
-		/*
-		 * For the EXCLUSIVE modes we do our own uniqueness tests
-		 * so don't want O_EXCL.
-		 */
-		if (open->op_createmode == NFS4_CREATE_GUARDED)
-			oflags |= O_EXCL;
-
-		switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
-		case NFS4_SHARE_ACCESS_WRITE:
-			oflags |= O_WRONLY;
-			break;
-		case NFS4_SHARE_ACCESS_BOTH:
-			oflags |= O_RDWR;
-			break;
-		default:
-			oflags |= O_RDONLY;
-		}
-
-		path.mnt = fhp->fh_export->ex_path.mnt;
-		path.dentry = child;
-		filp = dentry_create(&path, oflags, open->op_iattr.ia_mode,
-				     current_cred());
+		open->op_filp = dentry_create(&path, oflags, open->op_iattr.ia_mode,
+					      current_cred());
 		child = path.dentry;
 
-		if (IS_ERR(filp)) {
-			status = nfserrno(PTR_ERR(filp));
+		if (IS_ERR(open->op_filp)) {
+			status = nfserrno(PTR_ERR(open->op_filp));
+			open->op_filp = NULL;
 		} else {
-			open->op_filp = filp;
 			open->op_created = open->op_filp->f_mode & FMODE_CREATED;
 		}
 	}
-- 
2.50.0.107.gf914562f5916.dirty

