Received: from fhigh-a7-smtp.messagingengine.com (fhigh-a7-smtp.messagingengine.com [103.168.172.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C16013BE17F
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:31:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.158
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280697; cv=none; b=AsQTcuOu5uSdroEG5GYwLGSpdpeoSta8qsUcpz3O31tHa+Iv20INys3KQuE/qmzA4Dv5jyOkG7qOHu3neGGn76k7l5ussqu8b4zl7eoEF8uU5h21d29yHDdB1pjr+rHc8BcoF7fxnS/XapG7qgYViwzi5uGQg3GFFUVyuGsWjlo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280697; c=relaxed/simple;
	bh=ZjbPtUdJkzvGLk4K8xeExbi3VERmDr+6dr6IAwnxqRI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=M7T0/663mDDe2p5bWdbX0sdIDdGDQIUNsGT8qp+tCasQtvUZVG9rD1oVE1cbH9emuc1Yk7medRs+cDMuwGNbKQLgzk+rnBgkbCtUipN573bzxhfHQ2aKLKJpqIBOsqw5kcnVIObw+cGGmnSmY2+f+GCw6Ab7qBtU7Z7wOi0CJPg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=KKinY75U; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=g+aIVrPO; arc=none smtp.client-ip=103.168.172.158
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="KKinY75U";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="g+aIVrPO"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.phl.internal (Postfix) with ESMTP id E839E1400024;
	Fri, 17 Jul 2026 05:31:34 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Fri, 17 Jul 2026 05:31:34 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280694;
	 x=1784367094; bh=wgRQnyl6hc2be41bDsSsJOMgKn2jIfLkyQY9osErq9g=; b=
	KKinY75UphCAXmGbmBsvVFSAfqEOiY5GIpcpT4QSLUJUICBate9pTTMgCSbLtmbY
	Fi+1zY1YtlS6notncCXxj0WwaxW0QzgoqL+cxDx+55O0AXPXv7Fh5NTXijq+z6us
	q+feaIL4MMZVHyuH9Twjte2FbhQv7bZOQu44t5mLfJuU+bERL9QcQRq0fAeXRPnP
	gP9zsvj3PJRWHVyoWElgQVByTudyJePE73yOM/pY7Dn9zZYs1hONNKyvZKWpuwAj
	iggKeSQo6597L0PQve1VPKwLAMXL6ehUY2X7CxaEM3WXBOYtiGhXbWW/S6k8ghQr
	6h9vP05rGNDB83ltwDSp2A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280694; x=1784367094; bh=w
	gRQnyl6hc2be41bDsSsJOMgKn2jIfLkyQY9osErq9g=; b=g+aIVrPOSkgGsKD7c
	wfJukW/E+iHo22jcbrPajs8E+8cGwf4TSRGXJEJ7NJUtzWcH2Er6xNi90un4bXnN
	dtBw+AvC6osMbn791ni94kRfCN3z88CGVCcctq+eunwtn1ej8Omc03KsdWrZEl6D
	WIX00oBz6DdteJgz+6m+bTEZhXW9QwjSKwSRulRkYLmUpQIg0OswAPduiF/JQjbl
	zSqENwD/csKPa78BbZmOFWymBAkTfoXb1wVcL62HM1rhEAeu6kc6k4iwXp4VG3TE
	vlJyJNmTMgM12mUYkX4F1kUbF97vaURtrww7d/i0+spx3SCr0DmYDK4Md9n7u3uC
	qKA8w==
X-ME-Sender: <xms:dvZZagVi0mg8lxjEvftb-FG8KRbhHSgd4r0G1Tl1FZWLm4xBofoWHg>
    <xme:dvZZaoR7sU-Z5BsBg1PQmyeWGDn3bYwCyOOBTj1-SRRRYGqfmJQPzQc6MWdHCenIs
    A0HgWRLA-f0jxfsr6Xbz24oxKqq9EaEDPvEchlXLfc6fGbuNg>
X-ME-Received: <xmr:dvZZauOJ_QE2jX7BvgqQqv-OyDgdpWVBZgwrg3xkJrMgeV6n3mWLTE2A6dFqDKVQeyti3B0DEVlplP3e3ipXW7XDAVl47vI>
X-ME-Proxy-Cause: dmFkZTEWR11FIoOU7sLBysZ6MvBVA6kk3IPNP6YE/I53vP2pOfWKjkNlUeP+s2aJ83e6ID
    9m5wdHpLp28Kbqr8S3EO34JWG8UQDO4OgJ4NECiBfpWV6/jtmGuQ29O/t0+yaCKFdVxjCu
    2+c4BPeFMmJNt9nQnqio9kGZURKlbZ6guJLeRZWGYbJgs6hFz2+k5Vp9dQmxbocHJRb2ez
    Rbo/Hi+fKrHwlrp8u5Xo7hQobz5byTQlnnJy3OJdwVQ9MBNgzPG4Dhv4z9o9/FFJjSh/xM
    dEhm7ru3yn9Nb2b0YE3EpvHOTNLm1T0bZE13FeDcU/3CmDxuC4iGIdb4w2ViFywDYdLiSn
    +dLACHifog244tvtEWeayjKxA4iCP28Xd/6gh5voPF3YeGeHlmP+qkYyseYh0Bwgwn4p0z
    9090kaEBYpdbLE5wldLTkPCe08eTwnRl453XOfhKfxKhbo5uZFYlMMaDeBbo0A5joGf38B
    2aMTT34VOFn2gK2vNrbMPjZg1Y85x6ahhsGnLoMFX7KMtvE0GuzIWpILkKU89EATn1RVw+
    J5Ua0wymn4qgo3WnbVCcdapU1UehkOsOkKbN/RfYqu4/TlmwQUDS0JPl4075pNxehgpmKB
    9rXEd7rpjLv0tJxvGKhrLoQwshNIT1Aq2rL3tkofcG4OjxOHEcv6cfJ4m6YA
X-ME-Proxy: <xmx:dvZZamQXB37exN6Q55-AY7uLRdyZEmTmiGr4EiTCXR9aaKoKpTC3fQ>
    <xmx:dvZZasicrravwWiws8tQ7khYqeA7uUG8AK2RNAxL6pz91IrdFbW17Q>
    <xmx:dvZZav-PxDAdSqRWCQkyzxRMxF9V6-FllSNvKEfCqoC_zPlxGS0CvQ>
    <xmx:dvZZajHgLExVLpXPGDWgN-Yx6NGvcITxG55lZX9p45jadvcOmCA2BQ>
    <xmx:dvZZal0LIrN8MlpO-A9DHb4Wx1x57KGygEMUpOUnI2IBCr5zEiiYX0xx>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:31:32 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 18/18] nfsd: use do_lookup_open() for non-creating open requests too.
Date: Fri, 17 Jul 2026 19:28:06 +1000
Message-ID: <20260717093001.1972119-19-neilb@ownmail.net>
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

Now that we have do_lookup_open() for creating open requests, we can use
it for non-creating too as do_lookup_open() is already able to do that.

This prepares for switching to vfs_lookup_open() once the VFS provides
that.  This will ensure consistent code and fs-interaction with VFS open().

The resulting simplification allows fh_fill_pre_attrs_unlocked() to be
moved into nfsd4_open_file() (renamed from nfsd4_create_file()) so it is
closer to fh_full_post_attrs and fh_fill_post_noop calls.

As ->op_create_mode isn't defined when op_create is zero, we need a
local create_mode which is -1 (illegal value) when op_create is zero.

The non-create path now doesn't use nfsd_lookup().  As mount-point
crossing including nfsd_check_access() is already included for existing
names, this does not lose us anything.

We now only call mnt_want_write() is there is a flag which indicates we
might want write access - previously O_CREAT was always set.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 113 ++++++++++++++++++++++-----------------------
 1 file changed, 56 insertions(+), 57 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index b7fdc75c4b81..11d0411dec08 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -204,9 +204,10 @@ static struct file *do_lookup_open(struct path *parent,
 	struct file *filp = NULL;
 	struct path path;
 	struct dentry *child;
-	int want_write_err = 0;
+	int want_write_err = -ENOENT;
 
-	want_write_err = mnt_want_write(parent->mnt);
+	if (oflags & (O_CREAT|O_RDONLY|O_RDWR|O_TRUNC))
+		want_write_err = mnt_want_write(parent->mnt);
 
 	child = start_creating(&nop_mnt_idmap, parent->dentry, name);
 	if (IS_ERR(child)) {
@@ -242,29 +243,30 @@ static struct file *do_lookup_open(struct path *parent,
 }
 
 /*
- * Implement NFSv4's unchecked, guarded, and exclusive create
- * semantics for regular files. Open state for this new file is
- * subsequently fabricated in nfsd4_process_open2().
- *
+ * Implement NFSv4's open semantics for regular files.
+ * Both create (unchecked, guarded, and exclusive) and non-create.
+ * Open state for this new file is subsequently fabricated in
+ * nfsd4_process_open2().
  * Upon return, caller must release @fhp and @resfhp.
  */
 static __be32
-nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
-		  struct svc_fh *resfhp, struct nfsd4_open *open)
+nfsd4_open_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
+		struct svc_fh *resfhp, struct nfsd4_open *open)
 {
 	struct iattr *iap = &open->op_iattr;
 	struct nfsd_attrs attrs = {
 		.na_iattr	= iap,
 		.na_seclabel	= &open->op_label,
 	};
-	int oflags = O_CREAT | O_LARGEFILE;
+	int oflags = O_LARGEFILE;
 	struct dentry *child = ERR_PTR(-EINVAL);
 	struct path parent = {
 		.mnt = fhp->fh_export->ex_path.mnt,
 		.dentry = fhp->fh_dentry,
 	};
 	__u32 v_mtime, v_atime;
-	__be32 status, create_status;
+	int createmode = -1;
+	__be32 status, create_status = 0;
 	int want_write_err;
 
 	if (name_is_dot_dotdot(open->op_fname, open->op_fnamelen))
@@ -276,6 +278,10 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (status != nfs_ok)
 		return status;
 
+	status = fh_fill_pre_attrs_unlocked(fhp);
+	if (status)
+		return status;
+
 	if (open->op_createmode == NFS4_CREATE_UNCHECKED) {
 		/*
 		 * If name is already in dcache we need to check for mountpoints
@@ -305,11 +311,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (!IS_POSIXACL(d_inode(parent.dentry)))
 		iap->ia_mode &= ~current_umask();
 
+	if (open->op_create) {
+		createmode = open->op_createmode;
+		oflags |= O_CREAT;
+	}
 	/*
 	 * For the EXCLUSIVE modes we do our own uniqueness tests
 	 * so don't want O_EXCL.
 	 */
-	if (open->op_createmode == NFS4_CREATE_GUARDED)
+	if (createmode == NFS4_CREATE_GUARDED)
 		oflags |= O_EXCL;
 
 	switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
@@ -344,7 +354,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	v_mtime = 0;
 	v_atime = 0;
-	if (nfsd4_create_is_exclusive(open->op_createmode)) {
+	if (nfsd4_create_is_exclusive(createmode)) {
 		u32 *verifier = (u32 *)open->op_verf.data;
 
 		/*
@@ -366,11 +376,11 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		iap->ia_atime.tv_nsec = 0;
 	}
 
-	create_status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
-	if (create_status)
-		/* Might still succeed if no create is needed */
-		oflags &= ~O_CREAT;
-
+	if (oflags & O_CREAT) {
+		create_status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE);
+		if (create_status)
+			oflags &= ~O_CREAT;
+	}
 	open->op_filp = do_lookup_open(&parent,
 				       &QSTR_LEN(open->op_fname,
 						 open->op_fnamelen),
@@ -392,14 +402,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		goto out;
 
 	if (!open->op_created &&
-	    nfsd4_create_is_exclusive(open->op_createmode) &&
+	    nfsd4_create_is_exclusive(createmode) &&
 	    inode_get_mtime_sec(d_inode(child)) == v_mtime &&
 	    inode_get_atime_sec(d_inode(child)) == v_atime &&
 	    d_inode(child)->i_size == 0)
 		open->op_created = true;
 
 	if (!open->op_created) {
-		if (open->op_createmode == NFS4_CREATE_UNCHECKED) {
+		if (open->op_create == NFS4_OPEN_NOCREATE ||
+		    createmode == NFS4_CREATE_UNCHECKED) {
 			/* NFSv4 protocol requires change attributes
 			 * even though no change happened.
 			 */
@@ -494,46 +505,34 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
 	fh_init(*resfh, NFS4_FHSIZE);
 	open->op_truncate = false;
 
-	status = fh_fill_pre_attrs_unlocked(current_fh);
-	if (status)
-		goto out;
-	if (open->op_create) {
-		/* FIXME: check session persistence and pnfs flags.
-		 * The nfsv4.1 spec requires the following semantics:
-		 *
-		 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
-		 * Reply Cache  | server |                 |
-		 * -------------+--------+-----------------+--------------------
-		 * no           | no     | EXCLUSIVE4_1    | EXCLUSIVE4_1
-		 *              |        |                 | (SHOULD)
-		 *              |        | and EXCLUSIVE4  | or EXCLUSIVE4
-		 *              |        |                 | (SHOULD NOT)
-		 * no           | yes    | EXCLUSIVE4_1    | EXCLUSIVE4_1
-		 * yes          | no     | GUARDED4        | GUARDED4
-		 * yes          | yes    | GUARDED4        | GUARDED4
-		 */
+	/* FIXME: check session persistence and pnfs flags.
+	 * The nfsv4.1 spec requires the following semantics:
+	 *
+	 * Persistent   | pNFS   | Server REQUIRED | Client Allowed
+	 * Reply Cache  | server |                 |
+	 * -------------+--------+-----------------+--------------------
+	 * no           | no     | EXCLUSIVE4_1    | EXCLUSIVE4_1
+	 *              |        |                 | (SHOULD)
+	 *              |        | and EXCLUSIVE4  | or EXCLUSIVE4
+	 *              |        |                 | (SHOULD NOT)
+	 * no           | yes    | EXCLUSIVE4_1    | EXCLUSIVE4_1
+	 * yes          | no     | GUARDED4        | GUARDED4
+	 * yes          | yes    | GUARDED4        | GUARDED4
+	 */
 
-		current->fs->umask = open->op_umask;
-		status = nfsd4_create_file(rqstp, current_fh, *resfh, open);
-		current->fs->umask = 0;
+	current->fs->umask = open->op_umask;
+	status = nfsd4_open_file(rqstp, current_fh, *resfh, open);
+	current->fs->umask = 0;
 
-		/*
-		 * Following rfc 3530 14.2.16, and rfc 5661 18.16.4
-		 * use the returned bitmask to indicate which attributes
-		 * we used to store the verifier:
-		 */
-		if (nfsd4_create_is_exclusive(open->op_createmode) && status == 0)
-			open->op_bmval[1] |= (FATTR4_WORD1_TIME_ACCESS |
-						FATTR4_WORD1_TIME_MODIFY);
-	} else {
-		status = nfsd_lookup(rqstp, current_fh,
-				     open->op_fname, open->op_fnamelen, *resfh);
-		/*
-		 * NFSv4 protocol requires change attributes even though
-		 * no change happened.
-		 */
-		fh_fill_post_noop(current_fh);
-	}
+	/*
+	 * Following rfc 3530 14.2.16, and rfc 5661 18.16.4
+	 * use the returned bitmask to indicate which attributes
+	 * we used to store the verifier:
+	 */
+	if (open->op_create &&
+	    nfsd4_create_is_exclusive(open->op_createmode) && status == 0)
+		open->op_bmval[1] |= (FATTR4_WORD1_TIME_ACCESS |
+				      FATTR4_WORD1_TIME_MODIFY);
 	if (status)
 		goto out;
 	status = nfserrno(nfsd_check_obj_isreg((*resfh)->fh_dentry));
-- 
2.50.0.107.gf914562f5916.dirty

