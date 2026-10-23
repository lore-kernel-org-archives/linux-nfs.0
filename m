Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.155
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792720432;
	b=TKPtnM28WtWWMit4N3X3C9dvtvKEwoW91F7z3Q6JG26LcrptjfmfCJjgIUQWSdqgZGyo
	 ehXGYk/soIYeDTJ4SulcQIZxRhSFB63gRwJVOaoyEqAhFEJR26zDbzjQaOFAeFHSjGfv5
	 btFPV0+fQfPNhgeIt8TZw4SoCpIPljqzzeSoGlrqJ+ovDGzXWAz0FhgFzvFst//UwR5Cd
	 MvAQNta84DuMmToQiqJqxTNtSEXBeXN3HBtUoIKJEdqTrqH/8gEEA462xVzEqm2j0fep9
	 KofZJlNeLQHuESkJqp90K0xQ27xWwlrKFp7D4H00pgW9jZyuQ+QGk64Ia/TnNxrn3Yg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792720432;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=oFOTcabOUaDITG4tMyEQMGpORQ3w7TT9QEt5KvYucoU=;
	b=m6OamER6RGj9LlRJWTFa4hwVIcGoOO2AhNnyOF0wYp08Ia9p5AGvAh4XFAWLeAJdYheE
	 6dVM7HIr/7Ds4FVhr09H8NsU4hBNP/p07RXDNSpHJMe0kqm4zdYEUzutUJUsZ8j9RhZ6y
	 cZ0pbZ/KR5OfH/fBWzSKrnH+8WJpVTgoALTjkUtPUX9zr+s2azmlPaKx1xyofOoyQ51E2
	 dpHcmIqWbT6KMr83SeoQTQFDJI9A8vdxnxEWzE/q95ads+MKV1zIUUYrcp+oyCXwUN++4
	 UXa50mQZOO+Xv+xSdT9hSnR1Am1bWlCkiL4yRepHcPJcFESHfNk9PS4L+LQ8ek8eUyg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=Fi9p00jV;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=ii0AmO3y;
	arc=none smtp.remote-ip=202.12.124.155
Received: from fhigh-b4-smtp.messagingengine.com (fhigh-b4-smtp.messagingengine.com [202.12.124.155])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 56168606A31F
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 01:53:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 56168606A31F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=Fi9p00jV;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=ii0AmO3y
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfhigh.stl.internal (Postfix) with ESMTP id D254A7A0186
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 21:53:51 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Thu, 22 Oct 2026 21:53:51 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1792720431;
	 x=1792806831; bh=oFOTcabOUaDITG4tMyEQMGpORQ3w7TT9QEt5KvYucoU=; b=
	Fi9p00jVJxvMNmIDPXiQ6PNVHer24j4pxJujxhVoR4wH2tm3L31Y+rTPINqCcENK
	JhC+sZu3f9n+yTOuksLLQudO7OB02ToTLhCAhuW2n7joKZV7+3hFPJU/Tle64iVT
	CGd2XKWo5pdtEROT6WQc2pmezKmZyJsPmjGKh28obhOLCTORcSwyw7X9FBrFoD0F
	JV+Z0tnD9hpaz4Ylbu43BcphsIjoUMnPmapdGA4U2XCRSVA/TKcM3K5BNBtHjYbj
	ia+80Mf/wCWd9LfPgP1zPvZ2svilLIrbXqHk8BMxPcM8f4P8ktDpwctgD3hv4vfm
	Phr7AmHACI/HEp+4KVKngg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1792720431; x=1792806831; bh=o
	FOTcabOUaDITG4tMyEQMGpORQ3w7TT9QEt5KvYucoU=; b=ii0AmO3yTCkaUnPBh
	yl9Lqv150GNwEYYMjFBVdorK0XImkcufAHPZxEvdxR8Ls89gKr+TICrRfx6NCXcW
	85CX+1MC2VthCTywQ972onSj7oonCtwHKrQBQqUB7gmFQOx6i3D8yC7jddO/CvB9
	PWe5q4+qFHLKm5nUlzsc+EBxz7AhpxewH7oq/TBA/btmwx8Esm0zK5ZOReebaZLw
	8x00snOlqtQKw6uFT2eiruZ/E76VcpKBZkQkdJ2TKeWdGnWgeZ2ufKdoSJryOGkL
	ybM4KZ4ncESxSg+1LFU76WWcIFI+vvRV2KNJUEhpHalfBhLW1N7jvr0YoAwt3Zuo
	xArZA==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1792720431; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:PcHer5oEEdTKERlbl9HE45pf5KOjp9po3SU2WkYE5css9+0
	JE+07KnA4l4xoQqyfDL4NicPdUr5oEfOvvrW9mwti8woYw7gbCmKQ8wz8yBKOVHA
	8N+EBEyELRmgTdfL0BbYfVuN0roEVldbvwkkdHYdne9zu3J21xIK/QUh7A4zHKer
	tdnpUGBrOEN3G6tiKKzbI9bM3dO6wd2GHm6ttgHUvYcW5aNihG+ErFYgwvrLkPip
	jSu2tfXBGmk+eZFJCN23J+EoHrS7nMR5yHqHvhl5I9/fv5/hiiOnDfj454xYQclD
	qZd4Tuf/nZN3KZK3KIVI3fe8Hr64vvB096CfA1w==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:5ZdfL6FUKde0j7j+Y9LZ4el5r9e3lJKtwMsVkWlcIeg=:rbHspKL6TWJzpn44ltkPTz21vMfy6PPF37rbDutP1vw=;
