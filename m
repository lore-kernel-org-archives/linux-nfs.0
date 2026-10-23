Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.146
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792720426;
	b=sRgkHvW3PLC4Uoky6nKsghBWLE5Ry2vcwl30icYnn6oE/S/T1VO7yQfWYZZJ0u1efzpR
	 ey3Ig+/VwBgI0Ue1U73IFp2y0Zbqk647ad8/l3qBtVvkHFh91RlcGQRhR4X9ReSdKlgrL
	 pjHv4zUEaG9oqCmn0NWxY6cjQnhT4xlWNj87IxTTjtqvXgQcnrjZqPrTRmtztC3ypNjZr
	 OzoevW0EPZstn+SJmc8snt6JPu0jmnvMy3Z9/kcMFmPFEyErRIW/FzSPbLf2SRqrJ7lad
	 0cTw0RJrMUX3DRdCP+1THlSH3v4a9XfENDbKNtI3pTgnh7nz3rTJ6qZemt5fnsFdoPA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792720426;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=HdHebxdKhpXqqd0m6+YgUsQpX199pECCZdgt3PFRqbI=;
	b=IpN6zKfOYobZk0NYh729rnoScTf1dxyy5WCSSbPXxVyxeT6pD4xOEKIwzz3kFBV+QkN0
	 GnobVy4q//Rhbch+23RK64MmhalFgEaAkDnWkApWSwfptkRjPmdpU4dQXUKfTfyZK1rj2
	 Wvbabd9j0dhSAjpKvByLPE+2N5MKUq5aac3dBqlR5tOy9GvX7Flrv6U9bzU06SYnX9e+H
	 TgHF38FbUBrQ88O6YINeOwJFNGxf+V00Vv8EENHOi0xdnXcc4jNyfuSe+UD/DWLAqm6z8
	 Ki/R5rGiDIxjiEJiyYJQKo57gq5WP98PLoDaRNPPLlxBff13GUJ6QAd40tOfDyVygOg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=gf45WkLk;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=XuB8BDEp;
	arc=none smtp.remote-ip=202.12.124.146
Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6DF2606A32A
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 01:53:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A6DF2606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=gf45WkLk;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=XuB8BDEp
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.stl.internal (Postfix) with ESMTP id 309AD1D001B1
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 21:53:45 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-04.internal (MEProxy); Thu, 22 Oct 2026 21:53:45 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1792720424;
	 x=1792806824; bh=HdHebxdKhpXqqd0m6+YgUsQpX199pECCZdgt3PFRqbI=; b=
	gf45WkLkzzhfmI09RtETctc9Nn5BcZfYZA5s/M5mKE76x81q7fp1dqv5jGsnAKcs
	/Zo6z6K5noZ02sn7SulxVTXAUtHY3WCq32sBFUAbQDLJXIXa5UtVOc7J5gnjXW2e
	xpbLmcZG5POW4Rsrddudh1mbj1b7Ty0aw7LM6ZDUEkNH3Rf0WzsaN5EO/1705gMC
	W+1E1ERffIcdnrNftYrCjSZS5V3RhUV7mwSNonZD4EXbv1ztCp+p9OyKTGYEWR65
	CLVQaJRyp+kSDVa0iIe8nfrGYGP+sHe5kG8An5EiiS3zZm1+AcWvNMucg72mdI5Q
	adMDS6ZOTcttZzP52FSung==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1792720424; x=1792806824; bh=H
	dHebxdKhpXqqd0m6+YgUsQpX199pECCZdgt3PFRqbI=; b=XuB8BDEpN1+Du50zM
	MXgjrr/9ZpP+wNqGO3sU51EvZnQ8Pc1c1bxsP1uM012dHqmkl6o34B0YMq2SDJQe
	kNx+/zJwhbL72lITAOb9IZVLKc98SAwCKOCa1Xc0cOerb6KMR1g+oU9KGNvmC/7m
	UCiENHlShR1mZ2aGarNZER7ERHLBvXMUhsgN6ONe3DOPB0gSPb/f+XPsOvlc0+JK
	P7Ro1CeaxKzFtuhGSBLavi2tFYUb7jFjYrId5G+8QN12vpVRfiYJsQE08LcUuqOu
	zDae+epiXVEE1ZuHZNab5kn03mAxFrVJxaAzdU2rEeME2j7bJjxLH990uUggMPhm
	nb6ow==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1792720424; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:bdZ5e09Mm0bIyL85XOjKJASYvA7/PYJ4KroWGyDAMwthiWZ
	koiPWrJ+GbQJfVKdaAPDWrc4lVjTAdXfIe3MzxQjYmsZ1lVcnshY+iCTHgfIuzlD
	o9POtUr7tMQ0abVyFCVfuJOdYx8de0YPjxWGIfk++Fvsuebl9XzeXlsP3WVtDr44
	TrQY2NBCSRUevw9+7+WWeYftxqUaLyA0uL8aktUekGYonIRx3hJfSAli8jsSWpFr
	L4cmFeDR8h8t9s/IsoVHUpXueTCpn21fZdnsjuAK4DIXMcKnajNVYaznWYdNw26r
	Xf4ntR55AMV9cUpYYIlPoEiqmsHV8NnZRLSPsGQ==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:x7Ii+fFpU4vbH1ECyBBb8sx9l3bGU+o7k9uZHF/HwwY=:wYSIAm8YsbVURQBQTWfolAeLVN33sC0Sn3ksxmzIZX8=;
