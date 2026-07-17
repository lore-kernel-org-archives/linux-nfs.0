Received: from fhigh-a7-smtp.messagingengine.com (fhigh-a7-smtp.messagingengine.com [103.168.172.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68D033BB135
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:30:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.158
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280625; cv=none; b=GRDyqn5OREdRdtg4Fliv68mOyDBjM34bceOhffpfWaQ+6/UZJrp0TEYBgRKdQzcE4W1UJFgmwUBi+Jb0T+Wu7dINIL7o/1U43AwUVQLQlJLCn/Wj8/QqW/lfw4FawRpaksbzL6DEvH6k4R7f/WDmzaxtuTOUBBK0K/4FEMXAhFs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280625; c=relaxed/simple;
	bh=VmjtYPtPInlnhuFEFw3CScvRoj7J1cgbjyXab5FnoaI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=nsnPN/nBT2V/eEOAGEsWDsXAOvlTVXVmMY/MShCKnVGgg+niqdMBoLh3yEmUhspqcSUljh/Lfd8kAvdv+K0D5XSevlDG9BmZ2dDjBzANNPdSHh32OnfwWFp/QFLfxq7mLdi+hGFaPj/raegiY/zyj+q4jH4+iF8xNUMo3lb0XjU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=CvpbWTZF; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Nzf7MUzA; arc=none smtp.client-ip=103.168.172.158
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="CvpbWTZF";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Nzf7MUzA"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 82DD21400075;
	Fri, 17 Jul 2026 05:30:22 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Fri, 17 Jul 2026 05:30:22 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280622;
	 x=1784367022; bh=X9i/BGGLUU5cerX5nQnokgW/5e0xkO8WJDIHEsEFH9A=; b=
	CvpbWTZFtFfS/Ny9sCVfsLgQcTvExnzHXNGCb1+IfWRo4GZdbYQlYRKPPx1S4AL2
	8ySZqcklMuhJrVBQ+UERiMKtjRH6/HubEnRR/frtC6zDzbTalX5XcdAycbKcnAMp
	5qDA4yE+CmaA4y9Tz2pbG/flfIyIvzFmIQMHKR86ljcW05bgBv30Ja8eKujOlUN/
	IsKhRWuDCtu8sBcllUj3B3dpV3bjfeNr8VzNIXJHDfpfFx5BM97HhBE6PqvdfqPK
	6pYrrufiGVc9azmS3bkJq2zeACSALygGVPx8CLJVJzInG8Hvi0uMcSExxCh3yvQR
	Tnc9m7JPO4LdgoZ5w3r+8Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280622; x=1784367022; bh=X
	9i/BGGLUU5cerX5nQnokgW/5e0xkO8WJDIHEsEFH9A=; b=Nzf7MUzAGUyHIr7ou
	6TlPiY1//qxsFUQVoDBxPmgMWvcjB0EAC6dvsMebZ6F/Wr6ms/nYSfBTTvZoW8P7
	+j/K5vrLrIwLjiFG+qEqyZRsKHuUQGZAOgTSrXcbdIb9p2M+WfU1GoFiIvIKkTNh
	p+VNMKLbbtofzgHLpM2whdaL90qREnH6jpWs1FK+X+MrqS3SPTk1bBbPOayLacTy
	pRiA+ZfvDYSyCqL2GXHxNOiTXm4s+Mnfbhzzap2cqzXOx4M7Ri4svvGtlborRexZ
	mNjg0cmTZ6oxGacpSXg+HrCRyRShJnLW0v6l0SNQya6zF3s24BeemV0+qBxeEoZo
	HWxAQ==
X-ME-Sender: <xms:LvZZagUHdHmw6AZXGpGqbwOOylggz5bBK7PqdOvUX0FThlqKH0BTug>
    <xme:LvZZaoS8wrofOCmbKYnFxg_YQRq0gd7SpEQztx7N2hn7Y9RLKSHuTQJbkgfBrMG1S
    BszTS8dFqlcglluMEjyfkkqasGNLye0XCTYUlDjiwnXxFKV6g>
X-ME-Received: <xmr:LvZZauM2vAQjjXlhmkd19xUmWbs0KtusUWahkOsJe59372xpDPotx3L5soPTT44lo7qzJNeiULW-4Y84ogyB_9ZnJ6-VumY>
X-ME-Proxy-Cause: dmFkZTFLeSmY3ixqka4KlC55qBsg85QSOzArahO9pcWU16vwhY9n3pLhloq6nxziJTlbtD
    5I5Spv/mTk7NcsBoklkoQIDZfGVxmAyJtIAm67t6RtGKLq14Ycl0M7zPAnkMAVyCcYO01J
    Cv3ufQ2tqFOsLlvTthybtxgnz1zOULUZj4roEAw6aPfkifJXoKqRdWsB7ob1/FEfoEvPGv
    iSz1f7AmIp05QUi4Zn68d4pjboG3+xxkxhDMZvZrdVqX5npZILP2jnw2bUIaCSrbjh6p6l
    i4/sgZlPPCH05Qt3wybld8/7pkZttQjOTO7irSmGRWljSe7U/ma9CRxQdqzl/F3bok6OXm
    qSDYwcY82hB1vS5OFZXzSrFw8O53wL1p8A4+PiaOiEilmYSjwbkcy9x9RTDbC1gd+vOVS+
    XtfFKDMom9dIgLORPjw2kZirN9zs1lLPsdR4UUHBMTs+I1Vzqk3VLUk2bpaO1ZpBSA2uMB
    E7NReP2zkyNgEzexliWFY9RKk/Tb2Hrb/nC7wAfwhWOikI6+Wd5tYrcFtAtfu95VDeWBQG
    lqag+ZcGWBmNvFXoiIuWUkJ1UYrFYyhwKD8LGOcZYuewy0gx+B2auyWpUn4lixosCrlrXV
    VOnlJ7PnygVSZl+3E0bF037qvpA3jKQ7AeDNqwjfe55WPniAiyoETMP86E2A
X-ME-Proxy: <xmx:LvZZamTApHQGblfs0lkvvUdmUGXZMB0Z4tJ1v0PZ7YILaOgNBWAVXw>
    <xmx:LvZZasiRpSk3czqXJeb-kA4Nz2ihks5hEPRdc5GoHF-7L_L07pkouA>
    <xmx:LvZZav_gCODrR85Z4_GaPSlukB8-YVvk9C_seDAFtvgvW8GTwjAjFQ>
    <xmx:LvZZajFdCfkk3uoMMOB8ace_EDiYAAjO81NfOLHjCZj7VCbNyW_R3w>
    <xmx:LvZZal3wY3ttIRW5qiDvutG9IH55ZPrE-Z7E6hcTTGbmUAyVy20OBME7>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:30:20 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 02/18] nfsd: move check_nfsd_access() call into nfsd_cross_mnt()
Date: Fri, 17 Jul 2026 19:27:50 +1000
Message-ID: <20260717093001.1972119-3-neilb@ownmail.net>
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

Whenever we cross a mount point, we need to check_nfsd_access() for v4.
So move the call into nfsd_cross_mnt() in the place where we actually do
cross.  This avoids the possibility of calling nfsd_cross_mnt() without
the required check_nfsd_access().

Also remove the last arg from check_nfsd_access(), which is always false.

nfsd_cross_mnt() now returns an nfserr rather than an errno.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/export.c   |  6 ++----
 fs/nfsd/export.h   |  3 +--
 fs/nfsd/nfs4proc.c |  2 +-
 fs/nfsd/nfs4xdr.c  |  9 +-------
 fs/nfsd/vfs.c      | 54 +++++++++++++++++++++++++---------------------
 fs/nfsd/vfs.h      |  4 ++--
 6 files changed, 36 insertions(+), 42 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index a47c90f40422..5aefb388cc27 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1890,21 +1890,19 @@ __be32 check_security_flavor(struct svc_export *exp, struct svc_rqst *rqstp,
  * check_nfsd_access - check if access to export is allowed.
  * @exp: svc_export that is being accessed.
  * @rqstp: svc_rqst attempting to access @exp.
- * @may_bypass_gss: reduce strictness of authorization check
  *
  * Return values:
  *   %nfs_ok if access is granted, or
  *   %nfserr_wrongsec if access is denied
  */
-__be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp,
-			 bool may_bypass_gss)
+__be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp)
 {
 	__be32 status;
 
 	status = check_xprtsec_policy(exp, rqstp);
 	if (status != nfs_ok)
 		return status;
-	return check_security_flavor(exp, rqstp, may_bypass_gss);
+	return check_security_flavor(exp, rqstp, false);
 }
 
 /*
diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index d2b09cd76145..117fb28db1e0 100644
--- a/fs/nfsd/export.h
+++ b/fs/nfsd/export.h
@@ -104,8 +104,7 @@ int nfsexp_flags(struct svc_cred *cred, struct svc_export *exp);
 __be32 check_xprtsec_policy(struct svc_export *exp, struct svc_rqst *rqstp);
 __be32 check_security_flavor(struct svc_export *exp, struct svc_rqst *rqstp,
 			     bool may_bypass_gss);
-__be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp,
-			 bool may_bypass_gss);
+__be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp);
 
 /*
  * Function declarations
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index bb99ab6b78b5..0317ff3f1c39 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -3328,7 +3328,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 
 			if (current_fh->fh_export &&
 					need_wrongsec_check(rqstp))
-				op->status = check_nfsd_access(current_fh->fh_export, rqstp, false);
+				op->status = check_nfsd_access(current_fh->fh_export, rqstp);
 		}
 encode_op:
 		if (op->status == nfserr_replay_me) {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 606ddcb085c0..04755c41d871 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4574,8 +4574,6 @@ nfsd4_encode_entry4_fattr(struct nfsd4_readdir *cd, const char *name,
 	 * directly from the mountpoint dentry.
 	 */
 	if (nfsd_mountpoint(dentry, exp)) {
-		int err;
-
 		if (!(exp->ex_flags & NFSEXP_V4ROOT)
 				&& !attributes_need_mount(cd->rd_bmval)) {
 			ignore_crossmnt = 1;
@@ -4586,12 +4584,7 @@ nfsd4_encode_entry4_fattr(struct nfsd4_readdir *cd, const char *name,
 		 * Different "."/".." handling?  Something else?
 		 * At least, add a comment here to explain....
 		 */
-		err = nfsd_cross_mnt(cd->rd_rqstp, &dentry, &exp);
-		if (err) {
-			nfserr = nfserrno(err);
-			goto out_put;
-		}
-		nfserr = check_nfsd_access(exp, cd->rd_rqstp, false);
+		nfserr = nfsd_cross_mnt(cd->rd_rqstp, &dentry, &exp);
 		if (nfserr)
 			goto out_put;
 		crossed = true;
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 8923a9910a08..7898af35874b 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -118,15 +118,15 @@ nfserrno (int errno)
 	return nfserr_io;
 }
 
-/* 
- * Called from nfsd_lookup and encode_dirent. Check if we have crossed 
+/*
+ * Called from nfsd_lookup and encode_dirent. Check if we have crossed
  * a mount point.
- * Returns -EAGAIN or -ETIMEDOUT leaving *dpp and *expp unchanged,
+ * Returns an nfs error leaving *dpp and *expp unchanged,
  *  or nfs_ok having possibly changed *dpp and *expp
  */
-int
-nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp, 
-		        struct svc_export **expp)
+__be32
+nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
+	       struct svc_export **expp)
 {
 	struct svc_export *exp = *expp, *exp2 = NULL;
 	struct dentry *dentry = *dpp;
@@ -134,6 +134,7 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 			    .dentry = dget(dentry)};
 	unsigned int follow_flags = 0;
 	int err = 0;