X-ME-Sender: <xms:L77aas8VDRdr0uEhn_H4g6PhAsxYIfD-T7ZlT-cffx6TnIKTnTvLKw>
    <xme:L77aanxEc1_g3bL6N2-XrtaaH5nPpPniUC_UgtS6NsB5WiPq7iVsyMhCDStj2uXs_
    x6VbSmiix2fEZsNZS52R9NPzUvzcS-01l3vmjMMGLuOSzO8MY4>
X-ME-Received: <xmr:L77aaspoCTrArW1MXn93s3ZMGtmaa64UxzVASaWTVndAr8-7kzOdfQ6634zSDRwejw5OkDYbL2VuyBCMCL55qvKZq7jLIv0>
X-ME-Proxy-Cause: dmFkZTFVyNFdAZA/YInXu4cBUv41coFXzEDPlYDDipjNd44Ia/DjUEmy4uZJYf3Ff1wTHc
    ma5gXE+K5gN81uC/U8tvhPqWiGL69fFdM2OiFXqWmt6yHeen0UWYHq8nNnhM/2fZRZgFVu
    Et59zr/Cham0BU2l6WZC2hfA7WGTu2wFUyVaPwxeZdwDhGlW8r664If73I/cqgTVNE8GQX
    F+tnbIcSOITzdTHaai1tWTB/8nPf+iqkKJLKPPywa0hJ2rAjT4FFcfdgtG1y3YofMUu4Nj
    qLG8ElCPhcCxXCnUeoFyFAcSh85jVzzIeKI0tLHwgs3uQbUpq8nVHJ71S2LFp/0JXC8LmA
    0gABOtnk/L45iewAIYmpJc0WACoupQpwPGp7FkLZ67rTk11v9F8BzyErJ8tFkWCybxtGBe
    a/hDsmRczLKEp3rmWXjPENESjqHDMzgWyLR9z7epCBii0q3z6Xdw/raWi6xE657CBB8E+S
    XGVE8Lm5ysLLyJHY5OYmRBTcE1MW2dpnF82n0bCWFhX8uU5Nqh8RmltUUUxECFkc6WA0yj
    WkG8wcCz5STVjk3+dHho9XfC2k8SqpmEEgNqYKzFnGIaWDljtDExyvatkUaqvp6JRvgNOE
    9+MzS+g0rgsDMTJrorFJ6z6l8fsQth1z49/cr6yvIlkZcQGkq3Iso/DBGtyg
