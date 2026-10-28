Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.159
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793160675;
	b=iJ355dHMPIi1nwd+VFfOVzmeMcYG4rWY9EcLGqm5BacfS6hgs0R7iDK2Ht2MKrp3nN6+
	 I9DnN2eS8QTFAhUmC0I2x29mN+YjuS6SpXmAtr7jJANiSNhuENXnuOKHf8NWcOSxfHXf1
	 TbXzHW8Hhv4M0RQuTiPIinng20K6yBLC/IWR8a0sElj8rtZ4QlAxkBRS0EGQgkmZSFZIj
	 YSfs+MD5motCEAqkwhdXKYFPRi5u97svNVgP/EgfbPJDoVePNtZPaeQYtbJIPTDypRbYR
	 jlvL0t5SLb97zDp8FpWMqrgzd19XsvH1OS3NYJVRmpQDaZB93i8z0ne5fVn/DqG0/xA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793160675;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=M2nhzGeTR3XCn0+kY7MvMAf8lbsMpETg5OA2scdJMc8=;
	b=OevNKh5pT5ZZ/C5ZDzfJxzNybjGj1Rxdt57Gml4Kmil0J4KvxNLBg19saYcBR6IQ+u/9
	 nxCNOmnJvW5VkORpT9C5iRR37ZEBBMJ6B9c9xujnkUXqRx1ZHFsgvWbTd/nxI0hSaf1tt
	 8O8cL5nBUDMqHOKuqSqNdopPdUhmOyLNE53D30DnzVoC70KqAgOW3goO480owWTqcKAK5
	 Lrn9zzuoUyP2CTZE7PIRhuSuyabG/1djwJkyRjQoV2mYiLFqWe8S4Ci0XqIQ0wphgGbp6
	 +YLtACO6FbxAMsiYQdw2CFhMI+nXS4qDR+Iodbt2dyrlXt7iTEYSzqLppztxEP8ILkg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=QhzcunxG;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=gCQaU0Ff;
	arc=none smtp.remote-ip=202.12.124.159
Received: from fhigh-b8-smtp.messagingengine.com (fhigh-b8-smtp.messagingengine.com [202.12.124.159])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CEE46606A31D
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 04:11:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CEE46606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=QhzcunxG;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=gCQaU0Ff
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 413577A021B
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 00:11:14 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Wed, 28 Oct 2026 00:11:14 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1793160673;
	 x=1793247073; bh=M2nhzGeTR3XCn0+kY7MvMAf8lbsMpETg5OA2scdJMc8=; b=
	QhzcunxGlYPybCeBULs4Yhuhs5yQ0EL4ltL5eQ92ZFdPc4/p83CQ1sG/t7SqGV5F
	RYI/cdujNVLNcSM5QlwM90GWh7Tcz6w0mdfEx1bQAyiBUK0YU6HdbF1cEGxPgsM5
	+IS7UURjAzLMyDelSmtKRmC8eICKA79XaJwHegOsXNMegqAe/1K/HMlrtsvrCBR0
	wOZVB1ojvqVn13+fMNv3sZa71lv1gIH4dmE4RYbi2cyLwi4L84YwHpJVfNHIxvDG
	aoQyPICC37rV/DjYnRy2SU7FUBTzW/zTQk+Lusacg3OJzgbOcFpnTHoOf8EgEQwr
	nSVFhrExnns65abkUqyHkA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1793160673; x=1793247073; bh=M
	2nhzGeTR3XCn0+kY7MvMAf8lbsMpETg5OA2scdJMc8=; b=gCQaU0FfsrZnPw1iv
	iYil8KDTVaKl2nFigOXlBDi5agjT9CRU/+tw4xVxCw5z/kIFf5yBYGx/wSeEgasP
	B5vfJ7I+GbPSC3LJXuTnbqh1CtJNf49zwKv+AuLMaYHLTaRy6Q+bgqJHJ+CZgcI3
	4sC9wpqofEQQqVozvEqU7dsKf1JpzT4JVdijeU7KW3+/o+jKoyEvfnMZEOOScMPa
	j7Xz/GQbZVC52Tt6SuxLT3kvuT7ODnlkEcqScEpPV1pHkoxVh5k3ZyuLzosJd2eo
	KbhJ7FXz6vOdHnzBwjIJWzPZD14HY/D8H0QYCgDUoBVwRdTAw4q4+4H3KZKt2/UP
	Lpkxw==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1793160673; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:iBKI44RbB+6/ExXswkjyc10GRaCdA0f44k5gPZYHVPm4Iid
	jlP3iSG+nW08WeNRujCNd9pWcrfIaWcsGB2Qzpjbs75D3w7C1Y51ObsNbzNTNVbU
	iLZPvzfWf4O1pLGE5H2/Ag9sLOAzyeVzdHovvEElehUzqXFmtQJ1xhWEbcSOcb88
	hQc+ap93VQ0d5++B1pptq5sdfwyO1jN/UBo+rA2IGOr2QvzdsGtFjya/v3CybH+j
	w1hCIZtMPf5528cgkviCGm5nTIHg3QvQw57n6L8re3WqQUDNsen3Fjjm6b+C6AJF
	+N3unU6S7QEpXBsFNvOIx23MTmNv5SUnR6FULVA==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:LMj66w5S38GQOV1O9IJl8BRHO1zeH6SR7Vp/bS+V8RI=:NgedNFXdS406by5Est67Dd5OKKOnPltMOciR/K/LVrQ=;