+	__be32 nfserr = nfs_ok;
 
 	if (exp->ex_flags & NFSEXP_CROSSMOUNT)
 		follow_flags = LOOKUP_AUTOMOUNT;
@@ -163,23 +164,28 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 			err = 0;
 	} else if (nfsd_v4client(rqstp) ||
 		(exp->ex_flags & NFSEXP_CROSSMOUNT) || EX_NOHIDE(exp2)) {
-		/* successfully crossed mount point */
-		/*
-		 * This is subtle: path.dentry is *not* on path.mnt
-		 * at this point.  The only reason we are safe is that
-		 * original mnt is pinned down by exp, so we should
-		 * put path *before* putting exp
-		 */
-		*dpp = path.dentry;
-		path.dentry = dentry;
-		*expp = exp2;
-		exp2 = exp;
+		nfserr = check_nfsd_access(exp, rqstp);
+		if (nfserr == nfs_ok) {
+			/* successfully crossed mount point */
+			/*
+			 * This is subtle: path.dentry is *not* on path.mnt
+			 * at this point.  The only reason we are safe is that
+			 * original mnt is pinned down by exp, so we should
+			 * put path *before* putting exp
+			 */
+			*dpp = path.dentry;
+			path.dentry = dentry;
+			*expp = exp2;
+			exp2 = exp;
+		}
 	}
 out:
 	path_put(&path);
 	if (exp2)
 		exp_put(exp2);
