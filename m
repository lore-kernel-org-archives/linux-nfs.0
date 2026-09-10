Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 079B92931CD;
	Thu, 10 Sep 2026 00:30:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789000228; cv=none; b=jLA01S8Zpsg4+cgNqrYa7MeEVSb0WlAVxhbeCGPXNNvASrPLX7A6MATTlTxzsmojXQPVJloMRt2eSPG07GgmaTSBgOOr3DdqPctrz71u3XRyP2MOhQT+nCJFooOjSfycdSfyq9updnM/jCKzCrXgEDX+5l5FOnpoZZ0LEhdV/K4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789000228; c=relaxed/simple;
	bh=y72ap5RBnFU2C98W59l+udbjWPZJigxz1Xi2wFt9N6w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=i1dYUny0g4FsgT/5AEKvTZMcIh+QGvpPleERw62G2N7gzBfmfwKT2T4th4oTOiPCRyoXc3ropliFTmI+xbok3XLBQg3RuchFLrF3Er42ahzqYMFXZN7r2lD7547dD4q7M0remVSnvtuDesL1nZcXIvlu19v+uqCTuzKQKxyuBSk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Yd7BU2tr; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=FnAWD7cZ; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Yd7BU2tr";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="FnAWD7cZ"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.stl.internal (Postfix) with ESMTP id 2FD111D0008B;
	Wed,  9 Sep 2026 20:30:26 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Wed, 09 Sep 2026 20:30:26 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789000226;
	 x=1789086626; bh=cftcWUxa4Z5TMae9NkimSDS21OOJu/UTxDfN4wbd81Y=; b=
	Yd7BU2trYp6KKbeK95lOIDPdXpjCJfbxmOYkB61rUYaLkDWjHZG4mWt2iWyveUup
	4n7QFjClnFptgh/HahNYOs5GFEPphdkFHEGeeQtrNOlo1atdgEaLZ3wKHYPsJfQ+
	XlkNo8LuGZ8f3DcE46f8gCj3ri1doepV1E/JoN7EY61gfFrSKT348aIIhx09Dbj9
	iTibFmwprf1DSf9QAMyPMTk+juPrJ15ELbtV0NeaCBf5jVWjqfv0xucDBCKDoxLz
	uovNAFNAnN7hF0uwR2b7UYLpP/R1GYODoqJ5LuohmrH5tLHQjIs8cVMktJsVqz/t
	YW47tiXIQPWqI6HZ9fu42A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789000226; x=1789086626; bh=c
	ftcWUxa4Z5TMae9NkimSDS21OOJu/UTxDfN4wbd81Y=; b=FnAWD7cZJ4hgeEkoy
	yOkJxugCROrACTOm/i5Dx3ZviyPQ/Jdk75Tra4y0AruZgRgf2ClQ1Xu7PHX4luj4
	zwQYFX9rlVWjWkktsdeAATQZeIs9/QJUEGWUfKASrj1VQvohTczSS4tVCOM2WHgz
	AMKhpKXpedRxa1jZsUEZfx3kPuyD6Lz1S+09CvbcsF1NXd/BIJ2tnSF9dDDDnxuS
	6CtJzZjdrNjFWGNpL9JeIjQXMxUp4j9o5iQJlkGlBPiObbDCGVK32TLB0BU0peRo
	lsnQjiamGrnTPK4nk6mCUuLbn6S99Yt/J2FDX352AeU46SqJM8/T8GcdQrwWpy3w
	dc1yw==
X-ME-Sender: <xms:Ifqhagtkd73Cu9UY-Zf5fwNjCT8EaYe2VN8BQsBIOY0CN8XYND9zxQ>
    <xme:Ifqhavt-qbJtWlEZ-RtEnqZ-OlRKOwj4S0OAnbebK8k-m55CUxh__EuL6pz1iTp3X
    FrgojGTp5cGa660OMxlZ69pTtU8sF5yUBcx5pJoQKDoNq1GTXm9>
X-ME-Received: <xmr:IfqhauBu6P732rv_EgITTMVCjfT3NXC5OF6OUJsvnDx1fluAU1YE_Yp8sr7JjWFP78XHDwb90ZkM-HD4unOJ_QLUkSU4Uvg>
X-ME-Proxy-Cause: dmFkZTEf6Pyw7VAJhfi9sMP3VFp+ykFQ9cqmL1euhD/op+yf6ZyTpVmK0RGfRQSMuAuwQi
    mWsK+m6EL8BRjRCW/jWChk7AbeVysSgkNOLwC79TyWuK80RTnhVpWzbyW1CLaqcxHMTigf
    NLXg/LinKKAaZzlibCwlG+h73l98Bh4oYtaAUC3AqEX9FB6E/2Zn1pJmjPq5zk7/KzgL6w
    dZhpbrUJffrCdNDEXW+vyHnQSJc7rn7HEeRWlco2iwGamqqihpsh6kFcukC3KBZx87Yx7n
    0S6NX7+6yDQlL09IOB6kKo3IwEJ9TdjOKY//MGsIcj8RQk0OUpsJtQzINJzGZxHqA48EYj
    F7k0Ca2x1OUXtDiVHcWUnA2Imyxnn6irGJ6VvnG2b67Zm0Zd4i5J+y3m4uj2Zy1causGc9
    Rc5o6ayWW9OjkHkz2DK/+cPTuyTqjssycSZiwaOG8Sh2YM9qw++Q92QtmlNhLX/hiCyGPe
    nMtCUavj+r+zB/tRMTNIZCHNahHqC7VzXSkUtubFSiZBXdHT+fNDFmRgxFE55Gs8Xa+7EQ
    dRzw5aXH/GtktnA8KXo0E5dNqQe0C/w9obcnm5rGyXO92ffuj3dsAgCdsQ4JZfIDHL2zk6
    TsCtnNpErtzxwOI+KPdauFuCKV08GuUXq/N78Jx821OTtXOzXzXnmLxi4NTA