X-ME-Proxy: <xmx:L77aaoqRYckYYhLCmfBqAw25BEaEVdjOUawoufKaci-Szyra4m-lrg>
    <xmx:L77aasBcRdJe7Dsu3-1MM-xQlj0HeCt2h4CpOHv7XPvxextWUBEBkA>
    <xmx:L77aamsOT5wYGFTHDGzDfEUo-qPBCEfoThg5Skm1zjPircHcP_eEEA>
    <xmx:L77aarIHvDJukzsajCvbo0McjwgPZWE1ABazMc1rqEI6lNnMP2NcFQ>
    <xmx:L77aaunAIUbGxoBCaR-1N2sy7AjIBIecWKK0h-mo0nFr2_qIuBUUNcqG>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 22 Oct 2026 21:53:48 -0400 (EDT)
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
Subject: [PATCH v3 8/9] nfs: use d_alloc_trylock() in silly-rename
Date: Fri, 23 Oct 2026 12:50:18 +1100
Message-ID: <20261023015239.2163480-9-neilb@ownmail.net>
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

Rather than performing a normal lookup (which will be awkward with
future locking changes) use d_alloc_trylock() to find a dentry for an
unused name, and then open-code the rest of lookup_slow() to see if it
is free on the server.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/unlink.c | 59 ++++++++++++++++++++++++++++++++-----------------
 1 file changed, 39 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 11a46a993e11..0eddc7ee1115 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -451,7 +451,7 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	static unsigned int sillycounter;
 	unsigned char silly[SILLYNAME_LEN + 1];
 	unsigned long long fileid;
-	struct dentry *sdentry;
+	struct dentry *sdentry, *old;
 	struct inode *inode = d_inode(dentry);
 	struct rpc_task *task;
 	int            error = -EBUSY;
@@ -468,26 +468,45 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 
 	fileid = d_inode(dentry)->i_ino;
 
-	sdentry = NULL;
-	do {
+newname:
+	sillycounter++;
+	scnprintf(silly, sizeof(silly),
+		  SILLYNAME_PREFIX "%0*llx%0*x",
+		  SILLYNAME_FILEID_LEN, fileid,
+		  SILLYNAME_COUNTER_LEN, sillycounter);
+
+	dfprintk(VFS, "NFS: trying to rename %pd to %s\n", dentry, silly);
+	sdentry = d_alloc_trylock(dentry->d_parent, &QSTR(silly));
+	if (sdentry == ERR_PTR(-EWOULDBLOCK))
+		/* Name currently being looked up */
+		goto newname;
+	if (IS_ERR(sdentry))
+		goto out;
+	if (!d_in_lookup(sdentry)) {
+		if (d_really_is_negative(sdentry)) {
+			/* try to get an in-lookup dentry */
+			d_drop(sdentry);
+			sillycounter--;
+		}
 		dput(sdentry);
-		sillycounter++;
-		scnprintf(silly, sizeof(silly),
-			  SILLYNAME_PREFIX "%0*llx%0*x",
-			  SILLYNAME_FILEID_LEN, fileid,
-			  SILLYNAME_COUNTER_LEN, sillycounter);
-
-		dfprintk(VFS, "NFS: trying to rename %pd to %s\n",
-				dentry, silly);
-
-		sdentry = lookup_noperm(&QSTR(silly), dentry->d_parent);
-		/*
-		 * N.B. Better to return EBUSY here ... it could be
-		 * dangerous to delete the file while it's in use.
-		 */
-		if (IS_ERR(sdentry))
-			goto out;
-	} while (d_inode(sdentry) != NULL); /* need negative lookup */
+		goto newname;
+	}
+	/* This name isn't known locally - check on server */
+	old = nfs_lookup(dir, sdentry, 0);
+	d_lookup_done(sdentry);
+	/*
+	 * N.B. Better to return EBUSY here ... it could be
+	 * dangerous to delete the file while it's in use.
+	 */
+	if (IS_ERR(old)) {
+		dput(sdentry);
+		goto out;
+	}
+	if (old || d_is_positive(sdentry)) {
+		dput(old);
+		dput(sdentry);
+		goto newname;
+	}
 
 	ihold(inode);
 
-- 
2.50.0.107.gf914562f5916.dirty

