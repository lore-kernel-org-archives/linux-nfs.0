Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.152
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794185753;
	b=KEQ1II85XFnXh2laZmX5gRtHSz4kowzrAqs69aDpu1qqvEEGAOgr2UuW01PixL48Uu+O
	 B+V0T0pKts2GU0IW7zsYA/6eck79d1DElDjnKHZkCV3Ha/7SmRpjF+HS/WdgeDi3ZO8X1
	 NVEL8t+Rw5RyM7Y4n1qdkXBpkSuZIi3g9rgfz8XzHGia/OUTiCpupUil8esNL//lNBDY8
	 V1/bF7mIC+QNMQoF05oV5jpaXH1ws9r0SVjp2yrflvcVhR+rbh3F9avyX5lYbodDcT8ce
	 DXbzFa0uDc9F5KpQv3OY+O9z8PLzTW1PB0qTgOmVpkm/Yw52gu2gcsahlzpNtzka2AA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794185753;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=Hbkp+k7ZMUMmsElC9djGjv3fmS/zGII8fUHA8z83Od4=;
	b=JdY1aXDMNPOSMA6Fhe5rzngiSMBgPUrS/xoNjbn6oiI6bSoawCeQum63aVakXbsUNGWB
	 bu+bjEBlm4CB2fZjHwk8UifXpvQxwB/HIq4p8sgjWCvvuM2xQ9NdXqDOJZ91qxhdpj++j
	 +xgzIdbAkOhMJCycIMMX0eZ99w/epQ9d9a8FOjsOHm+9rpWt3duI+5nlN0kM+6UTgntfz
	 jdoUzS2fPtwMu+JSnJDriJ/AufH+3mAe9J5yTRJSAeSgmDGDIofgGxz3WjqFpfUBpDM8R
	 CtWY4IO23nOu7rGBkflKuFff4g/m+YS/lrGmT2gNTIva2QBhqm+0HO1mef9iKGlPCZQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=ZlWXuxAn;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=aappanqh;
	arc=none smtp.remote-ip=202.12.124.152
Received: from fhigh-b1-smtp.messagingengine.com (fhigh-b1-smtp.messagingengine.com [202.12.124.152])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5EB7606A322
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 00:55:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B5EB7606A322
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=ZlWXuxAn;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=aappanqh
Received: from phl-compute-07.internal (phl-compute-07.internal [10.202.2.47])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 45B047A0074
	for <linux-nfs@vger.kernel.org>; Sun,  8 Nov 2026 19:55:52 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-07.internal (MEProxy); Sun, 08 Nov 2026 19:55:52 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1794185752;
	 x=1794272152; bh=Hbkp+k7ZMUMmsElC9djGjv3fmS/zGII8fUHA8z83Od4=; b=
	ZlWXuxAnqwiqSv1gLpKUBJNS4ZA8OUKjX+C4t5J6JY6MXtyeMXMKMfk/gfJmB3xE
	CMVkjbELH+ISYSiLiY/RzBXyZdflCKZ38niP0mQkER14RlEjsoWkwRl7mV5P0+Qp
	64F927AC2BtbBeAjWobFfy5H5z8qkoh1HNvLlujB8SpEIXtc/wSlTw98alTIi5Nk
	T7RPr0CKsgL28dYbo5aCAq51qRO4ESpopFLdNDWwyTxKPA9d3yhAft7Vu9Erzls0
	XLrsTAHtxDhYdTYSu8XjGEx6eG6owu84hoak+n1BWQ5jQiz2+73ZWeRQ4vqaxCIz
	OwC5FHl4AljNWDyMLIPToQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1794185752; x=1794272152; bh=H
	bkp+k7ZMUMmsElC9djGjv3fmS/zGII8fUHA8z83Od4=; b=aappanqhTth0gWcVZ
	GjdI/WkaGBy44jO3Iy5DJINYg+Qald5HE5U1fiSeXUmlbgGFWYZlTz8jVppPWIF/
	dMFmyLe5gwHrJhSMmxBpUlrVMD3UbQ4BQSs5dwcJUikBEzQS9LjhhBRI4QcPOLnj
	1vCXd4UfxwIOoOVpSg8PwECUh3ymPp7Z7JjMPONNNeC1VtDf0TC88RNNVlRdfHjg
	t0Wk4dcoRLQKdyr87ODL1L0EwUlPs/4SC+7YDPIrMoRdeB3kaAoWV1cHcZIE1lEW
	CPtolUjs72pVkXtqJS3/UzLzBvwXR5Vnp+AHqNGY9TUafMzIU8ja4VGSXhacD+jE
	s+oUA==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794185752; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm3:rsa-sha256:YSoQFW+rAe8oD2jSnXcF9UdbBA88m/fj6JhSlt1sVC0DUUQ
	1FmDB6yM6uQpVg/Vk7wesN/n6dc2BZS63PikHYfZCGVaOMzTJeGIofsaskzXwvln
	FLhcCzfu4SM7F1jTD0IiTbmSKCi/BDnXq+/DWerW2ihIJyIWFjwKGHso1rfD4GB4
	os5m+Gd0FX7M1BwsOGAqzEq7unUzG6IbguShlgF5KiuCFZYnnuWhn5CTcs9KginA
	LQYintzJB1QyRAY4oxemtsCxTqxF4KYlmxsEH4h2gG4st5SpOME/+dEwTZxTzpdp
	VtxJ3bx4lKwd3+YjRXrA8jsmaxcO+tTn/ZMLDDw==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:CqqlDpXr296GEcuTqDd1wuiO35+H0DVHZPABuFaxAfo=:sGjCD+DWnwboWL1MeYRtnOYTi3oNWmcWe8rXfFXojvc=;
