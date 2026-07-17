Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 08E5B3C13F5
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:31:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.145
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280665; cv=none; b=cU7m6X+R4QQRAOIuB26DRdFtu4AG40Yd6Wo+gQEX6RqPEJgMNmkaW7SQ5InCAJ7fTgM+ctlUI+B7p6VQs+IRIkRLsLthkPjoJ0OnzLKQHiiFBPjoCPP2E6Wrr3e7bb+ILvcBA31kV8WhCtA4peywgGjBFAkzkIuczariY19mZ6Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280665; c=relaxed/simple;
	bh=GLD0KEeQ3wbDzhkPIrT8cC71GROJWRgX0pdEy164IZ8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ZKuUXVK+pFI88+i1hEbblhqmQFCb6fxxam5UYC7G0WpKwjvVWfSsmZmlZcbpMtb8T3CiQoMhXaXDhIvGWOxJdObOjBNtAxodU4qACL5C7KuuC05U3CpKQujV3ndyAwb2X3mGqwjeFmAnn+gXSvk4nWzu5W4RuI7ikEqW8+LgyQY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=TsDlR2v6; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Zh3pdPRE; arc=none smtp.client-ip=103.168.172.145
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="TsDlR2v6";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Zh3pdPRE"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfout.phl.internal (Postfix) with ESMTP id 2AE22EC012B;
	Fri, 17 Jul 2026 05:31:03 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Fri, 17 Jul 2026 05:31:03 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280663;
	 x=1784367063; bh=ZwYNOwBzNNNfq3Q0oxUQ4NdIEoRdzUlCGlLAa4R3QLY=; b=
	TsDlR2v6HR+gI3gii0r+3/xbqDE++dh66+vkb36eqnV2kCoG/PzfLsW3pT5mkEDD
	/KK1gtJhMHip3fKewXhzVcTEVlrfx9+pPnr+8AzI9UUf+KVsGkO64A0FwLblkevz
	C840guz4aMYO6kJ1AtsZZJ/Wl0ynnd0sO05dfRn1c7dQQeu/2IkgeZRP5314P5YR
	szqSfqnMwf0OfZJA2DJszLhDGyQCKhNen/gZXLZ5dNZ+cXiDLH5RnB/YOKPEkY/5
	Y+HfPCI2qz00NBok6BeBXNf4lWqxvwAJM5VVU2Q8oaMXVd2y3TTFj0/w84nh5Me9
	3VQZ+JKt0lpEycEq+lXTTw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280663; x=1784367063; bh=Z
	wYNOwBzNNNfq3Q0oxUQ4NdIEoRdzUlCGlLAa4R3QLY=; b=Zh3pdPREBGtcQzSRL
	aXartC2+ETcRwkOH3TO7J/K0zUv4JvS7bhfH9xt8v78a3f54Dh80eUHLRz8rhIiE
	v4wNvlBL2NU4MomL9nUDt8Ven0YYVSfJ/jy/EJHX+lHPJ6WWuucSrcynN7b9JWmY
	OYsls0OZGLjM/+UyhELhd05XDFvqZ0/r81bP+lHTdkSB2QeI4wIlUEK72+Uqhe0h
	FvfCEasCkDbV7bLKyP4Cn3a0jQ+6sxqUM+R8FB/+UgPDYSpfiFKmPfHTzES2/FZC
	8Asv5LuMeVHKO/LLQQHNtcsFVzd3ShsFaogNikw+Mh6Kdrf0G/v+Br9QgF9qOOQ+
	eMTrw==
X-ME-Sender: <xms:V_ZZavJcblqdMnlO-ExHbenPz67i0-aV-9yHWdNg2LBRtQ12j4jk2Q>
    <xme:V_ZZam1ACCuZaiUMWst9Y4bud7RHa8mEo3vx1d1JjTuulpw2gnS_Y72XSYD9Ktc82
    SXSFLq5tpBqF1hbiQiFqnw39RZAyWKojwR8gNfNbId_ZDs>
