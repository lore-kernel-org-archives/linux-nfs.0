Received: from fhigh-b3-smtp.messagingengine.com (fhigh-b3-smtp.messagingengine.com [202.12.124.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 937A1285C91
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:33:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262821; cv=none; b=dD5Q18yfYVoIb9sauJvb0/Y1verqRDSsoDx0RGUKh6dZKVYrPNbEOQx5kSTF6bk8/Bwp3DcVltTFXD/Y0iX1umaGktSaOzwLvK4deb/2OzYYXEAu0vWBGWKI008g6YBE7cdns3ECEcAZMMmgyqMKf0u6yZSOyCWrcQ7KI479QJg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262821; c=relaxed/simple;
	bh=1XGcYYgO08V6+3wsvZjALQZQRSkksTkUTx7tKd9lvbw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Ci4HqxAGk04ER44pziWFdFRI/Me405EhYB8bdwxb0WakTT3YAEWZg86jNbhNWhdJNyOwlsNUJagug+Weo+QK/ffPpX+tezYh/yeIkv1bHLUVsISg+OflTRsOAVSvXmHtKDLla2JWRIJP8/Ax6eP35lTs6prPr5RzVeyxSA2bVWs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=O0G0hCAa; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=mRtTdjcf; arc=none smtp.client-ip=202.12.124.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="O0G0hCAa";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="mRtTdjcf"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 3BCB97A011B;
	Fri, 17 Jul 2026 00:33:34 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Fri, 17 Jul 2026 00:33:34 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262814;
	 x=1784349214; bh=Hm1WB/QfGfNUuILJ4U+cIkrJel13v79Ig5A6omWtSM0=; b=
	O0G0hCAaubWCH08SuyMSaR5PudI/nj8d6OxKTRrNX3D+xdfv6PTaj3KB+99IWpDF
	UWIPWNPFvinfT5+uLIod7Em9o4UxMMW+nuiJTlu48As6MBbKArOC69h1ELKaVOfm
	0BJGBVxsYbcc8OmV4duZ2lmwNfhvMm9Bj3ofyBm/0V41JS5dyFBNETU4o+tzzNsI
	jHZrdHiRNb6uLpxlHZqtov4SWDItmkXsmUzRBcHy/2o26Dn/53HBIcSe92kYhPe/
	uRuN6am1jjIdlO0sJd+g0SeIavB3NLuh8T56GTQi0YFwCECZS8MQ+oJfW3wj8vOl
	skVK5fQ+1PV4lEXSqyaalg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262814; x=1784349214; bh=H
	m1WB/QfGfNUuILJ4U+cIkrJel13v79Ig5A6omWtSM0=; b=mRtTdjcfUprZ2BF//
	q00toHk6ak0/pnViWte8soE8NZTEmFVzgSPYnQasnW/0i66UJFcKje8oCjNwAiTw
	c1ek3cnccmOK5L3L4tWH33Bnile3+I1XERJbBDGdAof9i6udvEVSGJavoFMVidbb
	Y/Cao9wRPhyy/RnI1YQVtTE1SmzDSEwwG7k0Ld9veiiULpdEaYx1EPqqIdQUu4Gb
	qkwLuElq9DK3gm+f6WlHITDHxGDldMuwH7VSSXQvTZHX1Dv4WIbaw+O2hf7Zbs8t
	cOx1ctA8eT8yKtuaFh5f64XPr7vNHycPajd6Ca2vc0N9ELQXDhFedu1jcpHtA55e
	YYqIw==
X-ME-Sender: <xms:nrBZaoIRHDokhfJXXhO2E8t79kcpqldZ5PbsY4Wh8Zs6K_ZKqroFkg>
    <xme:nrBZar2B98z4F5MmRRqwMBGVngWQbkLLEWuv6JofosOoAmSzdL2MxRkptgEv-XupZ
    9Xm1Gf2oSp2Fyl-MDiT3HdRyplogQ-djjjeAdnE31da0Q8B8g>
X-ME-Received: <xmr:nrBZaihm8WzJctP65pelGhrLCreNNIyXEAhusy6BKnh0kERSs49WQ6BEwJoPajeloo0TewuwpugD9dSUeIMxU9CJDgMsCLc>
X-ME-Proxy-Cause: dmFkZTFe1fPNt0teZMz+igsEg0Yi62Nw1HA3RWU9lajtn/KqgzCHwE0SDkRLEuN+X2bdVn
    +JxjBa/aSTWuozTeEfNHmtuHiUV9Fs0BisuGE4A6T2CuSFG0Kbv+f8y8Mx+y2wKStdSD9p
    PaPx17A/9gdYw6sCXZWoqwe8lNQRn2EzH+qt+7c1YcHbUG//gzMSJJTZ/alz3WThwvIjtT
    idS8iFF3/6rHUzD/jtcaZ1nbGsquEb2JQSEJPSew5ZS0S8U3+gbXCpYfG8PNx1QnJfm2Ft
    pgkeO93PTIHeEUjFLtz/B0GOYhyxjLHHwxBr0+PWJNH+dGjEfqQKxE8vXo/hgjfbNoODKK
    0/Xm2o8Bkdpx7ioKBDyWNa6VlELBkSwZR5tboifejFjj9kBAK/lq8qf0/T71XH2Hh/7y0O
    qknEViIG2iwRIoMUno3HdB6mSYc/XaXzfzqpGfRxeeYx7UK9ERUAygUXq3GEc2fS226cEk
    DTyMvhow+VHEkfBUfdGzj/W0wMqdiR0LDcEtjlDGqane+hpa8UMKPU2BdUPKjWj2cg7wKF
    o5gwafWjQnCA1IgaXSigxq5kATRxjIbKXdZ7VwEeT7ejcz/WbWeb2iMP7vyIaO/ZiDcTGT
    zBfiVhDZfV4T1yc8KQrkOMG9siv8heRUU/ZkqVKdp28CYd2nuLkb9wRmrIVg
X-ME-Proxy: <xmx:nrBZasXeXQXZSlL8G-bWv7BwmBMGNA0SIJb34Lkt9N_4Qs-SyN1G4w>
    <xmx:nrBZahWnLjn-oIXsv6YRFyXtWZrh-v4OvP9adsCDr1Aykojb2JUm0w>
    <xmx:nrBZasgghg-F4PSvVQXovRmK-9Rvjugl2LqPYbz9kaARn5wdqkdIHQ>
    <xmx:nrBZasYb-NNuOM7co58d5C8yBL4BQPEnOuYhmHN4AYoBZpmKp_qkdA>
    <xmx:nrBZahoZ9ieNEuq4ZIYb9cnHEOPtIufQFzulyNBwDk4aZ-66IDQycQxf>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:33:31 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 09/18] nfsd: nfsd4_create_file(): Move NFSD_MAY_CREATE check earlier
Date: Fri, 17 Jul 2026 14:31:07 +1000
Message-ID: <20260717043242.1865905-10-neilb@ownmail.net>
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

We only need NFS_MAY_CREATE check if the file doesn't exist, but it is
nfsd-specific code as it needs to check NFSEXP_READONLY and I want that
to be separate from vfs-specific code, which eventually all be provided
by the VFS.

So move that check earlier, but hold the error status until needed.

The if/else chain here looks a bit clumsy, but it will make a later
patch cleaner.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 8840f6dd8a0a..5e56bf6e6bd9 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -261,7 +261,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct dentry *parent, *child = ERR_PTR(-EINVAL);
 	__u32 v_mtime, v_atime;
 	struct inode *inode;
-	__be32 status;
+	__be32 status, create_status;
 	int host_err;
 
 	if (name_is_dot_dotdot(open->op_fname, open->op_fnamelen))
@@ -347,6 +347,8 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		iap->ia_atime.tv_nsec = 0;
 	}
 
+	create_status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
+
 	host_err = fh_want_write(fhp);
 	if (host_err) {
 		status = nfserrno(host_err);
@@ -360,16 +362,17 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		goto out;
 	}
 
-	if (d_really_is_negative(child)) {
-		status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
-		if (status != nfs_ok)
-			goto out;
-
+	if (d_really_is_positive(child)) {
+		/* No creation needed */
+	} else if (create_status) {
+		status = create_status;
+	} else {
 		status = nfsd4_vfs_create(fhp, &child, open);
-		if (status != nfs_ok)
-			goto out;
-		open->op_created = open->op_filp->f_mode & FMODE_CREATED;
+		if (status == nfs_ok)
+			open->op_created = open->op_filp->f_mode & FMODE_CREATED;
 	}
+	if (status != nfs_ok)
+		goto out;
 
 	status = fh_compose(resfhp, fhp->fh_export, child, fhp);
 	if (status != nfs_ok)
-- 
2.50.0.107.gf914562f5916.dirty

