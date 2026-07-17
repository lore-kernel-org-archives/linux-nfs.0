Received: from fhigh-b3-smtp.messagingengine.com (fhigh-b3-smtp.messagingengine.com [202.12.124.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DBA2619C556
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:33:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262792; cv=none; b=k/Pz8doc1b7CrZk4DOFyexPJ7apExsYYvbDnEHPDpJGZK4lManwWQ0rUjsC2vud471CZx22eA3nmKks/yZqcTVTu1CVRHa7k2p3WCRJ8sZTE6vc+DpX+BeeOJXAnfLbUi6Ye1EZdbr3ZDHBH2lgMeR1RCtM05dFvg8IOzE/wksE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262792; c=relaxed/simple;
	bh=6y7UJPmgpHGRonUbF/XAZ5j3QGhs3Hdq5qDsoaZ9NYo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=C7E+QX1AFsJ08s3A/kYLzWbmbsmh4aeZ/ocX3p86TAv6rzBbNBVYYXa02eVx+AlkaX0uUzA1mFf8qM3AtSWDAt0iJYdz51sB73etUDdgMh0T9xhaqFwH9bEoo0VXEfXJfKnN8fIqmtdQ1j2au6xtg3s2Zb4ypvNWMv2UyJFML60=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=IM7BXf7d; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=jsfUGnsc; arc=none smtp.client-ip=202.12.124.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="IM7BXf7d";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="jsfUGnsc"
Received: from phl-compute-11.internal (phl-compute-11.internal [10.202.2.51])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 0E1817A009B;
	Fri, 17 Jul 2026 00:33:10 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-11.internal (MEProxy); Fri, 17 Jul 2026 00:33:10 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262789;
	 x=1784349189; bh=JhS8C8ewb5yVVJQVq0EGcXl4M50bjK4/3bqumHDfA7U=; b=
	IM7BXf7dOHAgyrvqTS02kV5gVKFWYO7CM3T683aF04Aa2tRngeg7AerV9ANgwsar
	onPzfc5lKwfBuT0C6qZ+MAe/1LJZjRtBLriPVW2eMmek2Rx/YomeoNu4DPOgGRjJ
	wr+Pjm8hZlbDDYdxVqR7bLq87s2xY/5G7KyyRIEHfRmZA1PSnUlV1brqLK6HfD4v
	4QgV3ImwKKAuQ3GZTD5bi2iAKd127e7pEHrGlleE/Ct4pC8iLB1S+yngmnZEkZkT
	eYtCLiVww6NQz/dEf5+eDMlP8FkwROOctz8QBn5Yk9meUg6KcVK7Eb6CMP9RGS7e
	2DIMO8fdiQXvQ+8KodPm4Q==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262789; x=1784349189; bh=J
	hS8C8ewb5yVVJQVq0EGcXl4M50bjK4/3bqumHDfA7U=; b=jsfUGnscSCUV15ZLj
	ZBSOGsYSYKfLSPvwEm2iqKOTb+vYj80vCs27BWwu5k08hJ+cMrTDmQoBbi12/zVf
	nTBrpDVLRJmezvEle8M0kyDzMxle9/edXpJf8DDF/W1KYKitiNUH9gDKUUX+LzPg
	tSoMoFdJV1lCMi1qQsWB03Yd8UfGWd+BDGUV4m3aPHa3XKebrIOEQTHWcSCMQS4O
	oAmOFh8Oqxr9ZqT07Ww9yLX+4rtRz6eggnGlwJOYB7Ozr0jcZ94HXz/l2G5/R6DJ
	OA8F1W4L8FDr8lsr1dL3vQwmGDxyOaCEsa17APlcKgkgqxpm95q2o7Ecw9t3L5BO
	zbTYA==
X-ME-Sender: <xms:hbBZarH-rbpU1Xk-izY_e_IBY2fO3Tx1TjiLwzBF7SKeJL8838c5wg>
    <xme:hbBZasC4hQ9LIV9J9mx9zUrEDY0ZGdmQVx9gf_w2TLIdY9NTPzlhCE44v1jRgRZre
    1Cj2vkPEEe3HnkWE3pBvcNXg7ITDmT6PVSaY1LJgD6CCOCADQ>
X-ME-Received: <xmr:hbBZam-Er9mMdVhDZHgOBhZBtWpbffC8wfoJLhYdMmR6Ea02AEfbhUuLaFckmfolDY6spAI0f2UJrFE88JAPQ-tH9reS9nA>
X-ME-Proxy-Cause: dmFkZTEM58T6k0FdKde3vqXstJh4TNGQx0aMkXSf6W/Bm65owkFToMup52zfElxqwg8+mK
    qceVNcN+nXpnr9GL6vAG/PisJgB4fMGdXB4wRESqVAnXADljTNPDP3I3NSrU7YgMBk0Q9o
    6yR8EaQKD7SmBxaw9WuXnA5jauv4ECI4pSpLMKqki9gz5w9ejvx9oB+y/MDPi8NaHr8xd9
    YCkKinrFCYly+TDzg6lIHRyvqsE/SorLMIXYb7WoKI5I3R/fRnuPAyuaHR/+mCKvWPWY0z
    bMHH30Zsk3wESgY7pWozq9NE0B1RkGrQNoJNby3C8DesCkKaupJuCL44Ugwifo+9F4PhV/
    3YP8cF+aSNSdf6JE63hi7WJj1mVBm7z0UqyszRVRBhIZWX+l1bmm/WS46qqLLjYfTD/HkG
    BFhY3gX+bWpHXPQIJ9qNcr4JRlN2Q93XWPIi6kagi8ZEb6Wy1iFRsalNv+966mBnAHMCTQ
    C3x9eX41D/k8LTnq4TjfQduBJZF4Gu42VR5veslqtOOJhHmLRlaHV4OKhrnDuudh+ho74r
    fJ3yLinZDN2Hcs6De0hhKIHqHmm2ZUsoiTdfpjdUVNemnBCiFuyS3EkBux7wX1uhcZBxDF
    a1Z/Fyv6Q6Yv6Yr/4wbmKGr7jTVcYtovWcGK9O5uVbpREY5B8iU7D94r2Jfw
X-ME-Proxy: <xmx:hbBZagCN-Jy-lRAOj6qzNlg7BRz6zn3DRUJ3PFJ62XOpTRsLKXBKMg>
    <xmx:hbBZajTY94aQjocvle7FpQ0AyPHRJLNtm1lKBYEHhG4U6hsWVyJ0Ew>
    <xmx:hbBZavvk5RrkvEz62fIZbSGX11UrG5D46GHqZxogVMxxJoLlxT5ahA>
    <xmx:hbBZan13CM8SU0WoZRy9fi6p1VGN46J8hAjxqTrHzaOcixnXK2C7-g>
    <xmx:hbBZagm3szA6dTbgNFOA8J7skZtFwsk3eLVweERDCII2QdIaiIq22--Z>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:33:07 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 04/18] nfsd: replace fh_fill_both_attrs() with fh_fill_post_noop()
Date: Fri, 17 Jul 2026 14:31:02 +1000
Message-ID: <20260717043242.1865905-5-neilb@ownmail.net>
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

fh_fill_both_attrs() is only needed for open/create and is used in the
case when the target already existed so no creating happens.

As part of refactoring this code it is changed to call
fh_fill_pre_attrs() once early on (so errors only need to be caught in
one place) and then to use a new fh_fill_post_noop() when it is
determined that no creation happened.

fh_fill_pre_attrs() now stores the attrs (which it had to get all of
anyway)_ in ->fh_post_attr.  fh_fill_post_noop() simply marks them as
valid.  fh_fill_post_attrs() replaces them.

This change involves moving fh_fill_pre_attrs() out of the inode_lock on
the directory.  This means that we cannot provide "atomic" wcc data so a
new fh_fill_pre_attrs_unlocked() is provided which marks the attrs as
non-atomic.

This is unfortunate but inevitable if we are ever to allow concurrent
updates in a directory (which can significantly improve performance in
some cases).  To get atomic pre/post attributes we will need to be able
to ask the fs to provide them, or to request a lease on the directory
for the duration of an operation.

Note that we haven't provided pre/post attrs on WRITE requests for a
long time for exactly this reason - we cannot lock the file to get them.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 23 +++++++---------
 fs/nfsd/nfsfh.c    | 69 +++++++++++++++++++++++-----------------------
 fs/nfsd/nfsfh.h    | 14 +++++++++-
 3 files changed, 57 insertions(+), 49 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a13dc1756b1b..6e02976484d9 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -285,8 +285,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			if (status == nfs_ok)
 				status = fh_compose(resfhp, exp,
 						    child, fhp);
-			if (status == nfs_ok)
-				status = fh_fill_both_attrs(fhp);
+			fh_fill_post_noop(fhp);
 			open->op_truncate =
 				(iap->ia_valid & ATTR_SIZE) &&
 				!iap->ia_size;
@@ -355,9 +354,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		/* NFSv4 protocol requires change attributes even though
 		 * no change happened.
 		 */
-		status = fh_fill_both_attrs(fhp);
-		if (status != nfs_ok)
-			goto out;
+		fh_fill_post_noop(fhp);
 
 		status = fh_compose(resfhp, fhp->fh_export, child, fhp);
 		if (status != nfs_ok)
@@ -404,9 +401,6 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (!IS_POSIXACL(inode))
 		iap->ia_mode &= ~current_umask();
 
-	status = fh_fill_pre_attrs(fhp);
-	if (status != nfs_ok)
-		goto out;
 	status = nfsd4_vfs_create(fhp, &child, open);
 	if (status != nfs_ok)
 		goto out;
@@ -492,6 +486,9 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
 	fh_init(*resfh, NFS4_FHSIZE);
 	open->op_truncate = false;
 
+	status = fh_fill_pre_attrs_unlocked(current_fh);
+	if (status)
+		goto out;
 	if (open->op_create) {
 		/* FIXME: check session persistence and pnfs flags.
 		 * The nfsv4.1 spec requires the following semantics:
@@ -523,11 +520,11 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
 	} else {
 		status = nfsd_lookup(rqstp, current_fh,
 				     open->op_fname, open->op_fnamelen, *resfh);
-		if (status == nfs_ok)
-			/* NFSv4 protocol requires change attributes even though
-			 * no change happened.
-			 */
-			status = fh_fill_both_attrs(current_fh);
+		/*
+		 * NFSv4 protocol requires change attributes even though
+		 * no change happened.
+		 */
+		fh_fill_post_noop(current_fh);
 	}
 	if (status)
 		goto out;
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index c7c60c35bdfc..c0a46784d525 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -782,34 +782,53 @@ __be32 fh_getattr(const struct svc_fh *fhp, struct kstat *stat)
 				    AT_STATX_SYNC_AS_STAT));
 }
 
