Received: from fout-b1-smtp.messagingengine.com (fout-b1-smtp.messagingengine.com [202.12.124.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 97F5E34F259
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:33:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262828; cv=none; b=akh/grtYz4gBZpAe6TnU5wnGKqRtg8HGpRegTN+rOITiU+k1mrLKnhx7Q+SG1NRsvsQCx8z7yt7AwrwrhiqouqJ/HqRjo4AlGsQflPJwa7FjanJJ/09GVbLaSn1KNUzbrzH/9NPsCWZVDjX5EYCcd2yI9Auo5x/OZDlbVEpJs7E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262828; c=relaxed/simple;
	bh=GLD0KEeQ3wbDzhkPIrT8cC71GROJWRgX0pdEy164IZ8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=knfll4DBJWn8ab/XTf+cxESbrJhQFf+wV9Wowt5En7msTS0Hbz1lpoiCJsRyvxTiIKfBm6WPo8WU/HreLyUK7IHKc/DxCU80k+C0gjbr52RlBUeSFLUTFfpzPseIEXofOlTly8z8VUXZbxjRQGCkUpZyEI9X+MdNSsY0ne3sYHE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=FzLyag66; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Yoxvre96; arc=none smtp.client-ip=202.12.124.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="FzLyag66";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Yoxvre96"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfout.stl.internal (Postfix) with ESMTP id ACC871D000BE;
	Fri, 17 Jul 2026 00:33:43 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Fri, 17 Jul 2026 00:33:43 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262823;
	 x=1784349223; bh=ZwYNOwBzNNNfq3Q0oxUQ4NdIEoRdzUlCGlLAa4R3QLY=; b=
	FzLyag66gIAUVLgpsuXfWHdppg7COwqnYTPNs+XCuLkNIUVMvkLy0g2rBjktSiJG
	LXENoUMAlqwRrgzgkHAYFhirF1m6i5233rhEPRvh9LYsXA5zJ66XsiY4IaWT3mYG
	0XefWdrRc6LF+f7puIt8wn67YIxQlzQ2iM9qJ+gn212QLfV7ILz8zLe/sSMbsEIW
	g24/HQbuEfHEyYP2Ot8ckkYA2+Y1tRVkMkP6UEGtXcXtXmdFIL2ATt7lUQusSZGm
	qZZf4SGMoEHk2riL84Tt+vAy19w1nTfo04FLunIO2O85O8HgH8wCO+Zzy7Mk/qfH
	0ZJ37V6HE2Nmpe1yhHDWMA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262823; x=1784349223; bh=Z
	wYNOwBzNNNfq3Q0oxUQ4NdIEoRdzUlCGlLAa4R3QLY=; b=Yoxvre9646labbkPt
	BVEcT7ki+t6fAxNDVzG5zcZemnabVlGD1srPD7tAlNnRDYWYnnYyx+rIm9iT25gd
	GbwrR2qci0Z2XsH31DhbPRNCZ6G6DaVMyvxEmkuz8/DXCuqD3ct4YPSpZ3pwEaKc
	TMlxAmFmKsKJYOjaAYhQzjcTfUQ1GgpLBa/bzCMvOu/TXSnovf+NlK4J4fpbaYoK
	LgixUEKXC97TUAGIsCZhIL44kyVsq5kotmS+OETcE2J26vQWympIpvutM4I65aaT
	v6x+dJeKPmbv60WiIDdukPTfoZaSgy78cZMU/2YMpfY0foyYt2v8ikNFPTxCjyqp
	MFJ3w==
X-ME-Sender: <xms:p7BZauiB463McAVEcPa33KILvOEtFpdzTsFyCsUyrqmgTcoozATuQA>
    <xme:p7BZaisB5lntoPGYgNc9grlDegJZoE47jzTrOED_uZSqOrTf3_DwidrH-gLmS8rvf
    jYnNNr_d_oJiYHKqhP9w_7U-GTBxwi003Y9hYm4OEs8Nz2h1Q>
X-ME-Received: <xmr:p7BZav57YpK-axodO_sgNlkDDqbTOLHBMKtnvdr6rrfY91GTRNQmUgATpWT6UAc3WtO8sW7NxkFV09W8Ak4sfDrhF8LpK3w>
X-ME-Proxy-Cause: dmFkZTEYbV/O4rHrcG2pD7g+lcRX3B/+gNPg2GmR980GEuAuHei5en8xSXbHzI3CGul9WZ
    2wyTVMqKjH3Gwr8l0bxq3+gJYxAuCaKsWNQqLRXWJMJ4PsRsuumSSsv/v6MJO7XYC6xpIa
    vcnnDVTuUuMQk5cAowe2NwKaJfSCnmBAw0ipwGptG+ww7YtnuPy4gDHn7ZdBpl0ZsZpkwP
    MnyIuVgfV+AX6SJU5C/DP56d1Wt/NDzA2IXtopXrm9Sb4Kn913mOAzz3mkvTJArWN7bgvP
    G7RfvyjNaPhNpWwcaCH1o0rbK0rNbwsgX9TYV1xS3Iq3WSAnK9mVoidV/lV9qVPcqwMrcr
    vkQObD0pt1eJTHBiZybjrZ1OYgPvHLvTyXg32vV9Bsq/rz0sg7vB1/nFcBOPX8nFOTYcnD
    nAo04SFJgpm0/5RKVMJ8/L+DB04rpFWpktrNVR6qdwcwqVbixkRn0R7fiObwQ6NiQigAaG
    +LrE8ino+53tcnWcngamsGaoXwU6+iDGymY2/t8UZgb/YFTfGqro5ldkZS3pIRCuFDWb2y
    gAKbHjz9vBjNoEB+HB8HNyPx3M6DG5gQU1TMhSqegqvRA6WFCQcs912ExIpeSZq4aI2tnp
    7Y+GlpPJ63u8XdYy8SS3r/wUlcRDnwXPQJr0O0KwlRhpg6CBsm3hkTxLe38g
X-ME-Proxy: <xmx:p7BZauNuakXRBML5wtF0tfGRdN_qfQQmbkPBOJNhfMWylsY0NiUoWQ>
    <xmx:p7BZatv3qqdPW13H76TvhJplnEs9_GRO3xDJ0Rpy4KXaHH40Bja_nw>
    <xmx:p7BZahZpjvUjev0SV2MKEk_eBA4ymY1AdZrDeGQKOGOkjgavQeGkVw>
    <xmx:p7BZavz4XIKyMRMF_XXBRsTjfOkHX0uZ77htj0F-5zqVeUt5ikFx3A>
    <xmx:p7BZagDFIZm_UcTc7uv1HvWkL0UsDtrr6LnT0e4kNInaxKdSkNJU4YYG>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:33:41 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 11/18] nfsd: (almost) always open file in nfsd4_create_file()
Date: Fri, 17 Jul 2026 14:31:09 +1000
Message-ID: <20260717043242.1865905-12-neilb@ownmail.net>
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

