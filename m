Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.152
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794185738;
	b=aqB2MDewtOoeDltAacQHh6fBZrJxoYUHbgtVpi1/kBqHZB1v1bDLvFusbTSTI7+anVcu
	 dk8hfhSKa7LXm6GNDzi7TcSCczLQXt01ILQkHbwvzYFKY7FBiR7DAOm89PI4FQ3zqzXxJ
	 LZKu3+X9Dn9rtUW2AUG1I7QSwMFgEIjVyzF4iz3ZJZ//nRZj2vBl1PpAtL0PCnBx12lIb
	 7vuZJQC1wOB/mNR4OKjsRZTHJXe5LhSzKF/nmiRpN7Z08U9sntsuh6BKkvqQBqY/xpaUk
	 UyBT1XZLPSEkLYZ5DO7SHmJPeUulfHJxsQ90Mv21/+hezSGjcdVRFizduoKNyQ65sPg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794185738;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=gPrLVsOlUNKWtq0UDxMv188RLW2wDLM5BvWfGyZRN0w=;
	b=IOdglC8aAQRdYlWEN8T0x0JsnBGYMeqvvALm2FNwxgHMaPY0BMpMGCL0wwR+nDd3B+yb
	 1t+Vb9GVFyG0gKttRvOCfXRn3TsJkx2pIENbcG6wzvjwKcVIaaJKlYDYlNeNFknKtT6rw
	 dIOrbTMJPNyWswK7D4x/LyKa8j0rUAlJi7MdYvN/7VopFTWlZOXavjy45jqCUwakejnXd
	 asXt8qQu8l0YENEPCGN9MRv8j5/Vy0xuXcxOumCPz9SN8/oq/um2jDyJ5APT1W5Ck2vR9
	 kivta0J+VRSjkLExSPcSleId/zXSPtcpB5zU/ZiTIqjt80N5xDb9k9bxNQyXQVfWfLQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=1n0Gquk2;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=rvRDHaOo;
	arc=none smtp.remote-ip=202.12.124.152
Received: from fhigh-b1-smtp.messagingengine.com (fhigh-b1-smtp.messagingengine.com [202.12.124.152])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 04FC0606A320
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 00:55:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 04FC0606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=1n0Gquk2;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=rvRDHaOo
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 629C67A00E1
	for <linux-nfs@vger.kernel.org>; Sun,  8 Nov 2026 19:55:37 -0500 (EST)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-04.internal (MEProxy); Sun, 08 Nov 2026 19:55:37 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1794185737;
	 x=1794272137; bh=gPrLVsOlUNKWtq0UDxMv188RLW2wDLM5BvWfGyZRN0w=; b=
	1n0Gquk2F+EuVOfupWtOWF1g14zZDXEx+PblbIorlWMiPS44ERrp0Oi2DJQR9hsC
	doNYNgFSTSpYJMJD1rvqXhj++lAJu7Xxu8UCEPUZRUUrDMVdd4+g+vR4/3KScy4f
	4AOoUV9XglJNBiUphZ/BOs31VqL9q451cSeJ0FLr7PkBlMZIm1KGsuH1YW41484b
	xfct6yKkxt/7c2xln2iZnsF6GPPrJdCdQR1Q9/50UZvuBJjUwkbTMaGDUdKP7KWI
	hp7yC39bmb2BQDfBFQxgU9jOvrLK2yyWSQe+B7Pth1uBNF4whteC6pxi7XydYYSr
	UPp6133L9idZuK21g0A7Xw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1794185737; x=1794272137; bh=g
	PrLVsOlUNKWtq0UDxMv188RLW2wDLM5BvWfGyZRN0w=; b=rvRDHaOoxUGK1QT3U
	C5+9aWXeyPktmH3ibJ2p1DPxZxOz7QjO6RThWXNW4TCadPylTMhmD1fJxSRZrXCs
	v/XGBW0DosPWUumRCHvU9s0NlqEUOo48cwtb3H9He1cWqbkZmTesh8jSq3T+5V0U
	/8i9yhQO0a1d5abcZKkzLbKnVwHD5/i/vp9zI/FINlY4Mnk8TfGs0PezdigsoKO8
	ZRyh1kshbhoJyYK1tRoJ2BqBiEX+TsuUUS5+aKzR6NGW12JtZDB6ZjyowDOWYwXf
	6H52Lp1xSfw80BjjUpl57mDApWSvyN9mMHfDSG2V37dzJJHNuMGG18jiNl/TpO9F
	/aEaQ==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794185737; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm3:rsa-sha256:kfSGtxWtxLVLx/IQZU12BfZh+gEswoMngoXOwuGXwaQAlzf
	RAgDwRjBjm6c8xem8+FSDloM0XlTjIzVx3g60b9Aq/Ao9niK1TqYYw0DQZB/zrVd
	zbUKVTutXXg5VuvlcxK0AMpd3N7oJjduMF23hf46z4b3WS6i7mgHdDKaQxZ0yui+
	AZwYgiI/J9r+9mVL9X54VI+3O3NAw8YZFaDCqIjcqpHaZquuJVVxayKGR3Kmu6Yq
	gt6YQ1JfzyBznlS/s6NZwCQyd9T3IMrAG9X1wSEA22KnbKIcZ1uNeXkxT8byqEU/
	m7RmCZb8pxZaDevXohmFvcVmFp0/oknm28LaHAQ==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:6v6GoxfzvTE8ulC+Wp/bnFzUTg+w+BxpX6sC5/4PPOQ=:tjcKFcfkdnq4XKuikMzfpvbr+sJkZEYVoOZLFcDM6Q4=;