X-ME-Proxy: <xmx:IfqhapPjw2FVJOyUuc6WAKN3SFOy_RbJNXcA9ZJgqiJpdyYBIOtqug>
    <xmx:IvqhavzLFizxUWQUJiCPqgsv_IibrZhAjaSpHC8W6Y-0RfFa07Tggw>
    <xmx:IvqhahWilicvqup8BRozTxxUqR-FjGa4VRXW6OSdqdaF_JpCwmvbxA>
    <xmx:IvqhapM8-EUDFtcP9HCBtcR1Q41d9HDCww4bf0frii5MWnErZCxjLg>
    <xmx:IvqhalbDZcj43hMt-KRtBmzSKdr8CCUESZh4ZNtLflV654h3SpUAUuTU>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 9 Sep 2026 20:30:23 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 7/7] nfsd: use vfs_lookup_open() for non-creating open requests too.
Date: Thu, 10 Sep 2026 10:20:53 +1000
Message-ID: <20260910002934.192979-8-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260910002934.192979-1-neilb@ownmail.net>
References: <20260910002934.192979-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

Now that we have vfs_lookup_open() for open requests which create, we
can use it for non-creating requests too as vfs_lookup_open() is already
able to do that.  nfsd4_create_file() is renamed to nfsd4_open_file()
and enhanced to not always create, and is then used for all OPEN
requests.

The resulting simplification allows fh_fill_pre_attrs_unlocked() to be
moved into nfsd4_open_file() so it is closer to fh_full_post_attrs and
fh_fill_post_noop calls.

As ->op_create_mode isn't defined when op_create is zero, we need a
local create_mode which is -1 (illegal value) when op_create is zero.

The non-create path now doesn't use nfsd_lookup().  As mount-point
crossing including nfsd_check_access() is already included for existing
names, this does not lose us anything.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 109 ++++++++++++++++++++++-----------------------
 1 file changed, 53 insertions(+), 56 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a6ba7618a307..1f3096486565 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -251,29 +251,30 @@ static inline bool nfsd4_create_is_exclusive(int createmode)
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
-	int oflags = O_CREAT | O_LARGEFILE | O_NONBLOCK;
+	int oflags = O_LARGEFILE | O_NONBLOCK;
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
@@ -285,6 +286,10 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (status != nfs_ok)
 		return status;
 
+	status = fh_fill_pre_attrs_unlocked(fhp);
+	if (status)
+		return status;
+
 	if (open->op_createmode == NFS4_CREATE_UNCHECKED) {
 		/*
 		 * If name is already in dcache we need to check for mountpoints
@@ -315,11 +320,15 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
@@ -351,7 +360,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	v_mtime = 0;
 	v_atime = 0;
-	if (nfsd4_create_is_exclusive(open->op_createmode)) {
+	if (nfsd4_create_is_exclusive(createmode)) {
 		u32 *verifier = (u32 *)open->op_verf.data;
 
 		/*
@@ -373,11 +382,11 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
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
 	dget(parent.dentry);
 	open->op_filp = vfs_lookup_open(&parent,
 					&QSTR_LEN(open->op_fname,
@@ -387,7 +396,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (IS_ERR(open->op_filp)) {
 		status = nfserrno(PTR_ERR(open->op_filp));
 		if (status == nfserr_wrong_type) {
-			if (nfsd4_create_is_exclusive(open->op_createmode))
+			if (nfsd4_create_is_exclusive(createmode))
 				status = nfserr_exist;
 			else
 				status = nfsd_check_obj_isreg(parent.dentry);
@@ -409,14 +418,14 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		goto out;
 
 	if (!open->op_created &&
-	    nfsd4_create_is_exclusive(open->op_createmode) &&
+	    nfsd4_create_is_exclusive(createmode) &&
 	    inode_get_mtime_sec(d_inode(child)) == v_mtime &&
 	    inode_get_atime_sec(d_inode(child)) == v_atime &&
 	    d_inode(child)->i_size == 0)
 		open->op_created = true;
 
 	if (!open->op_created) {
-		if (nfsd4_create_is_exclusive(open->op_createmode)) {
+		if (nfsd4_create_is_exclusive(createmode)) {
 			status = nfserr_exist;
 		} else {
 			/* NFSv4 protocol requires change attributes
@@ -512,46 +521,34 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
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
 	status = nfsd_check_obj_isreg((*resfh)->fh_dentry);
-- 
2.50.0.107.gf914562f5916.dirty