-/**
- * fh_fill_pre_attrs - Fill in pre-op attributes
- * @fhp: file handle to be updated
- *
- */
-__be32 __must_check fh_fill_pre_attrs(struct svc_fh *fhp)
+static __be32 __must_check __fh_fill_pre_attrs(struct svc_fh *fhp)
 {
 	bool v4 = (fhp->fh_maxsize == NFS4_FHSIZE);
-	struct kstat stat;
 	__be32 err;
 
 	if (fhp->fh_no_wcc || fhp->fh_pre_saved)
 		return nfs_ok;
 
-	err = fh_getattr(fhp, &stat);
+	err = fh_getattr(fhp, &fhp->fh_post_attr);
 	if (err)
 		return err;
 
 	if (v4)
-		fhp->fh_pre_change = nfsd4_change_attribute(&stat);
+		fhp->fh_pre_change = fhp->fh_post_change =
+			nfsd4_change_attribute(&fhp->fh_post_attr);
 
-	fhp->fh_pre_mtime = stat.mtime;
-	fhp->fh_pre_ctime = stat.ctime;
-	fhp->fh_pre_size  = stat.size;
+	fhp->fh_pre_mtime = fhp->fh_post_attr.mtime;
+	fhp->fh_pre_ctime = fhp->fh_post_attr.ctime;
+	fhp->fh_pre_size  = fhp->fh_post_attr.size;
 	fhp->fh_pre_saved = true;
 	return nfs_ok;
 }
 