X-ME-Sender: <xms:CRrxagJ0QS9Z8-YOBBihF2bD-3xsw0XCxo0HoppSByoXwkgxc83pRQ>
    <xme:CRrxanAXHbZWXIg-Zjm9yeSW-h8t-FGNC6md42FFsgDu3B183onlOtHiuwfiUNaBJ
    VMuVdgPBhOymgzGyFmUAkJVObgIAM6T3oFMSdiGA73TD7Gc>
X-ME-Received: <xmr:CRrxapAtxAvw2xceqJi9gGF3S3OMCMFiyJGRUw3cY96yy4RosW_tFMLJG1rdQ-Nn08pcV0xct9TIpOK5c0u9obUY9_CiqGM>
X-ME-Proxy-Cause: dmFkZTEQPn+Yge6sJrsh4GhufwVJJvifhQacgyFXIJ+tZ1x4XdAxXqv1ND99BiFwipmBob
    y6nfUHf0kN2kCJ5RQk6bYv6wCAic7bsLt0JR9mOuWfdE0khzy0i/r6mT2IFODwZBE1XnwX
    qo7H1Y9+5k0a6yMzF9wXZGZNt8OvbxR3fvGUCcI/AN0fQ7p0GmYVvjOjxvLxFS1CshLRyv
    sqT5OxKjQROGlzN8+bZuEjnENZiVQEcHEUBCghxrG4dCyhGM8xZ2NnL0+TcZdIWIuUlxhx
    Gx9NlpyjVm7XgMEbt4h+uW5FBsannrghKtNCz0jYE+uxTf5KMu2nl0D7fXm+tjk5ZPq8W4
    ukW1P0me2RC+l/7f2kuF/CWOpyOGVpa3RKQm7ufeTHsV8DABDmFMEEPxqZyM+kzrMQRnhH
    vXzo5IdpQwWojEPI8xFQde99SaBKUcQlWtV/qSQcu2W3s4d3MA4PERp0H1QjAtBMfz29ci
    ToBzTjKGOy+EfRO5+GfPKb+7qyMBr0Q6WU759BKZ/rDDv2YI0hWhtUeMHSdl54qDYFNLCB
    VyrVOQZPF6aUPFOC+n7+zmp7kTJ/sgG8I0PCvpJ6hh8g9VrnCoq56iS9ezXIX3bFB+tjkA
    7MtLNiEVNPUbqK3PeqLmyh1GPm4p8U0GDfCjOqDx6yT/0ZWJUXQp1KUlCpTw
X-ME-Proxy: <xmx:CRrxapDw16nju4l-IRK5wd-FWCKbTnEn6mC2z5iEq-0IoM_kd0K9cg>
    <xmx:CRrxakqK6Cx8JW8W1KoLUS1NE5PjwD607BN32geoMzLWlmB6j-UiNA>
    <xmx:CRrxajm3dbeU-KTGwKkMYV5TPOrpbMdzV7-Sa8oRBOM2jBANBGrJgg>
    <xmx:CRrxakyBgYx6bodG8Ix6HvGFY5JzHN6_UxD3qI9c1nrqZnZVzhM2qA>
    <xmx:CRrxahNSDA0xN-vn3JxieN1-UdzhnKm4EoDwI05a-s7diCg6sgKdumZv>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 8 Nov 2026 19:55:35 -0500 (EST)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 4/8] nfs: don't d_drop() before d_splice_alias()
Date: Mon,  9 Nov 2026 11:52:33 +1100
Message-ID: <20261109005504.1804605-5-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20261109005504.1804605-1-neilb@ownmail.net>
References: <20261109005504.1804605-1-neilb@ownmail.net>
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

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c      | 4 ++--
 fs/nfs/nfs4proc.c | 1 -
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2b015a5c1dd5..eb1bf1b5164c 100644
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
index e1018b03c1cb..22a2a4009db0 100644
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

