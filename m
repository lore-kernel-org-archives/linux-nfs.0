Received: from fhigh-a7-smtp.messagingengine.com (fhigh-a7-smtp.messagingengine.com [103.168.172.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F0A23BE147
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:30:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.158
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280634; cv=none; b=LqSQKOzmUoHHJEtL0vRTyNQzUtKCQDTLFntt3GbvCJjBvCsUm+MLwUXLgay+uDQt6XsQi7vLfy7xozViuwgb4e92jq/xQXuB2+sBx6YUVdB1S4wOVoPugftZJ3IXg1GA73Ut1Xs6LN3air3tBrKNmyxrno5BBXsh4cuJuAcWdEg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280634; c=relaxed/simple;
	bh=6y7UJPmgpHGRonUbF/XAZ5j3QGhs3Hdq5qDsoaZ9NYo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ANUzQBOam5gLKXG0U17p+nGyeljm08KqoMEfSglAxUptysx7ZbBwEnMPlVdmyGQCNhY97glBqIKro0yRtyI0ucfyko8F/x0Ng4+JyHYA2oybKfhSUrAm3jgjxenjy1F9EDH7JYuN/Zh7XHGzyTqGS65zjURc+0ptPz5+ERjc814=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=SDu3Sokd; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Wry5lXZs; arc=none smtp.client-ip=103.168.172.158
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="SDu3Sokd";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Wry5lXZs"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.phl.internal (Postfix) with ESMTP id C15AE1400094;
	Fri, 17 Jul 2026 05:30:31 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Fri, 17 Jul 2026 05:30:31 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280631;
	 x=1784367031; bh=JhS8C8ewb5yVVJQVq0EGcXl4M50bjK4/3bqumHDfA7U=; b=
	SDu3SokdjMn5njwUqwzo/gvBY19BkXgc56hP+2yaZxENE263hS429wECJqu/CN0L
	Xzg/WCUusLURxE47S0RtKtFOx5o3s/HiPDu9tLYtr4p7CRmuXVTurKozWvpliBAr
	O2dVlHcdnTUJYls/aDnqc35oA+l9D2zfYdDTmzTXv+CLa7Bn9NlwPzuxZU6mNvlB
	nOgnDpCwaIe2Fn0BgXZNrj4rTa2LIp+uiY8AkHTVk17+deKfS0Z+gA4EAab6Gvu9
	QKUDCHq0QZOTLtXfQee65K323VcDxZBNYKGxe9kZIo0iLeiroubz92mj62Vk6DUC
	EZd5XNpWw5eOHKVaNRjYaQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280631; x=1784367031; bh=J
	hS8C8ewb5yVVJQVq0EGcXl4M50bjK4/3bqumHDfA7U=; b=Wry5lXZs0jM5ESHx6
	yHYTQf1EoeLXjQ1Uwp0c1gayB3fQBsTxkZmaKH4s3LPcOIvxIip1H/ORQqeZe4Pa
	JpnQ2VY9uf2dzb6q7w3n9J2m1qxnh71/320EPUtR3FlUelEXe5QggJ4HRu+SRM9h
	u8joIEtyJtTzFmQXHHxvzi/2klBdT5vTIlAhLClHclVzq27z2f0S5KLce9pRf0Al
	Zof8DG3/dZP8vFOBhZkng6k1LRSP2P5g/fxgG6WFll9+ryXU8EJl5g+cltk8wylq
	ilqzYW+eTiDpze16u8ZJv2mE6w2e9YyTQnvRtFKDp/DrUbyltSv5/aKVM1IVuy8u
	8nnag==
X-ME-Sender: <xms:N_ZZaoXzegDzdU_iFxb2H6NX-zFRqu2NaWdPy61oPm_MzOj9aFuulQ>
    <xme:N_ZZagRvMHee45FACIchbKGwSfywUHFxgizDN7SIK-KgFSE_q-BtJuO_N2i707ZkI
    YWNyo4TKHnP91eW0DKMcQxC3hbUrPuVvWpmYPCewiY96nHNwaw>
X-ME-Received: <xmr:N_ZZamM30FvXaRhoRxSLkdgI5EXZmivqpQ5P-HxWQzM9p0NMk_Z8MMLHHrLRycUmb89b4NqeD6tbR7-pVPNdkk66iyANAT4>
X-ME-Proxy-Cause: dmFkZTEX57Ex8LbShfUXWkvJih4a1baE9EfQ6TgUPnJ0DaKnRO3Du70CAhhY681g13Zhbl
    7+6gjM4A0f7dNvQc03aRIz3FZBRqrxctlwbzsG3ndQuoUarocORY0qObpi2VHZQgoKrsuo
    Pz8T2Hzo9NtU7WBXPVmdapAMdiqKaX+pxxqioqIbP8tlHObQF+a7Mp8hX7zOHvDB6EOMWg
    1sbeLGfkgUP3SWNtJdyCx4zo2FvbCdw3kEs1ZvMn58hsAfPpvA+oTbrgQ0oPjv71NDjjPy
    WnL4ClTcOz8/DrmfPbmbnRXwAb95LZ30NPNsYA/6r5bUfJzKa9KuHLiAmSCPierLaaggPZ
    YeB4jm40p75lrCHlXZz7btYq+0bb0Vj0Zhun2qJj8bWBB48jAo1Qfslc0NVkChoyBaYc43
    zQcyypqn3tVMnVU6YwB/iN3tjvyb9H2mFPQe/NCsPTNugjv7h/slzS41iYA2RYwMRvDMJN
    PV42QIjrAHCBCycB8nN+1OQGMNrwNeuvP7sv9LAT5rWXLzd662JtJD5z5ymiKejf1lZwnI
    N0p1LXTsghzshYdtzoBiixd2uz9ZuEpspFGdU1IxKGEcfCFgLrFb3dLt0SLqh4Y6gTZfOw
    QFG+pMpscBSrb/Xi47oYiwieZX+h870ozqB2cUEt3F+oqZAb0ZDDLkT+3Bsg
X-ME-Proxy: <xmx:N_ZZauT2m_ZStFHN8NyPJ_lMfe4FnQqrWytEoyM4Xsk5tyPV314wBA>
    <xmx:N_ZZakjG3tjCh5T5Qke6FQI7HZWcM26zyVnUpTmT4w0kJflw6o3seg>
    <xmx:N_ZZan87j0Z_cIH1vLGxw9G7e6cqHWDmAK5aHKPTzVhECWKEgMmXeA>
    <xmx:N_ZZarHljMPKR6EhYrN9jtqvKzc73WrajhxywKa5Z6vE_GBD_L8QpA>
    <xmx:N_ZZat18H7vlYr-nI6C-NL2rvlqXkmrbo1T__R-POsLm2ls6GDCj5K7e>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:30:29 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 04/18] nfsd: replace fh_fill_both_attrs() with fh_fill_post_noop()
Date: Fri, 17 Jul 2026 19:27:52 +1000
Message-ID: <20260717093001.1972119-5-neilb@ownmail.net>
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

