Received: from fout-a7-smtp.messagingengine.com (fout-a7-smtp.messagingengine.com [103.168.172.150])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C25E8331209;
	Mon,  1 Jun 2026 07:02:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.150
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780297349; cv=none; b=r0udnExRXO7nQlzU16lGJYu/kRJVPt6CAkHU/6116jNfKZn8KNTYrH8AURKAF4DMoZxxow/BY3/vKWTxR6BYBsNFzFSrhGHS9jDvcjKM52upJjjRn3t+/7ky0BkEv1B4rXpKD8PscXs3mVOjUji/71/4nzcfdOWD1BjsGDN2NWc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780297349; c=relaxed/simple;
	bh=J0qaZrviEfWk8UyAgK5B2x9JogQu/0LntevatrbLS2k=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bF0/Q9ra2wh4Tmnz9cUwv5dQuwIYj5S425X33EnrRno4sPs9KlEYQjz+sK3maUpzfHXoAx9nBTb6kq0Ck9YDmPd5XQnexeKZBPYqpr3tyDppjF7wjVOwp5uD+VnV7NodiB41RC1qnK3uwRvDLOWJn7HjrfpGs89ui1R2MhqAXu8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=SZfahXIH; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=WXQGn3XC; arc=none smtp.client-ip=103.168.172.150
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="SZfahXIH";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="WXQGn3XC"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfout.phl.internal (Postfix) with ESMTP id 35A6DEC0064;
	Mon,  1 Jun 2026 03:02:27 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Mon, 01 Jun 2026 03:02:27 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1780297347;
	 x=1780383747; bh=4OSaLRuk/4AreJ7MjcmtJCk16PGJs0JerRMSkkSL+b0=; b=
	SZfahXIHv7NEUfPUvTAbQ+M11/yiwKRPtxdm3n4ZGwBV04589tAPvTAjSFTd2bOS
	hmrj/CNOUh5lHZeTk1YFbz4gzwtLoi8DEOB65JZ3lrm3jqbn3PMYGVll8dKkXEMG
	FfPaxuuctidlshPzeXbUdXAgzVSCcCnP7g1xBNQg1Pz5Ekw7wCgHGZeBXwSOOW1w
	JnyvG5OgHmD+KPbB9dyLGGbE0OxtwXPZ1OoaX9VW4h+ht78xFBYEyD87vTgDXos1
	AuY9TStbM/YxhS0tgGxQUsgv6SORyKM34x+YNXNpewvim7+ZV+ALB/CgWuyBh+Oo
	StXQ1QBrwUe/VG5Wi/DdTQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1780297347; x=1780383747; bh=4
	OSaLRuk/4AreJ7MjcmtJCk16PGJs0JerRMSkkSL+b0=; b=WXQGn3XCmc7Qqrepm
	d5jUAqbnj4h7ra4XXpVF2qJQS0jryHWx3ZHijaUQbcMPl5E+9jLW309aBh1+xP2d
	tFsKaIUdkI+lBPaYwG5wuRViy3hC7IS3eKt+96VloN2QmvXcgwEl0OUxoFwnHpfI
	cBKbdIPCtp7x4WL3kOOJy2i23HEc8ym0vL9cNp08VL71wPBaOZgEBOVhNKX35bn/
	buIsiaksYRiAjYqeIHwTHI1CRir/KXO2/bA/v8yIgYw1aM9cPCzXZNJ7S3i468Zv
	2igbbjxBxm672mnLHlO1XO5zzaV4v9XBKXUao8RKeAsNq8iReqhOOfGLepZ6PL2/
	S/tcg==
X-ME-Sender: <xms:gi4datBevjqZuiXYisKKmy98FzGERfeSjHoPdE5NVHjzLJKx-j3D4g>
    <xme:gi4dajtPb5ZROM7uco-XX2kJH6T_fzhTFM83Z9NRgSIMk5R3AyY4bUygFlpeiwLXU
    WUZRRVwLHxxcDr5WlxNXyq-rWUEAKx-G5EwKnr9k4FfA73U>
X-ME-Received: <xmr:gi4dakKAcsweDbzj74sFdH3s9Mxaq8kGMgyAJTdoXUQdB68rhI8KhtBT2JbmAJocQdSy_0juTTZ9TW0EaFS6huzGX45zkk4>
X-ME-Proxy-Cause: dmFkZTFNn2voCuMJwaZn4mQi+8OwFwP8MbOGesQswPxVACwdUxRDwWa/f62FrT4OS5+etX
    lpbG0CyNEC5ZEzEebDdmEkKKuwA8JYmTcJZDLGOjQuIsuC+VlGFN4cDtTpsp4TJxEBMQJN
    5UaE10g4X93jUBy1AA+vqprc2pKvYMKhkYGmTUuEeZluqnZwRRSGljv9KpJxnsuimm38u7
    Jp9HDBymSY6zDSdT1QCsnlup35Rls5SW6aC9Hwu2QHQS3M6fNepFkcCA+NA6zsxp9+rhtV
    lYy3c44qrxynOl4BJrfimD+Q/JXYY7JxRkwisEy5dkxg8tlTtB+eaV0PCk5+Kq5N3tTrAT
    A45ivwt2mnmfOdngQKmqLMdD16DR6JSSfdrg+GXgSgje7LCwJtgmdHGDZEWOlY1T1a85Sv
    R1RChIEDGeWE2wjaCIgXj5pZYi56Bw988l8/19SAC+KpgfXTz0EbCZRhRDQBKxyH0O/RH6
    +pILyJvRGDgFaysnv/KhdGxjLI5Fu4yGegkwd0kYmIZt2doRvkrU+rZyhRORCqnFbBlu0C
    9KWxfcgTaJUAdXOXF96m9XkduL2kpA5qaoH+nr9fsKyOx4ggMELLrllC7oPgEUvD7mw5oy
    AyOkPtmrW+XZrzXheoZacfkyz0tApkwClnEfUPEpzOqT5LPYl6hk5BKeEnwA
