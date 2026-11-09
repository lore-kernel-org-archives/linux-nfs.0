Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.152
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794185744;
	b=WZ6Ho7nc3DTrD1ZuwuoI/wcVtsMqmQ3yS1VLInLwp6tjRV4pDeCKS43w+FRoUcslvYP5
	 adFV2Hx4tj1tmF0vsA7WImo/LuGgKZ/KbxRs0179hzWkbOHCdzv5ofFtTgl3ng2TrFKbT
	 MDVuTv4uLdCaeAPyt5lvl9xO9fnaeiU8sr9NUgMrodIjuPxHdstNVFnxG44QGJrkXCKtC
	 LYu98RjZxne04QmnFmMxvldgSCZP2vqhtq4WsPmvHfOJfw/PG+1QNOirmrb6sOyv7iNvv
	 k7SWNfm6NKDnxnUzjeHZXOlJHE9MhVIrtYVoTJsNwN1VUGqBU8BroWQxA7uB8xyTUTA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794185744;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=NW1EukNYyIEJmeKkR2HmqHO4r3689yE0vQDmJ3LFXdQ=;
	b=kAgTIpwN3fMTyg2hs6UTtSal0znSA6qcczbWs7YWMuuHa27h9N5uK2bqTGHB0D4d4Ioy
	 dtrMuOpRhbpqwVI4IVlVxU3+cCuc9rEE7yUjrIsLAhyT9jNYAnGpIWQIoyfhByVGP6Q+G
	 uaaLV81vKXmvGkex5g7K5Qqmm3kyTtdZ7HvAt1PfOb1V1SGz0EvRvkTLx5VCK/NjPKegz
	 K4+saCHwurjgDHDpFJ3UXERu/jtrMPJQJ4N4qLAv0oj+YrN4ZOT1lJMHKgvwWVH4G0JWN
	 tqlrgSpURX92uoieUolFcxvlQXl15CKkBe4RzCM4n/DyP9693D5xiv4NpM5Eq71/uGg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=sxOwE07x;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=5ZQsNkto;
	arc=none smtp.remote-ip=202.12.124.152
Received: from fhigh-b1-smtp.messagingengine.com (fhigh-b1-smtp.messagingengine.com [202.12.124.152])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0BCFB606A321
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 00:55:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0BCFB606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=sxOwE07x;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=5ZQsNkto
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 4E16C7A0112
	for <linux-nfs@vger.kernel.org>; Sun,  8 Nov 2026 19:55:42 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Sun, 08 Nov 2026 19:55:42 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1794185742;
	 x=1794272142; bh=NW1EukNYyIEJmeKkR2HmqHO4r3689yE0vQDmJ3LFXdQ=; b=
	sxOwE07x8Jsd5cb9ItgcQnQJiPIz6b1OAGa/829/tt0PaU/k4U2cDEXG0Rd6QLLz
	YYT/3DE0I2z/bfiHPXDztt8Z4JcZuHmQaeORr/Phsur2nylW1JhJu8Gj36dCfehy
	RhZ8CPqvd8CBoPgkSn8ZBJ8WBuzbo9F2JSmIOuEBxZ6PGlHj5gAVKPneV2AXAH+h
	aD5930t0TkIP6RZKoZqMvIYqk0+MN2e9Mgti2cj1XYqeEEnI5PRoIar1LIZlxdMP
	CIpBpwy08D5y05ahHArNqGyvPyrcJ8zd6ygJkZ2sXoVNDhzzayOFOcUo3AAxjGCK
	oGkbu3AhjjDbHWlTBbwLRQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1794185742; x=1794272142; bh=N
	W1EukNYyIEJmeKkR2HmqHO4r3689yE0vQDmJ3LFXdQ=; b=5ZQsNktoNl7I51dlb
	mqFinCTkbtQi+NRAJ4XfhK17TB4QWMsrcCQ0hOdfjpxOtCv/e38CuHrrqGNrXPfW
	rOWOJGVBWMWSDOstbqxqTpLLIO/gN1z9RNiP7zowYofatuCaQy4XhIlxhFMxORba
	XkB9Afi6/3yJpnmDrM/ptZqQabbGg7Lq2USxQRq5W9LwCbU2i8B3NyDY/50oB9F0
	Z8kb5kWJa6h8RP/Ubw4mBOV2TFMlYM1pzZdD+JtEZkn+qRgfrfZGkSBVOEf3llkr
	v4JMEjSqxJI2yPpucvXaHg+KeZh+WVo0/6C8HmyHou1SPE6nfd1vCf1zT0ZRbpSB
	6rXNA==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794185742; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm3:rsa-sha256:NAdbxOsj598nXGozfp5LWmwYw27bLHBZfz/LgcyWfssBP8g
	NNCm7RXsQ9Ny13b2kHwmlZt6c2ePLs/zB4HgHWMtTJ0hRRltf0egaVcZXw5F0lXf
	KJtOelJYK2rhKimLIvfuSMbK64sdFggJ5yzsKaRiepmGnb8BVthKepb15Pz/ODUD
	ruxSB73uPrlSjZ7L8RAAcg21nV4zoTz7OF5wkuDhlSa1Dgwz8rYXf+U2nC8svP8H
	EReWrPHVlXqbo3w3gXl6j/xWlbtxcQE0HO2OFzRFmJ61kVnNCsqU0imUKQGQ1pTd
	x2QQzbTLHIrr4NavrJZGv3cwcq8C9a6qmdsRoZA==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:NpSVVxxFu0UEMZQCxq5ff+n+/nZl3kXxnuIHii2MqCc=:mD7G41yhpN+KmnektAR2wi160hOsQ85eH6NXHmxl88I=;