X-ME-Sender: <xms:GBrxas0vC8d4q-HVnf1iMiq7N4pkXDnjOUp2tmlWUXDWy9mbHbaq-g>
    <xme:GBrxat9u3r57MCMyP8HmO_tIIF-wlp-x95U6aRhEKHCfJcZLD7HWLhUJ5lsfqBsJ4
    cXWwWQcTnGqmws5hk1ObChFRdqP2jvUqiP2VYh2jmS2t0Zp8rA>
X-ME-Received: <xmr:GBrxatMh-FaGnx--7C8tICmt5nhPzYjE0L5rc5z5JKSmTSwAGiclt_P8HB9W6qVCXtWmFdaHqZTSpPUAOPl56jtbd3hez_Y>
X-ME-Proxy-Cause: dmFkZTEQPn+Yge6sJrsh4GhufwVJJvifhQacgyFXIJ+tZ1x4XdAxXqv1ND99BiFwipmBob
    y6nfUHf0kN2kCJ5RQk6bYv6wCAic7bsLt0JR9mOuWfdE0khzy0i/r6mT2IFODwZBE1XnwX
    qo7H1Y9+5k0a6yMzF9wXZGZNt8OvbxR3fvGUCcI/AN0fQ7p0GmYVvjOjxvLxFS1CshLRyv
    sqT5OxKjQROGlzN8+bZuEjnENZiVQEcHEUBCghxrG4dCyhGM8xZ2NnL0+TcZdIWIuUlxhx
    Gx9NlpyjVm7XgMEbt4h+uW5FBsannrghKtNCz0jYE+uxTf5KMu2nl0D7fXm+tjk5ZPq8Hg
    WUcJnjkiyD1UCqpF4TGoYzsFw5/FWuRUt+pPHdPvdgy8rmo/ldULQ98b3GwuxRtFv1lZe/
    dKqO3khYoOMr19GDsA2e+RlUhuA5GPEGmobTnA8d+ObYU8xuc7oc0tLMtyDgR89dWO8P/0
    w8WXeR4xH2Ib1UZUzWoHNg7bU0BZdB29pKn6jq+yJ0Dts6aIyvZh5qvp/MW6JRdW29hHDS
    +4QtGGr2eueG3RFBBeozCNnz6fSLlHRWV7s5kb8+c4fMMPKqZ5jgLOn570n8Rkl6mNfQYO
    uSQMvsoBvT17rx6/rLbLt8sBlY9sG0mYLT6tAdIeZOesp0UQCl+o/YSdbZYQ
X-ME-Proxy: <xmx:GBrxahcjL6QgjhbvY0fgh7vrpfBw2RZOV_B-XCBjbbSMBe2N_z5J8g>
    <xmx:GBrxasVX4sFVTjvd0gtEfE1hPWal7xwzwrceeCzjjMWrggs-zouxgw>
    <xmx:GBrxapi20qud8GY3adTq3aH_vdxsbSeqYdpmJ55UjsGh4nYGcdEQfg>
    <xmx:GBrxar-WHfMvgmUe9SXXfIa-LkQ6EmGvNSQXTsiyI8XdZfBoUVuROg>
    <xmx:GBrxampluDSnCrCavrMwjiT2TCaZn8XSLElCGsSkcG3NbBYhhBHZ5849>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 8 Nov 2026 19:55:50 -0500 (EST)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 7/8] nfs: use d_alloc_trylock() in silly-rename
Date: Mon,  9 Nov 2026 11:52:36 +1100
Message-ID: <20261109005504.1804605-8-neilb@ownmail.net>
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

Rather than performing a normal lookup (which will be awkward with
future locking changes) use d_alloc_trylock() to find a dentry for an
unused name, and then open-code the rest of lookup_slow() to see if it
is free on the server.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/unlink.c | 59 ++++++++++++++++++++++++++++++++-----------------
 1 file changed, 39 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index c8d712204e64..15c42d82a8d4 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -448,7 +448,7 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	static unsigned int sillycounter;
 	unsigned char silly[SILLYNAME_LEN + 1];
 	unsigned long long fileid;
-	struct dentry *sdentry;
+	struct dentry *sdentry, *old;
 	struct inode *inode = d_inode(dentry);
 	struct rpc_task *task;
 	int            error = -EBUSY;
@@ -465,26 +465,45 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 
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

