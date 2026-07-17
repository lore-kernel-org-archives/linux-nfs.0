Received: from fout-b1-smtp.messagingengine.com (fout-b1-smtp.messagingengine.com [202.12.124.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4040F2737E0
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:33:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262783; cv=none; b=SjVXBQQTOk1Owy/wveBlfRFN8qBz4vF71wtp/j50t0hIBsmCx71uPUPDWJZPKQOD20CLL9BtRWQ1ZuAvuaW1oSDJA+c6WOKy13dD+YkbdNfpMrVHbmn/4724oSoC6xOyn1VufY/qjWlFuc6tpvRDer7SgOylsoX/jPuZiqJMtV8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262783; c=relaxed/simple;
	bh=VmjtYPtPInlnhuFEFw3CScvRoj7J1cgbjyXab5FnoaI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=NY9AiOeoCHmKcHsnTz0xfWpXPVHNRxrf7HwIZbMgyfbEDsYkznafZXCecwC/oMLSF43FNjJsGbZNS0D81zMcRGlOm+pqauRr3+ZOd6LLrSIRDsCKUko6/y9cZwYkXWInYgNLDSfHGXscV1i6zooygU+9k4AYHhdlGgT3MeZpkKY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=kYaZgYN2; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=UwbmMogW; arc=none smtp.client-ip=202.12.124.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="kYaZgYN2";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="UwbmMogW"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfout.stl.internal (Postfix) with ESMTP id 3C60F1D000BE;
	Fri, 17 Jul 2026 00:33:00 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Fri, 17 Jul 2026 00:33:00 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262780;
	 x=1784349180; bh=X9i/BGGLUU5cerX5nQnokgW/5e0xkO8WJDIHEsEFH9A=; b=
	kYaZgYN28Lnok8cspLnTt+16KzZ8vdEQ44ipihnNFuuWIvp4dGlCZS3SnbR3rDXu
	fHD63Kb2/WJY/LcSQVo05PJzs6SHh3YwVtt8/U4AcMhqqNUG5NoMnbTuwexsZYs9
	BZplceYz2nbHsAu36fHM2ut0cEoWd+0efCaOLLKy3ZfSRnX0OEtyhPXk0aLyXQRJ
	yqWNY7/S4WtWndViiaDNUmRXusCxM1Buwb+T5sGk4fBJn+yEa8WjfVMqB2eCq6IV
	u0hZ8zJyj/JJkNcNe45RsZZyowfCBnyYZguNUdOuUX6pvAe0A6PJFWzSp46V5+aB
	gKg4HN/oue/I3AS+UtWBvg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262780; x=1784349180; bh=X
	9i/BGGLUU5cerX5nQnokgW/5e0xkO8WJDIHEsEFH9A=; b=UwbmMogWCMJmWIuh4
	EEK29a9/kndmo1wTyK5xtFl60eJzErXcLkZdZOvqWfRXEgggEZF+WJUcsGqTjX+W
	9MrDKeVf32SBCZvO7pzyE5cyOrugmZbsBE366WfyWafqtOPho8fROiHLtb/uqUhB
	EnVQ+geGO3eGexMHdPRX8HTJHBsvwbeZ0DV/sDPRCwPK/n1Uzg8hyNJ/tc0OM9TI
	w7PyDtYApYHUyVR/juL1JSsrd1YG+rSIHvkGNEMO3Fb05RVd9kP8UF8xm5EHNlOg
	YbDMBgR+wXnomPrVkoXziw7yU7Bn1uP2ZB/BWZOvoh9JeCazH1+wS2FYzHx23Axf
	tpYDw==
X-ME-Sender: <xms:fLBZavWP1EPon9QUNUyFaqIkPiwk2JYgrlGmq85VU5KRJdWxG-2PnQ>
    <xme:fLBZarSqJP4Qm0PWRLDvu6V02mqH54zITrwJvPKS3CzYme2UrIQb9X9DMZRXj7Lv9
    DvNn_KfYjFgY_wkgaahPjxMQUwi59x4ZdI38IKHz5XxWrPkTbM>
X-ME-Received: <xmr:fLBZalPBreU3jubzWJsOYc8gqm53sK2HW2gGj9rtYyVHJeAkz6c4LurngswONHPQ_DdO-f2-ELBItq8XJ_x_5i50nMd3OXI>
X-ME-Proxy-Cause: dmFkZTFf1QU68ccbCX8W2k8Y1nGREK2lfBZ8muLx/9jWiTseOaEvZ5XgO1veuwpDDLDOh8
    GTBUmiRJRPyTQkIt2BUTpACGqxcYNQqe9Tcjx6k+JMfW40TZxrio5AhHmqjioKB7znJTir
    ATb1v/hlECnvAs6heOVcOHOlHDBfVnNe9pooX5hb/po3RqsBkktpkbuLKQfQYMMzr+JzB9
    /njxHQoF8AY+jho0jMT1tubTiNoCuayOLJLgFmAfFIsropGRO+BVYqdpkyAIA5dLkXTXCV
    Ha4vNgb6VzTYvk/ZKP8hUsX7dik9VUXtlC+e2jQNq5KVv1wL7YMoKmhY7BOqudAWlfzymD
    bpdYmdhqk85mNb93qtJzvNHZtBj2rYdecqlq2X2cdt3Ysfiqk1GHNzy0dxtR5r0z5BUvJI
    ZD5tFDtXyGZFdkqqVlRWaa/SNnvP8w3y59hPJ/6917u60hi78Gfsif6SmQEZ/JaIeIhifu
    V7nrDO+RYWy4+dH3JNBjXt1vfv9djuwXNRiZJI6SzUNu3wg0I44IhJ3foXHvIyfdiwlcIu
    u7mB1UPqn1scM289Y1U3XAiMupzPUBJx3OhGt9TCM/5An5p9vKzRCRiowFqUG4hGmcjiXg
    yZe75/ldKMfKjixa1k/XwdpH/O7J0Hvb1WiYpq7TVElU3q/jcShzZeQRJLCA
X-ME-Proxy: <xmx:fLBZahRSHf1DKEqGxBIlldKNvw3D73wf3S4xweY4W9SmdoHpg19dSw>
    <xmx:fLBZari5H4Z5wGtqeXXhsd-973YpIv_4p8239vOr-cAxObiPRW3wjA>
    <xmx:fLBZai-CLfFjTBtNA7GBH_B2yHu-AOaa0VXNnIi9Apk5Cd7g44xLIg>
    <xmx:fLBZaqEes2YGhrLDjkrg0Z9H8SeotniH5VR9GlKzXzhTVkGyeUPV_A>
    <xmx:fLBZak0Ff9EUTPjMjvB5kt-VCVU8doPViIWCxlqcHlsBGS_b2Obet3BD>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:32:57 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 02/18] nfsd: move check_nfsd_access() call into nfsd_cross_mnt()
Date: Fri, 17 Jul 2026 14:31:00 +1000
Message-ID: <20260717043242.1865905-3-neilb@ownmail.net>
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