X-ME-Sender: <xms:KL7aavReDC6_VydMNUYFeWHJb-5Zobjdi0qHYO8h13mDSePL4mbbrg>
    <xme:KL7aaj2n-AmnscFTOVLMc_CqTtU_fWuBs271cUH5ZjOaQLejAOnOQDS0aeVidRjs5
    vwGrNqRFTeKZb4DTBx6a5ef5UDbn663CABDsq-l9_Uc__eG8RY>
X-ME-Received: <xmr:KL7aavfaeRMdoBwkobdJnoGzHI0AHcwDByGmaMpfC6iBnJQM_NozMLOLGMnLQbleDjaezh_4ot28VXRyb-C0II3_RiyplXc>
X-ME-Proxy-Cause: dmFkZTFVyNFdAZA/YInXu4cBUv41coFXzEDPlYDDipjNd44Ia/DjUEmy4uZJYf3Ff1wTHc
    ma5gXE+K5gN81uC/U8tvhPqWiGL69fFdM2OiFXqWmt6yHeen0UWYHq8nNnhM/2fZRZgFVu
    Et59zr/Cham0BU2l6WZC2hfA7WGTu2wFUyVaPwxeZdwDhGlW8r664If73I/cqgTVNE8GQX
    F+tnbIcSOITzdTHaai1tWTB/8nPf+iqkKJLKPPywa0hJ2rAjT4FFcfdgtG1y3YofMUu4Nj
    qLG8ElCPhcCxXCnUeoFyFAcSh85jVzzIeKI0tLHwgs3uQbUpq8nVHJ71S2LFp/0JXC8Lhk
    w1snlM6Z/0AFY7HHipGof6QKQdwdQ2UF+yqzu8zsoPz20bbTdSoEmgLWsb8atg/McZwxeN
    sO00TIcmYOixNh/RhT+X5kpwj0Q6IiwEpvT5g1SH5O4w0+3W2tSN742+IUIVTrIYMCJ9aV
    uOTAhYp7nC9d1PiNzE3cJvwwsRJEB8x0q/LeOSjnpY/EGhQM7EAZF3kjt/fDizbgQH70iR
    29ICpvEoRLyNzQOWkDoHrBUNDTHBXuM6cM2XXyxQalpq4ihgwNZPbzeBBTfNxGDf8nJdHE
    TWGbh2pqdYznGXOmz6P7Gm4Mh0KJ35uRQwtbnWzpUeW0ma6Vt+huuo9ThUSw
X-ME-Proxy: <xmx:KL7aarOcUqxVj2vH93YqXmDOgVNBYZdDVBNAuefiN58cZUKV4EpX3w>
    <xmx:KL7aajXzudrtNxpG1YHSqKkgJUmGGl4W6MPrQy7KD_JMD9uq9fU2og>
    <xmx:KL7aajw8_B4DZ1RW93tacDpdgXSTsO8vIHhdm6AgK0roILQubeCcMg>
    <xmx:KL7aaq9PTuiX9Fj-NSFZzd4OLLWjDjBumcdOsokM3a3CARylpleseA>
    <xmx:KL7aaqpMJs024TNRWno-P0JYCEqBCkZY_uecXs9ZJaihCBK-Z3LHsz4p>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 22 Oct 2026 21:53:41 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v3 7/9] nfs: Use d_alloc_trylock() in nfs_prime_dcache()
Date: Fri, 23 Oct 2026 12:50:17 +1100
Message-ID: <20261023015239.2163480-8-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20261023015239.2163480-1-neilb@ownmail.net>
References: <20261023015239.2163480-1-neilb@ownmail.net>
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

NFS uses the results of readdir to prime the dcache.  Using
d_alloc_parallel() can block if there is a concurrent lookup.  Blocking
in that case is pointless as the lookup will add info to the dcache and
there is no value in the readdir waiting to see if it should add the
info too.

Also this call to d_alloc_parallel() is made while the parent
directory is locked.  A proposed change to locking will lock the parent
later, after d_alloc_parallel().  This means it won't be safe to wait in
d_alloc_parallel() while holding the directory lock.

So change to use d_alloc_trylock(), which removes the need for
calculating the hash or doing a preliminary lookup.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 8a98247b6b2d..49283f533d6e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -749,15 +749,12 @@ void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry,
 		if (filename.len == 2 && filename.name[1] == '.')
 			return;
 	}
-	filename.hash = full_name_hash(parent, filename.name, filename.len);
 
-	dentry = d_lookup(parent, &filename);
 again:
-	if (!dentry) {
-		dentry = d_alloc_parallel(parent, &filename);
-		if (IS_ERR(dentry))
-			return;
-	}
+	dentry = d_alloc_trylock(parent, &filename);
+	if (IS_ERR(dentry))
+		return;
+
 	if (!d_in_lookup(dentry)) {
 		/* Is there a mountpoint here? If so, just exit */
 		if (!nfs_fsid_equal(&NFS_SB(dentry->d_sb)->fsid,
-- 
2.50.0.107.gf914562f5916.dirty

