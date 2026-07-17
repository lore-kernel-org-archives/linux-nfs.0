Received: from fhigh-b3-smtp.messagingengine.com (fhigh-b3-smtp.messagingengine.com [202.12.124.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A9877364058
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:34:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262863; cv=none; b=JgQ0KFZoALRDpGDSPiiMQKQ8007CSzHUKcTqoz4k2mTIs3h9zsfoYqHrgVD6XmVJCtEFSpNgVejFC7D8RaHU36IgbpWFePhib+krD/yduMJJv2NJFwQ5FrYwjFoT9JQ/TvrfayQQZLrw8/0gK93hldz8rc5jjJyewJGy2cwuZPI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262863; c=relaxed/simple;
	bh=kycnWru/5Px1syexPbo02RpSdcM5EvNrdHDgzseVu9g=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qrUlYtO05YuxQ9lWFHCtKeB3Ah6q6xdHzHM5mbJFvyWZ/2pI+cuvXEbsW6mjXGpd9aVNB6q9zV6MbE6czFgxXceGpYcl3yPjfl41s+MGuhabv1eCccQqYpTpTYDj4Ry+jUgfksUxpS6rR+IHqtOHRq8gbONnRn+Y0xDLYoutFqk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=CSDMeesl; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=X6F2cHxK; arc=none smtp.client-ip=202.12.124.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="CSDMeesl";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="X6F2cHxK"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.stl.internal (Postfix) with ESMTP id DDC857A0078;
	Fri, 17 Jul 2026 00:34:17 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Fri, 17 Jul 2026 00:34:18 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262857;
	 x=1784349257; bh=v8Cx0n7mCUqpdqKoqowaMeaPATTk3J+OfiT5HvYVWWU=; b=
	CSDMeesltvZacs4wKyIZqw1qFidoD5PGRFJP03pXDwXhYuYUxdDsf8monfBNMo1v
	eWbEV9fzuIGn5Dq3NzJlBKYoRN/os+HofEvDto7ZrtoSLtSkOQIP44hLESf5OUOR
	dp88Tx1WW0a2Toj56bwEKwZGzgeMUDx0/lLuWJv9RQPkYg2rn4+PlSS1mp+H1YCN
	miCiSxltVVsztrROufYirix2DYPwcNgP7B5jRGCkUnjr2RLUm0DRynnRyXFKdbOZ
	GCxDpWbRVhmu1ij6JNECkOtBLkZPgxzsQfGmSXTKiXylc+NmT7SDaOX/GbV2mkrP
	MvfJabBo0ox1aROGoxSX0A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262857; x=1784349257; bh=v
	8Cx0n7mCUqpdqKoqowaMeaPATTk3J+OfiT5HvYVWWU=; b=X6F2cHxKfq5wZTcS2
	GGjg57bBHDfdbdOarXkQEzQzSECFVlKxXVn4bJIjW+cPe4m817HWK8mDlfZBqvCa
	hqcLh362RS0uFxonMdGY46plsEgxSEwP26fhlABeSeKYsOeCObY7IFdccdQOaEYg
	3wyI0eH5Q38zPWPCTRhRpLJUbxoMHoV2eMpHmPVHG1I4Ee8OX0YiZjUapHymCUFY
	eQMilVimBYzHU4Rr2ns3nXuXYf03GsAtB7LvVesmYjGCZ1SF6pj1DoRjPrM/M3Rs
	+K2y4yTInk2mocG9GlN4+/rrpWQHXfBLCC4JLxUppQ8TnmnpV6WT/A/oNH010uNM
	or0+w==
X-ME-Sender: <xms:ybBZatmHJZkgqhZpyUGqvS3MYVrz4KdgndAZsW7uX3evktLTthOvDQ>
    <xme:ybBZahQo158ob8OZHE1Qv33qXpfuCPvakOJCmX2wrQ8lz4-dntBDvjKoM9VEzsl6B
    6PYH4tL4F4yVJmh_thyrMaz3bJ-KuYsW-D5kKoKKmzNuKutmB0>
X-ME-Received: <xmr:ybBZakF4-4r2Vnj8EUR9TRRVWjRgOHmmMyav6eLXQuDPsHyWH90bcyWElFyWIxcLkw9eSc-jaXvd4lZ692rDCs_9UJf1DIs>
X-ME-Proxy-Cause: dmFkZTEYbV/O4rHrcG2pD7g+lcRX3B/+gNPg2GmR980GEuAuHei5en8xSXbHzI3CGul9WZ
    2wyTVMqKjH3Gwr8l0bxq3+gJYxAuCaKsWNQqLRXWJMJ4PsRsuumSSsv/v6MJO7XYC6xpIa
    vcnnDVTuUuMQk5cAowe2NwKaJfSCnmBAw0ipwGptG+ww7YtnuPy4gDHn7ZdBpl0ZsZpkwP
    MnyIuVgfV+AX6SJU5C/DP56d1Wt/NDzA2IXtopXrm9Sb4Kn913mOAzz3mkvTJArWN7bgvP
    G7RfvyjNaPhNpWwcaCH1o0rbK0rNbwsgX9TYV1xS3Iq3WSAnK9mVoidV/lV9qVPcqwMrGU
    GsDGQyuWrVfE2TZjY4MFOLwSnuf/njSENoEg8cS2QpbVZqpq1U+YNtvSlEDOv5FyVbeJne
    LaDerXUWJRmoD4tvLgVw1/FUztt8sNC5rsVNJO07cjMfw36QVNZS7HEqh3GcdeqrarqnTQ
    0Nzg8nKEQDx9Ge8K5zeeuFzLp5sUHqSXFFcnQj071dW/E/i/vTCOFG/oC1pjuI1b1zAhoo
    0Xv6XxWRo/ABZszSKx8CO+BZbH+QG5ljKyBTQQPErzx9biOiHKKaaWkksCeZlIfySrFPkE
    jEJvlNtIPpONb1svZJn5z6C1efZmPaL9A4G/Gwva/I+2IrjoQw9tg/G10eIw
X-ME-Proxy: <xmx:ybBZauFofrt3-HiQ-MJ4SpwXU0uW2Kd2HasRXHDBEIHO9zZ5pUkG2w>
    <xmx:ybBZaqTsqMN20thaRiN3dUF0nxM3zSCYHVXugBtbDuptGTlXZmV6UA>
    <xmx:ybBZanKQwICzSoBRUZaI481QIxRlN2aSjyyHR4E4uLlYwX-R4zRHGQ>
    <xmx:ybBZatbwqdca8EB-O3rsxxFPxmDTHAfaWFAEFeFPjM7SlFz3D9Sq2w>
    <xmx:ybBZamzkdDBPgq_rZTb0doi96UZAQjDL1-ovCnjFX9LTc7ErIsv-uMe6>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:34:15 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 18/18] nfsd: use do_lookup_open() for non-creating open requests too.
Date: Fri, 17 Jul 2026 14:31:16 +1000
Message-ID: <20260717043242.1865905-19-neilb@ownmail.net>
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

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 108 ++++++++++++++++++++++-----------------------
 1 file changed, 53 insertions(+), 55 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9db63f9062a5..dd057025c925 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -242,29 +242,30 @@ static struct file *do_lookup_open(struct path *parent,
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
@@ -276,6 +277,10 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (status != nfs_ok)
 		return status;
 
+	status = fh_fill_pre_attrs_unlocked(fhp);
+	if (status)
+		return status;
+
 	if (open->op_createmode == NFS4_CREATE_UNCHECKED) {
 		/*
 		 * If name is already in dcache we need to check for mountpoints
@@ -305,11 +310,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
@@ -344,7 +353,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	v_mtime = 0;
 	v_atime = 0;
-	if (nfsd4_create_is_exclusive(open->op_createmode)) {
+	if (nfsd4_create_is_exclusive(createmode)) {
 		u32 *verifier = (u32 *)open->op_verf.data;
 
 		/*
@@ -366,11 +375,11 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
@@ -392,14 +401,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
@@ -494,46 +504,34 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
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