-	return err;
+	if (nfserr)
+		return nfserr;
+	return nfserrno(err);
 }
 
 static void follow_to_parent(struct path *path)
@@ -277,10 +283,11 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		if (IS_ERR(dentry))
 			goto out_nfserr;
 		if (nfsd_mountpoint(dentry, exp)) {
-			host_err = nfsd_cross_mnt(rqstp, &dentry, &exp);
-			if (host_err) {
+			int nfserr = nfsd_cross_mnt(rqstp, &dentry, &exp);
+			if (nfserr) {
 				dput(dentry);
-				goto out_nfserr;
+				exp_put(exp);
+				return nfserr;
 			}
 		}
 	}
@@ -327,9 +334,6 @@ nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
 	err = nfsd_lookup_dentry(rqstp, fhp, name, len, &exp, &dentry);
 	if (err)
 		return err;
-	err = check_nfsd_access(exp, rqstp, false);
-	if (err)
-		goto out;
 	/*
 	 * Note: we compose the file handle now, but as the
 	 * dentry may be negative, it may need to be updated.
@@ -337,7 +341,7 @@ nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
 	err = fh_compose(resfh, exp, dentry, fhp);
 	if (!err && d_really_is_negative(dentry))
 		err = nfserr_noent;
-out:
+
 	dput(dentry);
 	exp_put(exp);
 	return err;
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 4af2ff9e9dfe..5554878781f4 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -76,8 +76,8 @@ static inline bool nfsd_attrs_valid(struct nfsd_attrs *attrs)
 }
 
 __be32		nfserrno (int errno);
-int		nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
-		                struct svc_export **expp);
+__be32		nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
+			       struct svc_export **expp);
 __be32		nfsd_lookup(struct svc_rqst *, struct svc_fh *,
 				const char *, unsigned int, struct svc_fh *);
 __be32		 nfsd_lookup_dentry(struct svc_rqst *, struct svc_fh *,
-- 
2.50.0.107.gf914562f5916.dirty

