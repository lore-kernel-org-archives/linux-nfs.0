Received: from fout-b1-smtp.messagingengine.com (fout-b1-smtp.messagingengine.com [202.12.124.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B77AB36D9EE
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:34:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262852; cv=none; b=j6R8bxt0t1MGayCGLTPxThShGThZ4MXv0PVgodwKvTGq0NR/0Vbba5M3vSQBFidPLTUI+fxgO6p7x3GC/WpoqMqx388tru00AMhs4bmpDs3qgNpYfe+adUYQ2kbU+h7tYipu+Eo3De8Iig5EhkSK+ljG0Hymm7YEIF1dNzyLR/c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262852; c=relaxed/simple;
	bh=r/ViqJpRsJe0g5E04zNZ27/nOQ+w8wzlDKbPgyoVAGQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=YYqX481rZCdgP/3A/zO0NB2NjuGEE18c3cLGUAGZVxg53wOXOmrCAdO5F0Obv5XowttGxjSI8RgddZIJtZGUmeLXAF/5Bip6zrBuT6FSXs8QC1Y+RSSUEyHDky/6X4TziMGWRmp8jioFVcwtf6p4WUD/qtRWRaIBnXWgHLZkhlo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=lO4g+ibN; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=KwQz4yi8; arc=none smtp.client-ip=202.12.124.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="lO4g+ibN";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="KwQz4yi8"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfout.stl.internal (Postfix) with ESMTP id 08C481D0001D;
	Fri, 17 Jul 2026 00:34:08 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Fri, 17 Jul 2026 00:34:08 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262847;
	 x=1784349247; bh=iJFqUAEA8Uh5LnQz42qtnnThH0xM0cpNuDAhs/R3/3U=; b=
	lO4g+ibNYES6jCnFOFN/XxZF+4ZKqZLY2/KngfqR495aktF0q+RNgFLF90koJIOb
	NkB2aTj6tho0p3Jsh145Q+BAqAXhss3ZO3eCGqfu1f8dndtbovehVGQsRwsE13fi
	aHiO1vcnGI9BESXEHZxqDURdjz7EKgL+5gjOYRV4pGOtT329KFtkOrn7fi6wtX0C
	eTaRR2ApYKpaHnZVwbtHFJzRm/dAa3cUm8xiKXEmgzn5GopVFKu7BnSElsrMDyLj
	pn6YGtD2MQfYk7cpbljOnxyVIOz/oiAr2s6v9o1krT20NhLC2YkyhTD5HSkAAn/5
	g6e2gR6iFpekwqyZHcEyFg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262847; x=1784349247; bh=i
	JFqUAEA8Uh5LnQz42qtnnThH0xM0cpNuDAhs/R3/3U=; b=KwQz4yi8MKdtwMu6h
	wCAIGYTKmz3Huby71pdPP4YAuDC4yKe6T0D4LP+R7TaZ+Hk/gNgbSeCHOdw6pYGE
	vW85ADWZGjIuMkiiTKze9ePMxWTI05NSgo0UDHBBiDnnuVFWie+/dckRBqLjFjgv
	EtyKWyhtkx46td4NnhDBkYKDFyHhubWMVsVJW37hHoxGYhQimPOe6tyMoRGeZNkw
	gh6V2AOARtDn83g6+8dbZqWbsJkdEUGqOJn72k0n4K1JmQMbjFPLYkBkquFujaC3
	LaITf7luasgtYodXukmttsc0+eYDy/GJ68hIG2hKy4c9LJ654dPBGNNA/Q+eAxFC
	0ovkQ==
X-ME-Sender: <xms:v7BZat6dIwUrnhLYUgnbkptdZZeRR4P0RBZsfTCJUdd_kCcWI50h9g>
    <xme:v7BZaunsGDRG1cxx3igLHAAZhQLeLsNN1AwIH6-bzArjFBtDg8DNAjyH4Qz5g42GK
    1XPBPnWJsT1MAG2faDJjAeshEacdbEZlNe--WHlkEsmceFe1A>
X-ME-Received: <xmr:v7BZauSPBVEjJpTRqqPDcG-6zgkI_pv73YOUqj51HBeQMM4U5f83tBARWkuXur1YiN9q8TIJsG1g9jhstgnv365n0Mt0pKs>
X-ME-Proxy-Cause: dmFkZTFnEpgNJ5d20c54qdZKAJEfDKeEsLFu4GhQwTmzausBhx9zFB3HjMPveQfQcE55T2
    3sdGUpBuymjivVU+VJmEAia8FhKvCSd9LLXwGKBQ709zK+Kad4BtYxXVFSKV7YP2theml9
    izmgFoMCcN8xPORTs7ZQ9kIFJfoJW1QWJRZ74IDWujCJQ2deXVbGcKTcJGTYqc/Z89vZ5y
    JIbRdmq7skMHvh1OvKbrF1HHuvHJjOP4T5oOhP2yGtB2ieI6XB9e0wVuO5KaJLJxL8cJV9
    qfQQTZaJIPwDUQnxG6t/svyoyevxcmuBvcCJgKPaPIHDu3qX36GGEwWtYiTqpisM71GmMs
    MZQk/MrKYZOG3bANC8tGD1B55ij1V17gfuc0yVEWOb+vnlGCA+V0kpsg2r4ygscdWHnXKH
    iVT2nVnYF/T7csTp0RIX09tqhWs+NeVroptF775KSU5N0IbTgu/KI67dVhMC+OT8o4UrTV
    iCH1a30D+xnlTyQJSiwydTY34q7Y2XKPxpkZeJtgKaqMINnIN6FNTsl3yLxqqb+M++aT6j
    Jic9sZc5IMxS0c28ww1dIoPVyS+LubPBqgARPXmiM/EqpTn9a8HAIoAtoyNg2lk+LjrPfE
    Hn5EID+c4EpRiSRExG4TrJ2Okxfkzc4G/IwpZhxLkqGklOrqVSNdQtZBWP9Q
X-ME-Proxy: <xmx:v7BZatGLwsBxStdv6cVDJUPs7w58D1cV10YYmol9F8ksjhwe24DNeQ>
    <xmx:v7BZajEdlWUOd13vizXCSwh0gIER3wpuCKNmGtQG_WB90cnngGn4aw>
    <xmx:v7BZarSSEy-JTU78W16XTD2k0SKFiGv6msJJDgsSqTMSDdGtv7mSiA>
    <xmx:v7BZakKlGwXyZ0bJuGPjQXtFmHJhxHUB7wwiEMyvVK5--hahaPCsjg>
    <xmx:v7BZanYwarVnZkH_4_NqgTmp415qgsaLMhmh5aW5HnWJNSMFtq99PJag>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:34:05 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 16/18] nfsd: move v0 checking out of nfsd_check_obj_isreg()
Date: Fri, 17 Jul 2026 14:31:14 +1000
Message-ID: <20260717043242.1865905-17-neilb@ownmail.net>
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

A future patch will use nfsd_check_obj_isreg() in a context where the
protocol version is not easily available.  So move the version check out
and put it at the end of do_open_lookup().

Also change to return errno error code and use nfserrno() to convert to
nfs error codes.  Use -ELOOP for nfserr_symlink, which is an error
indication a problem with symlinks.  -EFTYPE is a good match for
nfserr_wrong_type.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 29 ++++++++++++-----------------
 fs/nfsd/vfs.c      |  4 +++-
 2 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index ec925f60b2ae..760354818189 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -169,23 +169,17 @@ do_open_permission(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfs
 	return fh_verify(rqstp, current_fh, S_IFREG, accmode);
 }
 
-static __be32 nfsd_check_obj_isreg(struct dentry *child, u32 minor_version)
+static __be32 nfsd_check_obj_isreg(struct dentry *child)
 {
 	umode_t mode = d_inode(child)->i_mode;
 
 	if (S_ISREG(mode))
-		return nfs_ok;
+		return 0;
 	if (S_ISDIR(mode))
-		return nfserr_isdir;
+		return -EISDIR;
 	if (S_ISLNK(mode))
-		return nfserr_symlink;
-
-	/* RFC 7530 - 16.16.6 */
-	if (minor_version == 0)
-		return nfserr_symlink;
-	else
-		return nfserr_wrong_type;
-
+		return -ELOOP;
+	return -EFTYPE;
 }
 
 static void nfsd4_set_open_owner_reply_cache(struct nfsd4_compound_state *cstate, struct nfsd4_open *open, struct svc_fh *resfh)
@@ -213,8 +207,6 @@ static __be32
 nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		  struct svc_fh *resfhp, struct nfsd4_open *open)
 {
-	struct nfsd4_compoundres *resp = rqstp->rq_resp;
-	struct nfsd4_compound_state *cstate = &resp->cstate;
 	struct iattr *iap = &open->op_iattr;
 	struct nfsd_attrs attrs = {
 		.na_iattr	= iap,
@@ -354,8 +346,8 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		 * op_filp and consequently a valid ->f_path.dentry.
 		 */
 
-		status = nfsd_check_obj_isreg(child, cstate->minorversion);
-		if (status == nfs_ok) {
+		status = nfserrno(nfsd_check_obj_isreg(child));
+		if (!status) {
 			open->op_filp = dentry_open(&path, oflags,
 						    current_cred());
 			if (IS_ERR(open->op_filp)) {
@@ -534,8 +526,7 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
 	}
 	if (status)
 		goto out;
-	status = nfsd_check_obj_isreg((*resfh)->fh_dentry,
-				      cstate->minorversion);
+	status = nfserrno(nfsd_check_obj_isreg((*resfh)->fh_dentry));
 	if (status)
 		goto out;
 
@@ -547,6 +538,10 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
 	status = do_open_permission(rqstp, *resfh, open, accmode);
 	set_change_info(&open->op_cinfo, current_fh);
 out:
+	if (status == nfserr_wrong_type && cstate->minorversion == 0)
+		/* RFC 7530 - 16.16.6 */
+		return nfserr_symlink;
+
 	return status;
 }
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 7898af35874b..b346f683143e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -63,7 +63,7 @@ u64 nfsd_io_cache_write __read_mostly = NFSD_IO_BUFFERED;
  * it's an error we don't expect, log it once and return nfserr_io.
  */
 __be32
-nfserrno (int errno)
+nfserrno(int errno)
 {
 	static struct {
 		__be32	nfserr;
@@ -107,6 +107,8 @@ nfserrno (int errno)
 		{ nfserr_perm, -ENOKEY },
 		{ nfserr_no_grace, -ENOGRACE},
 		{ nfserr_io, -EBADMSG },
+		{ nfserr_symlink, -ELOOP },
+		{ nfserr_wrong_type, -EFTYPE },
 	};
 	int	i;
 
-- 
2.50.0.107.gf914562f5916.dirty