X-ME-Proxy: <xmx:gy4daiZuTMeTvL_5WASrc9cpc_8mdzAgnC8FlpLpIxa8SmQXu1jJ3g>
    <xmx:gy4dauBN1_wHm5lKpYhLIvhOAsXX4LLku5S7Q8PKgGhF1UDbgwE5oA>
    <xmx:gy4dakY7CBnTRjFIktV8z8K3f-Dz5Mbia-bj2O6UNEGZRGQXedsIwA>
    <xmx:gy4dauk7FTZagxgDWlpfB8Ta4oKxQ4r7E_EHyUgxOTwrRZQ--lJZtA>
    <xmx:gy4damFpDnvbiKjy5ixwrFnKnbAR-vL__7b0oZ20gEBeW6zWf-47k4N4>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 1 Jun 2026 03:02:23 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Christian Brauner <brauner@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	"Jori Koolstra" <jkoolstra@xs4all.nl>,
	Benjamin Coddington <ben.coddington@hammerspace.com>,
	"Mateusz Guzik" <mjguzik@gmail.com>
Subject: [PATCH 17/18] nfsd: use vfs_lookup_open() for non-creating open requests too.
Date: Mon,  1 Jun 2026 16:38:05 +1000
Message-ID: <20260601070042.249432-18-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260601070042.249432-1-neilb@ownmail.net>
References: <20260601070042.249432-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

Now that we use vfs_lookup_open() for creating open requests, we can use
for non-creating too as vfs_lookup_open() is already able to do that.

This means that when exporting NFS, the lookup and open can be combined
using ->atomic_open.

The resulting simplification allows fh_fill_pre_attrs() to be moved into
nfsd4_open_file() (renamed from nfsd4_create_file()) so it is closer to
fh_full_post_attrs and fh_fill_post_noop calls.

As ->op_create_mode isn't defined when op_create is zero, we need a
local create_mode which is -1 (illegal value) when op_create is zero.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 97 +++++++++++++++++++++++-----------------------
 1 file changed, 48 insertions(+), 49 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 61ecd4123817..19a2d3446ae3 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -201,30 +201,30 @@ static inline bool nfsd4_create_is_exclusive(int createmode)
 		createmode == NFS4_CREATE_EXCLUSIVE4_1;
 }
 
-
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
+	int createmode = -1;
 	__be32 status;
 
 	if (isdotent(open->op_fname, open->op_fnamelen))
@@ -236,6 +236,10 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (status != nfs_ok)
 		return status;
 
+	status = fh_fill_pre_attrs(fhp);
+	if (status)
+		return status;
+
 	if (!IS_POSIXACL(d_inode(parent.dentry)))
 		iap->ia_mode &= ~current_umask();
 
@@ -258,13 +262,18 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		open->op_pacl = NULL;
 	}
 
+	if (open->op_create) {
+		createmode = open->op_createmode;
+		oflags |= O_CREAT;
+	}
+
 	/* A newly created file already has a file size of zero. */
 	if ((iap->ia_valid & ATTR_SIZE) && (iap->ia_size == 0))
 		iap->ia_valid &= ~ATTR_SIZE;
 
 	v_mtime = 0;
 	v_atime = 0;
-	if (nfsd4_create_is_exclusive(open->op_createmode)) {
+	if (nfsd4_create_is_exclusive(createmode)) {
 		u32 *verifier = (u32 *)open->op_verf.data;
 
 		/*
@@ -288,7 +297,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	/* Only ask the fs to provide exclusive-create if we aren't using
 	 * the NFS verifier to do it outselves.
 	 */
-	if (open->op_createmode == NFS4_CREATE_GUARDED)
+	if (createmode == NFS4_CREATE_GUARDED)
 		oflags |= O_EXCL;
 
 	switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
@@ -321,14 +330,14 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		goto out;
 
 	if (!open->op_created &&
-	    nfsd4_create_is_exclusive(open->op_createmode) &&
+	    nfsd4_create_is_exclusive(createmode) &&
 	    inode_get_mtime_sec(d_inode(child)) == v_mtime &&
 	    inode_get_atime_sec(d_inode(child)) == v_atime &&
 	    d_inode(child)->i_size == 0)
 		open->op_created = true;
 
 	if (!open->op_created &&
-	    open->op_createmode == NFS4_CREATE_UNCHECKED) {
+	    createmode == NFS4_CREATE_UNCHECKED) {
 		/* NFSv4 protocol requires change attributes
 		 * even though no change happened.
 		 */
@@ -429,45 +438,35 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
 	fh_init(*resfh, NFS4_FHSIZE);
 	open->op_truncate = false;
 
-	status = fh_fill_pre_attrs(current_fh);
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
+
+	/*
+	 * Following rfc 3530 14.2.16, and rfc 5661 18.16.4
+	 * use the returned bitmask to indicate which attributes
+	 * we used to store the verifier:
+	 */
+	if (open->op_create && status == 0 &&
+	    nfsd4_create_is_exclusive(open->op_createmode))
+		open->op_bmval[1] |= (FATTR4_WORD1_TIME_ACCESS |
+				      FATTR4_WORD1_TIME_MODIFY);
 
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
-		/* NFSv4 protocol requires change attributes even though
-		 * no change happened.
-		 */
-		fh_fill_post_noop(current_fh);
-	}
 	if (status)
 		goto out;
 	status = nfsd_check_obj_isreg(*resfh, cstate->minorversion);
-- 
2.50.0.107.gf914562f5916.dirty