X-ME-Received: <xmr:V_ZZahi3pO-Nw4JNbFVM-FZ5ZuSZ3845XkLRmdQFIp-JzbGhrIJnelJ9SQPrZkz-HDinBrRL7IlI0lNXP_MyqYfsOychnIU>
X-ME-Proxy-Cause: dmFkZTEApqFO5jAKqrP3EdbU0Ae0MCQnQFfvSrW+r84mL3qL2UFfbuf83R37o+6oMtcUaH
    6DPJoG+34uUdqXbvR7Bw2l/P4dHaUP7HQXwsVpft7xVFNPuQCF7CPPRrJ8RbY/S97ZLP41
    U7XX1t/FfVPe+wX4TXpm1uyeb7KPzLLiiaQZAxoL0T352PWKJdXBYkCUMqwJ+Qc6GUYgZ3
    Uoo8xLxf76by20kMmFLftmzj5U0bznLrEBN2m623yRBHfn2OKPGMWK6sTxb/HqvCRKz8H9
    PuQ4+q7R9RbgvgWOq6XwvxxK5Vgvb3Gcdtw7XfnM+DdDvQvzx8yPyLi9NGYtfL0WuGqtjU
    KNJzirUa41nFf8ZdAJx0pD0wohzsTWU5ZZ8ShWA5r86m0CyfByufJ0Fjy4cxuo22Fidd7+
    Zzx/XwwLT29efaq/r06qR13CB/FiJ6C4M9o8G91/xXkQ8qpzFiIu5fBGE4vdZ5Rlk8bNuT
    atDIufCz5grbl9jO30ClINTvvJZMNSBC92W9hXbswe/Zjm0VmcOiTk/vbWIR3IosQ8MyNQ
    dr9QQeye7KpRms1LSli4MpI8lz0sN36dsgDWkZhqwHF/ralOID6zdEHM25a8r1Jx6Qs6iB
    s5SYOWSepaNX2qg0rd+lQ5hNuhaSDraibZEan9PwQnyBRtEM3s/fcuyLnUew
X-ME-Proxy: <xmx:V_ZZavX0roNjPq2y0-c7-zHck1dB0FF-8AvaFybZRto-tSGQcUcHtg>
    <xmx:V_ZZaoU55O-4RLjhrh3DRU1NWX8Gkwty9d8jAWu5Qofk9igupdYf4g>
    <xmx:V_ZZangaphtyiamg9KDgI2anaiKatL22F-PLIujmhcQpMRfcjUlXAA>
    <xmx:V_ZZaraLKYYuzpIStAfxh8gIjZh-u_umK_qFWAejM8NqDrqZufmZOg>
    <xmx:V_ZZaooQX7hoN5WoXVD_9m3-axjcLVJ2D8-k0oiIkqPN2TX4sVawUB-8>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:31:01 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 11/18] nfsd: (almost) always open file in nfsd4_create_file()
Date: Fri, 17 Jul 2026 19:27:59 +1000
Message-ID: <20260717093001.1972119-12-neilb@ownmail.net>
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

If the file is found to already exist, open it anyway.  This will
normally be needed eventually anyway, and providing a consistently valid
op_filp will simplify future changes.

To simplify this, change nfsd_check_obj_isreg() to take a dentry.

This doesn't apply in the case where the file was found in the dcache to
be mounted-on.  That takes a different path and doesn't require an early
open.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 39 +++++++++++++++++++++++++++++++++++----
 1 file changed, 35 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a4838d36885b..0b3b358679f3 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -169,9 +169,9 @@ do_open_permission(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfs
 	return fh_verify(rqstp, current_fh, S_IFREG, accmode);
 }
 
-static __be32 nfsd_check_obj_isreg(struct svc_fh *fh, u32 minor_version)
+static __be32 nfsd_check_obj_isreg(struct dentry *child, u32 minor_version)
 {
-	umode_t mode = d_inode(fh->fh_dentry)->i_mode;
+	umode_t mode = d_inode(child)->i_mode;
 
 	if (S_ISREG(mode))
 		return nfs_ok;
@@ -253,6 +253,8 @@ static __be32
 nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		  struct svc_fh *resfhp, struct nfsd4_open *open)
 {
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
+	struct nfsd4_compound_state *cstate = &resp->cstate;
 	struct iattr *iap = &open->op_iattr;
 	struct nfsd_attrs attrs = {
 		.na_iattr	= iap,
@@ -362,7 +364,35 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	}
 
 	if (d_really_is_positive(child)) {
-		/* No creation needed */
+		/*
+		 * open the file so that we consistently have a valid
+		 * op_filp.
+		 */
+		struct path path = {.mnt = fhp->fh_export->ex_path.mnt,
+				    .dentry = child,
+		};
+		unsigned int oflags = O_LARGEFILE;
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
+		status = nfsd_check_obj_isreg(child, cstate->minorversion);
+		if (status == nfs_ok) {
+			open->op_filp = dentry_open(&path, oflags,
+						    current_cred());
+			if (IS_ERR(open->op_filp)) {
+				status = nfserrno(PTR_ERR(open->op_filp));
+				open->op_filp = NULL;
+			}
+		}
 	} else if (create_status) {
 		status = create_status;
 	} else {
@@ -516,7 +546,8 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
 	}
 	if (status)
 		goto out;
-	status = nfsd_check_obj_isreg(*resfh, cstate->minorversion);
+	status = nfsd_check_obj_isreg((*resfh)->fh_dentry,
+				      cstate->minorversion);
 	if (status)
 		goto out;
 
-- 
2.50.0.107.gf914562f5916.dirty