+/**
+ * fh_fill_pre_attrs - Fill in pre-op attributes
+ * @fhp: file handle to be updated
+ *
+ * Post-op attrs are filled and pre-op attrs are copied
+ * from there.  The post-op attrs can later be replaced by
+ * fh_fill_post_attrs() or activated by fh_fill_post_noop().
+ *
+ * The inode must be locked.
+ *
+ * Returns: error from vfs_getattr() which must be checked.
+ */
+__be32 __must_check fh_fill_pre_attrs(struct svc_fh *fhp)
+{
+	lockdep_assert_held_write(&fhp->fh_dentry->d_inode->i_rwsem);
+	return __fh_fill_pre_attrs(fhp);
+}
+
+__be32 __must_check fh_fill_pre_attrs_unlocked(struct svc_fh *fhp)
+{
+	fhp->fh_no_atomic_attr = true;
+	return __fh_fill_pre_attrs(fhp);
+}
+
 /**
  * fh_fill_post_attrs - Fill in post-op attributes
  * @fhp: file handle to be updated
@@ -826,6 +845,9 @@ __be32 fh_fill_post_attrs(struct svc_fh *fhp)
 	if (fhp->fh_post_saved)
 		printk("nfsd: inode locked twice during operation.\n");
 
+	if (!fhp->fh_no_atomic_attr)
+		lockdep_assert_held_write(&fhp->fh_dentry->d_inode->i_rwsem);
+
 	err = fh_getattr(fhp, &fhp->fh_post_attr);
 	if (err)
 		return err;
@@ -837,29 +859,6 @@ __be32 fh_fill_post_attrs(struct svc_fh *fhp)
 	return nfs_ok;
 }
 
-/**
- * fh_fill_both_attrs - Fill pre-op and post-op attributes
- * @fhp: file handle to be updated
- *
- * This is used when the directory wasn't changed, but wcc attributes
- * are needed anyway.
- */
-__be32 __must_check fh_fill_both_attrs(struct svc_fh *fhp)
-{
-	__be32 err;
-
-	err = fh_fill_post_attrs(fhp);
-	if (err)
-		return err;
-
-	fhp->fh_pre_change = fhp->fh_post_change;
-	fhp->fh_pre_mtime = fhp->fh_post_attr.mtime;
-	fhp->fh_pre_ctime = fhp->fh_post_attr.ctime;
-	fhp->fh_pre_size = fhp->fh_post_attr.size;
-	fhp->fh_pre_saved = true;
-	return nfs_ok;
-}
-
 /*
  * Release a file handle.
  */
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index cdeb5eea65a8..ab15b59ac7b3 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -337,6 +337,18 @@ static inline void fh_clear_pre_post_attrs(struct svc_fh *fhp)
 
 u64 nfsd4_change_attribute(const struct kstat *stat);
 __be32 __must_check fh_fill_pre_attrs(struct svc_fh *fhp);
+__be32 __must_check fh_fill_pre_attrs_unlocked(struct svc_fh *fhp);
 __be32 fh_fill_post_attrs(struct svc_fh *fhp);
-__be32 __must_check fh_fill_both_attrs(struct svc_fh *fhp);
+
+/**
+ * fh_fill_post_noop - Copy pre attrs to post attrs
+ * @fhp: file handle to be updated
+ *
+ * This is used when the directory wasn't changed, but wcc attributes
+ * are needed anyway.
+ */
+static inline void fh_fill_post_noop(struct svc_fh *fhp)
+{
+	fhp->fh_post_saved = true;
+}
 #endif /* _LINUX_NFSD_NFSFH_H */
-- 
2.50.0.107.gf914562f5916.dirty

