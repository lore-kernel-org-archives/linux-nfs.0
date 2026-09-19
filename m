Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 274EA2F851;
	Sat, 19 Sep 2026 02:26:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789784791; cv=none; b=Y6BzJ5YoksJu1IPEKzToRHkRju9tgRSF2rsAQ10kDyuDauu3IShMCp6NBp2oAPwwQ12slzaoWRw+Ot3nsZSkynkUc1PlJRcqLHqPJg8l9EtxAO4vtHWLSr50jV8s+ehQF251GH1yTbCix4MN0zaYbJQ6Xz8U4WkO74H0RCN+aso=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789784791; c=relaxed/simple;
	bh=LgM3ek1vRw7FbAowI6VV8Qj/wZEj89St+btl2/eeFdY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=sTV1uZiIFMkjR2PR4w6a13jKtpAwdqzQ6G4g45krAKZ4j/u9jqq0nbTDkHQT1bUdY3Bx/zRPAVeAkUoXNYjKaELy8sDPJ1TcIqZa4RsqQjOWvqCXDrqF3WHDaHRwOoo890izHW+zVX54ZSQJhfTyMgfoXGie9Hqej8eoaLKGVSQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=MuofAQ6x; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=F9+LdOPF; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="MuofAQ6x";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="F9+LdOPF"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 16A5C7A0105;
	Fri, 18 Sep 2026 22:26:29 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Fri, 18 Sep 2026 22:26:29 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789784788;
	 x=1789871188; bh=uAAwhvwdXHtnGFcjTnIg5TE5HaF00IG5RfrJD5pW1+U=; b=
	MuofAQ6xlrNN8OiE2n985mmuD7wqjUkjSjtavkXEp/NUjoPiuijoJ3XvfdW5Iq2m
	7vzRY0e6+r3muvgIILLmFi88x88HAN8jy2Cbtqn328rL5f/z8iYJyJGK94E+d4v9
	tHwJUvDyso6hbWcsLXThay2QsYo1PPGSzLVsgTHAMhBVPDHhoWctXRh5Q2XD/4El
	o2F7z6GepsjJt2gGXDEC3wVJaHSCLORhYiZq4ONXBba2t3GnjLyMZoeFknYHAJUl
	UrvEpcu3ZAGc5i88I5vseIhKkbFABdFuFh7DV8iJOfnT9ptxLOfUT+H+7lDjnDNT
	HjpQK6HsfchcUK10YEmmHw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789784788; x=1789871188; bh=u
	AAwhvwdXHtnGFcjTnIg5TE5HaF00IG5RfrJD5pW1+U=; b=F9+LdOPFSOkTfondH
	N/kZaW8v5EW32l8c/lexBJ4ZjApfO9d3xynV8jEok25b6+G/fFu/pgsKO59lzjyB
	otGDJ9gTzkenSrcIwcmtzDmOry75173wawWG76H5bHBx3KheG1ayDbkMA/C9eS9L
	gaoxbVv3B175Jv/eAIFsNsTlEJw5YrOdo65ym0kubpU0Vw0KNmjoLNKHlfqRCFuR
	+ZMKWCydvgWJxuCd0KM26GgNfvl3Oto1Juslt/aLy9MHouB+Vmdc7txM9oUr940y
	YAO+yCLZnzaVPLB4SheP0r1q0myvLD14T2cw3Bxu7DgEDIXZUq07dxSjysnHvGBx
	XWXVA==
X-ME-Sender: <xms:1PKtamTf1Bk2lvyzt3twkfl80DRpcR7ECga7kA1471yo_Z8PdF2uuA>
    <xme:1PKtasKplbKx11UzgkQhrUsi8UmSnNBvL08ZSogAa9OoeugC7HNLrftlBCGoHKDJ_
    0Lar39McNEVqtmi-rKB2YGwke1etpDWcczK2YIo2Psi_3X-6aM>