X-ME-Sender: <xms:4XXharQA3czSXkIAouI3tMf5eB2XyNmmDf4esUoolXwE5Vg3fChwfw>
    <xme:4XXharCKI-nCbIQfJCyKgnjWoPIwIzEZuv8g87smv4A4JgWoVAKDVdHFrojCCobVC
    YHGtizHfxIoj_UhEOlZ5WjIX3PTUWEeGJvIJANMwOuPpuW7tQ>
X-ME-Received: <xmr:4XXhaqJwSqRqQ7iwEf-om-ngyXDSRrpDsfF1UfSemn-6kKVmzSzIzuXFH7BZSLZCKsHOt_p3OXCX74MjhJP87aYGNpfak94>
X-ME-Proxy-Cause: dmFkZTFqL9d6vtBCb+NcWzd/7SiNibAA9OzG8/8ItNoKhrCbp6apHJN0xGHTCiaM1Ns9eo
    Lr4mu7Y4yew0MDnBN6JXNQRuaqzU16LCUJ7ad9et0QcMvgBWEXRg1603Ru5AglHe2+TxKv
    ydoMFP7Hms9hJwmlbMuKnQeaW1uHkQOzd/uAKOtWzI+liIsbjRbrwDvwZz57yfNjJsYMfS
    GK3j7TzeoY+fFbVyhaDEEKjSfaVH0uPQQGvy9QSfC9U8EamqqN/pxHKYIXHw2LlfOVJIla
    6PTXYyJsCWjbbbyiBydX7EBzCiMYy0tMvaOQy2L3pkcXcIGHXyMFUhmiaWdxscS01qQeC9
    5An1Hau1k16g8+1k59Rfb6+G/x6GsvltVi/ZaDs3vSX+CMbsJA3E5NOkp42CcaSPlwwDnd
    ZF6oSrwkDLYs0FRgBWKkvQnKI15HiwoBX9CooapKlniWJJrlTNIaXVtcBPbNdxjGlPehj1
    HNwCUynLLZEI4JWCZfyfDA5Ivx+/mUsZqu7TnJBGRjjYw5aRXsOFOr8y1RQG210HqbP6mQ
    97QLZDUHo7qAKyjCjjeul7fw79MfGmpTJuET5Ch+OF4Ku3DnzseQK8zbwZUtonEYb339Ps
    GcVufJ/DLF9Pkp1SHeKOsK9M+PdV4vr3HVDZzPUFBEWpe+2xVYoSh4harcNA
X-ME-Proxy: <xmx:4XXhauBTIB1WxGWjAsUzAqlYHoDkAIqGo2_vCindiuhxqBdlkyx20A>
    <xmx:4XXhansRatQcPvoc0FGo9W57V6qu8-LGoo8Bf8WUPP1iweNhLB-dIw>
    <xmx:4XXhakRec0Hx8vGSTmS6Bvt9KztECTtQJd1PrSKaROW0I_fZmg6n0A>
    <xmx:4XXhamJ00SvTuxonfS7vIi-_b1KMdVBzV7taA7Qpbzib-GkIPERsvw>
    <xmx:4XXhau1iGWRucYF-bMxQ121AQqmUXP8jWMkZukdqnoerjCE_Rzfvoa2z>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 28 Oct 2026 00:11:10 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v4 5/9] nfs: don't d_drop() before d_splice_alias()
Date: Wed, 28 Oct 2026 15:06:33 +1100
Message-ID: <20261028041023.3738553-6-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20261028041023.3738553-1-neilb@ownmail.net>
References: <20261028041023.3738553-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

nfs_add_or_obtain() is used, often via nfs_instantiate(), to attach a
newly created inode to the appropriate dentry - or to provide an
alternate dentry.
It has to drop the dentry first, which is problematic for proposed
locking changes.

As d_splice_alias() now works with hashed dentries, the d_drop() is no
longer needed.

However we still d_drop() on error as the status of the name is
uncertain.

_nfs4_open_and_get_state() is only used for files so we should be able to
use d_instantiate().  However as that depends on the server for
correctness, it is safer to stay with the current code pattern and use
d_splice_alias() there too.

Acked-by: Anna Schumaker <anna.schumaker@hammerspace.com>
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c      | 4 ++--
 fs/nfs/nfs4proc.c | 1 -
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e4c7acaaf2ba..b29dc1260d91 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2362,8 +2362,6 @@ nfs_add_or_obtain(struct dentry *dentry, struct nfs_fh *fhandle,
 	struct dentry *d;
 	int error;
 
-	d_drop(dentry);
-
 	if (fhandle->size == 0) {
 		error = NFS_PROTO(dir)->lookup(dir, dentry, &dentry->d_name,
 					       fhandle, fattr);
@@ -2381,6 +2379,8 @@ nfs_add_or_obtain(struct dentry *dentry, struct nfs_fh *fhandle,
 	inode = nfs_fhget(dentry->d_sb, fhandle, fattr);
 	d = d_splice_alias(inode, dentry);
 out:
+	if (IS_ERR(d))
+		d_drop(dentry);
 	dput(parent);
 	return d;
 out_error:
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 21e5df7e5251..e8ca92b07190 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3113,7 +3113,6 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 	nfs_set_verifier(dentry, dir_verifier);
 	if (d_really_is_negative(dentry)) {
 		struct dentry *alias;
-		d_drop(dentry);
 		alias = d_splice_alias(igrab(state->inode), dentry);
 		/* d_splice_alias() can't fail here - it's a non-directory */
 		if (alias) {
-- 
2.50.0.107.gf914562f5916.dirty