X-ME-Sender: <xms:Dhrxahn-IgUHbCQYWFlIT7mGZ6Kd1JmA4Zc-BsoBTn2j0IjoIO6mqg>
    <xme:DhrxajuNaahgS86-076D8CNQj_rThfkRUVUjz4tyzyIluB7yvGK699TijLxb23_u3
    1X-H3tl3TX2l7Iy-a66qo0inpDq3tlrozutdsKKJcMZULENXg>
X-ME-Received: <xmr:Dhrxav-2SomB_m-b0UvoVGBagaSc1c1_oCGnJUKD5Vr3jqLomaYl1peof2rFxrcIP0sWjJ8v69kH6CMzGOMQKDclavi2DUQ>
X-ME-Proxy-Cause: dmFkZTGDl4OR50xfSN26wRwGV+LWpGX7oo07wrxQVzzC5ItVIQOYWiLppUwe9vvLubYoJc
    PTM099B9nN+9/bOeu+IKbvF0P38Yc9/Qd7nwLuEqP2uMjZIeud4qTDvUHJXIm/B4vAUsWf
    65LBhDiTAcrHrJC8B9sf76zBkfxIuXD0s6FqP30gm3bUjt47tmdyEj1BUG0a5eoMdFFVI6
    sMdf35y0rrjjMr6L/WcC6iaAC6ivBf8Gvmalkz+bI28fEdsaM9+nGARLE63RPJ4Qsd3fQ0
    tat6qKAUa3T9nrBKFA4yc/fTkTffL0tRdisMAbpnzrfpegGhyvpTslQo4aYrWOk/Ds+/fI
    7mq/Bn+uTU8Xb778Jf/gj3WXSCeVx2MFyzzFD3BSrhYRrXYZznFTqxpCt4s3xQYpUaiQOh
    wA6RdZcYFFX4w322A/GmP9BEs6mO1gR0CBSpSrwdqA1vLTeSKh206T4qgrjA2ekikvV4md
    OnCNOzU6SuDMNAzEZu9+qlgmuT8J0B+LdUhY5IR43hCz5HJAIf+n/zpjeUvm2EPdkZJNOE
    SZT2UCQ7CTS+AzC7Ad+LGmm440jOkYKjlnL15UhivL7ePdLwTiofZpO/rx5sE54/wUNmxa
    lnUgJlGas84q0aZbKeTve6/wMLW1o7foGXz+0Qqk3fJSvlI5dGmM9Q3adiGA
X-ME-Proxy: <xmx:DhrxatMu7u_4ZvyNDxaaLH8L6_fDSR-kKinYMOVRpbANLbt8gjwBbg>
    <xmx:DhrxatE-FYBhlLf2Q4mEBp7N-rvPAG3mfMjIXvPKmemmMOySODs5Gw>
    <xmx:DhrxarTeI8pegQ8ul7jm5yd-5Chx8QJyP3CSLNTaOGOx5sUMySAfPg>
    <xmx:DhrxaqvShAcn_GdFoAhZK1EawBqHPY1JzDgmid_UuulVpCHGMQdISg>
    <xmx:DhrxamaSKStd6AEylYiJN8e3qYUswa9VEr6nv9AacNCu-ub2axoVQlIU>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 8 Nov 2026 19:55:40 -0500 (EST)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v5 5/8] nfs: don't d_drop() before d_splice_alias() in atomic_create.
Date: Mon,  9 Nov 2026 11:52:34 +1100
Message-ID: <20261109005504.1804605-6-neilb@ownmail.net>
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

When atomic_create fails with -ENOENT we currently d_drop() the dentry
and then re-add it (d_splice_alias()) with a NULL inode.
This was because the dentry could be in-lookup or could be
hashed-negative and d_splice_alias() couldn't handled hashed-negative
dentries.

This drop-and-re-add will not work with proposed locking changes.

As d_splice_alias() now supports hashed dentries, we don't need the
d_drop() until it is determined that some other error has occurred.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index eb1bf1b5164c..c702a87b67d1 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2196,7 +2196,6 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 		err = PTR_ERR(inode);
 		trace_nfs_atomic_open_exit(dir, ctx, open_flags, err);
 		put_nfs_open_context(ctx);
-		d_drop(dentry);
 		switch (err) {
 		case -ENOENT:
 			if (nfs_server_capable(dir, NFS_CAP_CASE_INSENSITIVE))
@@ -2205,7 +2204,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 				dir_verifier = nfs_save_change_attribute(dir);
 			nfs_set_verifier(dentry, dir_verifier);
 			d_splice_alias(NULL, dentry);
-			break;
+			goto out;
 		case -EISDIR:
 		case -ENOTDIR:
 			if (open_flags & __O_REGULAR) {
@@ -2221,6 +2220,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 		default:
 			break;
 		}
+		d_drop(dentry);
 		goto out;
 	}
 	file->f_mode |= FMODE_CAN_ODIRECT;
@@ -2254,7 +2254,8 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 			dput(res);
 			res = ERR_PTR(-EOPENSTALE);
 		}
-	}
+	} else
+		d_drop(dentry);
 	return finish_no_open(file, res);
 }
 EXPORT_SYMBOL_GPL(nfs_atomic_open);
-- 
2.50.0.107.gf914562f5916.dirty