X-ME-Received: <xmr:1PKtak-hz7kCs26tyTbFvVLJZ1hrsogqU5VTMqN4wVJluYsPzgrSBV5ODjfZDsYIr-pP1X2PUh2pFbhEu4GOhjKr_HbUghk>
X-ME-Proxy-Cause: dmFkZTGgqDvHUiFoelb3szb25Xc5WIL1X0CmKVd0SSFttbFGm3ZS4/WbThw2/23Wv0kT2L
    zTiD3f7/mbRn4xQkog4u9WXAUu/Z8xbLL7habzJ5iT0L9pvsBxuMoK5k8M+5CBBhCA34Md
    HPlNAQAuPUTpsFoyG9EfHruislsqzF/ELe8vhu1WoHNTpMpKsXLXUP8fPb+iJDnGZK+wxX
    pyu1Y8XGp2Ez4Y8aWvA0+LsWIM5P5beRGa1K+yf2x8AAFZFB+FqQNejpWDyXiPsbkOSKyy
    pf6WO9eid06RPw0E0qVieiQBSzbPbVfHpbR/XZ98dIIyde1pgFtUnUmkW5DtGlTWNRmkeO
    1gKLjxkrYJFvad5f0ECtqEpUvleFXftqF88s+HyJUu3ucTD230GRp8NUIlZoWfXdU8LGZk
    CAKdVcI/f14RzKanmSbKUIawBY5UKNv+05neuisNrJtCfYlU14IVA4amNL6TjwYQ+E0W5p
    noU3bM6b1WGNYxpIVpz0yH3ZfsEheQwqv3zkAbQcLq0ncXemia1L4o1TLXP7fZp07L4Cus
    IvhZoOsjKfXOAs0Qh+GTwtgtsQp+X/sdd0MMjQyfwkF8DSW6sVHzDPkjJhbG6VwKVPgwKu
    1k00sgicijN9YUc+ERj/S1hDhLahCKhrRDzxlmRKX2YN1cf38aAzQk23u/ZQ
X-ME-Proxy: <xmx:1PKtauBZ-nyPIXmjcU7ZMkF5Ixm27Rnmoi_bLrR5YGUrwaLOMSU_PA>
    <xmx:1PKtauqIBtn8KMofDxhRusxXXK321k3PPjUxcqFWq3HYD9U_colcIw>
    <xmx:1PKtanIvPhU3Xl6ejkiKWk41_ZiO65Boq9CAWVxiQRKsvWOHm1gyMw>
    <xmx:1PKtagI9WMkUTWEvxsWSo5YGLBWchv9wRj2mD9JMp84d1p7ZW_X_9Q>
    <xmx:1PKtanHcPGIOY6R-SoUuARPHtrk1xSKhz0D4NNG_3xt_VM9Wi4B3Ozhl>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 22:26:23 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Jori Koolstra <jkoolstra@xs4all.nl>,
	Mateusz Guzik <mjguzik@gmail.com>,
	Dorjoy Chowdhury <dorjoychy111@gmail.com>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	gfs2@lists.linux.dev,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	ceph-devel@vger.kernel.org,
	Paulo Alcantara <pc@manguebit.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	linux-cifs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH v2 10/14] nfsd: make EEXIST checks in nfsd4_create_file() more consistent.
Date: Sat, 19 Sep 2026 12:06:14 +1000
Message-ID: <20260919022441.3305170-11-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260919022441.3305170-1-neilb@ownmail.net>
References: <20260919022441.3305170-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

nfsd4_create_file() has two places that check if an "eexists" style
error is needed - only if create_mode is not NFS4_CREATE_UNCHECKED.

One if when checking the error code from do_lookup_open(), one when
checking if ->op_created wasn't set.

These are not consistent - one tests if op_createmode IS
NFS4_CREATE_UNCHECKED, the other tests if it isn't.

Rearrange the second piece of code so that the tests look similar.
This will make some following patches a bit cleaner.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3a82af381a8d..6e443503d0b7 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -462,23 +462,24 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		open->op_created = true;
 
 	if (!open->op_created) {
-		if (open->op_createmode == NFS4_CREATE_UNCHECKED) {
-			/* NFSv4 protocol requires change attributes
-			 * even though no change happened.
-			 */
-			fh_fill_post_noop(fhp);
-
-			/*
-			 * In NFSv4, we don't want to truncate the file
-			 * now. This would be wrong if the OPEN fails for
-			 * some other reason. Furthermore, if the size is
-			 * nonzero, we should ignore it according to spec!
-			 */
-			open->op_truncate = (d_is_reg(child) &&
-					     (iap->ia_valid & ATTR_SIZE) &&
-					     !iap->ia_size);
-		} else
+		if (open->op_createmode != NFS4_CREATE_UNCHECKED) {
 			status = nfserr_exist;
+			goto out;
+		}
+		/* NFSv4 protocol requires change attributes
+		 * even though no change happened.
+		 */
+		fh_fill_post_noop(fhp);
+
+		/*
+		 * In NFSv4, we don't want to truncate the file
+		 * now. This would be wrong if the OPEN fails for
+		 * some other reason. Furthermore, if the size is
+		 * nonzero, we should ignore it according to spec!
+		 */
+		open->op_truncate = (d_is_reg(child) &&
+				     (iap->ia_valid & ATTR_SIZE) &&
+				     !iap->ia_size);
 		goto out;
 	}
 	/* file was created */
-- 
2.50.0.107.gf914562f5916.dirty

