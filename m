Received: from fhigh-a7-smtp.messagingengine.com (fhigh-a7-smtp.messagingengine.com [103.168.172.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BAFC13BE647
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 09:31:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.158
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784280688; cv=none; b=pClI7pCV20lrcij3rKfLOlApHceTRx22fBjfEbUn+dD7EuWQTTfY/YHorkShOVtsL051XjcW3Duw9ab0C9Y8gbofm88H0HrVAHYsKdWG0h3oypvng2f/44nH4hA5tkCTT+CPZbrk4WG/grka2bcE9Q4fCmbMLINR1mbvonPf/pU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784280688; c=relaxed/simple;
	bh=r/ViqJpRsJe0g5E04zNZ27/nOQ+w8wzlDKbPgyoVAGQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=t0t6ii09a78HKGYOd2kPL+98cj3pWhv/afM+BE7uswGogm7bbA50KMxq2zamC8FLtUm4ThfzdYJqAbkdR3oN42/tn6mrZGSSi9/zVM2l13lxIUtMZSB1Z/ctn7D9j0qzeQ3fhK20+4ERpnQnalVY711dPWsVtRaCkUCa7LTHi0A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=PZCzoVbR; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=JxJCTMwl; arc=none smtp.client-ip=103.168.172.158
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="PZCzoVbR";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="JxJCTMwl"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.phl.internal (Postfix) with ESMTP id D366C140005F;
	Fri, 17 Jul 2026 05:31:25 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Fri, 17 Jul 2026 05:31:25 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784280685;
	 x=1784367085; bh=iJFqUAEA8Uh5LnQz42qtnnThH0xM0cpNuDAhs/R3/3U=; b=
	PZCzoVbRD3VuT/UGx5yRGay5uECI5WZa0TgkJpHbU5ouHhRGv0pldpvi3g3gnKil
	HCvZs9A6uiLulw+WGCgd9/RjRyUlazi51Z7Gy7m5uEpmy1OZp5iF7U72PU427H8q
	tOZi5YiVm5X9rH2HGwLz+h5sSmQZEFwdoZe8GBrWleG+acdtInu6oRyAZ81gJnqA
	AtElTk1a98iLf02g/4TYpS161MN4vGWwW2gxJOoWQBqkf7fvFirnyqVL8m1G56SS
	2jvnvXZmleynRzTlyPLmRo4g8qtYpf/PY6MKJl1BxNGyUIoESnyUSKg7GHTrxnQh
	swtN0tZxW66dwK9wvKGyhg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784280685; x=1784367085; bh=i
	JFqUAEA8Uh5LnQz42qtnnThH0xM0cpNuDAhs/R3/3U=; b=JxJCTMwlRIR+utgWo
	DTMsJAaZozPjqk1PZYsRuYL0sLpOzpV2MSUYFO9q1yDGl4CCeoDPw7QQRfT8xjZ0
	UBgZGsaOrtvzPCRyAuhnmwUfPGj300686aGqDSaV1Uf4ESO5wdDqMiwfV/i9k6sN
	Y4fvsA7alGjliSmpTIk3ESEvmjbWZw6aNY9+lDc4anJpv4W5VaLeOKexCwyhvbUA
	ldrCDp6zqoaphWLio+9sfH8rLB6jBD9QG8zPNgzkTXRVen1P+e1UC1OTfcUQ0rWx
	AtY9Lq+l2qZPxdBh+2cTo+dPSzjVr0/uGy0gCaasuvaQ4QcJIZh5EwqDUmN7L/w9
	bdXXA==
X-ME-Sender: <xms:bfZZajXCcv2AFMu6fKkwB-3q6O1ibsyppmFJ6EbqszyTZvPHD7YnCQ>
    <xme:bfZZavSPpfpNtyxtYeZFVcowGlg2RomKekBDwwMp3URXcxo_Jw0NtOINfVD88hqvW
    CKNN-wawuLwrMQgpopRPAtc79ucpqRkkl1yvCJuUEaUFKODDA>
X-ME-Received: <xmr:bfZZapPdhg0xxMcm5-lz-UC8XFj9w329kA78jBKIdGsRQceLeH_81UizwbLWjA6v0HNYEnu3cHVlDrqGy24007WK3vMLepg>
X-ME-Proxy-Cause: dmFkZTFLeSmY3ixqka4KlC55qBsg85QSOzArahO9pcWU16vwhY9n3pLhloq6nxziJTlbtD
    5I5Spv/mTk7NcsBoklkoQIDZfGVxmAyJtIAm67t6RtGKLq14Ycl0M7zPAnkMAVyCcYO01J
    Cv3ufQ2tqFOsLlvTthybtxgnz1zOULUZj4roEAw6aPfkifJXoKqRdWsB7ob1/FEfoEvPGv
    iSz1f7AmIp05QUi4Zn68d4pjboG3+xxkxhDMZvZrdVqX5npZILP2jnw2bUIaCSrbjh6p6l
    i4/sgZlPPCH05Qt3wybld8/7pkZttQjOTO7irSmGRWljSe7U/ma9CRxQdqzl/F3bok6OF0
    4MWjR8BpUxZMZkOgk/p7uz/Em62EtgxLipgyPVSCGqkXv6wBMqBH2hCId+SHrp507A3yNz
    KjX1/K/wNcgvFsXqnatxx9QXs/nWb6uWeQzz6UZFOBk0S7f/u0CrDGcUN7PGOmlGvO7EVb
    0ocXauWCm5VcrRDxGX15l+125uXEnpoJz2IXGcpgcV2JYo6ZxEDh3ZBlihVGrv4ZO0DT4P
    h7k/qoxYsynIcOXNPGwDhtDPHvRdnLknpjwzVIWafqLS99sUY1MwMTSr9mDi5xE8XGS1J8
    I4HLnBZvcmrYE7yYBDkrqOk4SmPp8/0G5BnYumV9ZxEzHOtlZfBhgUe4Jvpw
X-ME-Proxy: <xmx:bfZZalTZ747FXCxwkKRvGxMrTUug70KpQTBwHu11jzm3hRpF-Kw8eQ>
    <xmx:bfZZavjPRvHcHH0R1MFj963SYxGYtMq1SgFRzqF3GKHXL2u-TYoOCg>
    <xmx:bfZZam97z7GOJTx4tbGoRz__LzJy6TzI4eZ8Q8VRRoNjMuiaJaWxuQ>
    <xmx:bfZZauG-mTjJoalb2b1ow2ZZDV-PTRMum6llcO_IXE486pI1kz9Y1Q>
    <xmx:bfZZao2HulE4Yzr4XlSuR0DoLWkmvyb3bfKfCGExcq-MzRsweW4rsl4H>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 05:31:23 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 16/18] nfsd: move v0 checking out of nfsd_check_obj_isreg()
Date: Fri, 17 Jul 2026 19:28:04 +1000
Message-ID: <20260717093001.1972119-17-neilb@ownmail.net>
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

